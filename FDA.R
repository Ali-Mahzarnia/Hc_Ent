library("stringr") 
library(fda)
library(fda.usc)
library(ggplot2)
cvs_folder = '/Users/ali/Desktop/Dec23/BuSA/disect/Hc_Ent/cvs/'
master_path = '/Users/ali/Desktop/Dec23/BuSA/disect/Hc_Ent/AD_DECODE_data_stripped.csv'
master =read.csv2(master_path, sep = ',')

files = list.files(cvs_folder)
subjs = unique(str_sub(files, 1,6))

basis<- create.bspline.basis(c(0,50),10)

output = matrix(NA, length(subjs), 12)
output = as.data.frame(output)
colnames(output) = c(colnames(master)[2:7], "mean_left", "sd_left", "mean_right", "sd_right", "div_mean", "div_sd" )

for (subj in subjs) {
  mriid=str_sub(subj,3,6)
  index_master = which(master$MRI_Exam == mriid )
  output[index_master , 1:6] = master[index_master, 2:7]
  
  
  both_index = grep(subj, files )
  both = files[both_index]
  
  right_index = grep("Right", both)
  right = both[right_index]
  
  left_index = grep("Left", both)
  left = both[left_index]
  
  right_data= read.csv2( paste0( cvs_folder,right) , sep = " ", header = F)
  right_data= right_data[2:dim(right_data)[1],]
  #right_data = na.omit(data.frame(sapply(right_data, function(x) as.numeric(as.character(x)))))
  right_data = na.omit((sapply(right_data, function(x) as.numeric(as.character(x)))))
  
  p05 <- quantile(right_data, 0.05)
  right_data = right_data[right_data>p05]
  
  #fd_right = Data2fd(t(right_data), basisobj=basis)
  #plot(fd_right)
  #fdmean_right = mean.fd(fd_right)
  #mean_right = norm.fd(fdmean_right)
  #output$mean_right[index_master] = mean_right 
  output$mean_right[index_master] = mean(unlist(right_data)) 
  
  #plot(mean_right)
  #fdsd_right = sd.fd(fd_right)
  #plot(fdsd_right)
  #sd_right = norm.fd(fdsd_right)
  
  #output$sd_right[index_master] = sd_right
  output$sd_right[index_master] = sd(unlist(right_data)) 
  
  left_data= read.csv2( paste0( cvs_folder,left) , sep = " ", header = F)
  left_data=left_data[2:dim(left_data)[1],]
  #left_data = na.omit(data.frame(sapply(left_data, function(x) as.numeric(as.character(x)))))
  left_data = na.omit((sapply(left_data, function(x) as.numeric(as.character(x)))))
  
  p05 <- quantile(left_data, 0.05)
  left_data = left_data[left_data>p05]
  
  fd_left = Data2fd(t(left_data), basisobj=basis)
  #plot(fd_left)
  fdmean_left= mean.fd(fd_left)
  #plot(fdmean_left)
  mean_left = norm.fd(fdmean_left)
  #output$mean_left[index_master] = mean_left 
  output$mean_left[index_master] = mean(unlist(left_data)) 
  
  fdsd_left = sd.fd(fd_left)
  sd_left = norm.fd(fdsd_left)
  #output$sd_left[index_master] = sd_left
  output$sd_left[index_master] = sd(unlist(left_data)) 
  
  
  
  #div_mean= norm.fd(fdmean_left-fdmean_right)
  #output$div_mean[index_master] = div_mean
  output$div_mean[index_master] = abs( output$mean_right[index_master] - output$mean_left[index_master])
  #div_sd = norm.fd(fdsd_right-fdsd_left)
  #output$div_sd[index_master] = div_sd
  output$div_sd[index_master] = abs( output$sd_left[index_master] - output$sd_right[index_master] )
  
  
}
output = na.omit(output)



df = output

index_removal = (df$Risk=="MCI" | df$Risk=="AD" )
df2 = df[-index_removal,]

df2$geno = df2$genotype
df2$geno[df2$genotype=="APOE23"] = "APOE33"
df2$geno[df2$genotype=="APOE34"] = "APOE44"


df2$age= as.numeric(df2$age)


for (i in 7:(dim(df2)[2]-1)) {
  
  temp = summary(lm(unlist(df2[, i])~df2$age + df2$age: as.factor(df2$geno ) ))
  temp = temp$coefficients
  
  plt = ggplot(df2, aes(x=age, y= unlist(df2[, i]) , color=geno, shape=geno)) +
    geom_point() +
    geom_smooth(method=lm, fullrange=TRUE) +
    theme_linedraw() +
    labs( title = paste0("P-Value of interaction term between age and genotype is ", temp[3,4]),  x = "Age",   y = paste0(colnames( df2[, i] ) ) ) 
  ggsave( paste0("linear",colnames( df2)[i], ".png") )
  
}






for (i in 7:(dim(df2)[2]-1)) {
  
  ytemp =   unlist(df2[, i])
  xtemp = df2$age      
  xtemp2 = (df2$age )^2              
  groupstemp = as.factor(df2$geno )
  
  tempnull = lm(ytemp ~xtemp +xtemp2  )
  tempalter = lm(ytemp ~xtemp +xtemp2  + groupstemp + xtemp*groupstemp +xtemp2*groupstemp   )
  anov = anova(tempnull, tempalter)
  pval = anov$`Pr(>F)`[2]
  
  
  
  plt = ggplot(df2, aes(x=age, y= unlist(df2[, i]) , color=geno, shape=geno)) +
    geom_point() +
    geom_smooth(method=lm, fullrange=TRUE, formula = y ~ x + I (x^2)) +
    theme_linedraw() +
    labs( title = paste0("Partial F-test P-Value between age, age^2 and APOE is ",pval),  x = "Age",   y = paste0(colnames( df2[, i] ) )  ) 
  ggsave( paste0("quadratic",colnames( df2)[i], ".png") )
  
}












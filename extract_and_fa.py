#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Dec 27 13:49:09 2023

@author: ali
"""
import os, sys

perm = '/Volumes/dusom_mousebrains/All_Staff/Nariman_mrtrix_ad_decode/perm_files/'
output = '/Users/ali/Desktop/Dec23/BuSA/disect/Hc_Ent/output/'
cvs_folder = '/Users/ali/Desktop/Dec23/BuSA/disect/Hc_Ent/cvs/'

files = os.listdir(perm)

tcks = [i for i in files if "small" in i]
fas = [i for i in files if "fa.mif" in i]
asmnts = [i for i in files if "assignments_con_plain" in i]

subjs = [i[0:6] for i in tcks]


for subj in subjs:
    #subj = subjs[0]
    tck = [i for i in tcks if subj in i][0]
    fa = [i for i in fas if subj in i][0]
    asmnt = [i for i in asmnts if subj in i][0]

    os.system('connectome2tck '+perm+tck +' '+ perm+asmnt +' '+ output+'Left_Hc_Ent'+subj  +' -exclusive -nodes 6,7 -files single -force > /dev/null 2>&1')
    os.system('tckedit ' + output+'Left_Hc_Ent'+subj+'.tck' + ' ' + output+'Left_Hc_Ent'+subj+'.tck' + '  -minlength 5  -maxlength 100 -force > /dev/null 2>&1')
    os.system('tckresample '+output+'Left_Hc_Ent'+subj+'.tck '+ output+'Left_Hc_Ent'+subj+'.tck  -num_points 50 -force > /dev/null 2>&1' )
    os.system('tcksample ' +output+'Left_Hc_Ent'+subj+'.tck ' + perm+fa + ' '+ cvs_folder+subj+'Left_Hc_Ent.csv -force  > /dev/null 2>&1' )


    
    os.system('connectome2tck '+perm+tck +' '+ perm+asmnt +' '+ output+'Right_Hc_Ent'+subj  +' -exclusive -nodes 15,14 -files single -force > /dev/null 2>&1')
    os.system('tckedit ' + output+'Right_Hc_Ent'+subj+'.tck' + ' ' + output+'Right_Hc_Ent'+subj+'.tck' + '  -minlength 5  -maxlength 100 -force > /dev/null 2>&1')
    os.system('tckresample '+output+'Right_Hc_Ent'+subj+'.tck '+ output+'Right_Hc_Ent'+subj+'.tck  -num_points 50 -force > /dev/null 2>&1' )
    os.system('tcksample ' +output+'Right_Hc_Ent'+subj+'.tck ' + perm+fa + ' '+ cvs_folder+subj+'Right_Hc_Ent.csv -force  > /dev/null 2>&1' )

    
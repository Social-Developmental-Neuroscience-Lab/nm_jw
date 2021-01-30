#!/usr/bin

# this script will copy mean images produced by realign step to match naming format for preprocessing script

# user inputs:

Subs="3836 3845 3846 3847 3848 3849 3851 3852 3854 3855 3864 3865 3871 3877 3880 3882 3883 3886 3887 3889 3890 3891 3892 3893 3895 3896 3910 3912 3914 3920 3967 3992 4017 4018 4019 4020 4069"
input_dir=/data/projects/STUDIES/nm_jw/data/s

for sub in $Subs
do
        cp /data/projects/STUDIES/nm_jw/s${sub}/s${sub}_nonnormed_NM.nii /data/projects/STUDIES/nm_jw/s${sub}/s${sub}_SDC_NM.nii

done


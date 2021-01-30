#!/usr/bin

# this script will open all of the social doors files in fsleyes at once for quick visual checks

# user inputs:
#Subs="3836 3845 3846 3847 3848 3849 3851 3852 3854 3855 3864 3865 3871 3877 3880 3882 3883 3886 3887 3889 3890 3891 3892 3893 3895 3896 3910 3912 3914 3920 3967 3992 4017 4018 4019 4020 4069"
sub="3836"
input1=nonnormed
input2=normed
image_type=NM
root_folder=/data/projects/STUDIES/nm_jw/data/

fsleyes ${root_folder}s${sub}/s${sub}_${input1}_${image_type}.nii ${root_folder}s${sub}/s${sub}_${input2}_${image_type}.nii


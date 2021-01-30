
#!/usr/bin

# this script will add T1w files to subject directories

# list subjects whose data you're working with:
Subs="3836 3845 3846 3847 3848 3849 3851 3852 3854 3855 3864 3865 3871 3877 3880 3882 3883 3886 3887 3889 3890 3891 3892 3893 3895 3896 3910 3912 3914 3920 3967 3992 4017 4018 4019 4020 4069"
maindir="/data/projects/STUDIES/nm_jw/data/s"

for sub in $Subs
do
        cp ${maindir}${sub}/s${sub}_SDC_T1w.nii ${maindir}${sub}/s${sub}_SDC_T1w.nii
        
done

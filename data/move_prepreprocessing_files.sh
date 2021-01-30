#!usr/bin

# this script will move all of the pre-preprocessing files out of subject data directories to prep for running the preprocessing script

# list subjects whose data you're working with:
Subs="3836 3845 3846 3847 3848 3849 3851 3852 3854 3855 3864 3865 3871 3877 3880 3882 3883 3886 3887 3889 3890 3891 3892 3893 3895 3896 3910 3912 3914 3920 3967 3992 4017 4018 4019 4020 4069"
maindir="/data/projects/STUDIES/nm_jw/data/s"

for sub in $Subs        
do
	cd ${maindir}${sub}
	mkdir prepreprocessing_files
	mv ${maindir}${sub}/means${sub}_nonnormed_NM.nii ${maindir}${sub}/prepreprocessing_files/
        mv ${maindir}${sub}/rp_s${sub}_nonnormed_NM.txt ${maindir}${sub}/prepreprocessing_files/
       	mv ${maindir}${sub}/s${sub}_nonnormed_NM.nii ${maindir}${sub}/prepreprocessing_files/
        mv ${maindir}${sub}/rs${sub}_nonnormed_NM.nii ${maindir}${sub}/prepreprocessing_files/
        mv ${maindir}${sub}/s${sub}_nonnormed_NM.json ${maindir}${sub}/prepreprocessing_files/
done

cd /data/projects/STUDIES/nm_jw/data

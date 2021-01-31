#!/bin/bash

# this script will remove all files from subject directories

# list subjects whose data you're working with:
Subs="3836 3845 3846 3847 3848 3849 3851 3852 3854 3855 3864 3865 3871 3877 3880 3882 3883 3886 3887 3889 3890 3891 3892 3893 3895 3896 3910 3912 3914 3920 3967 3992 4017 4018 4019 4020 4069"


# this script was orignially meant to delete all files EXCEPT for the T1w, isolated here:
# loop through and print each one to make sure you're finding the right file
for sub in $Subs
do
	echo 's'${sub}'_SDC_T1w.nii'
done

# ask for user to confirm that they want to delete all files
echo Are you sure you want to delete all files in your subject data folders? Yes or No

read user_input

if [ $user_input = "Yes" ];
then
	# loop through and remove all files that do not match this naming convention
	# something's wrong with this loop so it ends up removing all files; see "add_T1w_script.sh" to add them back 
	for sub in $Subs
	do
		cd /data/projects/STUDIES/nm_jw/data/s${sub}
		find . ! -name "s${sub}_SDC_T1w.ni" -type f -exec rm -f {} +
		rm -r prepreprocessing_files
		cd ../
	done
	echo Files deleted
else
	echo Closing script
fi	

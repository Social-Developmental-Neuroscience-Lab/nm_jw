#!/usr/bin

# this script will convert dicom files into nifti images
# structure is specific to social doors SBU data

# user inputs:
Subs="3836 3845 3846 3847 3848 3849 3851 3852 3854 3855 3864 3865 3871 3877 3880 3882 3883 3886 3887 3889 3890 3891 3892 3893 3895 3896 3910 3912 3914 3920 3967 3992 4017 4018 4019 4020 4069"
dicom_dir=/data/projects/STUDIES/nm_jw/RawDataRepository/s
output_dir=/data/projects/STUDIES/nm_jw/data/s
normed=0 # nonnormed=0, normed=1

# loop through and print each one to make sure you're finding the right directory
for sub in $Subs
do
	# finds the dir containing the dicom, changes to that dir, and creates an array
	input_dir=${dicom_dir}${sub}/
	cd ${input_dir}
	files=(*)
	
	# files[] takes the index of the files array of the dicom directory; 
	# 0=non-normalized NM image, 1=normalized NM image
	#echo "${files[0]}"	
	

	if [ $normed == 0 ]; then
		# this line runs the conversion: first path finds mricron; second sets the name for the output image; third sets the output directory; fourth selects the dicom to be converted
		/home/local/TU/tun46412/Desktop/mricron/Resources/dcm2niix -f "s${sub}_nonnormed_NM" -p y -z n -ba n -o "${output_dir}${sub}" "${files[0]}"
	
	elif [ $normed == 1 ]; then
 		/home/local/TU/tun46412/Desktop/mricron/Resources/dcm2niix -f "s${sub}_normed_NM" -p y -z n -ba n -o "${output_dir}${sub}" "${files[1]}"
	
	else
		echo "Set input for 'normed' variable"
	fi

done

cd /data/projects/STUDIES/nm_jw/data/



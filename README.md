# nm_jw
Scripts for neuromelanin preprocessing and analyses: dicom conversions, realignment, preprocessing, and voxelwise analyses. Some of these scripts are specific to the 36 subject sample for the SBU social doors data. Steps with more detailed notes found here: https://sdneuro-lab.slab.com/public/cgfkh3n1

## scripts
### data directory
- removal_script.sh, removes all files from subject data directories (subject data directories not viewable on github)
- add_T1w_script.sh, adds T1w files to subject data directories from other location
- convert_dicoms.sh, converts dicoms to niftis using [dcm2niix](https://github.com/rordenlab/dcm2niix)
  - turns files in dicoms folder into an array and calls file to be converted by index; allows user to discriminate between first and second dicom image dir for any given subject
- rename_means.sh, (after running scripts/realign_nonnormed.m) renames mean NM files in format for use in preprocessing script
- move_prepreprocessing_files.sh, stores output from realignment step in a subdirectory

### scripts directory
- realign_nonnormed.m, runs realignment step in spm12 for the nonnormed .nii files of all 36 subjects (will eventually be replaced with the more flexible realign.m script)
- preprocess_nm_jw.m, includes full preprocessing steps
- SN_Voxelwise_Analysis.m, performs voxelwise robust linear regression analysis within the SN mask and creates maps of effects within the SN
- SN_Voxelwise_Analysis_permutations.m, gives a p-value for the cluster of voxels observed in the SN_voxelwise_analysis.m script

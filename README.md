# nm_jw
Scripts for neuromelanin preprocessing and analyses: dicom conversions, realignment, preprocessing, and voxelwise analyses. Some of these scripts are specific to the 36 subject sample for the SBU social doors data. Steps with more detailed notes found here: https://sdneuro-lab.slab.com/public/cgfkh3n1

## scripts
### data directory
- 'removal_script.sh', removes all files from subject data directories (subject data directories not viewable on github)
- 'add_T1w_script.sh', adds T1w files to subject data directories from other location
- 'convert_dicoms.sh', converts dicoms to niftis using [dcm2niix](https://github.com/rordenlab/dcm2niix)
  - turns files in dicoms folder into an array and calls file to be converted by index; allows user to discriminate between first and second dicom image dir for any given subject
- 'rename_means.sh', (after running scripts/realign_nonnormed.m) renames mean NM files in format for use in preprocessing script
- 'move_prepreprocessing_files.sh', stores output from realignment step in a subdirectory

### scripts directory
- 'realign_nonnormed.m', runs realignment step in spm12 for the nonnormed .nii files of all 36 subjects (will eventually be replaced with the more flexible realign.m script)
- 'preprocess_nm_jw.m', includes full preprocessing steps
- 'SN_Voxelwise_Analysis.m', performs voxelwise robust linear regression analysis within the SN mask and creates maps of effects within the SN
- 'SN_Voxelwise_Analysis_permutations.m', gives a p-value for the cluster of voxels observed in the SN_voxelwise_analysis.m script

## running the scripts
Organization: Main project directory should contain three subdirectories: /data, /scripts, and /templates. /data and /scripts should contain all of the scripts seen above. /data should also contain a subdirectory for each subject (e.g., "s9999"). /templates should contain seven templates (i.e., Template_0.nii - Template_6.nii)

### pre-preprocessing

- to start with clean, empty subject data directories, run 'removal_script.sh' to remove all files
-from the /data directory, run 'add_T1w_script.sh'
  - output: s9999_SDC_T1w.nii
- open 'convert_dicoms.sh' and confirm the setting for normed vs. nonnormed dicoms (should be set to nonnormed for this project). run 'conver_dicoms.sh'
  - output: s9999_nonnormed_NM.nii, s9999_nonnormed_NM.json
  - visual check: you can change the setting in convert_dicoms.sh to write out .niis for the normed data for comparison. Images should be identical except that nonnormed images are brighter 
- cd to the scripts directory and open matlab
- run the 'realign_nonnormed.m' script
  - output: means3836_nonnormed_NM.nii, rp_s3836_nonnormed_NM.txt, rs3836_nonnormed_NM.nii
- back in the terminal, cd back to the data directory and run the 'rename_means.sh' script
  - visual check: visualize means9999_nonnormed_NM.nii and s9999_SDC_NM.nii to confirm that they are identical
- run 'move_prepreprocessing_files.sh' to clean up subject data directories
  
### preprocessing
Launch matlab again and open 'perprocess_nm_jw.m'. confirm that user inputs (i.e., Subs, templatedir, TPMdir, and root_folder) are entered correctly
- change coreg=0 to coreg=1 (line 17) and run the script (takes roughly 5 minutes)
  - output: rs9999_SDC_NM.nii
  - visual check: in fsleyes or mricron, overlay rs9999_SDC_NM.nii on the T1 image s9999_SDC_T1w.nii and confirm their alignment
  
- set coreg=0 and change segment_dartel_normalize=1, then run the script (takes roughly 4.5 hours)
  - primary output: ws9999_SDC_T1w.nii (warped T1 image), wrs9999_SDC_NM.nii (warped NM image)
  - other output: u_rc1s9999_SDC_T1w.nii (multi-volume nifti image)
    - Segmented images registered to T1w
      - c1s9999_SDC_T1w.nii - gray matter
      - c2s9999_SDC_T1w.nii - white matter
      - c3s9999_SDC_T1w.nii- csf
      - c4s9999_SDC_T1w.nii - skull
      - c5s9999_SDC_T1w.nii - other tissue (e.g., face)
      - c6s9999_SDC_T1w.nii - non-tissue (e.g., background)
    - Warped segmented images registered to ws3999_SDC_T1w.nii
      - rc1s9999_SDC_T1w.nii - gray matter
      - rc2s9999_SDC_T1w.nii - white matter
      - rc3s9999_SDC_T1w.nii- csf
      - rc4s9999_SDC_T1w.nii - skull
      - rc5s9999_SDC_T1w.nii - other tissue (e.g., face)
      - rc6s9999_SDC_T1w.nii - non-tissue (e.g., background)
  - visual check:  overlay warped NM image onto warped T1 and check for (1.) full/partial/no coverage of SN at slice 62 (top) and (2.) full/partial/no coverage of LC at slice 43 (bottom)

- turn off segmentation and turn on make_avg_image1
  - output: avg_spatially_normalized.nii (averaged image of spatially normed images for all subjects; main data folder)

- turn off make_avg_image1 and turn on intensity_norm
  - output: psc_wrs9999_SDC_NM.nii (intensity normed NM image)

- turn off intensity_norm and turn on make_avg_image2
  - output: avg_CNR_image.nii (averaged image of CNR images for all subjects; main data folder)

- turn off make_avg_image2 and turn on make_top_slice
  - output: top_slice.mat, bottom_slice.mat

- turn off make_top_slice and turn on smooth
  - output: s1_psc_wrs3999_NM.nii (fully preprocessed image)
  - visual check: overlay this fully processed image onto a canonical T1w image; find a landmark on the SN on the canonical image and toggle to the s1* image to make sure they're aligned
  - visual check: overlay warped T1w image over canonical as a sanity check for any images that are difficult to discern
  

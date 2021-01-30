clear all

addpath('/data/spm12', '-end');
savepath;
root_folder=('/data/projects/STUDIES/nm_jw/data/');

Subs = [3836, 3845, 3846, 3847, 3848, 3849, 3851, 3852, 3854, 3855, 3864, 3865, 3871, 3877, 3880, 3882, 3883, 3886, 3887, 3889, 3890, 3891, 3892, 3893, 3895, 3896, 3910, 3912, 3914, 3920, 3967, 3992, 4017, 4018, 4019, 4020]

existing_template=1;
templatedir= '/data/projects/STUDIES/nm_jw/templates/';
TPMdir = '/data/spm12/tpm/TPM.nii';
hasT2 = 0;
root_folder=('/data/projects/STUDIES/nm_jw/data/');

% for s = 1:length(Subs)
%     NMscanname = dir([root_folder 's' num2str(Subs(s)) '/s' num2str(Subs(s)) '*nonnormed_NM.nii']); %this line will need to be customized to find your file
%     NMscanfiles{s,1} = [root_folder 's' num2str(Subs(s)) '/' NMscanname.name];
% end

%for s = 1:length(Subs)
%%
matlabbatch{1}.spm.spatial.realign.estwrite.data = {
                                                    {'/data/projects/STUDIES/nm_jw/data/s3836/s3836_nonnormed_NM.nii,1'}
                                                    {'/data/projects/STUDIES/nm_jw/data/s3845/s3845_nonnormed_NM.nii,1'}
                                                    {'/data/projects/STUDIES/nm_jw/data/s3846/s3846_nonnormed_NM.nii,1'}
                                                    {'/data/projects/STUDIES/nm_jw/data/s3847/s3847_nonnormed_NM.nii,1'}
                                                    {'/data/projects/STUDIES/nm_jw/data/s3848/s3848_nonnormed_NM.nii,1'}
                                                    {'/data/projects/STUDIES/nm_jw/data/s3849/s3849_nonnormed_NM.nii,1'}
                                                    {'/data/projects/STUDIES/nm_jw/data/s3851/s3851_nonnormed_NM.nii,1'}
                                                    {'/data/projects/STUDIES/nm_jw/data/s3852/s3852_nonnormed_NM.nii,1'}
                                                    {'/data/projects/STUDIES/nm_jw/data/s3854/s3854_nonnormed_NM.nii,1'}
                                                    {'/data/projects/STUDIES/nm_jw/data/s3855/s3855_nonnormed_NM.nii,1'}
                                                    {'/data/projects/STUDIES/nm_jw/data/s3864/s3864_nonnormed_NM.nii,1'}
                                                    {'/data/projects/STUDIES/nm_jw/data/s3865/s3865_nonnormed_NM.nii,1'}
                                                    {'/data/projects/STUDIES/nm_jw/data/s3871/s3871_nonnormed_NM.nii,1'}
                                                    {'/data/projects/STUDIES/nm_jw/data/s3877/s3877_nonnormed_NM.nii,1'}
                                                    {'/data/projects/STUDIES/nm_jw/data/s3880/s3880_nonnormed_NM.nii,1'}
                                                    {'/data/projects/STUDIES/nm_jw/data/s3882/s3882_nonnormed_NM.nii,1'}
                                                    {'/data/projects/STUDIES/nm_jw/data/s3883/s3883_nonnormed_NM.nii,1'}
                                                    {'/data/projects/STUDIES/nm_jw/data/s3886/s3886_nonnormed_NM.nii,1'}
                                                    {'/data/projects/STUDIES/nm_jw/data/s3887/s3887_nonnormed_NM.nii,1'}
                                                    {'/data/projects/STUDIES/nm_jw/data/s3889/s3889_nonnormed_NM.nii,1'}
                                                    {'/data/projects/STUDIES/nm_jw/data/s3890/s3890_nonnormed_NM.nii,1'}
                                                    {'/data/projects/STUDIES/nm_jw/data/s3891/s3891_nonnormed_NM.nii,1'}
                                                    {'/data/projects/STUDIES/nm_jw/data/s3892/s3892_nonnormed_NM.nii,1'}
                                                    {'/data/projects/STUDIES/nm_jw/data/s3893/s3893_nonnormed_NM.nii,1'}
                                                    {'/data/projects/STUDIES/nm_jw/data/s3895/s3895_nonnormed_NM.nii,1'}
                                                    {'/data/projects/STUDIES/nm_jw/data/s3896/s3896_nonnormed_NM.nii,1'}
                                                    {'/data/projects/STUDIES/nm_jw/data/s3910/s3910_nonnormed_NM.nii,1'}
                                                    {'/data/projects/STUDIES/nm_jw/data/s3912/s3912_nonnormed_NM.nii,1'}
                                                    {'/data/projects/STUDIES/nm_jw/data/s3914/s3914_nonnormed_NM.nii,1'}
                                                    {'/data/projects/STUDIES/nm_jw/data/s3920/s3920_nonnormed_NM.nii,1'}
                                                    {'/data/projects/STUDIES/nm_jw/data/s3967/s3967_nonnormed_NM.nii,1'}
                                                    {'/data/projects/STUDIES/nm_jw/data/s3992/s3992_nonnormed_NM.nii,1'}
                                                    {'/data/projects/STUDIES/nm_jw/data/s4017/s4017_nonnormed_NM.nii,1'}
                                                    {'/data/projects/STUDIES/nm_jw/data/s4018/s4018_nonnormed_NM.nii,1'}
                                                    {'/data/projects/STUDIES/nm_jw/data/s4019/s4019_nonnormed_NM.nii,1'}
                                                    {'/data/projects/STUDIES/nm_jw/data/s4020/s4020_nonnormed_NM.nii,1'}
                                                   }';
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 4;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 2;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = '';
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [2 1];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r';
%%
%end

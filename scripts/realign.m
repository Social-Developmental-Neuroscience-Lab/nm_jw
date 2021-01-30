% Script for realign (est. & resize) step for NM files in spm
%% UNDER CONSTRUCTION: still working on getting this data input variable (first line of loop) to run properly
%%
clear all

addpath('/data/spm12', '-end');
savepath;
root_folder=('/data/projects/STUDIES/nm_jw/data/');

Subs = [3836, 3845, 3846, 3847, 3848, 3849, 3851, 3852, 3854, 3855, 3864, 3865, 3871, 3877, 3880, 3882, 3883, 3886, 3887, 3889, 3890, 3891, 3892, 3893, 3895, 3896, 3910, 3912, 3914, 3920, 3967, 3992, 4017, 4018, 4019, 4020]

% This loop will create a name file that should be able to be added to the first matlabbatch line to cover all of the subjects
for s = 1:length(Subs)
    NMscanname = dir([root_folder 's' num2str(Subs(s)) '/s' num2str(Subs(s)) '*normed_NM.nii']); %this line will need to be customized to find your file
    NMscanfiles{s,1} = [root_folder 's' num2str(Subs(s)) '/' NMscanname.name ',1'];
end

%%
%for s = 1:length(Subs)
    %matlabbatch{1}.spm.spatial.realign.estwrite.data = {{NMscanfiles{1,1}};
    matlabbatch{1}.spm.spatial.realign.estwrite.data = {{'/data/projects/STUDIES/nm_jw/data/s3836/s3836_normed_NM.nii,1'}};
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

    spm_jobman('run', matlabbatch)
%end
%%

% if batch isn't running correctly, run this 'interactive' code to review inputs in the GUI (do this for single subject):
% spm_jobman('interactive', matlabbatch)
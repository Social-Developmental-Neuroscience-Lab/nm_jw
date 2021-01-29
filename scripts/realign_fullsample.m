% Realign: Est. & Res.

clear all

addpath('/data/spm12', '-end');
savepath;
root_folder = ('/data/projects/STUDIES/social_doors_jw/nm-jw/data2/');

%Subs = [3836, 3845, 3846, 3847, 3848, 3849, 3851, 3852, 3854, 3855, 3864, 3865, 3871, 3877, 3880, 3882, 3883, 3886, 3887, 3889, 3890, 3891, 3892, 3893, 3895, 3896, 3910, 3912, 3914, 3920, 3967, 3992, 4017, 4018, 4019, 4020];
Subs = [3845, 3846, 3847, 3848, 3849, 3851, 3852, 3854, 3855, 3864, 3865, 3871, 3877, 3880, 3882, 3883, 3886, 3887, 3889, 3890, 3891, 3892, 3893, 3895, 3896, 3910, 3912, 3914, 3920, 3967, 3992, 4017, 4018, 4019, 4020];


existing_template=1;
templatedir= '/data/projects/STUDIES/LEARN/fMRI/NM/templates/';
TPMdir = '/data/spm12/tpm/TPM.nii';
hasT2 = 0;
root_folder = ('/data/projects/STUDIES/social_doors_jw/nm-jw/data2/');

for s = 1:length(Subs)
    
    rawNM_name = dir([root_folder 's' num2str(Subs(s)) '/s' num2str(Subs(s)) '*NM.nii']);
    rawNM_scanfiles{s,1} = [root_folder 's' num2str(Subs(s)) '/' rawNM_name.name];
    disp(rawNM_name)
end

keyboard

for s = 1:length(Subs)

matlabbatch{1}.spm.spatial.realign.estwrite.data = {{dir([rawNM_scanfiles{s,1} ',1'])}};
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

end;
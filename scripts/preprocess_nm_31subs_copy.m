%Preprocessing script for neuromelanin-sensitive MRI data. Written by Clifford Cassidy, April 2020
%Adjusted for 31 subjects Dec. 2020

clear all

addpath('/data/spm12', '-end');
savepath;
root_folder=('/data/projects/STUDIES/social_doors_jw/nm-jw/data/');

Subs = [3836, 3845, 3846, 3847, 3848, 3849, 3851, 3852, 3854, 3855, 3864, 3865, 3871, 3877, 3880, 3882, 3883, 3886, 3887, 3889, 3890, 3891, 3892, 3893, 3895, 3896, 3910, 3912, 3914, 3920, 3967, 3992, 4017, 4018, 4019, 4020]
%Subs = [3848, 3880, 3882, 3896, 3914]

existing_template=1;
templatedir= '/data/projects/STUDIES/nm-practice/nm-31subs/templates/';
TPMdir = '/data/spm12/tpm/TPM.nii';
hasT2 = 0;
root_folder=('/data/projects/STUDIES/social_doors_jw/nm-jw/data/');

coreg=0; %%step 1 of preprocessing
segment_dartel_normalize=0; %%step 3 of preprocessing
%for this step, make sure the TPMdir above is directing to SPM folder on your computer
make_avg_image1=0;  %step 5 of preprocessing. this will save 'avg_spatially_normalized.nii' in image of all participants' brains averaged in the root folder
intensity_norm=0; %step SN7 of preprocessing. this will generate CNR images (psc_wr prefix) by intensity normalization relative to the reference region
make_avg_image2=0; % step SN8 of preprocessing. this will save 'avg_CNR_image.nii' in image of all participants' brains with CNR values averaged in the root folder
make_top_slice=1; % step SN10 of preprocessing. this will tell for each subject if any data is missing in dorsal SN and at what slice the scan is cut off.
%the make_top_slice step saves something called top_slice that will be needed  for the voxelwise analysis script
smooth=0; %step SN11 of preprocessing. this will apply smoothing and create the fully preprocessed NM image (prefix s1_psc_wr), ready for voxelwise analysis with voxelwise analysis script
%%%%%%%make_divided_oi_LC_mask=0; %step LC7 of preprocessing. This will divide the manually-drawn over-inclusive LC mask into rostro-caudal segments
%inv_normalize=0; %step LC8. This will bring the LC overinclusive mask from MNI space to native space
%the inv_normalize step loads the normalization template, this must be the same template that was used in the segment_dartel_normalize step. it will look in the templatedir be sure this template is there.
%inv_register=0; %step LC9. This will reslice the LC overinclusive mask to the dimensions of native space

for s = 1:length(Subs)
    NMscanname = dir([root_folder 's' num2str(Subs(s)) '/s' num2str(Subs(s)) '*NM.nii']); %this line will need to be customized to find your file
    T1scanname = dir([root_folder 's' num2str(Subs(s)) '/s' num2str(Subs(s)) '*T1w*.nii']); %this line will need to be customized to find your file
    if hasT2==1
        T2scanname = dir([root_folder  num2str(Subs(s)) '\T2*.nii']); %this line will need to be customized to find your file
        T2scanfiles{s,1} = [root_folder  num2str(Subs(s)) '\' T2scanname.name];
        rT2scanfiles{s,1} = [root_folder  num2str(Subs(s)) '\r' T2scanname.name];
    end
    NMscanfiles{s,1} = [root_folder 's' num2str(Subs(s)) '/' NMscanname.name];
    T1scanfiles{s,1} = [root_folder 's' num2str(Subs(s)) '/' T1scanname.name];
    rNMscanfiles{s,1} = [root_folder 's' num2str(Subs(s)) '/r' NMscanname(1,1).name];
    wrNMscanfiles{s,1} = [root_folder 's' num2str(Subs(s)) '/wr' NMscanname(1,1).name];
    psc_wrNMscanfiles{s,1} = [root_folder 's' num2str(Subs(s)) '/psc_wr' NMscanname.name];
    s1_psc_wrNMscanfiles{s,1} = [root_folder 's' num2str(Subs(s)) '/s1_psc_wr' NMscanname.name];
    wT1scanfiles{s,1} = [root_folder 's' num2str(Subs(s)) '/w' T1scanname(1,1).name];
end

%%%%%%%%%%%%%%%%%%%%%%%coreg coregistration step%%%%%%%%%%%%%%%%%%%%
for s = 1:length(Subs)
    
    coregbatch{1}.spm.spatial.coreg.estwrite.ref = {T1scanfiles{s,1}};
    coregbatch{1}.spm.spatial.coreg.estwrite.source = {NMscanfiles{s,1}};
    coregbatch{1}.spm.spatial.coreg.estwrite.other = {''};
    coregbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
    coregbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
    coregbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    coregbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
    coregbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;
    coregbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
    coregbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
    coregbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';
    
    if coreg==1
        spm_jobman('run',coregbatch)
    end
    if hasT2==1
        coregbatch2{1}.spm.spatial.coreg.estwrite.ref = {T1scanfiles{s,1}};
        coregbatch2{1}.spm.spatial.coreg.estwrite.source = {T2scanfiles{s,1}};
        coregbatch2{1}.spm.spatial.coreg.estwrite.other = {''};
        coregbatch2{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
        coregbatch2{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
        coregbatch2{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
        coregbatch2{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
        coregbatch2{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;
        coregbatch2{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
        coregbatch2{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
        coregbatch2{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';
        
        if coreg==1
            spm_jobman('run',coregbatch2)
        end
    end
end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%segment_dartel_normalize step%%%%%%%%%%%%%%%%%

if hasT2==1
matlabbatch{1}.spm.spatial.preproc.channel(1).vols = T1scanfiles;
matlabbatch{1}.spm.spatial.preproc.channel(1).biasreg = 0.001;
matlabbatch{1}.spm.spatial.preproc.channel(1).biasfwhm = 60;
matlabbatch{1}.spm.spatial.preproc.channel(1).write = [0 0];
matlabbatch{1}.spm.spatial.preproc.channel(2).vols = rT2scanfiles;
matlabbatch{1}.spm.spatial.preproc.channel(2).biasreg = 0.001;
matlabbatch{1}.spm.spatial.preproc.channel(2).biasfwhm = 60;
matlabbatch{1}.spm.spatial.preproc.channel(2).write = [0 0];
else
matlabbatch{1}.spm.spatial.preproc.channel.vols = T1scanfiles;
matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001;
matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
matlabbatch{1}.spm.spatial.preproc.channel.write = [0 0];
end
matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {[TPMdir ',1']};
matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 1];
matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {[TPMdir ',2']};
matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 1];
matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {[TPMdir ',3']};
matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 1];
matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {[TPMdir ',4']};
matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [1 1];
matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {[TPMdir ',5']};
matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [1 1];
matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {[TPMdir ',6']};
matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [1 1];
matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
matlabbatch{1}.spm.spatial.preproc.warp.write = [0 0];

if existing_template==0
    matlabbatch{2}.spm.tools.dartel.warp.images{1}(1) = cfg_dep('Segment: rc1 Images', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','tiss', '()',{1}, '.','rc', '()',{':'}));
    matlabbatch{2}.spm.tools.dartel.warp.images{2}(1) = cfg_dep('Segment: rc2 Images', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','tiss', '()',{2}, '.','rc', '()',{':'}));
    matlabbatch{2}.spm.tools.dartel.warp.settings.template = 'Template';
    matlabbatch{2}.spm.tools.dartel.warp.settings.rform = 0;
    matlabbatch{2}.spm.tools.dartel.warp.settings.param(1).its = 3;
    matlabbatch{2}.spm.tools.dartel.warp.settings.param(1).rparam = [4 2 1e-06];
    matlabbatch{2}.spm.tools.dartel.warp.settings.param(1).K = 0;
    matlabbatch{2}.spm.tools.dartel.warp.settings.param(1).slam = 16;
    matlabbatch{2}.spm.tools.dartel.warp.settings.param(2).its = 3;
    matlabbatch{2}.spm.tools.dartel.warp.settings.param(2).rparam = [2 1 1e-06];
    matlabbatch{2}.spm.tools.dartel.warp.settings.param(2).K = 0;
    matlabbatch{2}.spm.tools.dartel.warp.settings.param(2).slam = 8;
    matlabbatch{2}.spm.tools.dartel.warp.settings.param(3).its = 3;
    matlabbatch{2}.spm.tools.dartel.warp.settings.param(3).rparam = [1 0.5 1e-06];
    matlabbatch{2}.spm.tools.dartel.warp.settings.param(3).K = 1;
    matlabbatch{2}.spm.tools.dartel.warp.settings.param(3).slam = 4;
    matlabbatch{2}.spm.tools.dartel.warp.settings.param(4).its = 3;
    matlabbatch{2}.spm.ttop_sliceools.dartel.warp.settings.param(4).rparam = [0.5 0.25 1e-06];
    matlabbatch{2}.spm.tools.dartel.warp.settings.param(4).K = 2;
    matlabbatch{2}.spm.tools.dartel.warp.settings.param(4).slam = 2;
    matlabbatch{2}.spm.tools.dartel.warp.settings.param(5).its = 3;
    matlabbatch{2}.spm.tools.dartel.warp.settings.param(5).rparam = [0.25 0.125 1e-06];
    matlabbatch{2}.spm.tools.dartel.warp.settings.param(5).K = 4;
    matlabbatch{2}.spm.tools.dartel.warp.settings.param(5).slam = 1;
    matlabbatch{2}.spm.tools.dartel.warp.settings.param(6).its = 3;
    matlabbatch{2}.spm.tools.dartel.warp.settings.param(6).rparam = [0.25 0.125 1e-06];
    matlabbatch{2}.spm.tools.dartel.warp.settings.param(6).K = 6;
    matlabbatch{2}.spm.tools.dartel.warp.settings.param(6).slam = 0.5;
    matlabbatch{2}.spm.tools.dartel.warp.settings.optim.lmreg = 0.01;
    matlabbatch{2}.spm.tools.dartel.warp.settings.optim.cyc = 3;
    matlabbatch{2}.spm.tools.dartel.warp.settings.optim.its = 3;
    matlabbatch{3}.spm.tools.dartel.mni_norm.template(1) = cfg_dep('Run Dartel (create Templates): Template (Iteration 6)', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','template', '()',{7}));
    matlabbatch{3}.spm.tools.dartel.mni_norm.data.subjs.flowfields(1) = cfg_dep('Run Dartel (create Templates): Flow Fields', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files', '()',{':'}));  
else
    matlabbatch{2}.spm.tools.dartel.warp1.images{1}(1) = cfg_dep('Segment: rc1 Images', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','tiss', '()',{1}, '.','rc', '()',{':'}));
    matlabbatch{2}.spm.tools.dartel.warp1.images{2}(1) = cfg_dep('Segment: rc2 Images', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','tiss', '()',{2}, '.','rc', '()',{':'}));
    matlabbatch{2}.spm.tools.dartel.warp1.settings.rform = 0;
    matlabbatch{2}.spm.tools.dartel.warp1.settings.param(1).its = 3;
    matlabbatch{2}.spm.tools.dartel.warp1.settings.param(1).rparam = [4 2 1e-06];
    matlabbatch{2}.spm.tools.dartel.warp1.settings.param(1).K = 0;
    matlabbatch{2}.spm.tools.dartel.warp1.settings.param(1).template = {[templatedir 'Template_1.nii']};
    matlabbatch{2}.spm.tools.dartel.warp1.settings.param(2).its = 3;
    matlabbatch{2}.spm.tools.dartel.warp1.settings.param(2).rparam = [2 1 1e-06];
    matlabbatch{2}.spm.tools.dartel.warp1.settings.param(2).K = 0;
    matlabbatch{2}.spm.tools.dartel.warp1.settings.param(2).template = {[templatedir 'Template_2.nii']};
    matlabbatch{2}.spm.tools.dartel.warp1.settings.param(3).its = 3;
    matlabbatch{2}.spm.tools.dartel.warp1.settings.param(3).rparam = [1 0.5 1e-06];
    matlabbatch{2}.spm.tools.dartel.warp1.settings.param(3).K = 1;
    matlabbatch{2}.spm.tools.dartel.warp1.settings.param(3).template = {[templatedir 'Template_3.nii']};
    matlabbatch{2}.spm.tools.dartel.warp1.settings.param(4).its = 3;
    matlabbatch{2}.spm.tools.dartel.warp1.settings.param(4).rparam = [0.5 0.25 1e-06];
    matlabbatch{2}.spm.tools.dartel.warp1.settings.param(4).K = 2;
    matlabbatch{2}.spm.tools.dartel.warp1.settings.param(4).template = {[templatedir 'Template_4.nii']};
    matlabbatch{2}.spm.tools.dartel.warp1.settings.param(5).its = 3;
    matlabbatch{2}.spm.tools.dartel.warp1.settings.param(5).rparam = [0.25 0.125 1e-06];
    matlabbatch{2}.spm.tools.dartel.warp1.settings.param(5).K = 4;
    matlabbatch{2}.spm.tools.dartel.warp1.settings.param(5).template = {[templatedir 'Template_5.nii']};
    matlabbatch{2}.spm.tools.dartel.warp1.settings.param(6).its = 3;
    matlabbatch{2}.spm.tools.dartel.warp1.settings.param(6).rparam = [0.25 0.125 1e-06];
    matlabbatch{2}.spm.tools.dartel.warp1.settings.param(6).K = 6;
    matlabbatch{2}.spm.tools.dartel.warp1.settings.param(6).template = {[templatedir 'Template_6.nii']};
    matlabbatch{2}.spm.tools.dartel.warp1.settings.optim.lmreg = 0.01;
    matlabbatch{2}.spm.tools.dartel.warp1.settings.optim.cyc = 3;
    matlabbatch{2}.spm.tools.dartel.warp1.settings.optim.its = 3;
    matlabbatch{3}.spm.tools.dartel.mni_norm.template = {[templatedir 'Template_6.nii']};
    matlabbatch{3}.spm.tools.dartel.mni_norm.data.subjs.flowfields(1) = cfg_dep('Run Dartel (existing Templates): Flow Fields', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files', '()',{':'}));

 end

matlabbatch{3}.spm.tools.dartel.mni_norm.data.subjs.images = {T1scanfiles rNMscanfiles};
%%
matlabbatch{3}.spm.tools.dartel.mni_norm.vox = [1 1 1];
matlabbatch{3}.spm.tools.dartel.mni_norm.bb = [NaN NaN NaN
    NaN NaN NaN];
matlabbatch{3}.spm.tools.dartel.mni_norm.preserve = 0;
matlabbatch{3}.spm.tools.dartel.mni_norm.fwhm = [0 0 0];

if segment_dartel_normalize==1
    spm_jobman('run',matlabbatch)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%code to
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%make_avg_image from normalized images (wr prefix)%%%%%%%%%%%%%%%%%%%%%
if make_avg_image1==1
    for s=1:length(Subs)
        v = spm_vol(wrNMscanfiles{s,1});
        V(:,:,:,s)=spm_read_vols(v);
    end
    V_avg=mean(V,4);
    v.fname = [root_folder 'avg_spatially_normalized_image.nii'];
    spm_write_vol(v,V_avg);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%code to perform intensity
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%normalization, making CNR images
if intensity_norm==1
    Vmask = spm_read_vols(spm_vol([root_folder 'CC_mask_pos2.nii'])); %this is where a user loads the reference region mask
    
    for s=1:length(Subs)
        
        clear F XI inmask_data F_index peaks_smooth_DF
        v = spm_vol(wrNMscanfiles{s,1});
        
        V = spm_read_vols(v);
        inmask_data = V(Vmask==1);
        inmask_data(inmask_data<100)=NaN;
        [F,XI] = ksdensity(inmask_data);
        for i= 1:length(F)
            if F(i) ==max(F)
                F_index(i) = 1;
            else
                F_index(i) = 0;
            end
        end
        peak_smooth_DF= XI(F_index==1);
        ref_sig(s) = peak_smooth_DF;
        psc_V = 100*((V - peak_smooth_DF)./peak_smooth_DF)+100;
        
        v.fname = psc_wrNMscanfiles{s,1};
        
        spm_write_vol(v,psc_V);
        
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%code to
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%make_avg_image from CNR images (psc_wr prefix)%%%%%%%%%%%%%%%%%%%%%
if make_avg_image2==1
    for s=1:length(Subs)
        v = spm_vol(psc_wrNMscanfiles{s,1});
        V(:,:,:,s)=spm_read_vols(v);
    end
    V_avg=mean(V,4);
    v.fname = [root_folder 'avg_CNR_image.nii']
    spm_write_vol(v,V_avg);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%code below is to define the top slice with usable data
if make_top_slice==1
    VmaskSN = spm_read_vols(spm_vol([root_folder 'full_SN_mask_pos2.nii']));%This is where to load SN mask file (manually traced in MNI space)
    
    for s= 1:length(Subs)
       
        v = spm_vol(psc_wrNMscanfiles{s,1});
        V = spm_read_vols(v);
        
        
        for sl = 1:size(V,3)
            if sum(sum(VmaskSN(:,:,sl)))>0
                Vbyslice = V(:,:,sl);
                SNbyslice = VmaskSN(:,:,sl);
                SNvoxbyslice{sl} = Vbyslice(SNbyslice==1);
                if length(SNvoxbyslice{1,sl}(SNvoxbyslice{1,sl}<50))/length(SNvoxbyslice{1,sl})>0.075
                    missing_slice(sl)=1;
                else
                    missing_slice(sl)=0;
                end
            end
            
        end
        %if sum(missing_slice)>0
        %    top_slice(s,1) = min(find(missing_slice))-1;
        %else
        %    top_slice(s,1) = max(find(squeeze(sum(sum(VmaskSN)))));
        if sum(missing_slice)== 0 | missing_slice(max(find(squeeze(sum(sum(VmaskSN)))))) == 0
            top_slice(s,1) = max(find(squeeze(sum(sum(VmaskSN)))));
        else
            top_slice(s,1) = min(find(missing_slice))-1;
        end
        save top_slice top_slice
        
        
        %bottom slice
        if sum(missing_slice)== 0 | missing_slice(min(find(squeeze(sum(sum(VmaskSN)))))) == 0
            bottom_slice(s,1) = min(find(squeeze(sum(sum(VmaskSN)))));
        else
            bottom_slice(s,1) = max(find(missing_slice))+1;
     
        end
    end
        save bottom_slice bottom_slice
end


%%%%%%%%%%%%%%%%%%%%%%%% %code below is for smoothing steps
if smooth==1
    load top_slice
    for s=1:length(Subs)
        
        v = spm_vol(psc_wrNMscanfiles{s,1});
        V = spm_read_vols(v);
        
        Vshort=V(:,:,1:top_slice(s));
        W = smooth3(Vshort, 'gaussian', [5,5,5], 0.425);
        V(:,:,1:top_slice(s)) = W;
       
        v.fname = s1_psc_wrNMscanfiles{s,1};
        spm_write_vol(v,V);
        
    end
end

%voxelwise analysis script for neuromelanin-sensitive MRI data, made by Cliff
%Cassidy, May 2020
clear all

root_folder = ['/data/projects/STUDIES/nm_jw/data/'];%%end rootfolder with a fileseparator (\ or /)
root_folder2 = []; %if merging data from different studies in different folders can accomodate that here. use the second column of scan_key ==1 for subs in root_folder and ==2 for subs in root_folder2
NM_subfolder = []; %be sure to put a \ or/ before the folder name e.g. '\NMimages' if there is no subfolder just keep it empty []
NM_subfolder2 = []; %in case the subfolder name is different in the 2 studies being merged. be sure to put a \ or/ before the folder name e.g. '\NMimages' if there is no subfolder just keep it empty []
NM_filestring = 's1_psc_wrs*NM.nii';% choose a filestring to select the fully preprocessed (s1_psc_wr) NM image here
topslicepath = ['/data/projects/STUDIES/nm_jw/scripts/top_slice.mat'];
load(topslicepath)
scan_key_path = ['/data/projects/STUDIES/nm_jw/scripts/scan_key_NEW_011921.mat'];
load(scan_key_path);
%scan_key is a matlab matrix with:
%1st column is subj id#;%2nd col is path (or code for path) to subj's processed NM image;
%%any additional col could be added to bring in additional variables to include in analysis

filter_subjects=1;
if filter_subjects==1
    filter = top_slice(:,1) > 57; %[scan_key(:,3)==1]-[scan_key(:,20)==1];
else
    filter = ones(length(scan_key(:,1)),1);%this filter lets everyone pass
end

scan_key=scan_key(filter==1,:);
top_slice=top_slice(filter==1,:);
%to check top_slice and scan_key, silence following line:
top_slice(:,2)=[];

% First input below (X) is the variable of interest, following iputs (Y, Y2) are controls
% IVs = [X, Y, Y2, ...]
IVs = [scan_key(:,3)];

%To write out masks showing location of significant voxels:
make_mask = 0; %change to 1 if want to write out these masks. note would overwrite files of same name so keep set at =0 most of the time
positive_relationship = 1; %makes masks of the data selectively with + or - relationships; if set to 0, would make mask including voxels with - relationships (see mask names below)
output_file05 = [root_folder filesep 'variable1_pos05.nii'];%name for mask containing voxels with relationships where p<0.05. give this filename any name you like
output_file01 = [root_folder filesep 'variable1_pos01.nii'];%name for mask containing voxels with relationships where p<0.01

%To filter out extreme-value voxels determined by distribution of all the voxels of all the subjects in the study:
exc_vox = 0; %this is a switch re: whether (=1 or =2) or not (=0) to exclude these voxels. If =1, the user can select the threshold of exclusion in the lines below. If =2 an automated threshold will be set to exclude the lowest and highest 1% of values based on the distribution of all SN voxels in all subjects combined.
%Exclusions (below) are calculated by reshaping inmask_data into a single row, removing NaNs, sorting, then finding values for indices at 1% (low) and 99% (high) 
LowVox = -10; %this excludes voxels with CNR value below -7% (if the switch exc_vox=1). These likely should be modified in a study specific manner based on the distribution of all voxels in all subjects
HiVox = 26; %this excludes voxels with CNR above 24%. 

VmaskFull = spm_read_vols(spm_vol([root_folder filesep 'full_SN_mask.nii']));%This is where you load the 'full' SN mask file

%% no more user input needed below this line %%%%%%%%%%%%%%%%%%%%

mask_top = max(top_slice);
for sl = min(top_slice):mask_top
    Vmasks{sl} = VmaskFull;
    Vmasks{sl}(:,:,sl+1:mask_top+1) = 0;
end

%Loading NM scans using scan key col 2 to code in which study path to find NIFTI files:
for s=1:length(scan_key(:,1))
    s
    Subs{s} = num2str(scan_key(s,1));
    
    if scan_key(s,2)==1
        NMscanname = dir([root_folder 's' num2str(Subs{s}) NM_subfolder filesep NM_filestring]); %added 's' to match file name structure
        NMscannames = [root_folder 's' num2str(Subs{s}) NM_subfolder filesep NMscanname(1,1).name];
        v = spm_vol(NMscannames);
    elseif scan_key(s,2)==2
        NMscanname = dir([root_folder2 's' num2str(Subs{s}) NM_subfolder2 filesep NM_filestring]);
        NMscannames = [root_folder2 's' num2str(Subs{s}) NM_subfolder2 filesep NMscanname(1,1).name];
        v = spm_vol(NMscannames);
    end
    V = (spm_read_vols(v))/10;
    
    full_scan(:,:,:,s) = V;%This is useful to make an average image of all subjects using an average of full_scan
    
    %Get subject-specific topslice definitions specified in scan_key col 3
    %and make appropriate SNmask.
    
    SNmask = Vmasks{top_slice(s)};
    
    %Eliminate all voxel values outside SN mask that has been cropped if needed in a subject-specific manner:
    V(SNmask==0)=NaN;
    
    %Extract all voxel values within SN mask to create inmask_data as
    %matrix, where each row is a voxel and each column is a subject:
    
    inmask_data(:,s) = V(VmaskFull==1);
    
end

inmask_data_prefilt = inmask_data; %keeps prefiltered version of inmask_data before filtering as follows below.
inmask_data_vector = reshape(inmask_data, 1, size(inmask_data,1)*size(inmask_data,2));
all_vox_all_subs_sorted =sort(inmask_data_vector);

if exc_vox==2
     LowVox= all_vox_all_subs_sorted(round(length(all_vox_all_subs_sorted)*0.01));
     HiVox=all_vox_all_subs_sorted(round(length(all_vox_all_subs_sorted)*0.99));
end

if exc_vox>0
    inmask_data(inmask_data(:,:)< LowVox) = NaN;
    inmask_data(inmask_data(:,:)> HiVox) = NaN;
end

for s = 1:length(scan_key(:,1))
    avg_inmask_data(s) = nanmean(inmask_data(:,s));
end
%The actual analysis begins here. Looping over voxels in SN mask, where i
%is a voxel.
for i = 1:length(inmask_data(:,1))
    
    %Note: Because some subjects have NaNs on some SN values, we ensure that
    %statistical analyses exclude these values on a voxel-by-voxel basis.
    %As a result, many voxels will have different degrees of freedom, e.g.
    %top slice voxels and extreme value voxels will have fewer DOF.
    
    try %(let's you get a bunch of NaNs in the output if the analyses don't 'work')
        %Robustfit protects from influential outliers biasing the
        %regression.
        [B,stats] = robustfit(IVs, inmask_data(i,:));
               
        avg_inmask_voxel(i) = nanmean(inmask_data(i,:)); %averages each voxels value for all subjects
        %Tracking actual output of analysis:
        beta(i)=B(2); %beta for the first independent variable
        betai(i) = B(1); %beta for the intercept
        dfe(i) = stats.dfe; %DOF
        pval(i)=stats.p(2);%pvalue for the first independent variable
        t(i)=stats.t(2);%tvalue for the first independent variable
        
        %Main output that we are currently looking at is counting the number of voxels that are significant in one
        %direction or another
        if pval(i)<0.02 & beta(i)>0 %because we are doing one-sided tests, if want to count voxels with p<0.01, use threshold of p<0.02 in one direction, i.e.in this case where beta is positive
            pos_sig01(i) = 1; %e.g. could change name to pos_sig01
        else
            pos_sig01(i) = 0;
        end
        if pval(i)<0.02 & beta(i)<0
            neg_sig01(i) = 1; %e.g. could change name to neg_sig01
        else
            neg_sig01(i) = 0;
        end
        if pval(i)<0.1 & beta(i)>0
            pos_sig05(i) = 1;
        else
            pos_sig05(i) = 0;
        end
        if pval(i)<0.1 & beta(i)<0
            neg_sig05(i) = 1;
        else
            neg_sig05(i) = 0;
        end
        if pval(i)<0.0020 & beta(i)>0
            pos_sig001(i) = 1;
        else
            pos_sig001(i) = 0;
        end
        if pval(i)<0.0020 & beta(i)<0
            neg_sig001(i) = 1;
        else
            neg_sig001(i) = 0;
        end
        
        stdeviat(i) = nanstd(inmask_data(i,:));
    catch
        pos_sig01(i) = NaN;
        beta(i) = NaN;
        pval(i)= NaN;
        t(i)=NaN;
        neg_sig01(i)=NaN;
        pos_sig05(i)=NaN;
        neg_sig05(i)=NaN;
        pos_sig001(i)=NaN;
        neg_sig001(i)=NaN;
        stdeviat(i) = NaN;
    end
end

%the lines below create averaged values for voxels where significant
%effects were seen (at different thresholds and in different directions)
for i = 1:length(scan_key(:,1))
    pos05vox_allsubs(:,i) = inmask_data(pos_sig05==1,i);
    avg_pos_05mask(i)  = nanmean(inmask_data(pos_sig05==1,i));
    avg_pos_01mask(i)  = nanmean(inmask_data(pos_sig01==1,i));
    avg_pos_001mask(i)  = nanmean(inmask_data(pos_sig001==1,i));
    avg_neg_05mask(i)  = nanmean(inmask_data(neg_sig05==1,i));
    avg_neg_01mask(i)  = nanmean(inmask_data(neg_sig01==1,i));
    avg_neg_001mask(i)  = nanmean(inmask_data(neg_sig001==1,i));
end

pos_sigvoxels01 = nansum(pos_sig01);
neg_sigvoxels01 = nansum(neg_sig01);

pos_sigvoxels05 = nansum(pos_sig05);
neg_sigvoxels05 = nansum(neg_sig05);

pos_sigvoxels001 = nansum(pos_sig001);
neg_sigvoxels001 = nansum(neg_sig001);

max_beta = max(beta);
min_beta = min(beta);
max_t = max(t);
min_t = min(t);

auc_pos = sum(t(beta>0));
auc_neg = sum(t(beta<0));

%the lines below write the masks

v.fname = output_file05;
v.descrip = ['correlated voxels at .05 '];
if positive_relationship
    V(VmaskFull==1)=pos_sig05;
elseif positive_relationship ==0
    V(VmaskFull==1)=neg_sig05;
end
V(VmaskFull==0)=0;
if make_mask
    spm_write_vol(v,V);
end

v.fname = output_file01;
v.descrip = ['correlated voxels at .01 '];
if positive_relationship
    V(VmaskFull==1)=pos_sig01;
elseif positive_relationship ==0
    V(VmaskFull==1)=neg_sig01;
end
V(VmaskFull==0)=0;
if make_mask
    spm_write_vol(v,V);
end
clear all
root_folder = ['/data/projects/STUDIES/social_doors_jw/nm-jw/data/'];
addpath('/data/spm12', '-end');
savepath;

%Switches for fine-tuning analysis by study: 
    %To filter out extreme-value voxels determined by distribution of all the voxels of all the subjects in the study: 
exc_vox = 1; %this is a switch re: whether (1) or not (0) to exclude these voxels
LowVox = 92; %this for example indicates that a voxel CNR below 92% would be excluded (if the switch is on). These likely should be modified in a study specific manner based on the distribution of all voxels in all subjects
HiVox = 140; %excluded if voxel CNR above 141% would also be excluded 
    
    %To write out masks:
make_mask = 0; %change to 1 if want to write out these masks. note would overwrite files of same name
positive_relationship = 1; %makes masks of the data selectively with + or - relationships; if set to 0, would make mask including voxels with - relationships
output_file05 = [root_folder 'genXage_pos_05.nii'];%mask containing voxels with relationships where p<0.05
output_file01 = [root_folder 'genXage_pos_01.nii'];%mask containing voxels with relationships where p<0.01

%load scan_key.mat
%for s=1:length(filepaths2_ch(:,1))
%    for var=1:length(filepaths2_ch(1,:))
%        if var==1
%            scan_key(s,var) = filepaths2_ch{s,3};
%        elseif var==7
%            scan_key(s,var)= strcmp('M', filepaths2_ch{s,var});
%        else
%            scan_key(s,var) = filepaths2_ch{s,var};
%        end
%    end
%end

%load college.mat
load scan_key_5.mat
root_folder = ['/data/projects/STUDIES/social_doors_jw/nm-jw/data/'];

%scan_key(:,2)=PDSubs;
%scan_key(:,5)=top_slice;
%scan_key(:,4)=bottom_slice;

%load scripts/scan_key.mat
%If want to exclude any subj based on variable condition:
%scan_key = scan_key(scan_key(:,10)==0,:);%%%%%%%%%%
%scan_key = scan_key(scan_key(:,4)<57,:);


%Load SN mask and make SN masks with various topslices based on full_SN_mask: 
%VmaskSN65 = spm_read_vols(spm_vol([root_folder '/SN_mask_139subs.nii']));%This is where JJW loads her 'full' SN mask file
%VmaskSN64 = spm_read_vols(spm_vol([root_fovlder2 '/scripts/SN_TU_adults_social_doors_56.nii']));%This is where JJW loads her 'full' SN mask file
VmaskSN64 = spm_read_vols(spm_vol([root_folder 'full_SN_mask_pos2.nii']));


VmaskSN63 = VmaskSN64;
VmaskSN63(:,:,64)= 0;
VmaskSN62 = VmaskSN63;
VmaskSN62(:,:,63)=0;
VmaskSN61 = VmaskSN62;
VmaskSN61(:,:,62)=0;
VmaskSN60 = VmaskSN61;
VmaskSN60(:,:,61)=0;


%Loading NM scans using scan key col 2 to code in which study path to find NIFTI files:
for s=1:length(scan_key(:,1))
    %old code:
    %scanname3 = dir([root_folder 'nm_avg' '/s1_psc_wr*.nii']);
    %scannames3 = [root_folder 'nm_avg' '/' scanname3(s,1).name];
    
    %new code:
    scannames3 = [root_folder 'nm_avg/s1_psc_wrs' num2str(scan_key(s,2)) '_SDC_NM.nii'];
    
    v = spm_vol(scannames3);
    V = spm_read_vols(v);
    
    full_scan(:,:,:,s) = V;%This is useful to make an average image of all subjects using an average of full_scan
    
    %Get subject-specific topslice definitions specified in scan_key col 3
    %and make appropriate SNmask. 
   
           
    if scan_key(s,5) == 60
        SNmask = VmaskSN60;
    elseif scan_key(s,5) == 61
        SNmask = VmaskSN61;
    elseif scan_key(s,5) == 62
        SNmask = VmaskSN62;
    elseif scan_key(s,5) == 63
        SNmask = VmaskSN63;
    elseif scan_key(s,5)>63
        SNmask = VmaskSN64;
    end
            
       

    %Eliminate all voxel values outside mask:
    V(SNmask==0)=NaN; 
    
    %Extract all voxel values within SN mask to create inmask_data as
    %matrix, where each row is a voxel and each column is a subject:
    
    inmask_data(:,s)=V(VmaskSN64==1);           
      
end

avg_NM = nanmean(full_scan,4);%makes average NM image of all subjects. (don't need this output unless you want it)

inmask_data_prefilt = inmask_data; %keeps prefiltered version of inmask_data before filtering as follows below.


if exc_vox
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
    %Probably don't need this, but just to be safe Cliff created is_nan
    %variable which indexes where the NaNs are.
    clear is_nan;
    is_nan = isnan(inmask_data(i,:));
     
    try %(let's you get a bunch of NaNs in the output if the analyses don't 'work')
        %Robustfit protects from influential outliers biasing the
        %regression.
        %Also note that this code is written such that the first
        %independent variable listed in the [] is the one for whom the stats are tracked;
        %i.e. if you want to get the stats for a different variable, you'd
        %switch the order of independent variables. 
        
        %age, age control for gender, age control for VS (combined, FB), age control for gender & VS 
        [B,stats] = robustfit([scan_key(is_nan==0,6)], inmask_data(i,is_nan==0));
        %[B,stats] = robustfit([scan_key(is_nan==0,6),scan_key(is_nan==0,7)], inmask_data(i,is_nan==0));
        
        %[B,stats] = robustfit([scan_key(is_nan==0,6),scan_key(is_nan==0,25)], inmask_data(i,is_nan==0));
        %[B,stats] = robustfit([scan_key(is_nan==0,6),scan_key(is_nan==0,7),scan_key(is_nan==0,25)], inmask_data(i,is_nan==0));
        
        %gender
        %[B,stats] = robustfit([scan_key(is_nan==0,7)], inmask_data(i,is_nan==0));
        %[B,stats] = robustfit([scan_key(is_nan==0,7), scan_key(is_nan==0,5)], inmask_data(i,is_nan==0));
        
        %[B,stats] = robustfit([scan_key(is_nan==0,7), scan_key(is_nan==0,25)],inmask_data(i,is_nan==0));
        %[B,stats] = robustfit([scan_key(is_nan==0,7),scan_key(is_nan==0,6),scan_key(is_nan==0,25)], inmask_data(i,is_nan==0));
        
        %interactions%
        %age * gender
        %[B,stats] = robustfit([scan_key(is_nan==0,7).*scan_key(is_nan==0,6),scan_key(is_nan==0,6),scan_key(is_nan==0,7)], inmask_data(i,is_nan==0));       
        
        %age * VS (combined, FB)
        %[B,stats] = robustfit([scan_key(is_nan==0,7).*scan_key(is_nan==0,25),scan_key(is_nan==0,25),scan_key(is_nan==0,7)], inmask_data(i,is_nan==0));       
        %gender * VS (combined, FB)
        %[B,stats] = robustfit([scan_key(is_nan==0,6).*scan_key(is_nan==0,25),scan_key(is_nan==0,6),scan_key(is_nan==0,6)], inmask_data(i,is_nan==0));       
           
        %VS DATA%
        %ANT%
        %VS (ANT L social)
        %[B,stats] = robustfit([scan_key(is_nan==0,8)], inmask_data(i,is_nan==0));
        %VS (ANT L social ctrl age)
        %[B,stats] = robustfit([scan_key(is_nan==0,8), scan_key(is_nan==0,7)],inmask_data(i,is_nan==0));
        %VS (ANT L social ctrl age and gender)
        %[B,stats] = robustfit([scan_key(is_nan==0,8), scan_key(is_nan==0,7), scan_key(is_nan==0,6)],inmask_data(i,is_nan==0));
        %VS (ANT R social)
        %[B,stats] = robustfit([scan_key(is_nan==0,9)], inmask_data(i,is_nan==0));
        %VS (ANT R social ctrl age)
        %[B,stats] = robustfit([scan_key(is_nan==0,9), scan_key(is_nan==0,7)],inmask_data(i,is_nan==0));
        %VS (ANT R social ctrl age and gender)
        %[B,stats] = robustfit([scan_key(is_nan==0,9), scan_key(is_nan==0,7),scan_key(is_nan==0,6)],inmask_data(i,is_nan==0));
        %VS (ANT L + R social)
        %[B,stats] = robustfit([scan_key(is_nan==0,10)], inmask_data(i,is_nan==0));
        %VS (ANT L + R social ctrl age)
        %[B,stats] = robustfit([scan_key(is_nan==0,10), scan_key(is_nan==0,7)],inmask_data(i,is_nan==0));
        %VS (ANT L + R social ctrl age and gender)
        %[B,stats] = robustfit([scan_key(is_nan==0,10), scan_key(is_nan==0,7),scan_key(is_nan==0,6)],inmask_data(i,is_nan==0));   
         
        %VS (ANT L door)
        %[B,stats] = robustfit([scan_key(is_nan==0,11)], inmask_data(i,is_nan==0));
        %VS (ANT L door ctrl age)
        %[B,stats] = robustfit([scan_key(is_nan==0,11), scan_key(is_nan==0,7)],inmask_data(i,is_nan==0));
        %VS (ANT L door ctrl age and gender)
        %[B,stats] = robustfit([scan_key(is_nan==0,11), scan_key(is_nan==0,7),scan_key(is_nan==0,6)],inmask_data(i,is_nan==0)); 
        %VS (ANT R door)
        %[B,stats] = robustfit([scan_key(is_nan==0,12)], inmask_data(i,is_nan==0));
        %VS (ANT R door ctrl age)
        %[B,stats] = robustfit([scan_key(is_nan==0,12), scan_key(is_nan==0,7)],inmask_data(i,is_nan==0));
        %VS (ANT R door ctrl age and gender)
        %[B,stats] = robustfit([scan_key(is_nan==0,12), scan_key(is_nan==0,7),scan_key(is_nan==0,6)],inmask_data(i,is_nan==0));
        %VS (ANT L + R door)
        %[B,stats] = robustfit([scan_key(is_nan==0,13)], inmask_data(i,is_nan==0));
        %VS (ANT L + R door ctrl age)
        %[B,stats] = robustfit([scan_key(is_nan==0,13), scan_key(is_nan==0,7)],inmask_data(i,is_nan==0));
        %VS (ANT L + R door ctrl age and gender)
        %[B,stats] = robustfit([scan_key(is_nan==0,13), scan_key(is_nan==0,7),scan_key(is_nan==0,6)],inmask_data(i,is_nan==0));
      
        %VS (ANT L combined)
        %[B,stats] = robustfit([scan_key(is_nan==0,14)], inmask_data(i,is_nan==0));
        %VS (ANT L combined ctrl age)
        %[B,stats] = robustfit([scan_key(is_nan==0,14), scan_key(is_nan==0,7)],inmask_data(i,is_nan==0));
        %VS (ANT L combined ctrl age and gender)
        %[B,stats] = robustfit([scan_key(is_nan==0,14), scan_key(is_nan==0,7),scan_key(is_nan==0,6)],inmask_data(i,is_nan==0)); 
        %VS (ANT R combined)
        %[B,stats] = robustfit([scan_key(is_nan==0,15)], inmask_data(i,is_nan==0));
        %VS (ANT R combined ctrl age)
        %[B,stats] = robustfit([scan_key(is_nan==0,15), scan_key(is_nan==0,7)],inmask_data(i,is_nan==0));
        %VS (ANT R combined ctrl age and gender)
        %[B,stats] = robustfit([scan_key(is_nan==0,15), scan_key(is_nan==0,7),scan_key(is_nan==0,6)],inmask_data(i,is_nan==0));
        %VS (ANT L + R combined)
        %[B,stats] = robustfit([scan_key(is_nan==0,16)], inmask_data(i,is_nan==0));
        %VS (ANT L + R combined ctrl age)
        %[B,stats] = robustfit([scan_key(is_nan==0,16), scan_key(is_nan==0,7)],inmask_data(i,is_nan==0));
        %VS (ANT L + R combined ctrl age and gender)
        %[B,stats] = robustfit([scan_key(is_nan==0,16), scan_key(is_nan==0,7),scan_key(is_nan==0,6)],inmask_data(i,is_nan==0));
        
        %FB%
        %VS (FB L social)
        %[B,stats] = robustfit([scan_key(is_nan==0,17)], inmask_data(i,is_nan==0));
        %VS (FB L social ctrl age)
        %[B,stats] = robustfit([scan_key(is_nan==0,17), scan_key(is_nan==0,7)],inmask_data(i,is_nan==0));
        %VS (FB L social ctrl age and gender)
        %[B,stats] = robustfit([scan_key(is_nan==0,17), scan_key(is_nan==0,7),scan_key(is_nan==0,6)],inmask_data(i,is_nan==0)); 
        %VS (FB R social)
        %[B,stats] = robustfit([scan_key(is_nan==0,18)], inmask_data(i,is_nan==0));
        %VS (FB R social ctrl age)
        %[B,stats] = robustfit([scan_key(is_nan==0,18), scan_key(is_nan==0,7)],inmask_data(i,is_nan==0));
        %VS (FB R social ctrl age and gender)
        %[B,stats] = robustfit([scan_key(is_nan==0,18), scan_key(is_nan==0,7),scan_key(is_nan==0,6)],inmask_data(i,is_nan==0));
        %VS (FB L + R social)
        %[B,stats] = robustfit([scan_key(is_nan==0,19)], inmask_data(i,is_nan==0));
        %VS (FB L + R social ctrl age)
        %[B,stats] = robustfit([scan_key(is_nan==0,19), scan_key(is_nan==0,7)],inmask_data(i,is_nan==0));
        %VS (FB L + R social ctrl age and gender)
        %[B,stats] = robustfit([scan_key(is_nan==0,19), scan_key(is_nan==0,7),scan_key(is_nan==0,6)],inmask_data(i,is_nan==0));   
        
        %VS (FB L door)
        %[B,stats] = robustfit([scan_key(is_nan==0,20)], inmask_data(i,is_nan==0));
        %VS (FB L door ctrl age)
        %[B,stats] = robustfit([scan_key(is_nan==0,20), scan_key(is_nan==0,7)],inmask_data(i,is_nan==0));
        %VS (FB L door ctrl age and gender)
        %[B,stats] = robustfit([scan_key(is_nan==0,20), scan_key(is_nan==0,7),scan_key(is_nan==0,6)],inmask_data(i,is_nan==0)); 
        %VS (FB R door)
        %[B,stats] = robustfit([scan_key(is_nan==0,21)], inmask_data(i,is_nan==0));
        %VS (FB R door ctrl age)
        %[B,stats] = robustfit([scan_key(is_nan==0,21), scan_key(is_nan==0,7)],inmask_data(i,is_nan==0));
        %VS (FB R door ctrl age and gender)
        %[B,stats] = robustfit([scan_key(is_nan==0,21), scan_key(is_nan==0,7),scan_key(is_nan==0,6)],inmask_data(i,is_nan==0));
        %VS (FB L + R door)
        %[B,stats] = robustfit([scan_key(is_nan==0,22)], inmask_data(i,is_nan==0));
        %VS (FB L + R door ctrl age)
        %[B,stats] = robustfit([scan_key(is_nan==0,22), scan_key(is_nan==0,7)],inmask_data(i,is_nan==0));
        %VS (FB L + R door ctrl age and gender)
        %[B,stats] = robustfit([scan_key(is_nan==0,22), scan_key(is_nan==0,7),scan_key(is_nan==0,6)],inmask_data(i,is_nan==0));

        %VS (FB L combined)
        %[B,stats] = robustfit([scan_key(is_nan==0,23)], inmask_data(i,is_nan==0));
        %VS (FB L combined ctrl age)
        %[B,stats] = robustfit([scan_key(is_nan==0,23), scan_key(is_nan==0,7)], inmask_data(i,is_nan==0));
        %VS (FB L combined ctrl age and gender)
        %[B,stats] = robustfit([scan_key(is_nan==0,23), scan_key(is_nan==0,7),scan_key(is_nan==0,6)],inmask_data(i,is_nan==0)); 
        %VS (FB R combined)
        %[B,stats] = robustfit([scan_key(is_nan==0,24)], inmask_data(i,is_nan==0));
        %VS (FB R combined ctrl age)
        %[B,stats] = robustfit([scan_key(is_nan==0,24), scan_key(is_nan==0,7)],inmask_data(i,is_nan==0));
        %VS (FB R combined ctrl age and gender)
        %[B,stats] = robustfit([scan_key(is_nan==0,24), scan_key(is_nan==0,7),scan_key(is_nan==0,6)],inmask_data(i,is_nan==0));
        %VS (FB L + R combined)
        %[B,stats] = robustfit([scan_key(is_nan==0,25)], inmask_data(i,is_nan==0));
        %VS (FB L + R combined ctrl age)
        %[B,stats] = robustfit([scan_key(is_nan==0,25), scan_key(is_nan==0,7)],inmask_data(i,is_nan==0));
        %VS (FB L + R combined ctrl age and gender)
        %[B,stats] = robustfit([scan_key(is_nan==0,25), scan_key(is_nan==0,7),scan_key(is_nan==0,6)],inmask_data(i,is_nan==0));
       
        
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
    V(VmaskSN64==1)=pos_sig05;
elseif positive_relationship ==0
    V(VmaskSN64==1)=neg_sig05;
end
V(VmaskSN64==0)=0;
if make_mask
    spm_write_vol(v,V);
end

v.fname = output_file01;
v.descrip = ['correlated voxels at .01 '];
if positive_relationship
    V(VmaskSN64==1)=pos_sig01;
elseif positive_relationship ==0
    V(VmaskSN64==1)=neg_sig01;
end
V(VmaskSN64==0)=0;
if make_mask
    spm_write_vol(v,V);
end
       
% % Calculate 'RVST' submask values:
% 
% VmaskSN64 = spm_read_vols(spm_vol([root_folder 'full_SN_mask_pos2.nii']));
% 
% v=spm_vol([root_folder 'RVSt_dBPND_05.nii']);
% V=spm_read_vols(v);
% vst_vox=V(VmaskSN64==1);
% for s=1:5
%     vst_da_SN_vox(s)=nanmean(inmask_data(vst_vox==1,s));
%     save vst_da_SN_vox vst_da_SN_vox
% end
% 
% figure;
% %hist(inmask_data(:,6))
% 
% 
% % size(V)
% % size(vst_vox)
% % size(inmask_data)
% 
% plot(inmask_data(1,:))



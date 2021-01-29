% List of open inputs
nrun = X; % enter the number of runs here
jobfile = {'/data/projects/STUDIES/social_doors_jw/nm-jw/scripts/spm_realign_23JAN2021_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(0, nrun);
for crun = 1:nrun
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});

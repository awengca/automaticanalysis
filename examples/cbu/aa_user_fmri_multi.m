% Automatic analysis
% User master script example (aa version 5.*.*)
%
% This is an example of how to process a longitudinal dataset.  This example processes
% one subject with six visits: one structural plus five functional; each functional with
% four sessions.
%
% For internal use at MRC CBU, Cambridge, UK - requires access to the CBU imaging
% system.
%
% v2: Johan Carlin, MRC CBU, 08-08-2018
% v1: Tibor Auer, MRC-CBSU, 08-02-2016

%% INITIALISE
clear
aa_ver5

%% DEFINE SPECIFIC PARAMETERS
aap=aarecipe('aap_tasklist_fmri_multi.xml');

% this example uses SPM tools in the user script, so we have to ensure SPM is
% on the path
spmhit = which('spm_spm');
if any(spmhit)
    assert(strcmp(fileparts(spmhit), aap.directory_conventions.spmdir), ...
        'spm on path differs from aap.directory_conventions.spmdir');
else
    fprintf('adding spmdir to path: %s\n', aap.directory_conventions.spmdir);
    addpath(aap.directory_conventions.spmdir);
end

% Modify standard recipe module selection here if you'd like
aap.options.wheretoprocess = 'qsub'; % queuing system	% typical value localsingle or qsub
aap.options.autoidentifyfieldmaps = 1;
aap.options.autoidentifystructural_choosefirst = 1;

aap.tasksettings.aamod_segment8.writenormimg=0;
% Set slice order for slice timing correction
aap.tasksettings.aamod_realignunwarp.eoptions.quality = 0.9;
aap.tasksettings.aamod_realignunwarp.eoptions.sep = 4;
aap.tasksettings.aamod_realignunwarp.eoptions.rtm = 1;
aap.tasksettings.aamod_realignunwarp.eoptions.einterp = 2;

aap.tasksettings.aamod_slicetiming.autodetectSO = 1;       	% descending
aap.tasksettings.aamod_slicetiming.refslice = 1;            % reference slice (bottom)
aap.tasksettings.aamod_norm_write_dartel.vox = [3 3 3];
aap.tasksettings.aamod_norm_write_meanepi_dartel.vox = [3 3 3];

aap.tasksettings.aamod_smooth(1).FWHM = 7;
aap.tasksettings.aamod_smooth(2).FWHM = 7;

aap.tasksettings.aamod_firstlevel_model(1).xBF.UNITS = 'secs';    	% OPTIONS: 'scans'|'secs' for onsets and durations, typical value 'secs'
aap.tasksettings.aamod_firstlevel_model(1).includemovementpars = 1;% Include/exclude Moco params in/from DM, typical value 1
aap.tasksettings.aamod_firstlevel_model(2).xBF.UNITS = 'secs';    	% OPTIONS: 'scans'|'secs' for onsets and durations, typical value 'secs'
aap.tasksettings.aamod_firstlevel_model(2).includemovementpars = 1;% Include/exclude Moco params in/from DM, typical value 1

aap = aas_renamestream(aap,'aamod_coreg_noss_00001','structural','aamod_biascorrect_structural_00001.structural');

%% STUDY
% Directory for analysed data
aap.acq_details.root = fullfile(aap.acq_details.root,'aa_demo');
aap.directory_conventions.analysisid = 'fmri_multi'; 

% Add data and model
aap.directory_conventions.subject_directory_format = 3; % manual
nVisit = 5;
nRun = 4;
for r = 1:(nVisit*nRun)
    aap = aas_addsession(aap,sprintf('run%02d',r));
end

subj = 'S1';
aap = aas_addsubject(aap,subj,150479);
aap = aas_addsubject(aap,subj,150489,'functional',5:5:20);
aap = aas_addsubject(aap,subj,150498,'functional',5:5:20);
aap = aas_addsubject(aap,subj,150504,'functional',5:5:20);
aap = aas_addsubject(aap,subj,150510,'functional',5:5:20);
aap = aas_addsubject(aap,subj,150526,'functional',5:5:20);

EVFolder = '/imaging/local/software/AA/test_resources/fmri_multi/evfiles';
for v = 1:nVisit
    for r = 1:nRun
        sessind = (v-1)*nRun+r;
        for ev = {'Up','Down','FB','NE','Rate','Omit'}
            EVfile= spm_select('FPList',EVFolder,sprintf('Visit%d_Run%d_%s.*txt$',v,r,ev{1}));
            EVs = dlmread(EVfile);
            if isempty(EVs), aas_log(aap,true,sprintf('ERROR: Empty EV: %s',EVfile)); end
            aap = aas_addevent(aap,'aamod_firstlevel_model_*',subj,...
                aap.acq_details.sessions(sessind).name,... % run
                ev{1},... % condition name
                EVs(:,1),... % onset
                EVs(:,2)... % duration
                );
        end
    end
end

% For each run
for r = 1:nVisit*nRun
    aap = aas_addcontrast(aap,'aamod_firstlevel_contrasts_*','*',['singlesession:' aap.acq_details.sessions(r).name],[1 0 0 0 0 0],[aap.acq_details.sessions(r).name ':Up'],'T');
    aap = aas_addcontrast(aap,'aamod_firstlevel_contrasts_*','*',['singlesession:' aap.acq_details.sessions(r).name],[0 1 0 0 0 0],[aap.acq_details.sessions(r).name ':Down'],'T');
    aap = aas_addcontrast(aap,'aamod_firstlevel_contrasts_*','*',['singlesession:' aap.acq_details.sessions(r).name],[1 -1 0 0 0 0],[aap.acq_details.sessions(r).name ':Up>Down'],'T');
    aap = aas_addcontrast(aap,'aamod_firstlevel_contrasts_*','*',['singlesession:' aap.acq_details.sessions(r).name],[-1 1 0 0 0 0],[aap.acq_details.sessions(r).name ':Down>Up'],'T');
end
% For each day
for v = 1:nVisit
    lVisit = nRun*(6+6);
    con0 = zeros(1,nVisit*lVisit);
    
    con = con0;
    con((v-1)*lVisit+1:v*lVisit) = repmat([1 0 0 0 0 0 0 0 0 0 0 0],1,nRun);
    aap = aas_addcontrast(aap,'aamod_firstlevel_contrasts_*','*','uniquebysession',con,sprintf('Day%d:Up',v),'T');
    con = con0;
    con((v-1)*lVisit+1:v*lVisit) = repmat([0 1 0 0 0 0 0 0 0 0 0 0],1,nRun);
    aap = aas_addcontrast(aap,'aamod_firstlevel_contrasts_*','*','uniquebysession',con,sprintf('Day%d:Down',v),'T');
    con = con0;
    con((v-1)*lVisit+1:v*lVisit) = repmat([1 -1 0 0 0 0 0 0 0 0 0 0],1,nRun);
    aap = aas_addcontrast(aap,'aamod_firstlevel_contrasts_*','*','uniquebysession',con,sprintf('Day%d:Up>Down',v),'T');
    con = con0;
    con((v-1)*lVisit+1:v*lVisit) = repmat([-1 1 0 0 0 0 0 0 0 0 0 0],1,nRun);
    aap = aas_addcontrast(aap,'aamod_firstlevel_contrasts_*','*','uniquebysession',con,sprintf('Day%d:Down>Up',v),'T');
    
end

% Across the whole training
aap = aas_addcontrast(aap,'aamod_firstlevel_contrasts_*','*','sameforallsessions',[1 0 0 0 0 0],'All:Up','T');
aap = aas_addcontrast(aap,'aamod_firstlevel_contrasts_*','*','sameforallsessions',[0 1 0 0 0 0],'All:Down','T');
aap = aas_addcontrast(aap,'aamod_firstlevel_contrasts_*','*','sameforallsessions',[1 -1 0 0 0 0],'All:Up>Down','T');
aap = aas_addcontrast(aap,'aamod_firstlevel_contrasts_*','*','sameforallsessions',[-1 1 0 0 0 0],'All:Down>Up','T');

%% DO ANALYSIS
aa_doprocessing(aap);
aa_report(fullfile(aas_getstudypath(aap),aap.directory_conventions.analysisid));

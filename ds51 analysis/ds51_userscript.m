% ------------------------------------------------------------------------------------------------------------------------------
% INITIALIZATION
% ------------------------------------------------------------------------------------------------------------------------------

clear all;
aa_ver5;

aap = aarecipe('aap_parameters_ANDREW.xml','ds51_tasklist.xml');
% ------------------------------------------------------------------------------------------------------------------------------
% FSL hack
% ------------------------------------------------------------------------------------------------------------------------------

FSL_binaryDirectory = '/usr/local/fsl/bin'; 
currentPath = getenv('PATH');
if ~contains(currentPath,FSL_binaryDirectory)
    correctedPath = [ currentPath ':' FSL_binaryDirectory ];
    setenv('PATH', correctedPath);
end

% ------------------------------------------------------------------------------------------------------------------------------
% DEFAULTS AND SANITY CHECKS
% ------------------------------------------------------------------------------------------------------------------------------

aap.acq_details.root = '/Users/andrewweng/Data/ds000051';
aap.directory_conventions.analysisid = 'RESULTS';

% just point rawdatadir at the top level BIDS dir; processBIDS does the rest

aap.directory_conventions.rawdatadir = '/Users/andrewweng/Data/ds000051';

% need to specify chooseblerg otherwise aa crashes

aap.options.autoidentifystructural_choosefirst = 1;
aap.options.autoidentifystructural_chooselast = 0;

aap.options.NIFTI4D = 1;
aap.acq_details.numdummies = 0;	
aap.acq_details.input.correctEVfordummies = 0;

% ------------------------------------------------------------------------------------------------------------------------------
% BIDS input
% ------------------------------------------------------------------------------------------------------------------------------

aap = aas_processBIDS(aap);

% ------------------------------------------------------------------------------------------------------------------------------
% GLM
% ------------------------------------------------------------------------------------------------------------------------------

% UNITS is 'secs' in event file (even though SPM auditory tutorial uses 'scans')
 
% aap.tasksettings.aamod_firstlevel_model.xBF.UNITS = 'scans'; 
aap.tasksettings.aamod_firstlevel_model.xBF.UNITS = 'secs'; 
 
% processBIDS will create the events for the model, but you must define the contrasts

aap = aas_addcontrast(aap, 'aamod_firstlevel_contrasts_*', '*', 'sameforallsessions', [1,0,0,0] , 'consonant strings','T');
 
aap = aas_addcontrast(aap, 'aamod_firstlevel_contrasts_*', '*', 'sameforallsessions', [0,1,0,0] , 'objects','T');

aap = aas_addcontrast(aap, 'aamod_firstlevel_contrasts_*', '*', 'sameforallsessions', [0,0,1,0] , 'scrambled objects','T');

aap = aas_addcontrast(aap, 'aamod_firstlevel_contrasts_*', '*', 'sameforallsessions', [0,0,0,1] , 'words','T');

% more contrasts

aap = aas_addcontrast(aap, 'aamod_firstlevel_contrasts_*', '*', 'sameforallsessions', [0,1,-1,0], 'objects greater than scrambled','T');
						   
% ------------------------------------------------------------------------------------------------------------------------------
% RUN AND REPORT
% ------------------------------------------------------------------------------------------------------------------------------

aa_doprocessing(aap);
% aa_report(fullfile(aas_getstudypath(aap),aap.directory_conventions.analysisid));
aa_close(aap);
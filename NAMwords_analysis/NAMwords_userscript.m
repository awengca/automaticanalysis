% ------------------------------------------------------------------------------------------------------------------------------
% INITIALIZATION
% ------------------------------------------------------------------------------------------------------------------------------

clear all;
aa_ver5;

aap = aarecipe('aap_parameters_ANDREW.xml','NAMwords_tasklist.xml');
% ------------------------------------------------------------------------------------------------------------------------------
% FSL hack
% ------------------------------------------------------------------------------------------------------------------------------

FSL_binaryDirectory = '/usr/local/fsl/bin'; 
currentPath = getenv('PATH');
if ~contains(currentPath,FSL_binaryDirectory)
    correctedPath = [ currentPath ':' FSL_binaryDirectory ];
    setenv('PATH', correctedPath);
end

% -----------------------------------------------------------------------------------------
% Overwrite desired parameter defaults
% ----------------------------------------------------------------------------------------- 

aap.acq_details.numdummies = 0;	% do not remove any epi files from the collection
aap.options.NIFTI4D = 1; 			% combine functional DICOMS into one nifti file
aap.tasksettings.aamod_smooth.FWHM = 12; % smoothing (Full Width Half Maximum)m


% ------------------------------------------------------------------------------------------------------------------------------
% Data Directories (for the beast)
% ------------------------------------------------------------------------------------------------------------------------------

aap.directory_conventions.rawdatadir = '/Users/andrewweng/Documents/Data/NAMWords1_YA/Subjects':
aap.acq_details.root = '/Users/andrewweng/Documents/Data/NAMWords1_YA';
aap.directory_conventions.analysisid = 'RESULTS';


% ------------------------------------------------------------------------------------------------------------------------------
% Specify data - structural
% ------------------------------------------------------------------------------------------------------------------------------





% -------------------------------------------------------------------------
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
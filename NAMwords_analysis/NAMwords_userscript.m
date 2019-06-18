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

aap.directory_conventions.rawdatadir = '/Users/andrewweng/Documents/Data/NAMWords1_YA';
aap.acq_details.root = '/Users/andrewweng/Documents/Data/NAMWords1_YA';
aap.directory_conventions.analysisid = 'RESULTS';


% ------------------------------------------------------------------------------------------------------------------------------
% Specify data - structural
% ------------------------------------------------------------------------------------------------------------------------------

aap.options.autoidentifystructural = 1;
aap.options.autoidentifystructural_choosefirst = 1;
aap.options.autoidentifystructural_chooselast = 0;
aap.directory_conventions.protocol_structural = 'T1w_MPR';

% ------------------------------------------------------------------------------------------------------------------------------
% Specify data - functional
% ------------------------------------------------------------------------------------------------------------------------------

aap = aas_addsubject(aap, 'PL00103','PL00103_03','functional', [16 20 14 18]);
aap = aas_addsubject(aap, 'PL00109','PL00109_01','functional', [22 26 24 28]); 
aap = aas_addsubject(aap, 'PL00111','PL00111_01','functional', [16 20 14 18]);
aap = aas_addsubject(aap, 'PL00112','PL00112_01','functional', [14 18 16 20]); 
aap = aas_addsubject(aap, 'PL00114','PL00114_01','functional', [16 20 14 18]); 
aap = aas_addsubject(aap, 'PL00116','PL00116_01','functional', [22 26 24 28]); 
aap = aas_addsubject(aap, 'PL00117','PL00117_01','functional', [16 20 14 18]); 
aap = aas_addsubject(aap, 'PL00118','PL00118_02','functional', [16 20 14 18]); 
aap = aas_addsubject(aap, 'PL00119','PL00119_01','functional', [14 18 16 20]); 
aap = aas_addsubject(aap, 'PL00120','PL00120_01','functional', [16 20 14 18]); 
aap = aas_addsubject(aap, 'PL00121','PL00121_01','functional', [14 18 16 20]); 
aap = aas_addsubject(aap, 'PL00123','PL00123_01','functional', [16 20 14 18]); 
aap = aas_addsubject(aap, 'PL00127','PL00127_01','functional', [14 18 16 20]); 
aap = aas_addsubject(aap, 'PL00128','PL00128_01','functional', [16 20 14 18]); 
aap = aas_addsubject(aap, 'PL00129','PL00129_02','functional', [14 18 16 20]); 
aap = aas_addsubject(aap, 'PL00131','PL00131_01','functional', [16 20 14 18]); 
aap = aas_addsubject(aap, 'PL00135','PL00135_01','functional', [16 20 14 18]); 
aap = aas_addsubject(aap, 'PL00139','PL00139_01','functional', [14 18 16 20]); 
aap = aas_addsubject(aap, 'PL00141','PL00141_01','functional', [20 24 22 26]); 
aap = aas_addsubject(aap, 'PL00144','PL00144_02','functional', [16 20 14 18]);
aap = aas_addsubject(aap, 'PL00167','PL00167_01','functional', [14 18 16 20]);
aap = aas_addsubject(aap, 'PL00266','PL00266_01','functional', [14 18 16 20]);
aap = aas_addsubject(aap, 'PL00269','PL00269_01','functional', [16 20 14 18]);
aap = aas_addsubject(aap, 'PL00270','PL00270_01','functional', [16 20 18 22]);
aap = aas_addsubject(aap, 'PL00275','PL00275_01','functional', [16 20 14 18]);
aap = aas_addsubject(aap, 'PL00276','PL00276_01','functional', [16 20 14 18]);



% -------------------------------------------------------------------------
% defining each of the four sessions
% -------------------------------------------------------------------------

aap = aas_addsession(aap,'SESS01');
aap = aas_addsession(aap,'SESS02');
aap = aas_addsession(aap,'SESS03');
aap = aas_addsession(aap,'SESS04');


% -------------------------------------------------------------------------
% specify events and contrasts for GLM
% ------------------------------------------------------------------------------------------------------------------------------

    %-------------------------------
    % read the .csv file (JUST 1 SUB ONE SESS FOR NOW)
    %-------------------------------
    
    events = csvread('fiveconditioncode/NAMWORDS1_PL00103_SESS01_FIVECONDITIONCODE.csv',1,0);
    
    %-------------------------------
    
    aap = aas_addevent(aap, 'aamod_firstlevel_model', 'PL00103', 'SESS01','ListenWord');
    aap = aas_addcontrast(aap, 'aamod_firstlevel_contrasts', '*', 'sameforallsessions', 1 , 'ListenWord','T');

% ------------------------------------------------------------------------------------------------------------------------------
% RUN AND REPORT
% ------------------------------------------------------------------------------------------------------------------------------

aa_doprocessing(aap);
% aa_report(fullfile(aas_getstudypath(aap),aap.directory_conventions.analysisid));
aa_close(aap);
clear all;
aa_ver5;



FSL_binaryDirectory = '/usr/local/fsl/bin';
currentPath = getenv('PATH');
if ~contains(currentPath,FSL_binaryDirectory)
	correctedPath = [ currentPath ':' FSL_binaryDirectory ];
	setenv('PATH', correctedPath);
end


aap = aarecipe('aap_parameters_ANDREW.xml','aa_temp_demo.xml');
aap.acq_details.root = '/Users/andrewweng/Data/MoAEpilot';
aap.directory_conventions.rawdatadir = '/Users/andrewweng/Data/MoAEpilot';
aap.directory_conventions.analysisid = 'RESULTS';


aap.options.autoidentifystructural_choosefirst = 1;
aap.options.autoidentifystructural_chooselast = 0;

aap.options.NIFTI4D = 1;
aap.acq_details.numdummies = 0;
aap.acq_details.intput.correctEVfordummies = 0;

aap = aas_renamestream(aap,'aamod_histogram_0001','foo','structural');

aap = aas_renamestream(aap,'aamod_histogram_0001','bar','pretty_image','output');

aap = aas_processBIDS(aap,[],[],{'sub-01',});

aap.tasksettings.aamod_firstlevel_model.xBF.UNITS = 'scans';

aap = aas_addcontrast(aap, 'aamod_firstlevel_contrasts_*','*','sameforallsessions', [1], 'test-contrast','T');

aa_doprocessing(aap);
aa_close(aap);
aa_jpeg_crawler(aap);
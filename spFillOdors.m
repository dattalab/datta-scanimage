function spFillOdors
global state gh

state.olfactometer.frameSpecificationField_1 = 62;
state.olfactometer.frameSpecificationField_2 = 7;
state.olfactometer.frameSpecificationField_3 = 62;
state.olfactometer.frameSpecificationField_4 = 1;

updateGUIByName({'gh.olfactometer.frameSpecificationField_1', 
            	 'gh.olfactometer.frameSpecificationField_2',
            	 'gh.olfactometer.frameSpecificationField_3', 
            	 'gh.olfactometer.frameSpecificationField_4'});

state.olfactometer.valveEnable_1 = 1;
state.olfactometer.valveEnable_2 = 1;
state.olfactometer.valveEnable_3 = 1;
state.olfactometer.valveEnable_4 = 1;
state.olfactometer.valveEnable_5 = 1;
state.olfactometer.valveEnable_6 = 1;
state.olfactometer.valveEnable_7 = 1;
state.olfactometer.valveEnable_8 = 1;

updateGUIByName({'gh.olfactometer.valveEnable_1', 
                 'gh.olfactometer.valveEnable_2', 
                 'gh.olfactometer.valveEnable_3', 
                 'gh.olfactometer.valveEnable_4'});
             
updateGUIByName({'gh.olfactometer.valveEnable_5', 
                 'gh.olfactometer.valveEnable_6',
                 'gh.olfactometer.valveEnable_7', 
                 'gh.olfactometer.valveEnable_8'});

state.olfactometer.valveOdor1Name_1 = 'null';
state.olfactometer.valveOdor1Name_2 = 'isoamyl acetate';
state.olfactometer.valveOdor1Name_3 = 'butyric acid';
state.olfactometer.valveOdor1Name_4 = '2-pentanone';
state.olfactometer.valveOdor1Name_5 = 'nonyl alcohol';
state.olfactometer.valveOdor1Name_6 = 'trimethylpyrazine';
state.olfactometer.valveOdor1Name_7 = 'dimethyl disulfide';
state.olfactometer.valveOdor1Name_8 = 'ethylbenzene';

updateGUIByName({'gh.olfactometer.valveOdor1Name_1', 
		         'gh.olfactometer.valveOdor1Name_2', 
                 'gh.olfactometer.valveOdor1Name_3', 
                 'gh.olfactometer.valveOdor1Name_4'});
updateGUIByName({'gh.olfactometer.valveOdor1Name_5', 
            	 'gh.olfactometer.valveOdor1Name_6', 
                 'gh.olfactometer.valveOdor1Name_7', 
                 'gh.olfactometer.valveOdor1Name_8'});


olfactometer_refresh;
calculateFrameTimes;
overrideFrames(state.olfactometer.nFrames);
olfactometer_refresh;

end
function header_saveMFile
% header_saveMfile - Set the header information as M file together with data files.
%
% SYNTAX
%  header_saveMFile;
%
% NOTES
%
% CHANGES
%  TO032410D - Check if the header gui program is running. -- Tim O'Connor 3/24/10
%
% Created 9/11/07 - Jinyang Liu
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007

%TO032410D
if ~isprogram(progmanager, 'headerGui')
    return;
end

tempName=xsg_getFilename;
[pathname, filename] = fileparts(tempName);
filename= [filename(1:end-8) '.m'];

hObject=getHandleFromName(progmanager, 'headerGUI', 'headerGUI');

setLocalBatch(progmanager, hObject, 'filename', filename, 'pathname', pathname);
setDefaultCacheValue(progmanager, 'headerGUI_filename', filename);
setDefaultCacheValue(progmanager, 'headerGUI_pathname', pathname);

if (pathname == 0)
    errordlg('A file must first be specified.');
    return;
end

f = fopen(fullfile(pathname, filename), 'w');

[experimenter,rig,speciesStrain,animalAge,gender,transgenicLine,sliceTime,...
        sliceType,temp,otherField,otherValue] = getLocalBatch(progmanager, hObject,...
    'experimenter','rig','speciesStrain','animalAge','gender','transgenicLine','sliceTime',...
        'sliceType','temp','otherField','otherValue');
    
[inUtero,targetCells,construct,treatment,whatTreatment,vi,virusAge,construct_vi,...
        virus,location] = getLocalBatch(progmanager, hObject,'inUtero','targetCells',...
    'construct','treatment','whatTreatment','vi','virusAge','construct_vi',...
        'virus','location');    
    
[saveCell1,brainArea1,region1,subregion1,cellType1,somaZ1,vRest1] = getLocalBatch(progmanager, hObject,...
    'saveCell1','brainArea1','region1','subregion1','cellType1','somaZ1','vRest1');    
[saveCell2, brainArea2,region2,subregion2,cellType2,somaZ2,vRest2] = getLocalBatch(progmanager, hObject,...
    'saveCell2','brainArea2','region2','subregion2','cellType2','somaZ2','vRest2');  
[saveCell3, brainArea3,region3,subregion3,cellType3,somaZ3,vRest3] = getLocalBatch(progmanager, hObject,...
    'saveCell3','brainArea3','region3','subregion3','cellType3','somaZ3','vRest3');  
[saveCell4, brainArea4,region4,subregion4,cellType4,somaZ4,vRest4] = getLocalBatch(progmanager, hObject,...
    'saveCell4','brainArea4','region4','subregion4','cellType4','somaZ4','vRest4');   

[intracellularSolutionType,intracellularSolutionDrugs,bathSolutionType,bathSolutionDrugs] = getLocalBatch(progmanager, hObject,...
    'intracellularSolutionType','intracellularSolutionDrugs','bathSolutionType','bathSolutionDrugs');

fprintf(f, ['%% ************* General info *****************%%' '\n']);    
fprintf(f, 'Experimenter = ''%s'';\n', experimenter);
fprintf(f, 'Rig = ''%s'';\n', rig);

fprintf(f, ['%% ************* Animal info *****************%%' '\n']);  
fprintf(f, 'Speciestrain = ''%s'';\n', speciesStrain);
fprintf(f, 'Age = %s; %% unit: days\n', num2str(animalAge));
fprintf(f, 'gender = ''%s'';\n', gender);
fprintf(f, 'transgenicLine = ''%s'';\n', transgenicLine);

fprintf(f, ['%% ************* Slice info *****************%%' '\n']);  
fprintf(f, 'sliceTime = ''%s'';\n', sliceTime);
fprintf(f, 'sliceType = ''%s'';\n', sliceType);
fprintf(f, 'temp = %s; %%unit: C\n', num2str(temp));

fprintf(f, ['%% ************* Other info *****************%%' '\n']);  
fprintf(f, 'otherField = ''%s'';\n',otherField );
fprintf(f, 'otherValue = ''%s'';\n', otherValue);

fprintf(f, ['%% ************* In utero electroporation  ***************%%' '\n']);  
fprintf(f, 'inUlteroElectroporation = %s; %% 1 means checked (N/A), 0 means unchecked.\n',num2str(inUtero));
fprintf(f, 'targetCells = ''%s'';\n', targetCells);
fprintf(f, 'construct = ''%s'';\n', construct);

fprintf(f, ['%% ************* Treatment info *****************%%' '\n']);  
fprintf(f, 'treatment = %s; %% 1 means checked (N/A), 0 means unchecked.\n',num2str(treatment));
fprintf(f, 'whatTreatment = ''%s'';\n', whatTreatment);

fprintf(f, ['%% ************* Viral injection *****************%%' '\n']);  
fprintf(f, 'viralInjection = %s; %% 1 means checked (N/A), 0 means unchecked.\n',num2str(vi));
fprintf(f, 'virusAge = %s; %% unit: days\n', num2str(virusAge));
fprintf(f, 'construct_vi = ''%s'';\n', construct_vi);
fprintf(f, 'virus = ''%s'';\n', virus);
fprintf(f, 'location = ''%s'';\n', location);

fprintf(f, ['%% ************* Cell info ******************%%' '\n']);  

if saveCell1
fprintf(f, '%% ********** cell #1 *********%%\n');
fprintf(f, 'brainArea1 = ''%s'';\n', brainArea1);
fprintf(f, 'region1 = ''%s'';\n', region1);
fprintf(f, 'subregion1 = ''%s'';\n', subregion1);
fprintf(f, 'cellType1 = ''%s'';\n',  cellType1);
fprintf(f, 'somaZ1 = %s; %%unit: um\n', num2str(somaZ1));
fprintf(f, 'vRest1 = %s; %%unit: mV\n', num2str(vRest1));
end

if saveCell2
    fprintf(f, '%% ********** cell #2 *********%%\n');
    fprintf(f, 'brainArea2 = ''%s'';\n', brainArea2);
    fprintf(f, 'region2 = ''%s'';\n', region2);
    fprintf(f, 'subregion2 = ''%s'';\n', subregion2);
    fprintf(f, 'cellType2 = ''%s'';\n',  cellType2);
    fprintf(f, 'somaZ2 = %s; %%unit: um\n', num2str(somaZ2));
    fprintf(f, 'vRest2 = %s; %%unit: mV\n', num2str(vRest2));
end

if saveCell3
fprintf(f, '%% ********** cell #3 *********%%\n');
fprintf(f, 'brainArea3 = ''%s'';\n', brainArea3);
fprintf(f, 'region3 = ''%s'';\n', region3);
fprintf(f, 'subregion3 = ''%s'';\n', subregion3);
fprintf(f, 'cellType3 = ''%s'';\n',  cellType3);
fprintf(f, 'somaZ3 = %s; %%unit: um\n', num2str(somaZ3));
fprintf(f, 'vRest3 = %s; %%unit: mV\n', num2str(vRest3));
end

if saveCell4
fprintf(f, '%% ********** cell #4 *********%%\n');
fprintf(f, 'brainArea4 = ''%s'';\n', brainArea4);
fprintf(f, 'region4 = ''%s'';\n', region4);
fprintf(f, 'subregion4 = ''%s'';\n', subregion4);
fprintf(f, 'cellType4 = ''%s'';\n',  cellType4);
fprintf(f, 'somaZ4 = %s; %%unit: um\n', num2str(somaZ4));
fprintf(f, 'vRest4 = %s; %%unit: mV\n', num2str(vRest4));
end

fprintf(f, ['%% ************* Intracellular solution *****************%%' '\n']);  
fprintf(f, 'intracellularSolutionType = ''%s'';\n', intracellularSolutionType);
fprintf(f, 'intracellularSolutionDrugs = ''%s'';\n', intracellularSolutionDrugs);

fprintf(f, ['%% ************* Bath solution *****************%%' '\n']);  
fprintf(f, 'bathSolutionType = ''%s'';\n', bathSolutionType);
fprintf(f, 'bathSolutionDrugs = ''%s'';\n', bathSolutionDrugs);

fclose(f);
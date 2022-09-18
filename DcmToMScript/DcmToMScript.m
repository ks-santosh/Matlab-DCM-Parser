%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input : DCM File
%
% Functionality : m-script with the variables data that can be loaded in
% the workspace
%
% Output : Creates m file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function DcmToMScript()
    warning('off','all');
    
    cprintf('key', '#############  DCM to M-Script #############\n');
        
    cprintf('-> Select DCM\n');
    [DcmFile, DcmFilePath] = uigetfile('*.dcm', 'Select DCM');
    DcmFilePath = fullfile(DcmFilePath,DcmFile);
    if isequal(DcmFile,0)
       cprintf('err','-> No DCM Selected\n');
       cprintf('key', '#############  Closed DCM to M-Script #############\n');
       return
    else
       fprintf('-> DCM selected : <a href="matlab: edit(''%s'')">%s</a>\n', DcmFilePath, DcmFile);
    end
    
    MScriptName = strsplit(DcmFile, '.');
    MScriptName = [MScriptName{1} , '.m'];
    MScriptPath = [pwd '\' MScriptName];
    MScriptFile = fopen(MScriptPath,'w');
    fprintf(MScriptFile,'%s\r\n \r\n', ['%%' DcmFile 'to M Script']);
    
    DcmVarMap = DcmParser(DcmFilePath);
    DcmVars = DcmVarMap('Order'); 
    
    for i = 2:length(DcmVars) % Excluding Start
        VarName = DcmVars{i};
        VarData = DcmVarMap(VarName);
        VarType = VarData{1};
        
        VarDataVal = VarData(end);
        
        switch(VarType)

            case 'FESTWERT'
                VarValueText = strjoin([VarName '= single(' VarDataVal ');'], ' ');
            
            case {'STUETZSTELLENVERTEILUNG', 'FESTWERTEBLOCK', 'GRUPPENKENNLINIE', 'GRUPPENKENNFELD'}
              
                VarValueText = strjoin(VarDataVal{1});
                VarValueText = [VarName ' = single([' VarValueText ']);'];
                            
            otherwise
                cprintf('err', '-> %s : Invalid Variable Type %s! Skipped.\n', Var, VarType);
                continue;
        end
        
        
        fprintf(MScriptFile,'%s\r\n', VarValueText);

    end
    fclose(MScriptFile);
    fprintf('-> Created M-Script <a href = "matlab: edit(''%s'')">%s</a>\n', MScriptPath, MScriptName);
    fprintf('-> Load <a href = "matlab: run(''%s'')">%s</a> to workspace\n', MScriptPath, MScriptName);
    cprintf('*comment', '-> Successfully Converted DCM to M-Script\n');
    cprintf('key', '############# DCM to M-Script End #############\n');
end

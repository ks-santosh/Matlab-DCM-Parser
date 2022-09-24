%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input : Map created from DcmParser.m
%         Output Dcm file path
%         Output Dcm File Name
%
% Functionality : Writes the DCM data from map to DcmName at DcmPath
%                 
% Output : (DcmName).DCM file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function MapToDcm(DcmVarMap,DcmPath,DcmName)
     
    if(nargin == 3)
        DcmFilePath = strcat(DcmPath,'\',DcmName);
    else
		% Default DCM file name
		DcmFilePath = 'MapToDcm.DCM';
		DcmName = 'MapToDcm.DCM';
	end
	
    DcmVar = DcmVarMap('Order');
    
    fprintf('START\n-> Creating DCM %s ...\n', DcmName);
    
    VarNum = length(DcmVar);
    DcmFile = fopen(DcmFilePath,'w');
    
    StartText = DcmVarMap('Start');
    for i=1:length(StartText)
        fprintf(DcmFile,'%s\r\n',StartText{i});
    end
    fprintf(DcmFile,'\r\n');
    
    for i=2:VarNum
        VarName = DcmVar{i};
        try
            VarData = DcmVarMap(VarName);
            DcmText = VarDataToDcmText(VarName,VarData);
        catch
            fprintf('-> Error in reading DCM Variable %s. Skipped!\n', VarName);
            continue;
        end
        
        DcmTextLines = length(DcmText);
        for j = 1:DcmTextLines
            if(strcmp(DcmText{j},'NA')==1)
                continue;
            end
            fprintf(DcmFile,'%s\r\n',DcmText{j});
        end
        fprintf(DcmFile,'\r\n');
    end
    fclose(DcmFile);
    fprintf('-> Successfully created %s!\n', DcmName);
    fprintf('END \n');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input : DCM File
%
% Functionality : Creates seperate DCM files for each FUNKTION
%
% Output : DCM Files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SplitDcm()
    
   
    cprintf('key', '#############  Split DCM #############\n');
    warning('off','all');
    mkdir Functional_DCMs
    
    cprintf('-> Select Project DCM\n');
    [DcmFile, DcmFilePath] = uigetfile('*.dcm', 'Select Project DCM');
    DcmFilePath = fullfile(DcmFilePath,DcmFile);
    if isequal(DcmFile,0)
       cprintf('err','-> No DCM Selected\n');
       cprintf('key', '#############  Closed DCM Split #############\n');
       return
    else
       fprintf('-> Project DCM selected : <a href="matlab: edit(''%s'')">%s</a>\n', DcmFilePath, DcmFile);
    end
    
    DcmVarMap = DcmParser(DcmFilePath);

    %% Get the variable list of both DCMs
    DcmVars = DcmVarMap.keys;

    DcmNumVars = length(DcmVars);

    FuncList = cell(10000,1);

    DcmFuncArr = cell(10000,1);
    DcmFuncVarMap = containers.Map();
    DcmFuncVarNumMap = containers.Map();

    %% Get function list
    k = 1;
    for i = 1:DcmNumVars
        Var = DcmVars{i};
        VarData = DcmVarMap(Var);
    
        VarType = VarData{1};
    
        FuncName = '';
    
        switch(VarType)

            case 'FESTWERT'
                FuncName = VarData(4);

            case 'STUETZSTELLENVERTEILUNG'
                FuncName = VarData(5);

            case 'FESTWERTEBLOCK'
                FuncName = VarData(5);

            case 'GRUPPENKENNLINIE'
                FuncName = VarData(5);

            case 'GRUPPENKENNFELD'
                FuncName = VarData(6);

            case 'Order'
                continue;

            case 'Start'
                continue;
            otherwise
                if(~strcmp(Var, 'Start'))
                    cprintf('err', '-> %s : has invalid parameter type %s! Skipped reading.\n', Var, VarType);
                end
                continue;
        end
    
        FuncName = FuncName{1};
    
        if length(FuncName) > 1
            FuncList{k} = FuncName;
            k = k + 1;
        else
            cprintf('err', '-> %s : No Function Name %s! Skipped reading.\n', Var, VarType);
        end
    
    % if function is not there in list
        if isKey(DcmFuncVarNumMap,FuncName) == 0
            DcmFuncVarNumMap(FuncName) = 2;
            DcmFuncVarMap(FuncName) = cell(1000,1);
            FuncVarList = DcmFuncVarMap(FuncName);
            FuncVarList{1} = 'Start';
            FuncVarList{2} = Var;
            DcmFuncVarMap(FuncName) = FuncVarList;
        else
            VarPos = DcmFuncVarNumMap(FuncName);
            DcmFuncVarNumMap(FuncName) = VarPos + 1;
            FuncVarList = DcmFuncVarMap(FuncName);
            FuncVarList{VarPos + 1} = Var;
            DcmFuncVarMap(FuncName) = FuncVarList;
        end
    
    end

    FuncList = DcmFuncVarNumMap.keys;
    NumFunc = length(FuncList);

    for i = 1:NumFunc
        FuncName = FuncList{i};
        Len = DcmFuncVarNumMap(FuncName);
        FuncVarList = DcmFuncVarMap(FuncName);
        FuncVarList = FuncVarList(1:Len);
        DcmFuncVarMap(FuncName) = FuncVarList;

        IndvDcmVarMap = containers.Map(DcmVarMap.keys,DcmVarMap.values);
        IndvDcmVarMap('Start') = {'KONSERVIERUNG_FORMAT 2.0'};
        IndvDcmVarMap('Order') = FuncVarList;

        FuncDcmName = [FuncName , '.DCM'];
        DcmFolderPath = [pwd '\Functional_DCMs'];
        try
            MapToDcm(IndvDcmVarMap, DcmFolderPath, FuncDcmName);
            FuncDcmPath = [DcmFolderPath '\' FuncDcmName];
            fprintf('-> Created <a href="matlab: winopen(''%s'')">%s</a>\n', FuncDcmPath, FuncDcmName);
        catch
            cprintf('err', '-> Unable to create %s\n', FuncDcmName);
        end
    end
    
    fprintf('-> Functional DCMs Kept here: <a href="matlab: winopen(''%s'')">DCM Files</a>\n', DcmFolderPath)
    cprintf('*comment', '-> Successfully Created Functional DCMs \n');
    cprintf('key', '#############  Split DCM End #############\n');
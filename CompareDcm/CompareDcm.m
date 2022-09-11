%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input : DCM Files to be compared
%
% Functionality : Compares two DCMs and stores the result in Excel
%
% Output : DcmComparisonRecord.xls
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CompareDcm()
    
    recordpath = [pwd '\DcmComparisonRecord.xls'];
    
    cprintf('key', '#############  DCM Comparison #############\n');
    warning('off','all');
    delete('DcmComparisonRecord.xls');
    
    cprintf('-> Select First DCM\n');
    [DcmFile1, DcmFilePath1] = uigetfile('*.dcm', 'Select First DCM');
    DcmFilePath1 = fullfile(DcmFilePath1,DcmFile1);
    if isequal(DcmFile1,0)
       cprintf('err','-> No DCM Selected\n');
       cprintf('key', '#############  Closed DCM Comparison #############\n');
       return
    else
       fprintf('-> DCM selected : <a href="matlab: edit(''%s'')">%s</a>\n', DcmFilePath1, DcmFile1);
    end
    fprintf('-> Select Second DCM\n');
    [DcmFile2, DcmFilePath2] = uigetfile('*.dcm', 'Select Second DCM');
    DcmFilePath2 = fullfile(DcmFilePath2,DcmFile2);
    if isequal(DcmFile2,0)
       cprintf('err', '-> No DCM Selected\n');
       cprintf('key', '#############  Closed DCM Comparison #############\n');
       return
    else
       fprintf('-> DCM selected : <a href="matlab: edit(''%s'')">%s</a>\n', DcmFilePath2, DcmFile2);
    end

    DcmVarDic1 = DcmParser(DcmFilePath1);
    DcmVarDic2 = DcmParser(DcmFilePath2);

    %% Get the variable list of both DCMs
    DcmVars1 = DcmVarDic1.keys;
    DcmVars2 = DcmVarDic2.keys;

    cprintf('*comment', '-> Starting DCM Comparison...\n')
    %% Variables in DCM 1 that are not in DCM 2
    DcmVarIn1Not2 = setdiff(DcmVars1, DcmVars2);
    if(isempty(DcmVarIn1Not2) == 1)
        DcmVarIn1Not2 = {'NA'};
    end
    %% Variables in DCM 2 that are not in DCM 1
    DcmVarIn2Not1 = setdiff(DcmVars2, DcmVars1);
    if(isempty(DcmVarIn2Not1) == 1)
        DcmVarIn2Not1 = {'NA'};
    end
    %% Variables in both DCMs
    DcmComVars = intersect(DcmVars1, DcmVars2);
    idxOrder = strcmp(DcmComVars, 'Order');
    DcmComVars(idxOrder) = [];
    idxStart = strcmp(DcmComVars, 'Start');
    DcmComVars(idxStart) = [];

    %% For common variables check if the data is same
    ComVarLen = length(DcmComVars);
    VarNotEqlArr = cell(10000,1);%cell(10000,3);
    VarNotEqlCount = 0;

    for i = 1:ComVarLen
        Var = DcmComVars{i};

        VarData1 = DcmVarDic1(Var);
        VarData2 = DcmVarDic2(Var);

        VarType = VarData1{1};

        switch(VarType)

            case 'FESTWERT'
                VarDataVal1 = VarData1(end);
                VarDataVal2 = VarData2(end);

            case 'STUETZSTELLENVERTEILUNG'
                VarDataVal1 = VarData1(end);
                VarDataVal2 = VarData2(end);

            case 'FESTWERTEBLOCK'
                VarDataVal1 = VarData1(end);
                VarDataVal2 = VarData2(end);

            case 'GRUPPENKENNLINIE'
                VarDataVal1 = VarData1(end-1:end);
                VarDataVal2 = VarData2(end-1:end);

            case 'GRUPPENKENNFELD'
                VarDataVal1 = VarData1(end-2:end);
                VarDataVal2 = VarData2(end-2:end);

            otherwise
                cprintf('err', '-> %s : Invalid Variable Type %s! Skipped.\n', Var, VarType);
                continue;
        end

        if(~isequal(VarDataVal1, VarDataVal2))
            VarNotEqlCount = VarNotEqlCount + 1;
            VarNotEqlArr{VarNotEqlCount,1} = Var;
            %VarNotEqlArr{VarNotEqlCount,2} = VarData1(end);
            %VarNotEqlArr{VarNotEqlCount,3} = VarData2(end);

        end
    end
    
    fprintf('-> Creating Excel DCM Mismatch Records in Current Folder...\n')
    
    VarNotEqlArr = VarNotEqlArr(1:VarNotEqlCount);
    
    if(isempty(VarNotEqlArr) == 1)
        VarNotEqlArr = {'NA'};
    end
    
    DcmVarIn1Not2Table = cell2table(DcmVarIn1Not2', 'VariableNames', {'Parameters'});
    DcmVarIn2Not1Table = cell2table(DcmVarIn2Not1', 'VariableNames', {'Parameters'});
    VarNotEqlArrTable = cell2table(VarNotEqlArr, 'VariableNames', {'Parameters'});
    
    SheetName1 = ['Added in ' DcmFile1(1:min(22,length(DcmFile1)))];
    SheetName2 = ['Added in ' DcmFile2(1:min(22,length(DcmFile2)))];
    try
        writetable(DcmVarIn1Not2Table, 'DcmComparisonRecord.xls', 'Sheet' , SheetName1);
    catch
        writetable(DcmVarIn1Not2Table, 'DcmComparisonRecord.xls', 'Sheet' , 'Added in First DCM');
    end
    try
        writetable(DcmVarIn2Not1Table, 'DcmComparisonRecord.xls', 'Sheet' , SheetName2);
    catch
        writetable(DcmVarIn1Not2Table, 'DcmComparisonRecord.xls', 'Sheet' , 'Added in Second DCM');
    end
    writetable(VarNotEqlArrTable, 'DcmComparisonRecord.xls', 'Sheet' , 'Modified');
   
    fprintf('-> Records written to : <a href="matlab: winopen(''%s'')">DcmComparisonRecord.xls</a>\n', recordpath);
    
    cprintf('*comment', '-> DCM Comparison Successfull!\n')
    cprintf('key', '#############  DCM Comparison End #############\n');
    warning('on','all');
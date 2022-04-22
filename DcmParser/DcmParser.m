%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input : Path of DCM File (String)
%
% Functionality : Reads DCM file and makes a map of variable names and
%                 its details
%
% Output : Map container of DCM Variables and its data 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [DcmVarMap] = DcmParser(DcmPath)
    
    DcmName = strsplit(DcmPath, '\');
    DcmName = DcmName{end};
    
    DcmFile = fopen(DcmPath,'r');
    DcmLine = '0';
    DcmStartText = cell(1,500);
    DcmVarArr = cell(1,10000);
    DcmVarDataArr = cell(1,10000);
    count = 1; % Number of variables in DCM file
    TextLine = 1; % Number of Text Lines in the start

    %% Read the DCM file
    % Read the starting comments of the DCM
    
    % DCMs may not use END keyword after the metadata
    % flag variable is to detect that condition
    flag = 0;
    KeyWord = '';
    fprintf('START\n-> Reading %s ...\n', DcmName);
    while(ischar(DcmLine))
        DcmLine = fgetl(DcmFile);
        DcmStartText(TextLine) = {DcmLine};
        TextLine = TextLine + 1;
        if(strcmp(DcmLine,'END'))
            break;
        end
        DcmContent = strsplit(DcmLine,' ');
        KeyWord = DcmContent(1);
        if(strcmp(KeyWord,'FESTWERT') || strcmp(KeyWord,'STUETZSTELLENVERTEILUNG')|| ...
            strcmp(KeyWord,'GRUPPENKENNLINIE') || strcmp(KeyWord,'GRUPPENKENNFELD') || strcmp(KeyWord,'FESTWERTEBLOCK'))
            flag = 1;
            break;
        end
    end
    DcmStartText = DcmStartText(1:TextLine-1-flag);
    
    % Read the variables defination in the DCM
    while ischar(DcmLine) % Process Line by Line
        if(flag == 0)
            DcmLine = fgetl(DcmFile);
            if(~ischar(DcmLine))
                continue;
            end
            DcmContent = strsplit(DcmLine,' ');
        
            if(length(DcmContent) < 2)
                continue;
            end
            KeyWord = DcmContent(1);
        else
            flag = 0;
        end
        
%% Parameter Read
        % Parameter
        % FESTWERT <name>
        % WERT <value>
        % END
        if(strcmp(KeyWord, 'FESTWERT'))
            DcmVarArr(count) = DcmContent(2);   % Storing Parameter Name
            
            DcmVarDesc = 'NA';
            DcmVarDisp = 'NA';
            DcmVarFunc = 'NA';
            DcmVarUnit = 'NA';

            while(true)
                ODcmLine = fgetl(DcmFile);
                DcmLine = regexprep(ODcmLine,' +',' ');
                DcmLine = strtrim(DcmLine);
                KeyDetail = strsplit(DcmLine);
                KeyDetail = KeyDetail{1};
                
                switch(KeyDetail)
                    case 'LANGNAME'                        
                        DcmVarDesc = GetStr(ODcmLine,1);
                    case 'DISPLAYNAME'
                        DcmVarDisp = GetStr(DcmLine,0);
                    case 'FUNKTION'
                        DcmVarFunc = GetStr(DcmLine,0);
                    case 'EINHEIT_W'
                        DcmVarUnit = GetStr(DcmLine,1);
                    case 'WERT'
                         break;
                    otherwise
                        break;
                end
            end
            
            DcmContent = strsplit(DcmLine,'WERT ');    
            DcmVarValue = DcmContent(2);         % Parameter Value

            VarData = {'FESTWERT',DcmVarDesc,DcmVarDisp,DcmVarFunc,DcmVarUnit,DcmVarValue{1}};
            DcmVarDataArr(count) = {VarData};
            count = count + 1;

%% Read Distribution
        % Distribution
        % Format:
        % STUETZSTELLENVERTEILUNG <name> <size_x>
        % ST/X <sample point list>1
        % END
        elseif(strcmp(KeyWord, 'STUETZSTELLENVERTEILUNG'))
            DcmVarArr(count) = DcmContent(2);   % Storing Group Name
            VarSize = str2double(DcmContent(3)); % size of the group
            
            DcmVarDesc = 'NA';
            DcmVarDisp = 'NA';
            DcmVarFunc = 'NA';
            DcmVarUnitX = 'NA';

            while(true)
                ODcmLine = fgetl(DcmFile);
                DcmLine = regexprep(ODcmLine,' +',' ');
                DcmLine = strtrim(DcmLine);
                KeyDetail = strsplit(DcmLine);
                KeyDetail = KeyDetail{1};
                
                switch(KeyDetail)
                    case 'LANGNAME'                        
                        DcmVarDesc = GetStr(ODcmLine,1);
                    case 'DISPLAYNAME'
                        DcmVarDisp = GetStr(DcmLine,0);
                    case 'FUNKTION'
                        DcmVarFunc = GetStr(DcmLine,0);
                    case 'EINHEIT_X'
                        DcmVarUnitX = GetStr(DcmLine,1);
                    case '*SST'
                        continue;
                    case 'ST/X'
                         break;
                    otherwise
                        break;
                end
            end

            ValueLines = ceil(VarSize/6);      % one line has 6 values
            XAxisArr = cell(1,1000);
            ValCount = 0;
            for i=1:ValueLines                  % Start Reading X Values
                DcmLine = regexprep(DcmLine,' +',' ');
                DcmLine = strtrim(DcmLine);
                DcmContent = strsplit(DcmLine,' ');
                DcmValues = DcmContent(2:end)';
                len = length(DcmValues);
                XAxisArr(ValCount+1:ValCount + len) = DcmValues; 
                ValCount = ValCount + len;
                DcmLine = fgetl(DcmFile);           % next line
            end
            XAxisArr = XAxisArr(1:VarSize);

            VarData = {'STUETZSTELLENVERTEILUNG',VarSize,DcmVarDesc,DcmVarDisp,DcmVarFunc,DcmVarUnitX,XAxisArr};
            DcmVarDataArr(count) = {VarData};
            count = count + 1;

%% Parameter Array Read
        % Parameter Array
        % Format:
        % array ::= FESTWERTEBLOCK <name> <size_x>
        % LANGNAME "<comment text>"
        % EINHEIT_W "<unit text>"
        % WERT <value list>6
        % END
        elseif(strcmp(KeyWord, 'FESTWERTEBLOCK'))
            DcmVarArr(count) = DcmContent(2);   % Storing Group Name
            VarSize = str2double(DcmContent(3)); % size of the group
            
            DcmVarDesc = 'NA';
            DcmVarDisp = 'NA';
            DcmVarFunc = 'NA';
            DcmVarUnitX = 'NA';

            while(true)
                ODcmLine = fgetl(DcmFile);
                DcmLine = regexprep(ODcmLine,' +',' ');
                DcmLine = strtrim(DcmLine);
                KeyDetail = strsplit(DcmLine);
                KeyDetail = KeyDetail{1};
                
                switch(KeyDetail)
                    case 'LANGNAME'                        
                        DcmVarDesc = GetStr(ODcmLine,1);
                    case 'DISPLAYNAME'
                        DcmVarDisp = GetStr(DcmLine,0);
                    case 'FUNKTION'
                        DcmVarFunc = GetStr(DcmLine,0);
                    case 'EINHEIT_W'
                        DcmVarUnitW = GetStr(DcmLine,1);
                    case '*SST'
                        continue;
                    case 'WERT'
                         break;
                    otherwise
                        break;
                end
            end

            ValueLines = ceil(VarSize/6);      % one line has 6 values
            WAxisArr = cell(1,1000);
            ValCount = 0;
            for i=1:ValueLines                  % Start Reading X Values
                DcmLine = regexprep(DcmLine,' +',' ');
                DcmLine = strtrim(DcmLine);
                DcmContent = strsplit(DcmLine,' ');
                DcmValues = DcmContent(2:end)';
                len = length(DcmValues);
                WAxisArr(ValCount+1:ValCount + len) = DcmValues; 
                ValCount = ValCount + len;
                DcmLine = fgetl(DcmFile);           % next line
            end
            WAxisArr = WAxisArr(1:VarSize);

            VarData = {'FESTWERTEBLOCK',VarSize,DcmVarDesc,DcmVarDisp,DcmVarFunc,DcmVarUnitW,WAxisArr};
            DcmVarDataArr(count) = {VarData};
            count = count + 1;
            
%% Group Read   
        % Group Char Line
        % Format:
        % group char. line::=GRUPPENKENNLINIE <name> <size_x>
        % *SSTX <X distribution>
        % ST/X <X sample point list>
        % WERT <value list>
        % END
        elseif(strcmp(KeyWord, 'GRUPPENKENNLINIE'))
            DcmVarArr(count) = DcmContent(2);   % Storing Group Name
            VarSize = str2double(DcmContent(3)); % size of the group
            
            DcmVarDesc = 'NA';
            DcmVarDisp = 'NA';
            DcmVarFunc = 'NA';
            DcmVarUnitX = 'NA';
            DcmVarUnitW = 'NA';
            DcmVarDistName = 'NA';

           while(true)
                ODcmLine = fgetl(DcmFile);
                DcmLine = regexprep(ODcmLine,' +',' ');
                DcmLine = strtrim(DcmLine);
                KeyDetail = strsplit(DcmLine);
                KeyDetail = KeyDetail{1};
                
                switch(KeyDetail)
                    case 'LANGNAME'                        
                        DcmVarDesc = GetStr(ODcmLine,1);
                    case 'DISPLAYNAME'
                        DcmVarDisp = GetStr(DcmLine,0);
                    case 'FUNKTION'
                        DcmVarFunc = GetStr(DcmLine,0);
                    case 'EINHEIT_X'
                        DcmVarUnitX = GetStr(DcmLine,1);
                    case 'EINHEIT_W'
                        DcmVarUnitW = GetStr(DcmLine,1);
                    case '*SSTX'
                        DcmVarDistName = GetStr(DcmLine,0);
                    case 'ST/X'
                         break;
                    otherwise
                        break;
                end
            end
            
           
            ValueLines = ceil(VarSize/6);      % one line has 6 values
            XAxisArr = cell(1,1000);
            WAxisArr = cell(1,1000);
            ValCount = 0;
            for i=1:ValueLines                  % Start Reading X Values
                DcmLine = regexprep(DcmLine,' +',' ');
                DcmLine = strtrim(DcmLine);
                DcmContent = strsplit(DcmLine,' ');
                DcmValues = DcmContent(2:end)';
                len = length(DcmValues);
                XAxisArr(ValCount+1:ValCount + len) = DcmValues; 
                ValCount = ValCount + len;
                DcmLine = fgetl(DcmFile);           % next line
            end
            ValCount = 0;
            for i=1:ValueLines                  % Start Reading Y Values
                DcmLine = regexprep(DcmLine,' +',' ');
                DcmLine = strtrim(DcmLine);
                DcmContent = strsplit(DcmLine,' ');
                DcmValues = DcmContent(2:end)';
                len = length(DcmValues);
                WAxisArr(ValCount+1:ValCount + len) = DcmValues; 
                ValCount = ValCount + len;
                DcmLine = fgetl(DcmFile);           % next line
            end
            XAxisArr = XAxisArr(1:VarSize);
            WAxisArr = WAxisArr(1:VarSize);

            VarData = {'GRUPPENKENNLINIE',VarSize,DcmVarDesc,DcmVarDisp,DcmVarFunc,DcmVarUnitX,DcmVarUnitW,DcmVarDistName,XAxisArr,WAxisArr};
            DcmVarDataArr(count) = {VarData};
            count = count + 1;
            
%% Map Read
        % group char map
        % Format
        % GRUPPENKENNFELD <name> <size_x> <size_y>
        % *SSTX <X distribution>
        % *SSTY <Y distribution>
        % ST/X <X sample point list>
        % ST/Y <Y sample point>
        % WERT <value list>
        % ...
        % END

        elseif(strcmp(KeyWord, 'GRUPPENKENNFELD'))
            DcmVarArr(count) = DcmContent(2);   % Storing Map Name
            VarSizeX = str2double(DcmContent(3)); % size of X sample points 
            VarSizeY = str2double(DcmContent(4)); % size of Y sample points
           
            DcmVarDesc = 'NA';
            DcmVarDisp = 'NA';
            DcmVarFunc = 'NA';
            DcmVarUnitX = 'NA';
            DcmVarUnitY = 'NA';
            DcmVarUnitW = 'NA';
            DcmVarDisXName = 'NA';
            DcmVarDisYName = 'NA';

            while(true)
                ODcmLine = fgetl(DcmFile);
                DcmLine = regexprep(ODcmLine,' +',' ');
                DcmLine = strtrim(DcmLine);
                KeyDetail = strsplit(DcmLine);
                KeyDetail = KeyDetail{1};
                switch(KeyDetail)
                    case 'LANGNAME'                        
                        DcmVarDesc = GetStr(ODcmLine,1);
                    case 'DISPLAYNAME'
                        DcmVarDisp = GetStr(DcmLine,0);
                    case 'FUNKTION'
                        DcmVarFunc = GetStr(DcmLine,0);
                    case 'EINHEIT_X'
                        DcmVarUnitX = GetStr(DcmLine,1);
                    case 'EINHEIT_Y'
                        DcmVarUnitY = GetStr(DcmLine,1);
                    case 'EINHEIT_W'
                        DcmVarUnitW = GetStr(DcmLine,1);
                    case '*SSTX'
                        DcmVarDisXName = GetStr(DcmLine,0);
                    case '*SSTY'
                        DcmVarDisYName = GetStr(DcmLine,0);
                    case 'ST/X'
                         break;
                    otherwise
                        break;
                end
           end
            
            XLines = ceil(VarSizeX/6);          % one line has 6 values
            XAxisArr = cell(1,1000);
            ValCount = 0;
            for i=1:XLines                      % Start Reading X Values
                DcmLine = regexprep(DcmLine,' +',' ');
                DcmLine = strtrim(DcmLine);
                DcmContent = strsplit(DcmLine,' ');
                DcmValues = DcmContent(2:end)';
                len = length(DcmValues);
                XAxisArr(ValCount+1:ValCount + len) = DcmValues; 
                ValCount = ValCount + len;
                DcmLine = fgetl(DcmFile); 
            end

            YLines = VarSizeY;          % one line has 1 value
            YAxisArr = cell(1,1000);
            WAxisArr = cell(1000,1000);
            ValCountY = 1;
            for i=1:YLines                  % Start Reading Y Values
                DcmLine = regexprep(DcmLine,' +',' ');
                DcmLine = strtrim(DcmLine);
                DcmContent = strsplit(DcmLine,' ');
                DcmValues = DcmContent(2);
                YAxisArr(ValCountY) = DcmValues; 

                ValCountW = 0;
                for j=1:XLines
                    DcmLine = fgetl(DcmFile);
                    DcmLine = regexprep(DcmLine,' +',' ');
                    DcmLine = strtrim(DcmLine);
                    DcmContent = strsplit(DcmLine,' ');
                    DcmValues = DcmContent(2:end)';
                    len = length(DcmValues);
                    WAxisArr(ValCountY, ValCountW+1:ValCountW + len) = DcmValues; 
                    ValCountW = ValCountW + len;
                end
                ValCountY = ValCountY + 1;
                DcmLine = fgetl(DcmFile); 
            end

            XAxisArr = XAxisArr(1:VarSizeX);
            YAxisArr = YAxisArr(1:VarSizeY);
            WAxisArr = WAxisArr(1:VarSizeY,1:VarSizeX);

            VarData = {'GRUPPENKENNFELD',VarSizeX,VarSizeY,DcmVarDesc,DcmVarDisp,DcmVarFunc,DcmVarUnitX,DcmVarUnitY,DcmVarUnitW,DcmVarDisXName,DcmVarDisYName,XAxisArr,YAxisArr,WAxisArr};
            DcmVarDataArr(count) = {VarData};
            count = count + 1;

        else
            continue;
        end

    end % DCM File End Reached
    DcmVarArr = DcmVarArr(1:count-1);
    DcmVarDataArr = DcmVarDataArr(1:count-1);
    DcmVarMap = containers.Map(DcmVarArr,DcmVarDataArr);
    DcmVarMap('Start') = DcmStartText; % DCM metadata
    DcmVarMap('Order') = ['Start',DcmVarArr]; % Variables in order
    fprintf('-> Successfully parsed DCM!\n');
    fprintf('-> Number of variables read: %d\n',count-1);
    fprintf('END \n');
    fclose(DcmFile);
end
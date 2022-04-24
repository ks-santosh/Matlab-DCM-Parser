%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input : Dcm Variable Data
%         Dcm Variable Name
% 
% Functionality : Creates the DCM formatted text
%                 
% Output : cell array of DCM formatted text of the variable details
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [DcmVarDataText] = VarDataToDcmText(DcmVarName,DcmVarData)

    DcmVarType = DcmVarData{1};
    DcmVarDataText = cell(100,1);
    
    %% Parameter
    if(strcmp(DcmVarType,'FESTWERT'))

        VarName = DcmVarName;
        VarDisc = DcmVarData{2};
        VarDisp = DcmVarData{3};
        VarFunc = DcmVarData{4};
        VarUnit = DcmVarData{5};
        VarValue = DcmVarData{6};

        DcmVarDataText{1} = ['FESTWERT',' ',VarName,' '];
        DcmVarDataText{2} = ['   LANGNAME ','"',VarDisc,'"'];
        if(strcmp(VarDisp,'NA') == false)
            DcmVarDataText{3} = ['   DISPLAYNAME ',VarDisp];
        else
            DcmVarDataText{3} = 'NA';
        end
        if(strcmp(VarFunc,'NA') == false)
            DcmVarDataText{4} = ['   FUNKTION ',VarFunc,' '];
        else
            DcmVarDataText{4} = 'NA';
        end
        DcmVarDataText{5} = ['   EINHEIT_W ','"',VarUnit,'"'];
        DcmVarDataText{6} = ['   WERT ',VarValue];
        DcmVarDataText{7} = 'END';
        DcmVarDataText = DcmVarDataText(1:7);
    
    %% Group Line
    elseif(strcmp(DcmVarType,'GRUPPENKENNLINIE'))
        VarName = DcmVarName;
        VarSize = DcmVarData{2};
        VarDisc = DcmVarData{3};
        VarDisp = DcmVarData{4};
        VarFunc = DcmVarData{5};
        VarUnitX = DcmVarData{6};
        VarUnitW = DcmVarData{7};
        VarDistX = DcmVarData{8};
        VarValueX = DcmVarData{9};
        VarValueW = DcmVarData{10};

        DcmVarDataText{1} = ['GRUPPENKENNLINIE ',VarName,' ',num2str(VarSize)];
        DcmVarDataText{2} = ['   LANGNAME ','"',VarDisc,'"'];
        if(strcmp(VarDisp,'NA') == false)
            DcmVarDataText{3} = ['   DISPLAYNAME ',VarDisp];
        else
            DcmVarDataText{3} = 'NA';
        end
        if(strcmp(VarFunc,'NA') == false)
            DcmVarDataText{4} = ['   FUNKTION ',VarFunc,' '];
        else
            DcmVarDataText{4} = 'NA';
        end
        DcmVarDataText{5} = ['   EINHEIT_X ','"',VarUnitX,'"'];
        DcmVarDataText{6} = ['   EINHEIT_W ','"',VarUnitW,'"'];
        DcmVarDataText{7} = ['*SSTX	',VarDistX];
        Lines = ceil(VarSize/6);
        VarValueX = ReshapeSix(VarValueX);
        VarValueW = ReshapeSix(VarValueW);
        pos = 8;
        for i = 1:Lines % Start X Values
            Xtext = strjoin(['   ST/X',VarValueX{i},''],'   ');
            DcmVarDataText{pos} = [Xtext,'   '];
            pos = pos + 1;
        end
        for i = 1:Lines % Start W Values
            Wtext = strjoin(['   WERT',VarValueW{i},''],'   ');
            DcmVarDataText{pos} = [Wtext,'   '];
            pos = pos + 1;
        end
        DcmVarDataText{pos} = 'END';
        DcmVarDataText = DcmVarDataText(1:pos);
        
    %% Group Map
    elseif(strcmp(DcmVarType,'GRUPPENKENNFELD'))
        VarName = DcmVarName;
        VarSizeX = DcmVarData{2};
        VarSizeY = DcmVarData{3};
        VarDisc = DcmVarData{4};
        VarDisp = DcmVarData{5};
        VarFunc = DcmVarData{6};
        VarUnitX = DcmVarData{7};
        VarUnitY = DcmVarData{8};
        VarUnitW = DcmVarData{9};
        VarDistX = DcmVarData{10};
        VarDistY = DcmVarData{11};
        VarValueX = DcmVarData{12};
        VarValueY = DcmVarData{13};
        VarValueW = DcmVarData{14};

        DcmVarDataText{1} = ['GRUPPENKENNFELD ',VarName,' ',num2str(VarSizeX),' ',num2str(VarSizeY)];
        DcmVarDataText{2} = ['   LANGNAME ','"',VarDisc,'"'];
        if(strcmp(VarDisp,'NA') == false)
            DcmVarDataText{3} = ['   DISPLAYNAME ',VarDisp];
        else
            DcmVarDataText{3} = 'NA';
        end
        if(strcmp(VarFunc,'NA') == false)
            DcmVarDataText{4} = ['   FUNKTION ',VarFunc,' '];
        else
            DcmVarDataText{4} = 'NA';
        end
        DcmVarDataText{5} = ['   EINHEIT_X ','"',VarUnitX,'"'];
        DcmVarDataText{6} = ['   EINHEIT_Y ','"',VarUnitY,'"'];
        DcmVarDataText{7} = ['   EINHEIT_W ','"',VarUnitW,'"'];
        DcmVarDataText{8} = ['*SSTX	',VarDistX];
        DcmVarDataText{9} = ['*SSTY	',VarDistY];

        Lines = ceil(VarSizeX/6);
        VarValueX = ReshapeSix(VarValueX);
        pos = 10;
        for i = 1:Lines % Start X Values
            Xtext = strjoin(['   ST/X',VarValueX{i},''],'   ');
            DcmVarDataText{pos} = [Xtext, '   '];
            pos = pos + 1;
        end
        for i = 1:VarSizeY
            Ytext = ['   ST/Y   ',VarValueY{i}];
            DcmVarDataText{pos} = Ytext;
            pos = pos + 1;
            VarValueWRow = ReshapeSix(VarValueW(i,:));
            for j = 1:Lines % Start W Values            
                Wtext = strjoin(['   WERT',VarValueWRow{j},''],'   ');
                DcmVarDataText{pos} = [Wtext, '   '];
                pos = pos + 1;
            end
        end
        DcmVarDataText{pos} = 'END';
        DcmVarDataText = DcmVarDataText(1:pos);
        
    %% Distribution
    elseif(strcmp(DcmVarType,'STUETZSTELLENVERTEILUNG'))
        VarName = DcmVarName;
        VarSize = DcmVarData{2};
        VarDisc = DcmVarData{3};
        VarDisp = DcmVarData{4};
        VarFunc = DcmVarData{5};
        VarUnitX = DcmVarData{6};
        VarValueX = DcmVarData{7};

        DcmVarDataText{1} = ['STUETZSTELLENVERTEILUNG ',VarName,' ',num2str(VarSize)];
        if(strcmp(VarDisc,'NA') == false)
            DcmVarDataText{2} = '*SST';
            DcmVarDataText{3} = ['   LANGNAME ','"',VarDisc,'"'];
        else
            DcmVarDataText{2} = 'NA';
            DcmVarDataText{3} = 'NA';
        end
        if(strcmp(VarDisp,'NA') == false)
            DcmVarDataText{4} = ['   DISPLAYNAME ',VarDisp];
        else
            DcmVarDataText{4} = 'NA';
        end
        if(strcmp(VarFunc,'NA') == false)
            DcmVarDataText{5} = ['   FUNKTION ',VarFunc,' '];
        else
            DcmVarDataText{5} = 'NA';
        end
        
        DcmVarDataText{6} = ['   EINHEIT_X ','"',VarUnitX,'"'];
        Lines = ceil(VarSize/6);
        VarValueX = ReshapeSix(VarValueX);
        pos = 7;
        for i = 1:Lines % Start X Values
            Xtext = strjoin(['   ST/X',VarValueX{i},''],'   ');
            DcmVarDataText{pos} = [Xtext, '   '];
            pos = pos + 1;
        end
        DcmVarDataText{pos} = 'END';
        DcmVarDataText = DcmVarDataText(1:pos);    
        
    %% Parameter Array 
    elseif(strcmp(DcmVarType,'FESTWERTEBLOCK'))
        VarName = DcmVarName;
        VarSize = DcmVarData{2};
        VarDisc = DcmVarData{3};
        VarDisp = DcmVarData{4};
        VarFunc = DcmVarData{5};
        VarUnitW = DcmVarData{6};
        VarValueW = DcmVarData{7};

        DcmVarDataText{1} = ['FESTWERTEBLOCK ',VarName,' ',num2str(VarSize)];
        DcmVarDataText{2} = ['   LANGNAME ','"',VarDisc,'"'];
        if(strcmp(VarDisp,'NA') == false)
            DcmVarDataText{3} = ['   DISPLAYNAME ',VarDisp];
        else
            DcmVarDataText{3} = 'NA';
        end
        if(strcmp(VarFunc,'NA') == false)
            DcmVarDataText{4} = ['   FUNKTION ',VarFunc,' '];
        else
            DcmVarDataText{4} = 'NA';
        end
        
        DcmVarDataText{5} = ['   EINHEIT_W ','"',VarUnitW,'"'];
        Lines = ceil(VarSize/6);
        VarValueW = ReshapeSix(VarValueW);
        pos = 6;
        for i = 1:Lines % Start X Values
            Wtext = strjoin(['   WERT',VarValueW{i},''],'   ');
            DcmVarDataText{pos} = [Wtext, '   '];
            pos = pos + 1;
        end
        DcmVarDataText{pos} = 'END';
        DcmVarDataText = DcmVarDataText(1:pos);    
    else
        fprintf('-> Error in Writing: Unknown datatype %s of DCM Variable %s. \n', DcmVarType, DcmVarName);
        fprintf('-> %s Writing is skipped.\n',DcmVarName);
    end
    
end % End Function VarDataToDcmText
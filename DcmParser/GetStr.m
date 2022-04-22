%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input : Line - String to be parsed
%         isQ - boolean (1 for "" quoated text, 0 otherwise)
% 
% Functionality : The Line is data like LANGNAME, FUNCNAME. GetStr returns
% the value assigned to these headers. 
% 
% Output : String
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [StrQuote] = GetStr(Line, isQ)
    if isQ == 1
        inquotes = strfind(Line,'"');
        if(isempty(inquotes))
            StrQuote = 'NA';
        else
            StrQuote = Line(inquotes(1)+1:inquotes(end)-1);
        end
    else
        Line = regexprep(Line, '\t', ' ');
        StrQuote = strsplit(Line,' ');
        StrQuote = StrQuote{2};
    end
end
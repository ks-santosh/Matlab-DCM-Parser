%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input :  Numeric 1D array
%
% Functionality : Splits the array into arrays of 6 elements (columns) 
%
% Output : Numeric array of cells of 1D arrays
%
% Example : [1 2 3 4 5 6 7 8 9] -> {[1 2 3 4 5 6]}
%                                  {[7 8 9]}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ReshapedSix] = ReshapeSix(InputArr)

    ArrSize = length(InputArr);
    Lines = ceil(ArrSize/6);
    ReshapedSix = cell(Lines,1);
   
    for i = 1:Lines-1
        ReshapedSix{i} = InputArr(6*i-5:i*6);
    end
    ReshapedSix{Lines} = InputArr(Lines*6-5:end);
end
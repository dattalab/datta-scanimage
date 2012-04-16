%  - 
%
% SYNTAX
%
% NOTES
%
% CHANGES
%  TO081507C: Vectorize, to support multiple objects simultaneously. -- Tim O'Connor 8/15/07
%
% Created
%  Timothy O'Connor 7/30/07
%
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function bool = eq(this, other)

if length(this) > 1 && length(other) > 1 && length(this) ~= length(other)
    error('Array dimension mismatch. Scalar values, equal length arrays, or a scalar value and array are supported.');
end

bool = zeros(max(length(this), length(other)), 1);%Assume they are not equal.
for i = 1 : length(this)
    for j = 1 : length(other)
        if (this(i).NIMEX_TaskDefinition == other(j).NIMEX_TaskDefinition)
            bool(i + j - 1) = 1;
        end
    end
end

return;
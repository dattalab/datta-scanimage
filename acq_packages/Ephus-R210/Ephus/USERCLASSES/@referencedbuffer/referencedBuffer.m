% REFERENCEDBUFFER - A pointer to a vector/matrix of data.
%
% SYNTAX
%  buff = referencedBuffer(array)
%   array - Any vector or matrix.
%
% USAGE
%  Once constructed the pointer may be used like any normal array variable. It will just allow pass-by-reference.
%
% STRUCTURE
%  
%
% NOTES:
%
% CHANGES:
%
% Created 11/24/04 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function this = referencedBuffer(varargin)
global referencedBuffers;

if isempty(referencedBuffers)
    referencedBuffers(1).map = [];
end

if isempty(varargin)
    data = [];
else
    data = varargin{1};
end

pointer = max(referencedBuffers(:, 1)) + 1;
referencedBuffers(1).map(size(referencedBuffers(1).map, 1) + 1) = pointer;
referencedBuffers(1).map(size(referencedBuffers(1).map, 1)) = length(referencedBuffers) + 1;

referencedBuffers(pointer) = data;

this = class(this, 'referencedBuffer');

return;
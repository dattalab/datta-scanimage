% @handleWrapper/handleWrapper - An object that can act exactly like a handle, but also allow for augmentation of functionality.
%
%  SYNTAX
%   hw = handleWrapper(handle)
%    handle - Any valid handle.
%    hw - A handleWraper instance.
%
%  NOTES
%   This is mostly useful for debugging. It would have been really nice if the @progmanager had been based
%   around this class, as was initially discussed, because it would vastly simplify the code and usability.
%   It is, more or less, too late to make such a drastic change now (it was, effectively, too late by the time
%   the @progmanager class was "done"). As far as I know, there was no reason for not doing it this way, just
%   misunderstanding.
%
%  CHANGES
%
% Created 12/7/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function this = handleWrapper(handle)

this.hObject = handle;
this = class(this, 'handleWrapper');

fprintf(1, '@handleWrapper: ''%s'' = %3.12f\n', get(handle, 'Tag'), handle);

return;
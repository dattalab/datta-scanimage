function  varargout = get(this, varargin)
global globalDumbampObjects;

for i = 1 : length(varargin)
    if ~isfield(globalDumbampObjects(this.ptr), varargin{i})
        varargout{i} = get(this.amplifier, varargin{i});
    else
        varargout{i} = globalDumbampObjects(this.ptr).(varargin{i});
    end
end

return;
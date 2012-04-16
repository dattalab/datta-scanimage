function  set(this, varargin)
global globalDumbampObjects;

for i = 1 : 2 : length(varargin)
    if ~isfield(globalDumbampObjects(this.ptr), varargin{i})
        set(this.amplifier, varargin{i}, varargin{i + 1});
    else
        globalDumbampObjects(this.ptr).(varargin{i}) = varargin{i + 1};
        if strcmpi(varargin{i}, 'outputName')
            setVComChannelName(this.amplifier, varargin{i + 1});
        elseif strcmpi(varargin{i}, 'inputName')
            setScaledOutputChannelName(this.amplifier, varargin{i + 1});
        end
    end
end

return;
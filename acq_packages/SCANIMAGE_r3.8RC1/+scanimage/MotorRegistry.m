classdef MotorRegistry
    
    methods (Static)
        
        function info = getControllerInfo(type)
            assert(ischar(type),'''type'' must be a stage controller type.');
            m = scanimage.MotorRegistry.controllerMap;
            if m.isKey(type)
                info = m(type);
            else
                info = [];
            end
        end
        
    end
    
    properties (Constant,GetAccess=private)
        controllerMap = zlclInitControllerMap();
    end
    
    methods (Access=private)
        function obj = MotorRegistry()
        end      
    end            
    
end

function m = zlclInitControllerMap

m = containers.Map();

s = struct();
s.Names = {'mp285';'sutter.mp285'};
s.Class = 'dabs.sutter.MP285';
s.SubType = '';
s.TwoStep.Enable = true; 
s.TwoStep.FastLSCPropVals = struct('resolutionMode','coarse');
s.TwoStep.SlowLSCPropVals = struct('resolutionMode','fine');
s.SafeReset = true;
zlclAddMotor(m,s);

s = struct();
s.Names = {'scientifica'};
s.Class = 'dabs.scientifica.LinearStageController';
s.SubType = '';
s.TwoStep.Enable = true;
s.TwoStep.FastLSCPropVals = struct(); %Velocity is switched between fast/slow, but determined programatically for each stage type
s.TwoStep.SlowLSCPropVals = struct(); %Velocity is switched between fast/slow, but determined programatically for each stage type
s.SafeReset = false;
zlclAddMotor(m,s);

s = struct();
s.Names = {'pi.e816'};
s.Class = 'dabs.pi.LinearStageController';
s.SubType = 'e816';
s.TwoStep.Enable = false; 
s.SafeReset = false;
zlclAddMotor(m,s);

s = struct();
s.Names = {'dummy'};
s.Class = 'dabs.dummies.DummyLSC';
s.SubType = '';
s.TwoStep.Enable = false; 
s.SafeReset = true;
zlclAddMotor(m,s);

% m('mp285') = 'dabs.sutter.MP285';
% m('mpc200') = 'dabs.sutter.MPC200';
% m('sutter.mp285') = 'dabs.sutter.MP285';
% m('sutter.mpc200') = 'dabs.sutter.MPC200';
% m('scientifica') = 'dabs.scientifica.LinearStageController';
% m('pi.e816') = {'scanimage.Adapters.PI.MotionController','e816'};
% m('pi.e665') = {'scanimage.Adapters.PI.MotionController','e816'};
% m('pi.e517') = {'scanimage.Adapters.PI.MotionController','e517'};
% m('pi.e753') = {'scanimage.Adapters.PI.MotionController','e753'};
% m('pi.e712') = {'scanimage.Adapters.PI.MotionController','e712'};
% m('dummy') = 'dabs.dummies.DummyLSC';

% switch lower(motorControllerType)
%     case {'mp285' 'sutter.mp285'}
%         hMotor.twoStepMoveEnable = true;
%         speedResolutionModes = struct('fast','coarse','slow','fine');
%         speedMoveModes = [];
%         speedSlowVelocityFactor = [];
%     case 'scientifica'
%         hMotor.twoStepMoveEnable = true;
%         speedResolutionModes = [];
%         speedMoveModes = [];
%         speedSlowVelocityFactor = 8;
%     case {'mpc200' 'sutter.mpc200' 'dummy'}
%         hMotor.twoStepMoveEnable = false;
%         speedResolutionModes = [];
%         speedMoveModes = struct('fast','accelerated','slow','accelerated');
%         speedSlowVelocityFactor = 8;
%     otherwise
%         hMotor.twoStepMoveEnable = false;
%         speedResolutionModes = [];
%         speedMoveModes = [];
%         speedSlowVelocityFactor = [];
% end

end

function zlclAddMotor(m,s)
names = s.Names;
for c = 1:length(names)
    m(names{c}) = s;
end
end

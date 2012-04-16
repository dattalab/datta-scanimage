% SIGNAL/private/setDefaultsByType - Essentially zeros out the unused fields in this object's instance.
%
% SYNTAX
%  setDefaultsByType(SIGNAL)
%
%  This function can be used for the constructor's initialization, as well as cleaning up if the type gets changed.
%
% CHANGES
%  Added the squarePulseTrain type, to simply port over the parameters from the original Physiology software. -- Tim O'Connor 5/2/05 TO050205A
%  Check for an empty 'type' field. -- Tim O'Connor 8/10/05 TO081005D
%
% Created 8/22/04 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function t = setDefaultsByType(this)
global signalobjects;

pointer = indexOf(this);

%Should this count as an update?
signalobjects(pointer).updated = 1;

%TO081005D: This'll choke the switch if it's empty.
if isempty(signalobjects(pointer).type)
    resetLiteral(pointer);
    resetRecursive(pointer);
    resetPeriodic(pointer);
    resetEquational(pointer);
    resetDistribution(pointer);
    resetFunctional(pointer);
    resetFunctionalWithArgs(pointer);
    resetSquarePulseTrain(pointer);
    return;
end

switch lower(signalobjects(pointer).type)
    case ''
        resetLiteral(pointer);
        resetRecursive(pointer);
        resetPeriodic(pointer);
        resetEquational(pointer);
        resetDistribution(pointer);
        resetFunctional(pointer);
        resetFunctionalWithArgs(pointer);
        resetSquarePulseTrain(pointer);

    case 'analytic'
        resetLiteral(pointer);        
        resetRecursive(pointer);
        if ~signalobjects(pointer).periodic
            resetPeriodic(pointer);
        end
        if ~signalobjects(pointer).equational
            resetEquational(pointer);
        end
        if ~signalobjects(pointer).distributional
            resetDistribution(pointer);
        end
        resetFunctional(pointer);
        resetFunctionalWithArgs(pointer);
        resetSquarePulseTrain(pointer);

    case 'literal'
        resetRecursive(pointer);
        resetPeriodic(pointer);
        resetEquational(pointer);
        resetDistribution(pointer);
        resetFunctional(pointer);
        resetFunctionalWithArgs(pointer);
        resetSquarePulseTrain(pointer);

    case 'functional'
        resetLiteral(pointer);
        resetRecursive(pointer);
        resetPeriodic(pointer);
        resetEquational(pointer);
        resetDistribution(pointer);
        resetFunctionalWithArgs(pointer);
        resetSquarePulseTrain(pointer);

    case 'functionalwithargs'
        resetLiteral(pointer);
        resetRecursive(pointer);
        resetPeriodic(pointer);
        resetEquational(pointer);
        resetDistribution(pointer);
        resetFunctional(pointer);
        resetSquarePulseTrain(pointer);

    case 'recursive'
        resetLiteral(pointer);
        resetPeriodic(pointer);
        resetEquational(pointer);
        resetDistribution(pointer);
        resetFunctional(pointer);
        resetFunctionalWithArgs(pointer);
        resetSquarePulseTrain(pointer);

    case 'squarepulsetrain'
        resetRecursive(pointer);
        resetLiteral(pointer);
        resetPeriodic(pointer);
        resetEquational(pointer);
        resetDistribution(pointer);
        resetFunctional(pointer);
        resetFunctionalWithArgs(pointer);
        
    otherwise
        error('Unrecognized type for @signal object ''%s'': %s', signalobjects(pointer).name, signalobjects(pointer).type);
end

%---------------------------------------------------------------
function resetLiteral(pointer)
global signalobjects;

signalobjects(pointer).signal = [];

return;

%---------------------------------------------------------------
function resetRecursive(pointer)
global signalobjects;

%Recursion - Complex signals (additive or multiplicative or concatenational).
signalobjects(pointer).children = [];
signalobjects(pointer).parents = [];
signalobjects(pointer).signalPhaseShift = [];
signalobjects(pointer).method = '';

return;

%---------------------------------------------------------------
function resetPeriodic(pointer)
global signalobjects;

signalobjects(pointer).periodic = 0;
signalobjects(pointer).amplitude = 0;
signalobjects(pointer).offset = 0;
signalobjects(pointer).phi = 0;
signalobjects(pointer).symmetry = 0;
signalobjects(pointer).waveform = '';
signalobjects(pointer).frequency = 0;

return;

%---------------------------------------------------------------
function resetEquational(pointer)
global signalobjects;

signalobjects(pointer).equational = 0;
signalobjects(pointer).equation = '';

return;

%---------------------------------------------------------------
function resetDistribution(pointer)
global signalobjects;

signalobjects(pointer).distributional = 0;
signalobjects(pointer).distribution = '';
%The meaning of these arguments depends on the distribution.
%For example, in a 'gaussian' distribution, arg1 is the mean, arg2 is the variance, and arg3 is ignored.
%A number of distributions depend only on arg1 (ie. 'poisson'), in which case arg2 (or greater) is ignored.
signalobjects(pointer).arg1 = 0;
signalobjects(pointer).arg2 = 1;
signalobjects(pointer).arg3 = 0;

return;

%---------------------------------------------------------------
function resetFunctional(pointer)
global signalobjects;

signalobjects(pointer).fcn = {};

return;

%---------------------------------------------------------------
function resetFunctionalWithArgs(pointer)
global signalobjects;

signalobjects(pointer).fcnTakesArgs = {};

return;

%---------------------------------------------------------------
function resetSquarePulseTrain(pointer)
global signalobjects;

%TO050205A - Classic Physiology square pulse definitions.
signalobjects(pointer).squarePulseTrainNumber = 0;
signalobjects(pointer).squarePulseTrainISI = 0;
signalobjects(pointer).squarePulseTrainWidth = 0;
signalobjects(pointer).amplitude = 0;
signalobjects(pointer).offset = 0;
signalobjects(pointer).squarePulseTrainDelay = 0;

return;
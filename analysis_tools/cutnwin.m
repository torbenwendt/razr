function [ir, win] = cutnwin(ir, parameters, is_sec)
% CUTNWIN - Apply signal cutting and windowing (Hann flanks) on impulse response.
% 
% Usage:
%   [ir, win] = CUTNWIN(ir, parameters, is_sec)
% 
% Input:
%   ir              RIR structure (see RAZR)
%   parameters      = [shift, attack, sustain, decay]. Windowing as sketched below:
%                                  ____________
%                                 /            \
%                                /              \
%                               /                \
%                   ___________/                  \
%                     shift  attack   sustain  decay
% 
%                   ... where the 'shift' part is cut away from the output signal.
%   is_sec          Set true, if 'parameters' are specified in seconds (false, if samples)
% 
% Output:
%   ir              Updated ir structure
%   win             Window which was appled

%------------------------------------------------------------------------------
% RAZR engine for Mathwork's MATLAB
%
% Version 0.90
%
% Author(s): Torben Wendt
%
% Copyright (c) 2014-2016, Torben Wendt, Steven van de Par, Stephan Ewert,
% Universitaet Oldenburg.
%
% This work is licensed under the
% Creative Commons Attribution-NonCommercial-NoDerivs 4.0 International
% License (CC BY-NC-ND 4.0).
% To view a copy of this license, visit
% http://creativecommons.org/licenses/by-nc-nd/4.0/ or send a letter to
% Creative Commons, 444 Castro Street, Suite 900, Mountain View, California,
% 94041, USA.
%------------------------------------------------------------------------------



if nargin == 3 && is_sec
	parameters = round(parameters*ir.fs);	% sec2samples
end

if length(parameters) ~= 4
	error('parameters must have 4 components.');
end
if any(parameters < 0)
    error('parameters must be non-negative.');
end

shift      = parameters(1);
attacklen  = parameters(2);
sustainlen = parameters(3);
decaylen   = parameters(4);

attackwin = hannwin(2*attacklen);
decaywin  = hannwin(2*decaylen);

win = [attackwin(1:attacklen); ones(sustainlen,1); decaywin(decaylen+1:end)];
winlen = attacklen + sustainlen + decaylen;


flds = {'sig', 'sig_direct', 'sig_early', 'sig_late'};
num = length(flds);

% cut and window:
for n = 1:num
    if isfield(ir, flds{n})
        ir.(flds{n}) = ...
            ir.(flds{n})((shift + 1):(shift + winlen), :).*repmat(win, 1, size(ir.(flds{n}), 2));
    end
end

if isfield(ir, 'start_spl')
    ir.start_spl = max([ir.start_spl - shift, 1]);
end

win = [zeros(shift,1); win];

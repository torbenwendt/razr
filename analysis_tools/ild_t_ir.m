function [ild_out, t] = ild_t_ir(ir, framelen, ramplen, is_sec)
% ILD_T_IR - Gateway function for ILD_T using the ir structure as input
%
% Usage:
%   [ild_out, t] = ILD_T_IR(ir, framelen, ramplen, is_sec)
%
% Input:
%   ir          RIR structure (see RAZR)
%   framelen    Frame length in samples
%   ramplen     Half of window length in samples
%               (signals will be faded in and out by hann ramps with full overlap).
%               If ramplen is an odd value, it will subtracted by 1 in order to obtain
%               equal lengths of in- and out-fading ramps
%	is_sec      Set true, if framelen and ramplen are specified in seconds
%
% Output:
%   ild_out     Vector containing ild values for each time frame
%               (positive values indicate higher energy to the right)
%   t           Vector containing time frames (seconds)
%
% See also: ILD, ILD_T

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



% check and treat input parameters:
if nargin < 4
    is_sec = true;
end
if ramplen > framelen/2
    error('ramplen must be lower that framelen/2');
end

% sec to spl:
if is_sec
    framelen = round(framelen*ir.fs);
    ramplen  = floor(ramplen*ir.fs/2)*2;		% floor to the nearest even number
end

ild_out = ild_t(ir.sig, framelen, ramplen);

t = (0:size(ild_out,1)-1)'*framelen/ir.fs;


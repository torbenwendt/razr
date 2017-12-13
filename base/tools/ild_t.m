function ild_out = ild_t(sig, framelen, ramplen)
% ILD_T - Time dependent interaural level difference
%
% Usage:
%	ild_out = ILD_T(sig, framelen, ramplen)
%
% Input:
%	sig			Signal matrix (size = len x 2)
%	framelen	Frame length in samples
%	ramplen		Half of window length in samples
%				(signals will be faded in and out by hann ramps with full overlap).
%				If ramplen is an odd value, it will subtracted by 1 in order to obtain
%				equal lengths of in- and out-fading ramps
%
% Output:
%	ild_out		Vector containing ild values for each time frame
%				(positive values indicate higher energy to the right)
%
% See also: ILD, ILD_T_IR

%------------------------------------------------------------------------------
% RAZR engine for Mathwork's MATLAB
%
% Version 0.93
%
% Author(s): Torben Wendt
%
% Copyright (c) 2014-2017, Torben Wendt, Steven van de Par, Stephan Ewert,
% University Oldenburg, Germany.
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
if ramplen > framelen/2
    error('ramplen must be lower that framelen/2');
end

sig_buf = hannbuf(sig, framelen, ramplen);

% calculate energy:
ergL = 10*log10(sum(squeeze(sig_buf(1, :, :)).^2, 1));
ergR = 10*log10(sum(squeeze(sig_buf(2, :, :)).^2, 1));

ild_out = (ergR - ergL).';

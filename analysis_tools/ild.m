function out = ild(ir, upperbound)
% ILD - Interaural level difference of BRIR
%
% Usage:
%   out = ILD(ir, upperbound)
%
% Input:
%   ir          RIR structure (see RAZR)
%   upperbound	Upper time limit in sec. (optional; default: BRIR length)
%
% Output:
%	out         ILD; positive, if level of right channel is larger
%
% See also: ILD_T_IR, ILD_T

%------------------------------------------------------------------------------
% RAZR engine for Mathwork's MATLAB
%
% Version 0.92
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


% check input parameters and convers upperbound to samples:
if nargin < 2
    upperbound = size(ir.sig, 1);
else
    upperbound = floor(upperbound*ir.fs);
end

sig = ir.sig(1:upperbound,:);
erg = 10*log10(sum(sig.^2, 1));
out = erg(2) - erg(1);

function atten = distce_atten(distce)
% DISTCE_ATTEN - "1/distance" attenuation factor with transition to constant 1 for small distances.
%
% Usage:
%   atten = DISTCE_ATTEN(distce)
%
% Input:
%   distce      Source-receiver distances in meters
%
% Output:
%   atten       Attenuation factors

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


distc_shift = 0;  % in meters
fadeConst = 0.9./(1 + exp(4*(distce + distc_shift - 1)));
fadeHyperb = 1./(1 + exp(4*(1 - distce + distc_shift)));
atten = min(fadeHyperb./(distce + distc_shift) + fadeConst, 1);

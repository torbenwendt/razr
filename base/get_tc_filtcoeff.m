function [b, a] = get_tc_filtcoeff
% GET_TC_FILTCOEFF - Get filter coefficients for global RIR tone correction
%
% Usage:
%   [b, a] = GET_TC_FILTCOEFF

%------------------------------------------------------------------------------
% RAZR engine for Mathwork's MATLAB
%
% Version 0.91
%
% Author(s): Nico Goessling
%
% Copyright (c) 2014-2017, Torben Wendt, Steven van de Par, Stephan Ewert,
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


b = 1;
a = [1 -0.3];

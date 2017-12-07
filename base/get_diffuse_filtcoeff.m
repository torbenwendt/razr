% GET_DIFFUSE_FILTCOEFF - Calculation of the filter coefficients for diffuse reflections (Shelving
% Method)
%
% Usage:
%   [bDiff, aDiff] = GET_DIFFUSE_FILTCOEFF(room, op)
%
% Input:
%   room            room structure (see RAZR)
%   op              options structure (see RAZR)
%
% Output:
%   bDiff, aDiff    filter coefficients for diffuse reflections as cell
%                   array (row = wall index, column = IS order)
%   bSpec, aSpec    filter coefficients for corresponding low-pass

%------------------------------------------------------------------------------
% RAZR engine for Mathwork's MATLAB
%
% Version 0.92
%
% Author(s): Nico Goessling, Torben Wendt
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

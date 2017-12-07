function [out, varargin_cell] = extract_args(argnames, defaults, varargin_cell)
% extract_args - Called within a function, varargin is translated to a struct containing custom
% input parameters.
%
% Usage:
%   [out, varargin] = extract_args(argnames, defaults, varargin_cell)
%
% Input:
%   argnames        Names of arguments to be parsed after
%   defaults        Respective default values
%
% Output:
%   out             Struct with fieldnames equal to argnames and fields equal to either args or
%                   defaults.
%   varargin_cell   varargin with removed argnames and defaults.
%
% Example usage within a function:
%
% -----------------------------------------------------------------------
% function myfunc(some_input, varargin)
%
% % define some input parameters (names and defaults):
% argnames = {'in1', 'in2'};
% defaults = {441, 'hello'};
%
% [myargs_struct, varargin] = extract_args(argnames, defaults, varargin);
% -----------------------------------------------------------------------
%
% If this function is now called by
%
% >> myfunc(some_input, 'in2', 'goodbye', 'further_arg1', 'further2')
%
% within this function the variable myargs_struct will be:
% myargs_struct = 
%   in1: 441
%   in2: 'goodbye'
%
% and varargin will be:
% varargin =
%   'further_arg1'   'further2'
%
% I.e. elements of varargin that are specified by argnames and defaults will be removed from
% varargin, all others will remain.

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


for n = 1:length(argnames)
    idx = find(strcmp(varargin_cell, argnames{n}));
    if ~isempty(idx)
        out.(argnames{n}) = varargin_cell{idx + 1};
        varargin_cell([idx, idx + 1]) = [];
    else
        out.(argnames{n}) = defaults{n};
    end
end

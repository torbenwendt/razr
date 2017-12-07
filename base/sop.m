function sop(pattern)
% SOP - Search option names. Displays all options whose names match a given pattern
%
% Usage:
%   SOP pattern
%
% Input:
%   pattern     Search pattern (regular expression, not case-sensitive)
%               If empty, a dialog asks whether all options shall be displayed.
%
% See also: GET_DEFAULT_OPTIONS, SMAT, SGREP

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


if nargin == 0
    pattern = '';
end

filename = 'get_default_options.m';
ignore_char = '%';

if isempty(pattern)
    disp_all = input('Display all options (Y/n)? ', 's');
    if isempty(disp_all)
        disp_all = 'y';
    end
    disp_all = strcmpi(disp_all, 'y');
    
    if ~disp_all
        return;
    end
else
    disp_all = false;
end

if disp_all
    pattern = '.';
end

sgrep(filename, pattern, ignore_char);

function sop(pattern)
% SOP - Search option names. Displays all available options whose names match a
% given pattern. This tool might be helpful, e.g., if you do not remember the
% exact name of an option.
%
% Usage:
%   SOP pattern
%
% Input:
%   pattern     Search pattern (regular expression, not case-sensitive)
%               If empty, a dialog asks whether all options shall be displayed.
%
% Example:
%   Search for options whose names contain "return":
%   >> sop return
%
%   op.return_rir_parts = 0;    % Return ir.sig_direct, ir.sig_early and ir.sig_late?
%   op.return_ism_data = 0;     % Return geometric data of ISM?
%   op.return_ism_sigmat = 0;   % Return monaural ISM output (one image source per matrix channel)?
%   op.return_op = 0;           % Return applied options structure (as additional field of ir)?
%   op.fdn_return_mc_output = 0;    % Return the multichannel FDN output? (Field ir.sig_late_mc)
%
% Known issues:
%   Only that line of the original file that contains the matching pattern will
%   be displayed. If an option description spans multiple lines, also only the
%   first line will be displayed.
%
% See also: GET_DEFAULT_OPTIONS, SMAT, SGREP

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


if nargin == 0
    pattern = '';
end

filename = 'get_default_options.m';
ignore_char = '%';

if isempty(pattern)
    inpt = input('Display all options (Y/n)? ', 's');
    if isempty(inpt)
        inpt = 'y';
    end
    disp_all = strcmpi(inpt, 'y');
    
    if ~disp_all
        return;
    end
else
    disp_all = false;
end

if disp_all
    pattern = 'op';  % will be found in each line that contains an option
end

do_boldface = ~disp_all;

sgrep(filename, pattern, ignore_char, do_boldface);

function col = brir_colors
% brir_colors - Unified colors for BRIR plotting.
%
% Usage:
%   col = brir_colors
%
% Output:
%   col     Struct containing RGB color vectors for plotting the direct, early and late BRIR parts.
%

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
% Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
% License (CC BY-NC-SA 4.0).
% To view a copy of this license, visit
% http://creativecommons.org/licenses/by-nc-nd/4.0/ or send a letter to
% Creative Commons, 444 Castro Street, Suite 900, Mountain View, California,
% 94041, USA.
%------------------------------------------------------------------------------


col.direct_L  = [0.4, 0.7, 0.3];
col.direct_R  = [0.2, 0.45, 0.2];
col.direct    = col.direct_L;
col.direct_LR = [col.direct_L; col.direct_R];

col.early_L  = [1.0, 0.4, 0.2];      % orange
col.early_R  = [0.6, 0.2, 0.2];      % dark red
col.early    = col.early_L;
col.early_LR = [col.early_L; col.early_R];

col.late_L   = [0.4, 0.5, 1.0];      % light blue
col.late_R   = [0.2, 0.2, 0.6];      % dark blue
col.late     = col.late_L;
col.late_LR  = [col.late_L; col.late_R];

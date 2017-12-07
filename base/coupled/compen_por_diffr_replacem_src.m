function por_compen = compen_por_diffr_replacem_src(room, op, isd)
% COMPEN_POR_DIFFR_REPLACEM_SRC - Get amplitude compensation factors for image sources which would
% occour for a receiver at that point returned by GET_DIFFR_REPLACEM_POINT.
%
% Usage:
%   por_compen = compen_por_diffr_replacem_src(room, op, isd)

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


% Torben Wendt
% 2016-02-02


room.recpos = get_diffr_replacem_point(room, 1);

ism_setup.do_diffraction = 0;
ism_setup.do_val_check = 0;
isd_replacem = scale_is_pattern(isd.pattern, room, op, ism_setup, 0);

por_compen = (isd_replacem.por./isd.por)';

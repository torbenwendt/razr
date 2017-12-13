function [room_rec, room_ngb] = prepare_rooms(room_rec, room_ngb, rec_src_same_room)

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


if ~isfield(room_ngb, 'srcpos') || isempty(room_ngb.srcpos)
    room_ngb.srcpos = room_rec.srcpos + room_rec.origin;
end

if ~isfield(room_rec, 'srcpos') || isempty(room_rec.srcpos)
    room_rec.srcpos = room_ngb.srcpos - room_rec.origin;
end

room_ngb.recpos = room_rec.recpos + room_rec.origin;
room_ngb.recdir = room_rec.recdir;

room_rec.recpos = pos_cheat(room_rec, room_rec.recpos);
room_ngb.recpos = pos_cheat(room_ngb, room_ngb.recpos);

if rec_src_same_room
    % place src inside ngb-room in order to get some image sources more easily:
    room_ngb.srcpos_orig = room_ngb.srcpos;
    [dpos_ngb, dcntr_ngb] = doorpos(room_ngb);
    room_ngb.srcpos = dcntr_ngb;
    room_ngb.srcpos = pos_cheat(room_ngb, room_ngb.srcpos);
end

end


function pos = pos_cheat(room, pos)
% cheat on recpos or srcpos to avoid undesired behaviour (aperture_distce_atten,
% get_diffraction_points)

rec_on_wall_neg = pos == 0;
rec_on_wall_pos = pos == room.boxsize;
shift = zeros(1, 3);
shift(rec_on_wall_neg) = 0.0001;
shift(rec_on_wall_pos) = -0.0001;
pos = pos + shift;

end

function out = spatialize(inmat, setup, op)
% SPATIALIZE - Spatial rendering of a signal matrix
%
% Usage:
%   out = SPATIALIZE(inmat, setup, op)
%
% Input:
%   inmat   Input signal matrix
%   setup   Structure whose required fields depend on spatialization mode:
%           - spat_mode:  'shm' (spherical head model), 'hrtf', 'diotic', 'ild',
%                         'array' (loudspeaker array)
%           - azim, elev: Azimuth and elevation angles for binaural rendering
%           - lrscale:    Scaling factors for ILDs
%           - relpos:     Loudspeaker positions, relative to listener, in
%                         cartesian coordinates; for loudspeaker rendering
%   op      Options structure (see RAZR)
%
% Output:
%   out     Spatialized signal

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


switch setup.spat_mode
    case 'shm'
        outmat_l = hsfilterMod(...
            setup.azim, setup.elev,  90, op.shm_warpMethod, op.fs, inmat);
        outmat_r = hsfilterMod(...
            setup.azim, setup.elev, -90, op.shm_warpMethod, op.fs, inmat);
        
        out = [sum(outmat_l, 2), sum(outmat_r, 2)];
        
    case 'hrtf'
        [outmat_l, outmat_r] = apply_hrtf(op.hrtf_dbase, inmat, ...
            setup.azim, setup.elev, op.fs, op.hrtf_options);
        
        out = [sum(outmat_l, 2), sum(outmat_r, 2)];
        
    case 'diotic'
        out = repmat(sum(inmat, 2), 1, 2);
        
    case 'ild'
        outmat_l = zeros(size(inmat));
        outmat_r = outmat_l;
        
        for ch = 1:size(inmat, 2)
            outmat_l(:, ch) = setup.lrscale(ch, 1)*inmat(:, ch);
            outmat_r(:, ch) = setup.lrscale(ch, 2)*inmat(:, ch);
        end
        
        out = [sum(outmat_l, 2), sum(outmat_r, 2)];
        
    case 'maplr1'      % full mapping to channels left/right, round scaling factors to [0, 1, 2]
        idxl = logical(round(setup.lrscale(:, 1)));
        idxr = logical(round(setup.lrscale(:, 2)));
        
        out = 2*[sum(inmat(:, idxl), 2), sum(inmat(:, idxr), 2)];
        
    case 'maplr2'      % full mapping to channels left/right, round scaling factors to [0, 2]
        idxl = logical(round(setup.lrscale(:, 1)/2));
        idxr = logical(round(setup.lrscale(:, 2)/2));
        
        out = 2*[sum(inmat(:, idxl), 2), sum(inmat(:, idxr), 2)];
        
    case '1stOrdAmb'      % first order ambisonics panning
        out = zeros(size(inmat, 1), 4);
        
        for ch = 1:size(inmat, 2)
            out(:, 1) = out(:, 1) + sqrt(0.5) * inmat(:, ch);
            out(:, 2) = out(:, 2) + cosd(setup.elev(ch)) * cosd(setup.azim(ch)) * inmat(:, ch);
            out(:, 3) = out(:, 3) + cosd(setup.elev(ch)) * sind(setup.azim(ch)) * inmat(:, ch);
            out(:, 4) = out(:, 4) + sind(setup.elev(ch)) * inmat(:, ch);
        end

    case 'array'        % arbitrary placed speakers
        distces = sqrt(sum(setup.relpos.^2, 2));
        source_coordinates = setup.relpos./repmat(distces, 1, 3);
        
        [speaker_coordinates, speaker_distances] = to_unit_sphere(op.array_pos);
        
        panning_matrix = map_to_speakers(source_coordinates, speaker_coordinates, op);
        out = render_array(inmat, panning_matrix, speaker_distances, op);

    otherwise
        error('spat_mode unknown: %s', setup.spat_mode);
end

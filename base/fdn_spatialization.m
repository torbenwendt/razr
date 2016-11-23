function out = fdn_spatialization(outmat, fdn_setup, op)
% FDN_SPATIALIZATION - Apply spatialization to FDN channels
%
% Usage:
%   out = FDN_SPATIALIZATION(outmat, fdn_setup, op)
%
% Input:
%   outmat      Matrix of monaural FDN output channels
%   fdn_setup   Output of GET_FDN_SETUP
%   op          Options structure (see RAZR)
%
% Output:
%   out         Spatialized signal

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
% Creative Commons Attribution-NonCommercial-NoDerivs 4.0 International
% License (CC BY-NC-ND 4.0).
% To view a copy of this license, visit
% http://creativecommons.org/licenses/by-nc-nd/4.0/ or send a letter to
% Creative Commons, 444 Castro Street, Suite 900, Mountain View, California,
% 94041, USA.
%------------------------------------------------------------------------------



switch op.spat_mode{end}
    case 'shm'
        outmat_l = hsfilterMod(fdn_setup.hrtf_angles(:, 1), fdn_setup.hrtf_angles(:, 2), ...
            90, op.shm_warpMethod, op.fs, outmat, []);
        outmat_r = hsfilterMod(fdn_setup.hrtf_angles(:, 1), fdn_setup.hrtf_angles(:, 2), ...
            -90, op.shm_warpMethod, op.fs, outmat, []);
            
        out = [...
            sum(bsxfun(@times, fdn_setup.atten(:)', outmat_l), 2), ...
            sum(bsxfun(@times, fdn_setup.atten(:)', outmat_r), 2)];
    
    case 'diotic'
        out = repmat(sum(outmat, 2), 1, 2);
        
    case 'hrtf'
        [outmat_l, outmat_r] = apply_hrtf(op.hrtf_database, outmat, ...
            fdn_setup.hrtf_angles(:, 1), fdn_setup.hrtf_angles(:, 2), op.fs, op.hrtf_options);
        
        out = [...
            sum(bsxfun(@times, fdn_setup.atten(:)', outmat_l), 2), ...
            sum(bsxfun(@times, fdn_setup.atten(:)', outmat_r), 2)];
        
    case 'ild'
        outmat_l = outmat*0;
        outmat_r = outmat_l;
        
        for ch = 1:fdn_setup.numDel
            outmat_l(:, ch) = fdn_setup.lrscale(ch, 1)*outmat(:, ch);
            outmat_r(:, ch) = fdn_setup.lrscale(ch, 2)*outmat(:, ch);
        end
        
        out = [...
            sum(bsxfun(@times, fdn_setup.atten(:)', outmat_l), 2), ...
            sum(bsxfun(@times, fdn_setup.atten(:)', outmat_r), 2)];
        
    case 'maplr1'      % full mapping to channels left/right, round scaling factors to [0, 1, 2]
        idxl = logical(round(fdn_setup.lrscale(:, 1)));
        idxr = logical(round(fdn_setup.lrscale(:, 2)));
        
        out = 2*[sum(outmat(:, idxl), 2), sum(outmat(:, idxr), 2)];
        
    case 'maplr2'      % full mapping to channels left/right, round scaling factors to [0, 2]
        idxl = logical(round(fdn_setup.lrscale(:, 1)/2));
        idxr = logical(round(fdn_setup.lrscale(:, 2)/2));
        
        out = 2*[sum(outmat(:, idxl), 2), sum(outmat(:, idxr), 2)];
        
    case '1stOrdAmb'      % first order ambisonics panning
        azim = fdn_setup.hrtf_angles(:, 1);
        elev = fdn_setup.hrtf_angles(:, 2);
        
        out = zeros(size(outmat, 1), 4);
        
        for ch = 1:fdn_setup.numDel
            out(:, 1) = out(:, 1) + sqrt(0.5) * outmat(:, ch);
            out(:, 2) = out(:, 2) + cosd(elev(ch)) * cosd(azim(ch)) * outmat(:, ch);
            out(:, 3) = out(:, 3) + cosd(elev(ch)) * sind(azim(ch)) * outmat(:, ch);
            out(:, 4) = out(:, 4) + sind(elev(ch)) * outmat(:, ch);
        end
        
    otherwise
        error('Spatialization for FDN unknown: %s', op.spat_mode{end});
end

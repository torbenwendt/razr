function [ir, ism_data] = image_source_model(room, ism_setup, op)
% IMAGE_SOURCE_MODEL - Synthesize (binaural) room impulse response for specified shoebox room, using
% the image source model.
%
% Usage:
%   [ir, ism_data] = IMAGE_SOURCE_MODEL(room, ism_setup, op)
%
% Input:
%   room        room structure (see RAZR)
%   ism_setup   Structure containg ISM setup specifications returned by GET_ISM_SETUP
%   op          Options struct (complete, i.e. output of COMPLEMENT_OPTIONS)
%
% Output:
%	ir          Impulse response as structure (see RAZR)
%   ism_data    Struct containing metadata for image sources

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


%% preallocs and initializations

if strcmp(op.spat_mode{1}, 'array')
    numCh = size(op.array_pos, 1);
else
    numCh = 2;
end

ir.sig_early  = zeros(ism_setup.len, numCh);
ir.sig_direct = zeros(ism_setup.len, numCh);
ir.early_refl_sigmat = [];
ir.early_refl_sigmat_diffuse = [];  % matrix needed, even if diffusion disabled

if op.return_ism_data
    ism_data.delays = [];
    ism_data.azim = [];
    ism_data.elev = [];
    ism_data.positions = [];
    ism_data.relpos = [];
    ism_data.b_diffr = [];
    ism_data.a_diffr = [];
    ism_data.b_air = [];
    ism_data.a_air = [];
    ism_data.idx_auralize = logical([]);
    ism_data.pattern = [];
    ism_data.order = [];
    ism_data.sr_perc_sor = [];
end

ism_data.filter_ranges = [];

% initializations - will be overwritten:
total_num_imgsrc = 0;
ir.start_spl = ism_setup.len;

% Do not change the loop order! curr_sigmat of the last loop iteration will be used for FDN input:
for n = 1:size(ism_setup.orders_from_to, 1)
    %% img-src-pattern and positions
    
    tic_ism_orders = tic;
    
    isd = create_is_pattern(...
        [ism_setup.orders_from_to(n, 1), ism_setup.orders_from_to(n, 2)], ...
        ism_setup.discd_directions);
    
    isd = scale_is_pattern(isd, room, op, ism_setup, ism_setup.rng_seeds(n));
    
    total_num_imgsrc = total_num_imgsrc + length(isd.order);
    ir.start_spl = min([min(isd.sor), ir.start_spl]);
    
    %% calc early reflections
    
    % the curr_sigmat of the last loop iteration will be used for FDN input:
    %[signal_IS, ir.curr_sigmat, curr_sigmat_diffuse, filter_ranges] = ...
    %    create_ism_output(isd, ism_setup, op);
    % Olli <--------------------------------------------------------------------
    % TW fix:
    ism_setup.start_direct_sample = ir.start_spl;
    
    [signal_IS, ir.curr_sigmat, curr_sigmat_diffuse, isd, filter_ranges] = ...
        create_ism_output(isd, ism_setup, op);
    % end <--------------------------------------------------------------------
    
    if all(ism_setup.orders_from_to(n, :) == 0)
        ir.sig_direct = signal_IS;
    else
        ir.sig_early = ir.sig_early + signal_IS;
    end
    
    ism_data.filter_ranges = [ism_data.filter_ranges; filter_ranges];
    
    if op.return_ism_data
        ism_data.idx_auralize = [ism_data.idx_auralize; isd.idx_auralize];
        ism_data.positions    = [ism_data.positions;    isd.positions];
        ism_data.relpos       = [ism_data.relpos;       isd.relpos];
        ism_data.delays       = [ism_data.delays;       isd.sor];
        ism_data.azim         = [ism_data.azim;         isd.azim];
        ism_data.elev         = [ism_data.elev;         isd.elev];
        ism_data.b_air        = [ism_data.b_air;        isd.b_air];
        ism_data.a_air        = [ism_data.a_air;        isd.a_air];
        ism_data.b_diffr      = [ism_data.b_diffr;      isd.b_diffr];
        ism_data.a_diffr      = [ism_data.a_diffr;      isd.a_diffr];
        ism_data.pattern      = [ism_data.pattern;      isd.pattern];
        ism_data.order        = [ism_data.order;        isd.order];
        ism_data.sr_perc_sor  = [ism_data.sr_perc_sor;  isd.sr];
    end
    
    if op.return_ism_sigmat
        ir.early_refl_sigmat = [ir.early_refl_sigmat, ir.curr_sigmat];
    end
    
    if op.return_ism_sigmat || op.ism_enable_scattering
        ir.early_refl_sigmat_diffuse = [...
            ir.early_refl_sigmat_diffuse, curr_sigmat_diffuse];
    end
    
    toc_ism_orders = toc(tic_ism_orders);
    if op.verbosity >= 3
        fprintf('ISM order %d to %d (%d image sources): %f seconds\n', ...
            ism_setup.orders_from_to(n, 1), ism_setup.orders_from_to(n, 2), ...
            size(isd.pattern, 1), toc_ism_orders);
    end
end

numCh_fdn_input = size(ir.curr_sigmat, 2);
ism_data.is_fdn_input = [...
    false(total_num_imgsrc - numCh_fdn_input, 1); ...
    true(numCh_fdn_input, 1)];

ir.sig = ir.sig_direct + ir.sig_early;
ir.fs = op.fs;

% security check:
if any(any(isnan(ir.sig)))
    error('nan detected in ir.sig.');
end

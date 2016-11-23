function ir = fadeout_ir(ir, do_trunc, do_plot)
% FADEOUT_IR - Perform exponential fade-out of IR noise floor at Lundeby-crosspoint.
%
% Usage:
%   ir = FADEOUT_IR(ir, [do_trunc], [do_plot])
%
% Input:
%   ir              RIR structure (see RAZR)
%   do_trunc        If true, truncate faded RIR at -120 dB (re max of signal averaged in 25-ms-
%                   blocks). Optional, default: true.
%   do_plot         If true, create a control plot. Optional, default: false
%
% Output:
%   ir              New RIR structure
%
% See also: LUNDEBY_CROSSPOINT, CUTNWIN

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



if nargin < 3
    do_plot = false;
    if nargin < 2
        do_trunc = true;
    end
end


[tcrosspoint, late_decayrate] = lundeby_crosspoint(ir, false);

% damping constant for the signal model "x(t) = 10^(-damping*t)"
damping = -late_decayrate/20;

transition_spl = round(tcrosspoint*ir.fs);

[len, numCh] = size(ir.sig);
tvec = timevec(len - transition_spl + 1, ir.fs);
fading = 10.^(-damping*tvec);

if do_plot
    figure;
    maxpeak = abs(max(max(abs(ir.sig))));
    plot(20*log10(abs(ir.sig/maxpeak)));
    hold on;
    plot(transition_spl:len, 20*log10(fading), ...
        'color', [1 1 1]*0.6, 'linewidth', 2);
end

ir.sig(transition_spl:len, :) = ir.sig(transition_spl:len, :) .* repmat(fading, 1, numCh);

if do_plot
    plot(20*log10(abs(ir.sig/maxpeak)));
end

%% truncation

if do_trunc
    trunc_level = -120;
    ir_db = 20*log10(abs(mean(ir.sig, 2)));
    
    blocklen = 25*1e-3;
    [ir_db_mean, tvec] = meanBlockwise(ir_db, blocklen, ir.fs);  % tvec in ms
    [maxval, idx_max] = max(ir_db_mean);
    idx_lower = find(ir_db_mean < (maxval + trunc_level));
    idx_1st = find(idx_lower > idx_max, 1);
    idx_trunc = idx_lower(idx_1st);
    
    if ~isempty(idx_trunc)
        idx_trunc = round(tvec(idx_trunc)/1e3*ir.fs);
    else
        idx_trunc = len;
    end
    
    decay = 2048;
    idx_trunc = min(idx_trunc, len - decay);
    
    if isfield(ir, 'start_spl')
        start_spl = ir.start_spl;
    else
        start_spl = 1;
    end
    
    attack = 0;
    shift  = start_spl - attack - 1;
    sustain = idx_trunc - shift - attack;
    ir = cutnwin(ir, [shift, attack, sustain, decay], false);
end

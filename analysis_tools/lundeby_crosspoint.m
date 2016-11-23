function [tcrosspoint, late_decayrate] = lundeby_crosspoint(ir, do_plot)
% LUNDEBY_CROSSPOINT - For measured RIRs containing noise floor, find truncation point for optimal
% limit of Schroeder integration, using the Lundeby method as described in:
% Karjalainen et al. (2002): Estimation of Modal Decay Parameters from Noisy
% Response Measurements, JAES Vol. 50 (11), pp. 867-878 (Sec. 2.5.2)
%
% Usage:
%   [tcrosspoint, late_decayrate] = LUNDEBY_CROSSPOINT(ir, [do_plot])
%
% Input:
%   ir              RIR structure (see RAZR)
%   do_plot         If true, iteration steps will be plotted (optional; default: false)
%
% Output:
%   tcrosspoint     Truncation point in sec.
%   late_decayrate  Slope of regression of late reverb (in dB/s)
%
% See also: SCHROEDER_RT

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



%% input parameters

if nargin < 2
    do_plot = 0;
end

do_plot_ir = 0;

%% improve first noise estimation, if field tpretrunc exists

if isfield(ir, 'tpretrunc')
    ir = cutnwin(ir, [0, 0, ir.tpretrunc, 0], true);
end

%% 1) mean blockwise

ir2 = mean(ir.sig,2).^2;

blocklen = 25*1e-3;								% 25*1e-3; recommended: 10...50 ms

[ir2mean, t] = meanBlockwise(ir2, blocklen, ir.fs);

ir2maxval  = max(abs(ir2mean));
L_ir       = 10*log10(ir2mean/ir2maxval);		% normalized IR level
ir2meanlen = size(ir2mean,1);

fs1 = ir2meanlen/t(ir2meanlen)*1e3;


%% 2) first noise estimation from the last 10 percent of IR

n1estim_interv1 = round((1-0.1)*ir2meanlen);	% recommended: (1-0.1)
n1estim_interv2 = ir2meanlen;

Lnoise1 = mean(  L_ir( n1estim_interv1:n1estim_interv2 )  );


%% 3) decay slope estimation

yfitrange = [0, Lnoise1+15];					% [0, Lnoise1+15]; recommended: [0, Lnoise1+5...10]

xfitrange    = zeros(1,2);
xfitrange(1) = find(L_ir==yfitrange(1),1);
tmp          = find(L_ir<=yfitrange(2));
xfitrange(2) = tmp(find(tmp>xfitrange(1),1));
pfit         = polyfit(t(xfitrange(1):xfitrange(2)), L_ir(xfitrange(1):xfitrange(2))', 1);

decay_slope  = 1e3*pfit(1);						% in dB/s


%% 4) crosspoint decay-Lnoise1

tcrossp = 1e-3*(Lnoise1-pfit(2))/pfit(1);		% in sec.

%% test plot

if do_plot
    figure
    
    % noise estimation interval:
    handle_noise = plot([n1estim_interv1, n1estim_interv2]/fs1*1e3, [1 1]*Lnoise1,...
        'color', [1 1 1]*0.6, 'linewidth', 3.0);
    hold on
    
    handle_sig = plot(t, L_ir);
    
    % fit:
    handle_fit = plot(t(xfitrange), polyval(pfit,t(xfitrange)), 'color', 'k');
    plot(t(xfitrange), yfitrange, '*', 'color', 'k');
    
    handle_crossp = plot([1 1]*tcrossp*1e3, [-100, 0], '--', 'color', [1 1 1]*0.6);
    
    legend([handle_sig, handle_noise, handle_fit, handle_crossp], ...
        {'normalized IR level', 'noise estimation interval', 'fit', 'truncation point'})
    
    xlabel('Time (ms)')
    ylabel('Normalized energy (dB)')
end


%% 5) new block length

numIntervals_per_10dBDecay = 7.5;					% 7.5; recommended: 3...10

blocklen2 = -10/(numIntervals_per_10dBDecay * decay_slope);


%% 6) averaging with new block length

[ir2mean2, t2] = meanBlockwise(ir2, blocklen2, ir.fs);

ir2maxval2  = max(abs(ir2mean2));
L_ir2       = 10*log10(ir2mean2/ir2maxval2);		% normalized IR level
ir2meanlen2 = size(ir2mean2,1);
[ans_, ir2maxarg2] = max(abs(ir2mean2));


%% 7) new noise estimation

decay_slope2 = decay_slope;
tcrossp2     = tcrossp;
do_break     = false;								% break while loop?
counter      = 0;

while ~do_break
    
    Dtau = -10/decay_slope2;						% -10/decay_slope2; recommended: 5...10
    fs2  = ir2meanlen2/t2(ir2meanlen2)*1e3;
    
    startspl_for_meancalc = min( [round((tcrossp2+Dtau)*fs2), round((1-0.1)*ir2meanlen2)] );
    alpha = 0.75;																			% weighting for mean
    endspl_for_meancalc   = round((1-alpha)*startspl_for_meancalc + alpha*ir2meanlen2);		% (this differs from Lundeby)
    
    Lnoise2 = mean( L_ir2(startspl_for_meancalc:endspl_for_meancalc) );
    
    
    %% 8) late decay slope estimation
    
    yfitrange2    = zeros(1,2);
    yfitrange2(2) = Lnoise2 + 7.5;					% 7.5; recommended: 5...10
    yfitrange2(1) = yfitrange2(2) + 15;				% 15;  recommended: 10...20
    
    xfitrange2    = zeros(1,2);
    tmp           = find(L_ir2<=yfitrange2(1));
    xfitrange2(1) = tmp(find(tmp>ir2maxarg2,1));
    tmp           = find(L_ir2<=yfitrange2(2));
    xfitrange2(2) = tmp(find(tmp>xfitrange2(1),1));
    pfit2         = polyfit(t2(xfitrange2(1):xfitrange2(2)), L_ir2(xfitrange2(1):xfitrange2(2))', 1);
    
    decay_slope2  = 1e3*pfit2(1);					% in dB/s
    
    
    %% 9) new crosspoint late decay-Lnoise2
    
    tcrossp2_tmp = tcrossp2;
    tcrossp2     = 1e-3*(Lnoise2-pfit2(2))/pfit2(1);	% in sec.
    
    
    %% stop criterion
    
    counter  = counter + 1;
    do_break = abs(tcrossp2_tmp - tcrossp2) < 1e-2 || counter==5;
    
    %% test plots
    
    if do_plot
        figure
        
        % noise estimation interval:
        handle_noise = plot([startspl_for_meancalc, endspl_for_meancalc]/fs2*1e3, [1 1]*Lnoise2, ...
            'color', [1 1 1]*0.6, 'linewidth', 3);
        hold on
        handle_sig = plot(t2, L_ir2);
        
        % fit:
        handle_fit = plot(t2(xfitrange2), polyval(pfit2, t2(xfitrange2)), 'color', 'k');
        plot(t2(xfitrange2), yfitrange2, '*', 'color', 'k');
        
        % crosspoint:
        handle_crossp = plot([1 1]*tcrossp2*1e3, [-100, 0], '--', 'color', [1 1 1]*0.6);
        
        legend([handle_sig, handle_noise, handle_fit, handle_crossp], ...
            {'normalized IR level', 'noise estimation interval', 'fit', 'truncation point'})
        
        xlabel('Time (ms)')
        ylabel('Normalized energy (dB)')
        title(sprintf('trcossp2 = %f', tcrossp2));
    end
    if do_plot_ir
        [ans_, hax] = plot_ir(ir,1,0);
        hold on
        plot(hax, [1 1]*tcrossp *1e3, [-100, 0], '--', 'color', [1 1 1]*0.4);
        plot(hax, [1 1]*tcrossp2*1e3, [-140, 0], '--', 'color', [1 1 1]*0.6);
        
        xlabel('Time (ms)')
        ylabel('Normalized energy (dB)')
    end
    
end

tcrosspoint    = tcrossp2;
late_decayrate = decay_slope2;		% in dB/s

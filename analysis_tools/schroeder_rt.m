function [rt, freq_out, edc_mean_lr, tvec, handles] = schroeder_rt(ir, varargin)
% SCHROEDER_RT - Calculate reveberation time measures from RIR, using the Schroeder integration
% method.
%
% Usage:
%   [rt, freq_out, edc_mean_lr, tvec, handles] = SCHROEDER_RT(ir, Name, Value)
%
% Required input:
%   ir          RIR structure (see RAZR)
%
% Optional Name-Value-pair arguments (defaults in parentheses):
%   freq        ([250 500 1e3 2e3 4e3 8e3]) Octave band center frequencies in Hz. Set to 0 for
%               broadband calculation
%   incl_edges  (false) If true, do calculation also in the outer spectral regions
%   measure     ('t30') Reverberation time measure (level intervals for linear fit of EDC in
%               brackets):
%               't30': reverberation time T30   [-5, -35]
%               'edt': Early decay time         [-0.1, -10]
%               'ldt': Late decay time          [-25, -35]
%               [upperLevel, lowerLevel]: a custom fit-interval
%   lundeby     (false) If true, apply noise truncation using the Lundeby method (see
%               LUNDEBY_CROSSPOINT)
%   plot        (false) If true, plot EDC (Schroeder integral) (default: false). The EDC will be
%               plotted for each frequency band. Curves are shifted for better readability. Fit
%               intervals are marked with squares, fit curves are plotted with black dashed lines.
%   plot_rt     (false) If true, plot reverberation time against frequencies
%   plot_fit    (true) If true, plot linear fit and mark fit-interval edges
%
% Output:
%   rt          Reverberation time in sec for specified frequencies
%   freq_out    if incl_edges == false: freq_out = freq, else: freq_out = [freq(1)/4, freq, ir.fs/2]
%               (useful for plotting)
%   edc_mean_lr Energy decay curve
%   tvec        Time vector for edc_mean_lr
%   handles     Structure containing all plot handles
%
% See also: LUNDEBY_CROSSPOINT

%------------------------------------------------------------------------------
% RAZR engine for Mathwork's MATLAB
%
% Version 0.91
%
% Author(s): Torben Wendt
%
% Copyright (c) 2014-2017, Torben Wendt, Steven van de Par, Stephan Ewert,
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

freq_default = [250 500 1e3 2e3 4e3 8e3];

p = inputParser;
addparam = get_addparam_func;
addparam(p, 'freq', freq_default);
addparam(p, 'incl_edges', false);
addparam(p, 'measure', 't30');
addparam(p, 'lundeby', false);
addparam(p, 'plot', false);
addparam(p, 'plot_rt', false);
addparam(p, 'plot_fit', true);

parse(p, varargin{:});

if isempty(p.Results.freq)
    freq = freq_default;
else
    freq = p.Results.freq;
end

numFreq = length(freq);
use_filterbank = ~(numFreq == 1 && freq == 0);

if p.Results.incl_edges
    freq_out = [freq(1)/4, freq, ir.fs/2];
else
    freq_out = freq;
end

numFreq_pE = length(freq_out);
len = size(ir.sig, 1);

%% Lundeby truncation

if p.Results.lundeby
    [lundtrunc] = lundeby_crosspoint(ir);
    ir = cutnwin(ir, [0, 0, lundtrunc, 0], true);
end

tvec = timevec(len, ir.fs);

%% apply filterbank

% make sure to have two channels:
if size(ir.sig, 2) == 1
    ir.sig = repmat(ir.sig, 1, 2);
end

IRsig_rep = repmat(ir.sig, 1, numFreq_pE);

if use_filterbank
    [bBank, aBank] = oct_filterbank(freq, ir.fs, p.Results.incl_edges);
    
    for n = 1:numFreq_pE
        IRsig_rep(:, 2*n-1:2*n) = filter(bBank(n, :), aBank(n, :), IRsig_rep(:, 2*n-1:2*n));
    end
end

%% Schroeder integration

ir2 = IRsig_rep.^2;

int2 = cumtrapz(ir2, 1);
int1 = flipud(cumtrapz(flipud(ir2)));

schroeder_edc = 10*log10(int1./repmat(int2(len, :), len, 1));

%% fitting

if ischar(p.Results.measure)
    switch p.Results.measure
        case 't30'
            yfitrange = [-5, -35];
        case 'edt'
            yfitrange = [-0.1, -10];  % -0.1 instead of 0, in order to omit the first samples close to 0 dB
        case 'ldt'
            yfitrange = [-25, -35];
        otherwise
            error('measure unknown: %s.', p.Results.measure);
    end
elseif length(p.Results.measure) ~= 2
    error('If measure specifies level range for linear fit, it must have two elements.');
else
    yfitrange = sort(p.Results.measure, 1, 'descend');
end

xfitrange   = zeros(numFreq_pE, 2);
pfit        = zeros(numFreq_pE, 2);
edc_mean_lr = zeros(len, numFreq_pE);
rt          = zeros(1, numFreq_pE);

for n = 1:numFreq_pE
    edc_mean_lr(:, n) = mean(schroeder_edc(:, 2*n-1:2*n), 2);
    xfitrange(n, :) = [...
        find(edc_mean_lr(:, n) <= yfitrange(1), 1), find(edc_mean_lr(:, n) <= yfitrange(2), 1)];
    pfit(n, :) = polyfit(...
        tvec(xfitrange(n, 1):xfitrange(n, 2)), edc_mean_lr(xfitrange(n, 1):xfitrange(n, 2), n), 1);
    
    % calculation method: "At what time hits the fit the -60 dB?":
    %Tr(n) = (-60 - pfit(n, 2))/pfit(n, 1);
    % calc method: "Multiply fitrange with factor" (more correct, if EDC doesn't hit 0 dB at time 0):
    rt(n) = 60*sign(diff(yfitrange))/pfit(n, 1);
end

%% plot EDC

handles = struct;

if p.Results.plot
    lw = 1.3;
    cmap = 0.4*autumn(numFreq_pE) + 0.6*flipud(summer(numFreq_pE));  % colormap
    colFit = [1 1 1]*0.0;
    lwFit = lw*0.5;
    styleFit = '--';
    
    handles.fig = figure;
    handles.plot_edc = zeros(numFreq_pE,1);
    
    for n = 1:numFreq_pE
        shift = -(n-1)*10;
        
        % Fit:
        if p.Results.plot_fit
            handles.plot_fit = plot(tvec, polyval(pfit(n, :), tvec) + shift, ...
                styleFit, 'color', colFit, 'Linewidth', lwFit);
            hold on;
        end
        
        % point at Tr:
        %handles.plot_point = plot(rt(n), polyval(pfit(n, :), 1e3*rt(n)) + shift, ...
        %    '*', 'color', colFit, 'Linewidth', lwFit);
        
        % EDC left and right:
        % edcl(n) = plot(t_ms/1e3,schroeder_edc(:,2*n-1)+shift,'color',cmap(n,:),'Linewidth',lw);
        % plot(t_ms/1e3,schroeder_edc(:,2*n)+shift,'--','color',cmap(n,:),'Linewidth',lw);
        
        % EDC mean(L,R):
        handles.plot_edc(n) = plot(...
            tvec, edc_mean_lr(:, n) + shift, 'color', cmap(n, :), 'Linewidth', lw);
        hold on;
        
        % fit interval:
        if p.Results.plot_fit
            handles.plot_fitinterval = plot(...
                tvec(xfitrange(n, :)), edc_mean_lr(xfitrange(n, :), n) + shift, ...
                's', 'color', cmap(n, :), 'markerfacecolor', 'w', 'Linewidth', lw);
        end
    end
    hold off
    
    xlabel('Time (s)')
    ylabel('Normalized signal energy (dB)')
    %title(ir.name,'Interpreter','none')
    grid on
    
    xlim([0, min(2*max(rt), tvec(end))]);
    ylim([-120, 0]);
    
    % legend:
    if ~(numFreq == 1 && freq == 0)
        leg = cell(numFreq_pE, 1);
        for n = 1:numFreq
            leg{n + p.Results.incl_edges} = cell2mat(freq2str(freq(n), true));
        end
        if p.Results.incl_edges
            leg{1} = ['< ', cell2mat(freq2str(min(freq), true))];
            leg{numFreq_pE} = ['> ', cell2mat(freq2str(max(freq), true))];
        end
        handles.legend = legend(handles.plot_edc, leg);
        %set(legh, 'Location', 'NorthEastOutside');
    end
    
    set(gca, 'Linewidth', lw);
    handles.ax = gca;
end

%% plot RT

if p.Results.plot_rt
    lw = 1.3;
    handles.fig_rt = figure;
    handles.plot_rt = semilogx(freq_out, rt, 'o-', 'markerfacecolor', 'w', 'linewidth', 1.3);
    xlabel('Frequency (Hz)');
    if ischar(p.Results.measure)
        title(upper(p.Results.measure));
    else
        title(sprintf('EDC fit interval: [%g, %g] dB', yfitrange(1), yfitrange(2)));
    end
    ylabel('Reverberation time (s)');
    set(gca, 'xtick', freq_out, 'xticklabel', freq2str(freq_out));
    grid on;
    ylim([floor(min(rt)), ceil(max(rt))]);
    set(gca, 'Linewidth', lw);
    handles.ax_rt = gca;
end

if nargout == 0
    clear rt
end

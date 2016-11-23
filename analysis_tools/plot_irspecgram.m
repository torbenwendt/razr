function [hfig, hax, hplot, pow, freq, t_sec] = plot_irspecgram(ir, winlen_sec, t_max)
% PLOT_IRSPECGRAM - Calculate and plot normalized spectrogram of RIR.

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



%% settings

nfft = 2^8;
nfft = 2^9;

if nargin < 3
    t_max = [];         % default will be numFrames, see below
    if nargin < 2
        winlen_sec = [];
    end
end

if isempty(winlen_sec)
    winlen = round(nfft);
else
    winlen = round(winlen_sec*ir.fs);
end

overlap = 0.75;
%overlap = 0.5;

do_img = 0;
greyscale = 1;
lw = 1.3;
%Llow = -100;            % im Plot: P = max(P, Llow), alle Werte unter Llow auf Llow setzen
Llow = -inf;

%%

numCh = size(ir.sig, 2);
pow = cell(1, 2);
st_ft = cell(1, 2);

for n = 1:numCh
    [st_ft{n}, freq, t_sec, pow{n}] = spectrogram(...
        ir.sig(:, n), winlen, round(overlap*nfft), nfft, ir.fs);
    
    % normalize:
    pow{n} = pow{n}./max(max(pow{n}));
end

numFrames = size(st_ft{1}, 2);

if isempty(t_max)
    t_max_idx = numFrames;
else
    [val, t_max_idx] = min(abs(t_max - t_sec));
end


if numCh == 2
    title_str = {'left', 'right'};
else
    title_str = cell(numCh, 1);
end

hfig = figure;

if do_img
    freq_khz = freq*1e-3;
    
    for n = 1:numCh
        subplot(1, numCh, n)
        hplot(n) = imagesc(t_sec, freq_khz, max(10*log10(pow{n}), Llow));
        xlabel('Time (s)');
        if n == 1
            ylabel('Frequency (kHz)');
            zlabel('Normalized energy (dB)');
        end
        title(title_str{n})
        xlim([0 size(ir.sig, 1)/ir.fs])
        ylim([0 ir.fs/2*1e-3])
        axis xy
        set(gca, 'Linewidth', lw);
        if greyscale
            colormap(flipud(gray));
        end
        hax(n) = gca;
    end
else
    freq_labels = octf(125, 16e3);
    
    st_ft_mean = (st_ft{1}(:, 1:t_max_idx) + st_ft{2}(:, 1:t_max_idx))/2;
    numFrames = size(st_ft_mean, 2);
    
    for n = 1:numFrames
        st_ft_mean(:, n) = smoothnew3(st_ft_mean(:, n), 4/12);
    end
    
    if greyscale
        cmap = gray(numFrames + 1);
        cmap = cmap(1:numFrames, :);
    else
        %cmap = autumn(numFrames);
        cmap = lines(numFrames);
    end
    set(gca, 'ColorOrder', cmap, 'NextPlot', 'replacechildren');
    hplot = semilogx(freq, 20*log10(abs(st_ft_mean)), 'linewidth', lw);
    grid on;
    xlabel('Frequency (Hz)');
    ylabel('Energy (dB)')
    xlim([125 ir.fs/2]);
    set(gca, 'Linewidth', lw, 'xtick', freq_labels, 'xticklabel', freq2str(freq_labels));
    legend(hplot, num2str(t_sec(1:t_max_idx)'*1e3), 'location', 'best');
    title('Legend shows time frames in ms');
    hax(n) = gca;
end

if nargout == 0
    clear hfig;
end

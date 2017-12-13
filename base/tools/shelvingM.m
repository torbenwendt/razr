function [b, a, H] = shelvingM(f0, fb, fs, gain, M, type, linGain, do_plot)
% SHELVINGM - Get filter coefficients for M-th order (low/high/peak) shelving filter after
% Holters and Zoelzer (2006): "PARAMETRIC HIGHER-ORDER SHELVING FILTERS"
% (14th European Signal Processing Conference (EUSIPCO 2006))
%
% Usage:
%   [b, a, H] = SHELVINGM(f0, fb, fs, gain, M, type, linGain, [do_plot])
%
% Input:
%   f0          Center frequency in Hz (not needed for low- and high-shelving filter)
%   fb          Bandwidth (peak shelving) or edge frequency (low/high)
%   fs          Sampling rate in Hz
%   gain        Gain as one- or two-component vector, G or [G1, G2], where specification of G
%               is equivalent to the specification [G1, 0] (linGain==0) or [G1, 1] (linGain==1).
%               For peak filter: G1 = boost/cut gain, G2 = "base" gain;
%               For low/high shelving: crossfading between G1 and G2
%   M           Filter order
%   type        Filter type: 'low', 'high', 'peak'
%               (swapping 'low' <-> 'high' is equivalent to swapping G1 <-> G2)
%   linGain     Set true, if gain is specified as linear factors,
%               set false, if gain is specified in dB
%	do_plot     If true, plot frequency response (optiona, default: false)
%
% Output:
%	b, a	Filter coefficient vectors
%	H       Frequency response in dB as a Makro, Input parameter: frequency in Hz

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


%% test call:

if nargin == 0
    fs = 44100;
    f0   = 1e3;
    fb   = 2*f0;
    gain = [-8 3];
    M = 2;
    type = 'peak';
    
    [b, a, H] = shelvingM(f0, fb, fs, gain, M, type, 0, false);
    
    % analytic representation of frequency response:
    f  = logspace(1,log10(fs/2), 100);
    %g(1) = 10.^((gain(1)-gain(2))/20);
    %H = 10*log10( ((f/fb).^(2*M) + g(1)^2) ./ ((f/fb).^(2*M) + 1) ) + gain(2);
    
    if 1
        figure
        plotFrqRsp(b,a,fs);
        hold on
        semilogx(f, H(f), '-.k')
        grid on
    end
    return;
end

%%

if nargin < 8
    do_plot = 0;
end

if ~linGain
    gain = 10.^(gain/20);
end

if length(gain) == 2
    g1 = gain(1)/gain(2);   % correction of maximum gain due to base gain
    g2 = gain(2);
else
    g1 = gain(1);
    g2 = 1;
end

alpha = (1 - (2*(1:M)' - 1)/M)*pi/2;	% Eq. (3) in Paper
K  = tan(pi*fb/fs);                     % Eq. (6) in Paper
c0 = repmat(cos(2*pi*f0/fs), M, 1);     % second eq. in sec. 4

expialpha = exp(1i*alpha);
Mthrootg = g1^(1/M);

switch type
    case 'low'
        bmat = [K*Mthrootg*expialpha + 1, K*Mthrootg*expialpha - 1];
        amat = [K*expialpha + 1, K*expialpha - 1];
        
        H = @(f) (10*log10( g2^2 * ((f/fb).^(2*M) + g1^2) ./ ((f/fb).^(2*M) + 1) ));
        
    case 'high'
        fb_tmp = fs/2 - fb;
        K  = tan(pi*fb_tmp/fs);
        
        bmat = [K*Mthrootg*expialpha + 1, -K*Mthrootg*expialpha + 1];
        amat = [K*expialpha + 1, -K*expialpha + 1];
        
        H = @(f) (10*log10( g2^2 * ((fb./f).^(2*M) + g1^2) ./ ((fb./f).^(2*M) + 1) ));
        
    case 'peak'
        bmat = [-1 - K*Mthrootg*expialpha, 2*c0, K*Mthrootg*expialpha - 1];
        amat = [-1 - K*expialpha, 2*c0, K*expialpha - 1];
        
        Omega = @(f) (f/fs*2*pi);
        cO2M  = @(f) ((c0(1) - cos(Omega(f))).^(2*M));
        KsO2M = @(f) ((K*sin(Omega(f))).^(2*M));
        H = @(f) (10*log10( g2^2 * (cO2M(f) + KsO2M(f)*g1^2) ./ (cO2M(f) + KsO2M(f)) ));
        
    otherwise
        error('Filter type not available: %s', type)
end

[ans0, coefflen] = size(bmat);
convlen = @(m) (m*(coefflen - 1) + 1);  % length of convolution product after m convolutions
b = [1, zeros(1, convlen(M) - 1)];
a = b;

for m = 1:M
    b(1:convlen(m)) = conv(b(1:convlen(m - 1)), bmat(m, :));    
    a(1:convlen(m)) = conv(a(1:convlen(m - 1)), amat(m, :));
end

% make sure that output is real (coeffs might be complex due to limited machine precision):
b = real(b)*g2;     % apply base gain
a = real(a);

if do_plot
    figure
    plotFrqRsp(b, a, fs);
end

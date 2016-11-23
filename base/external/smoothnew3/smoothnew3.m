function[H] = smoothnew3(H,oct,stopf,f)
% Octave based smoothing.
% [H] = smoothnew3(H,oct,stopf )
%
% H is magnitude (positive frequency) input vector.  H out will be same (row/column)
% oct is smoothing constant in octaves
% stopf is highest frequency to be smoothed (normally highest freq. in H)
%
% [H] = smoothnew3(H,oct,stopf,f )
%
% f is optional real frequency argument vector for H (same length)
% if f is NOT supplied
% data is treated like if each bin = 1 Hz !!
%    
% assume analytical signal for now
% H is real input vector.  H smoothed will be same.
%
%CHANGED 28/2/09 for working with 1Hz-Bin restriction
%CORRECTED 11/1/08 for window width (defined at -3 dB).  

if nargin == 2
    stopf = length(H);
end

%if the frequency argument vector exist, there is no 1Hz-Bin-restriction
if nargin == 4
    df = f(2);
    stopf = round(stopf/df)+1;%fstop is now the index not longer a Hz-value
end

startf = 1;   %fixed at 1 for now, doesnt work right if not starting at 1
N = stopf;    %Number of samples for log warping.  This seems to work well.


spacing = 10^(log10(stopf-startf)/N);   %this is a multiplicitive factor, not an even spacing
Noct = oct*log10(2)/log10(spacing); %number of bins per xth octave

%log warp
logsamp = logspace(log10(startf),log10(stopf),N);   
Hinterp = interp1(1:length(H),H, logsamp,'spline'); 

Noct_even = round(Noct/2)*2;    %so can divide by two later and use length(Noct_even) as argument to functions without uncertainty of rounding


%ADDED 11/1/08 to correct.  -3dB points of window should = Noct_even, not entire window.
% W = gausswin(Noct_even);
W = gausswin(Noct_even*2);

%extend the function to be smoothed to minimze errors at boundaries
lead = ones(1,length(W)).*Hinterp(1);
lag = ones(1,length(W)).*Hinterp(end);
Hinterp_extrap = [lead  Hinterp lag  ];

% figure(5)
% plot(H,'b')
% hold on
% plot(Hinterp,'g')
% plot(Hinterp_extrap,'r')
% hold off
% axis([0 20000 -60 0])


%convolve with smothing window
Htemp = fftfilt(W,Hinterp_extrap,length(W)*2)./sum(W);

Htemp = Htemp(length(lead)+.5*length(W)+1:length(lead)+.5*length(W)+length(Hinterp));   %get rid of extra bins from adding lead and lag
H = interp1(logsamp,Htemp,1:stopf,'spline');   %back to linear domain
% 
% figure(10)
% semilogx(H)
% hold on
% semilogx(Hsm,'r')
% % semilogx(csmooth2(H,oct,1,4,1,0,0),'g') %for comparison
% hold off





















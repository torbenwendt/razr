function win = hannwin(len)
% HANNWIN - Hann window. Replacement for hann(len),
% contained in Matlab's signal processing toolbox.
%
% Usage:
%	win = HANNWIN(len)
%
% Input:
%	len     Window length in samples
%
% Output:
%	win     Hann window as column vector


% Torben Wendt
% last modified: 2015-03-26

len_rd = round(len);
if len_rd ~= len
    warning('Window length rounded to nearest integer.');
end

if len_rd < 0
    error('Window length must be a non-negative integer.');
elseif len_rd == 1
    win = 1;
else
    n = (0:len_rd-1)';
    win = 0.5*(1 - cos(2*pi*n/(len_rd-1)));
end

% FDN_MAINLOOP_M - Matlab implementation of feeback delay network (FDN) mainloop, same algorithm
% as implented in the MEX-file FDN_MAINLOOP.
%
% Usage:
%   [outmat, outsig] = FDN_MAINLOOP_M(in, m, b, a, A);
%
% Input:
%   in      Input signal (1 or length(m) channels, i.e. columns)
%   m       Vector containing delays in samples
%   b, a    Matrix containing coefficients for absorption filters (one filter per row)
%   A       Feedback matrix of size length(m) x length(m)
%
% Output:
%   outmat  Output signal as matrix; columns represent FDN channels
%   outsig  sum(outmat, 2)
%
% See also: FDN_MAINLOOP

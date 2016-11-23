% FEEDBACK_DELAY_NETWORK
%
% Usage:
%   [out, outmat] = FEEDBACK_DELAY_NETWORK(in, fdn_setup, op)
%
% Input:
%   in          Input signal (1 or length(m) channels, i.e. columns)
%   fdn_setup   Structure containg FDN setup specifications returned by GET_FDN_SETUP.
%   op          Options struct (complete, i.e. custom options already merged with defaults!)
%
% Output:
%   out         Output signal
%   outmat      Output signal (monaural, multichannel)

% IMAGE_SOURCE_MODEL - Synthesize (binaural) room impulse response for specified shoebox room, using
% the image source model.
%
% Usage:
%   [ir, ism_data, isd] = IMAGE_SOURCE_MODEL(room, ism_setup, op)
%
% Input:
%   room        room structure (see RAZR)
%   ism_setup   Structure containg ISM setup specifications returned by GET_ISM_SETUP
%   op          Options struct (complete, i.e. output of COMPLEMENT_OPTIONS)
%
% Output:
%	ir          Impulse response as structure (see RAZR)
%   ism_data    Struct containing metadata for image sources
%   isd         Structure containing metadata for image sources of highest order calculated (see
%               SCALE_IS_PATTERN)

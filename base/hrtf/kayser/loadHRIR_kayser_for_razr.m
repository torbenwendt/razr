function hrir = loadHRIR_kayser_for_razr(environment,varargin)

% loadHRIR
%
% loads HRIRs, BRIRs and BTE-IRs from the database
% returns struct containing the data and information about the sound source
% position
%
% Anechoic HRIRs:
%   loadHRIR('Anechoic', distance, elevation angle in �, azimuth angle in �
%                                                              [, HRIRset])
%
%   with
%       distance  = {80 300}
%       elevation = {-10 0 10 20}
%       azimuth   = {-180 : 5 : 180}
%
% Office I HRIRs:
%   loadHRIR('Office_I', azimuth angle in � [, HRIRset])
%
%   with
%       azimuth   = {-90 ; 5 : 90}
%
% other HRIRs (Cafeteria, Courtyard, Office_II):
%   loadHRIR({'Cafeteria', 'Courtyard', 'Office_II'}, headorientation,
%                                               sourceposition [, HRIRset])
%
%   with
%        headorientation = {1 2}
%        sourceposition  = {'A' 'B' 'C' 'D' 'E' 'F'} ('A'-'D' for Office II)
%   according to the sketches of the environments available with the database.
%
% HRIRset is optional, default is 'all'
%   'all'       8-channel HRIRs                (6-chanell for Office I)
%   'in-ear'    IRs from in-ear microphoes     (not available for Office I)
%   'bte'       6-channel BTE-IRs
%   'front'     BTE-IRs front microphone pair
%   'middle'    BTE-IRs middle microphone pair
%   'rear'      BTE-IRs rear microphone pair
%
%
%   Odd channel numbers always correpond to the left side,
%   even channel numbers always correpond to the right side.
%
%
%   The HRIR database and more information is available at
%                        http://medi.uni-oldenburg.de/hrir/
%
%   Copyright notice: Permission to use this database for purely research
%   or educational purposes is granted. No commercial exploitation of this
%   database is permitted.
%   Copyright 2009, Medizinische Physik, Universitaet Oldenburg, Germany.
%   All rights reserved.
%
%   Author: Hendrik Kayser, hendrik.kayser@uni-oldenburg.de
%   June 2009


% Change this path to an absolute path if you need.
%baseDirectory = './hrir';
% edit TW 2016-03-23:

razr_cfg = get_razr_cfg;
baseDirectory = razr_cfg.hrtf_path__kayser;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
flipData = false;

environment = lower(environment);
switch environment
    case 'anechoic'
        if nargin == 4
            HRIRset = 'all';
        elseif nargin == 5;
            HRIRset = varargin{4};
        else
            error(['Wrong number of input arguments for ''' environment '''.'])
        end
        % for positive azimuth angle, load mirror symmetric data and flip
        % channels from left to right

        if all(varargin{1} ~= [80 300])
            error(['Distance not available: ' num2str(varargin{1})])
        elseif all(varargin{2} ~= -10 : 10 :20)
            error(['Elevation angle not available: ' num2str(varargin{2})])
        elseif all(varargin{3} ~= -180 : 5 : 180)
            error(['Azimuth angle not available: ' num2str(varargin{3})])
        else
            if varargin{3} > 0
                flipData = true;
                varargin{3}=-varargin{3};
            end
            hrir = load(fullfile(baseDirectory,environment,[environment '_distcm_' ...
                num2str(varargin{1}) '_el_' num2str(varargin{2}) '_az_' ...
                num2str(varargin{3}) '.mat']));
        end
    case 'office_i'
        environment = 'office_I';
        if nargin == 2
            HRIRset = 'all';
        elseif nargin == 3;
            HRIRset = varargin{2};
        else
            error(['Wrong number of input arguments for ''' environment '''.'])
        end
        if all(varargin{1} ~= -90 : 5 : 90)
            error(['Azimuth angle not available: ' num2str(varargin{1})])
        else
            hrir = load(fullfile(baseDirectory,environment,[environment ...
                '_distcm_100_el_0_az_' ...
                num2str(varargin{1}) '.mat']));
        end
    case {'office_ii','cafeteria','courtyard'}
        if strcmpi(environment,'office_ii')
            environment = 'office_II';
        end

        if nargin == 3
            HRIRset = 'all';
        elseif nargin == 4;
            HRIRset = varargin{3};
        else
            error(['Wrong number of input arguments for ''' environment '''.'])
        end
        if all(varargin{1} ~= [1 2])
            error(['Headorientation not available: ' num2str(varargin{1})])
        elseif strcmp(environment,'office_II') && all(~strcmpi(varargin{2},{'A' 'B' 'C' 'D'}))
            error(['Sourceposition not available: ' upper(varargin{2})])
        elseif all(~strcmpi(varargin{2},{'A' 'B' 'C' 'D' 'E' 'F'}))
            error(['Sourceposition not available: ' upper(varargin{2})])
        else
            hrir = load(fullfile(baseDirectory,environment,[environment ...
                '_' num2str(varargin{1}) '_' upper(varargin{2}) '.mat']));
        end
    otherwise
        error(['Environment ''' environment ''' is not available.'])
end


if strcmpi(environment,'office_i')
    switch lower(HRIRset)
        case 'all'
            HRIRset = 'bte';
            disp(sprintf('\n %s', 'NOTE: In-ear IRs are not available for Office I.'))
            channels = 1:6;
        case 'in-ear'
            error('Sorry, in-ear measurements are not available for ''Office I''.')
        case 'bte'
            channels = 1:6;
        case 'front'
            channels = 1:2;
        case 'middle'
            channels = 3:4;
        case 'rear'
            channels = 5:6;
        otherwise
            error([HRIRset ': Non-existing set.'])
    end
else
    switch lower(HRIRset)
        case 'all'
            channels = 1:8;
        case 'in-ear'
            channels = 1:2;
        case 'bte'
            channels = 3:8;
        case 'front'
            channels = 3:4;
        case 'middle'
            channels = 5:6;
        case 'rear'
            channels = 7:8;
        otherwise
            error([HRIRset ': Non-existing set.'])
    end
end

% flip left and right channels if azimuth > 0 (for anechoic only)
if flipData
    channels = [channels(2:2:end); channels(1:2:end)];
    channels = reshape(channels,1,2*size(channels,2));
    hrir.azimuth = abs(hrir.azimuth);
end

hrir.data = hrir.data(:,channels);
hrir.nChannels = length(channels);
hrir.HRIRset = lower(HRIRset);

end

function f = loadRaman(filePath, varargin)
%% f = loadRaman(fileName, fileExtension)
%
% load Raman data from mrspectra and other formats
%
% INPUT
% filePath - full file Name 
% varargin - file extenstion, *.mrspectra, *.spectra, *.peak
%
% OUTPUT
% f - data structure
% f.data - N dim array with shape f.shape
% f.Shape - shape of data
% f.Labels - axis labels
% f.Units - axis units
% f.AxesCoords - axis coords
%
% Author: Andrii Kutsyk
% 30/05/2022

%% LOAD Metadata
if isempty(varargin)
    [path,name,ext] = fileparts(filePath);
    fid = fopen(fullfile(path,[name,'.json']), 'r');
else
    ext = varargin{1};
    fid = fopen(strcat(filePath,'.json'), 'r');
end

raw = fread(fid, inf);
str = char(raw');
fclose(fid);
val = jsondecode(str);

if (ext == "peak" || ext == ".peak")
    if (isfield(val, 'peakDimensions'))
        f.AxesCoords = flip(val.peakDimensions.AxesCoords);
        f.Labels = flip(val.peakDimensions.Labels);
        f.Shape = flip(val.peakDimensions.Shape);
        f.Units = flip(val.peakDimensions.Units);
    else
        f.Shape = flip(val.Dimensions);
    end
else
    if (isfield(val, 'spectraDimensions'))
        f.AxesCoords = flip(val.spectraDimensions.AxesCoords);
        f.Labels = flip(val.spectraDimensions.Labels);
        f.Shape = flip(val.spectraDimensions.Shape);
        f.Units = flip(val.spectraDimensions.Units);
    else
        f.Shape = flip(val.Dimensions);
    end
end

%% LOAD data
if (ext(1) ~= '.')
    ext = ['.', ext];
end

if isempty(varargin)
    fid = fopen(filePath, 'r');
else
    fid = fopen(strcat(filePath, ext), 'r');
end
f.data = fread(fid, prod(f.Shape), 'single');
fclose(fid);

if numel(f.data) == prod(f.Shape)
    f.data = reshape(f.data, f.Shape');
else
    vals = zeros(prod(f.Shape),1);
    vals(1:length(f.data)) = f.data;
    f.data = reshape(vals, f.Shape');
end
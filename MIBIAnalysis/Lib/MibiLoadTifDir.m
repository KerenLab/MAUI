function [FinalImage,chanelNames] =  MibiLoadTifDir(FileTif)
% function [FinalImage,chanelNames] =  MibiLoadTifDir(FileTif)
% Function gets the name of a directory of tiff files and returns 
% FinalImage: a 3d matrix of dimensions [X,Y,channel-number]
% chanelNames: a cell array of the channel names in the same order as the
% channels in FinalImage

listing = dir([FileTif,'/*.tif*']);

NumberImages = length(listing);
% read first image to get size and prealocate
[filepath,name,ext] = fileparts(listing(1).name);
filename = [listing(1).folder,'/',name,ext];
Im = double(imread(filename));
chanelNames{1} = name;
FinalImage = zeros (size(Im,1),size(Im,2),NumberImages);
FinalImage(:,:,1) = Im;

for i=2:NumberImages
    [filepath,name,ext] = fileparts(listing(i).name);
    filename = [listing(i).folder,'/',name,ext];
    FinalImage(:,:,i)= double(imread(filename));
    chanelNames{i} = name;
end
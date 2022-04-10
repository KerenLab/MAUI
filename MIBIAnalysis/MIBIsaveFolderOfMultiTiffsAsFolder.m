% MIBIsaveFolderOfMultiTiffsAsFolder
% The function receives a folder of multiTIFFs as downloaded from the tracker and
% breaks each image to a folder of channel stacks

% enter the directory name of the multiTIFF folder
multiTifDir = '/Users/nofar/Dropbox (Weizmann Institute)/Nofar Azulay’s files/Home/GvHD/test_2/';

% script
tifdir = [multiTifDir,'extracted'];
mkdir (tifdir);
mtFileNames = dir([multiTifDir,'*.tiff']);



for i = 1:length(mtFileNames);
    Filetif = mtFileNames(i).name;
    disp(['Working on image ',num2str(i) , ': ',Filetif]);
    [FinalImage,chanelNames] =  MibiLoadMultiTiff([multiTifDir,'/',Filetif]);

    % save single TIFs
    [pathstr, fname, ext] = fileparts(Filetif);
    MibiSaveTifs ([tifdir,'/',fname,'/' , 'TIFs' , '/'], FinalImage, chanelNames); %nofar addedd TIF
    %MibiSaveTifs ([tifdir,'/',fname,'/'], FinalImage, chanelNames);
end
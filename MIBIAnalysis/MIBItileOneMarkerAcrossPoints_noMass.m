% MIBItileOneMarkerAcrossPoints
% Script creates a tiles images of each channel in different points in the
% dimensions specified by the user. All points are scaled the same.

corePath = {'/Users/nofar/Dropbox (Weizmann Institute)/Nofar Azulay’s files/Home/ark-analysis/data/Bin_files/2021-11-03_Slide103_TMA3_run8/extracted_full_range/fov-2-scan-1/', ...
   '/Users/nofar/Dropbox (Weizmann Institute)/Nofar Azulay’s files/Home/ark-analysis/data/Bin_files/2021-11-03_Slide103_TMA3_run8/extracted_mass_deficient/fov-2-scan-1/',...
    '/Users/nofar/Dropbox (Weizmann Institute)/Nofar Azulay’s files/Home/ark-analysis/data/Bin_files/2021-11-03_Slide103_TMA3_run8/extracted_panel/fov-2-scan-1/'}; % cores to work on. Can add several paths, separated by commas. 
% Note: If given a tiff file, the script assumes it is a multiTIFF. 
%       If given a directory, the script assumes this is a directory of single tifs.

coreNames = {'Full-range','Mass-deficeint' , 'Manual-seperation'}; % Names of cores to print on image

FS = 24; % Font size for FOV names

xTileNum = 1; % Number of rows in tile
yTileNum = 3; % Number of columns in tile
outDir = '/Users/nofar/Dropbox (Weizmann Institute)/Nofar Azulay’s files/Home/ark-analysis/data/Bin_files/2021-11-03_Slide103_TMA3_run8/tiled/fov-2-scan-1/';
defaultCap = 50; % Cap to use if no other cap is specified in the massFile
xSize = 1030; % X-Size of the largest image to be tiled. Can add a few pixels to generate a border
ySize = 1030; % Y-Size of the largest image to be tiled. Can add a few pixels to generate a border

%% script

coreNum = length(corePath);
mkdir (outDir);
% load all cores
p=cell(coreNum,1);
for i=1:coreNum
    currName = corePath{i};
    [filepath,name,ext] = fileparts(currName);
    if strcmp (ext,'.tiff') % multitiff
        [p{i} , channelName] = MibiLoadMultiTiff(corePath{i});
    elseif exist(currName, 'dir') % directory of tif files
        [p{i} , channelName] = MibiLoadTifDir(corePath{i});
    else
        disp (['Error in file name ',num2str(i), '. Please supply multiTIFFs or directories.']);
    end
end

for i=1:length(channelName)

    % Generate the data to plot
    currChannel = channelName{i};
    
    tiledIm = zeros(xTileNum*xSize,yTileNum*ySize);
    for j=1:coreNum
        % cap and pad dat
        data = p{j}(:,:,i);
        data(data>defaultCap)=defaultCap;
        % if data is smaller than expected, pad it
        dataPad = zeros(xSize,ySize);
        dataPad([1:size(data,1)],[1:size(data,2)]) = data;
        % get position
        xpos = floor((j-1)/yTileNum)+1;
        ypos = mod(j,yTileNum);
        if (ypos == 0)
            ypos = yTileNum;
        end
        tiledIm([(xpos-1)*xSize+1:(xpos-1)*xSize+xSize],[(ypos-1)*ySize+1:(ypos-1)*ySize+ySize])=dataPad;
    end
    imwrite(uint16(tiledIm),[outDir,'/',currChannel,'_tiled.tif']);
end

% generate the borders image
borderIm = zeros(size(tiledIm));
if xTileNum>1
    for r = 1: xTileNum-1
        borderIm(r*xSize,:)=1;
    end
end
if yTileNum>1
    for c = 1: yTileNum-1
        borderIm(:,c*ySize)=1;
    end
end

% add labels
for j=1:coreNum
    xpos = floor((j-1)/yTileNum)+1;
    ypos = mod(j,yTileNum);
    if ypos == 0
        ypos = yTileNum;
    end
    borderImRGB = insertText(borderIm,[(ypos-1)*ySize+10,(xpos-1)*xSize+10],coreNames{j},'FontSize',FS,...
        'TextColor','white','BoxColor','black','BoxOpacity',0);
    borderIm = rgb2gray(borderImRGB);
end
    
imwrite(uint16(borderIm),[outDir,'/Labels_tiled.tif']);
        
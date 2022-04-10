% MIBIcompare_titers
% Interactive script for choosing titers

corePath = {'SampleData/extracted/Point1/', ...
    'SampleData/extracted/Point2/'}; % cores to work on. Can add several paths, separated by commas.
% Note: If given a tiff file, the script assumes it is a multiTIFF. 
%       If given a directory, the script assumes this is a directory of single tifs.


Headers = {'High','Low'}; % Headers describing each one of the points. Good for visualization
cap = 5; % Capping value for plotting. 
channel = {'CD45RO'}; % Channel to work on
K=25; %Nearest neighbours to use for density estimation
First =1; % 1- If this is the first time running. If the script is slow, you can change to 0 to save the loading time after the first run.

%% script
coreNum = length(corePath);
% load all cores
if First == 1
    p=cell(coreNum,1);
    for i=1:coreNum
        currName = corePath{i};
        [filepath,name,ext] = fileparts(currName);
        if strcmp (ext,'.tiff') % multitiff
            [p{i} , channelName{i}] = MibiLoadMultiTiff(corePath{i});
        elseif exist(currName, 'dir') % directory of tif files
            [p{i} , channelName{i}] = MibiLoadTifDir(corePath{i});
        else
            disp (['Error in file name ',num2str(i), '. Please supply multiTIFFs or directories.']);
        end
    end
end

% 1. plot titration with same cap
for i=1:coreNum
    [TF,channelInd] = ismember(channel,channelName{i});
    if TF
        MibiPlotDataAndCap(p{i}(:,:,channelInd),cap,[channel , ' - ' , Headers{i}]); plotbrowser on;
    end
end

% 2. plot intensity histograms
figure;
for i=1:coreNum
    [TF,channelInd] = ismember(channel,channelName{i});
    if TF
        currData = p{i}(:,:,channelInd);
        currDataLin = currData(:);
        currDataLin(currDataLin == 0) = [];
        hold on;
        histogram(currDataLin,'Normalization','probability','DisplayStyle','stairs');
        xlabel('Intensity');
        ylabel('Counts');
        plotbrowser on;
    end
end
legend(Headers);

% 3. calculate NN histograms and plot
for i=1:coreNum
    [TF,channelInd] = ismember(channel,channelName{i});
    if TF
        q{i}.IntNormD{channelInd}=MibiGetIntNormDist(p{i}(:,:,channelInd),p{i}(:,:,channelInd),K,2,K);
    end
end

figure;
for i=1:coreNum
    [TF,channelInd] = ismember(channel,channelName{i});
    if TF
        hold on;
        histogram(q{i}.IntNormD{channelInd},'DisplayStyle','stairs');
        xlabel('Mean distance to nearest neighbours');
        ylabel('Counts');
        plotbrowser on;
    end
end
legend(Headers);
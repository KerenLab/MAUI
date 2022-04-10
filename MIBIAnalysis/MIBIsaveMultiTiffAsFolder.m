% function MIBIsaveMultiTiffAsFolder
% function MIBIsaveMultiTiffAsFolder
% The function loads a multiTIFF image and breaks it up to channel stacks

% enter the file name of the multiTIFF
FileTif = '/Users/lkeren/Box/Leeat_Share/position/MIBI/install images/Fine and SuperFine 800 Images/TissueQC_Fine_800/2020-09-18T14-33-12_TissueQC_Fine_800_Run-2570_FOV1_Tissue_QC_Fine_800.tiff';
% enter the file name of the TIF directory 
tifDir = '/Users/lkeren/Box/Leeat_Share/position/MIBI/install images/Fine and SuperFine 800 Images/TissueQC_Fine_800/';

[FinalImage,chanelNames] =  MibiLoadMultiTiff(FileTif);

% save single TIFs
MibiSaveTifs ([tifDir,'TIFs/'], FinalImage, chanelNames);

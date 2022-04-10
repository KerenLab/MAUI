function [FinalImage,chanelNames] =  MibiLoadMultiTiff(FileTif)
% function [FinalImage,chanelNames] =  MibiLoadMultiTiff(FileTif)
% Function gets the name of a multichannel tiff generated by the ionpath
% platform and returns 
% FinalImage: a 3d matrix of dimensions [X,Y,channel-number]
% chanelNames: a cell array of the channel names in the same order as the
% channels in FinalImage

InfoImage=imfinfo(FileTif);
mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;
NumberImages=length(InfoImage);
FinalImage=zeros(nImage,mImage,NumberImages);
chanelNamesFull=cell(NumberImages,1);
TifLink = Tiff(FileTif, 'r');
for i=1:NumberImages
   TifLink.setDirectory(i);
   FinalImage(:,:,i)=double(TifLink.read());
   chanelNames{i} = strtrim(regexprep(InfoImage(i).PageName,'\(\w*\)',''));
end
for i = 1 : length(chanelNames)
    str = chanelNames{i};
    if strfind(str,'/')
       str(strfind(str,'/')) = '-';
       chanelNames{i} = str;
    end
end
% loc = find(strcmp(chanelNames,'CD206/MRC1'));
% strfind(str,'in')
% if~isempty(loc)
%     chanelNames{loc} = 'CD206-MRC1';
% end
TifLink.close();


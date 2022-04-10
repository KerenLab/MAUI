function MibiPlotDataAndCap(data,cap,titlestr)
% function MibiPlotDataAndCap(data,cap)
% function plots the data and sets any value larger than cap to cap

currdata = data;
currdata(currdata>cap) = cap;
figure('Name',strcat(titlestr{1},titlestr{2},titlestr{3}));
imagesc(currdata);
title(titlestr);
function rmkdir(path)
    path = strsplit(path, filesep);
    dirString = '';
    for i=1:numel(path)
        if i == 1 %nofar debug
           dirString = [dirString, path{i}]; %nofar debug
        else %nofar debug
            dirString = [dirString, filesep, path{i}];
            [~,~,~] = mkdir(dirString)
        end
    end
end
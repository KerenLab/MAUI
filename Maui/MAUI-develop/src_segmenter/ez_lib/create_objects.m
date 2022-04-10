%create objects from masks and export to fcs for ez_segmenter
function create_objects(point_index, pipeline_data)

%% Pre-processing steps to mask data, convert into fcs / csv usable format, and create attributes to be saved later

    % get point from provided index    
    point_names = pipeline_data.points.getNames();
    point_name = point_names{point_index};
    point = pipeline_data.points.get('name', point_name);
    
    % do final calculation of mask and create objects (i.e. stats)
    [mask, stats] = calc_mask(point, pipeline_data);
    if isempty(stats)
        disp([point_names{point_index}, ' did not have objects within mask'])
        return
    end
    % convert mask from logical array to numeric array
    mask = double(mask);
    
    %%% TEST
    % create column with unique object id's to add to stats structure
    total_objects = size(stats,1);
    total_object_list = num2cell(1:total_objects);
    uniq_obj_id = 'obj_id';
    [stats.(uniq_obj_id)] = total_object_list{:};
    
    % amend mask to map unique object ids onto the 'image' (here a matrix)
    % for each element in stats, for each row column in pixelList, assign
    % row, column in mask to value of element
    for id = 1:total_objects
        for elem = [stats(id).PixelList]'
            % PixelList ouputs in [x y z ...] coord fashion, so need to
            % switch order when picking location is mask
            mask(elem(2), elem(1)) = id;
        end          
    end
    %output this mask as map and use obj_id list here in struct.
    % also use majoraxislength and other values in output mat
    %%%
    
    % save objects with unique identifiers, masks as tifs in results folder
    save_array_to_tif(pipeline_data, point_name, mask, 'masks');  
    
    % make a data matrix the size of the number of labels x the number of markers using reshape
    % this essentially creates a matrix of pixels (rows) and their counts
    % for each marker (columns)
    counts_size = size(point.counts);
    countsReshape = reshape(point.counts, counts_size(1)*counts_size(2), counts_size(3));
    
    % set up parameters & matricies for data loading
    channelNum = counts_size(3);
    
    dataScaleSize = zeros(total_objects,channelNum);
    objSizes = zeros(total_objects,1);
    
    % for each object extract information and load into matrices
    for i=1:total_objects
        currData = countsReshape(stats(i).PixelIdxList,:);
        dataScaleSize(i,:) = sum(currData,1) / stats(i).Area;
        objSizes(i) = stats(i).Area;
    end
    
    % get object identities only for objects - add additional properties
    % from stats through extraction using deal function.
    objSizesVec = objSizes;
    dataScaleSizeObjs = dataScaleSize;
    
    objIdentity = 1:total_objects;
    objVec = objIdentity';
    
    mapped_obj_ids = mask;
    
    [objCentroids{1:total_objects}] = deal(stats.Centroid);
    objCentroids = objCentroids';
    
    [objMajorAxisLength{1:total_objects}] = deal(stats.MajorAxisLength);
    objMajorAxisLength = objMajorAxisLength';
    
    [objPixelList{1:total_objects}] = deal(stats.PixelList);
    objPixelList = objPixelList';
    
    % extract point number to include as point_id variable for each object
    [~, point_number] = fileparts(point_name);
    point_id = regexp(point_number, '[0-9]*', 'match');
    point_id = str2num(point_id{1});
    pointVector = repmat(point_id, total_objects, 1);
    
    % name of objects - future version where csv uses a struct2csv writer
    %nameVector = repmat(pipeline_data.named_objects, objNum, 1);
    
    % !!! collect data for ouput !!!
    dataScaleSize_out = [pointVector, objVec, objSizesVec, dataScaleSizeObjs];
    
%% object file attributes and formation
    % data for objects --> ouput headers
    channelLabelsForObjs = ['point_id'; 'obj_id'; 'obj_size'; pipeline_data.points.labels'];

    % set up paths
    disp(['Saving objects for Point ' num2str(point_index)]);
    [folder_path, point_folder] = fileparts(pipeline_data.points.getPath(point.name));
    [folder_path, ~] = fileparts(folder_path);
    pathSegment = [pipeline_data.run_path, filesep, 'objects_points'];
    resultsDir = [pipeline_data.run_path, filesep, 'objects_all'];

    % save attributes and locations (mask) of the objects extracted from ez_segmenter in point folders :)
    save([pathSegment,'/',point_folder,'/',pipeline_data.named_objects,'_objData.mat'],'channelLabelsForObjs','pointVector','objVec','objSizesVec','objCentroids','objMajorAxisLength', 'objPixelList', 'mapped_obj_ids','dataScaleSizeObjs');

    % write csv with objects to objects_points folder using MIBI_GUI func csvwrite_with_headers
    csvwrite_with_headers([pathSegment,'/',point_folder,'/',pipeline_data.named_objects,'_dataScaleSize.csv'], dataScaleSize_out, channelLabelsForObjs);
    csvwrite_with_headers([resultsDir,'/',pipeline_data.named_objects,'_dataScaleSize_',point_folder,'.csv'], dataScaleSize_out, channelLabelsForObjs);

    
end
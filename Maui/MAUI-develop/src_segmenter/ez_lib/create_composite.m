% Creates a composite channel based on GUI inputs, creates TIF, updates
% points with composite data.
% Selectively adds or subtracts counts to composite depending on + or - at
% end of channels in composite channel listbox
function create_composite(handles, pipeline_data)

    % hObject    handle to create_composite (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % pipeline_data    contains points and variables
    
    %get channel names from channels_listbox
    channels_to_combine = pipeline_data.channels_to_combine;
    %get dimensions of individual tif slice
    data_size = pipeline_data.points.get_data_size;
    data_size_slice = data_size(1:2);
    
    %for each point in point_listbox:
    for point_number = 1:numel(handles.point_list.String)
        point_name = handles.point_list.String{point_number};
        point = pipeline_data.points.get('name', point_name);
        counts = point.counts;
        tags = point.tags;
        %make an empty array the same size of tifs
        composite_array = zeros(data_size_slice);
        
        %pull data from the channels above and add images together (abs)
        for channel_number = 1:numel(channels_to_combine)
            full_channel = channels_to_combine{channel_number};
            %parse channel to get name and operation (add or subract counts)
            channel = strsplit(full_channel);
            %load channel counts         
            channel_index = find(strcmp(channel{1}, pipeline_data.points.labels()));
            %loop protects against people who forget to remove spaces
            if isempty(channel_index)
                channel_index = find(strcmp([channel{1}, ' '], pipeline_data.points.labels()));
            end
            %add or subtract counts to empty composite
            channel_counts = counts(:,:,channel_index);
            if channel{2} == '+'
                composite_array = composite_array + channel_counts;
            elseif channel{2} == '-'
                composite_array = composite_array - channel_counts;
            end
        end
        %get rid of any negative values after channel subtraction
        composite_array(composite_array < 0) = 0;
        
        %create naming scheme for new composite channel if necessary
        %save matrix to point manager counts
        point.add_composites(pipeline_data.name_of_composite_channel, composite_array, data_size(3)+1, tags);
        %update load/point view/all other areas w/ new composite channel      
        set(handles.select_channel, 'string', pipeline_data.points.labels());
        set(handles.view_data, 'string', pipeline_data.points.labels());
        set(handles.view_mask, 'string', pipeline_data.points.labels());
        
        %save composite matrix as tifs to file directory
        save_composite_to_tif(pipeline_data, point_name, composite_array, 'composites');     
    
    end
    
    %update csv file to incorporate new channel (ensures repeatibility)
    composite_to_csv(pipeline_data, pipeline_data.name_of_composite_channel);
end
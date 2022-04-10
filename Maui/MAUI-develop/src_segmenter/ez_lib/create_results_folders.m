function pipeline_data = create_results_folders(handles, pipeline_data)

    %global pipeline_data;    
    point_paths = keys(pipeline_data.points.pathsToPoints);
    pt_path = point_paths{1};
    
    [folder, ~, ~] = fileparts(pt_path);
    [folder, ~, ~] = fileparts(folder);
    % ask to name this run, save the results path for later use in save functions
    run_name = inputdlg('Name this run: ', 's'); 
    resultsPath = [folder, filesep, 'ezSegResults_', run_name{1}];
    pipeline_data.run_path = resultsPath;
    % make results folders
    mkdir(resultsPath);
    
    %% Make new info/csv file to populate with composites
    mkdir([resultsPath, filesep, 'info']);   
    
    %obtain csv file (csv_filepath) by using fileparts and fullfile functions
    [folder, ~, ~] = fileparts(pt_path);
    [folder, ~, ~] = fileparts(folder);
    csv_panelPath = [folder, filesep, 'info'];
    csvList = dir(fullfile(csv_panelPath, '*.csv'));
    csvList(find(cellfun(@isHiddenName, {csvList.name}))) = [];
    csv_filepath = [csvList.folder, filesep, csvList.name]; 
    %pull up panel from csv
    panel = dataset('File', csv_filepath, 'Delimiter', ',');
    %make sure mass name is accounted for:
    if ~isempty(strmatch('Mass', get(panel, 'VarNames')))
        masses = panel.Mass;
    elseif ~isempty(strmatch('Isotope', get(panel, 'VarNames')))
        masses = panel.Isotope;
    end
    %copy csv file and move the copy to the results/info folder
    nuPanelPath = [pipeline_data.run_path, filesep, 'info'];
    copyfile(csv_filepath, nuPanelPath);
    %movefile(nuPanel, nuPanelPath);
    
    %% make or append results, composites, masks folders (check using objects_all folder presence)
    form_path = [pipeline_data.run_path, filesep];
    
    if exist([form_path, 'objects_all'], 'dir')
        append_results_folder(pipeline_data);
    else
        mkdir([form_path, 'objects_all']);
        append_results_folder(pipeline_data)
    end
        
end
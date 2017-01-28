function saveToFile(this, plantids, varargin)
    % Get the spectra objects
    if isempty(plantids)
        return
    end
    if isnumeric(plantids)
        idx = plantids;
    else
        idx = [];
        for i = 1:length(plantids)
            idx = [idx;find(strcmp(this.PlantNames, plantids{i}))]; %#ok<AGROW>
        end
    end
    plants = this.Plants(idx);
    dupids = [];
    
    % Saving to file
    hwait = waitbar(0,'Saving to file...', 'WindowStyle', 'modal');
    
    % Make the save structure
    plantsSave = cell2struct(this.Plants(idx),this.PlantNames(idx));
    
    if numel(varargin) > 0
        [path,fname,ext] = fileparts(varargin{1});
        file = sprintf('%s%s',fname,ext);
    else
        % Select a file
        [file,path] = uiputfile('*.mat','Save Fits As...');
    end
    
    % Save the file
    save(fullfile(path,file),'-struct','plantsSave');
    close(hwait);
end
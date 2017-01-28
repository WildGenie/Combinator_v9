function setInitialConditions(this, plantids)
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
    
    data = inputdlg({'Name','Value'},'Initial Conditions',[1;1],{'MLC','0'});
    
    if isempty(data)
        return
    end
    
    % Open the plot browsers
    for i = 1:length(plants)
        plants{i}.initialConditionsNames = {data{1}};
        plants{i}.initialConditionsValues = str2double(data{2});
    end
end
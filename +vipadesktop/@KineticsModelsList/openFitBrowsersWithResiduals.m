function hfig = openFitBrowsersWithResiduals(this, plantids)
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

    % Open the plot browsers
    for i = 1:length(plants)
        hfig = plants{i}.plotbrowser('fits+residuals');
    end
end
function hfig = exportToSimBiology(this, plantids)
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

    % Set the path length using an input box
    data = inputdlg({'Base Workspace Name','Path Length [cm]'},'Simbiology Export',[1;1],{'simBioTable','1'});
    baseVariableName = data{1};
    pathlength = str2double(data{2});
    
    % Open the plot browsers
    for i = 1:length(plants)
        if i == 1
            t = plants{i}.getTable(1,pathlength);
        else
            t = union(t,plants{i}.getTable(i,pathlength));
        end
        %plants{i}.exportDOCOglobals();
    end
    assignin('base',baseVariableName,t);
    fprintf('''%s'' added to base workspace\n',baseVariableName);
end
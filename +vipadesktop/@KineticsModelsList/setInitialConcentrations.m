function hfig = setInitialConcentrations(this, plantids)
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
    plantNames = this.PlantNames(idx);
    dupids = [];
    
    % Allow for data importing
    [filename,filepath] = uigetfile( ...
            {  '*.xlsx','Excel Files (*.xlsx)'}, ...
               'Pick a file', ...
               'MultiSelect', 'off');

    if filepath == 0
        excelData = [];
        nameColumn = {};
    else
        [~,~,excelData] = xlsread(fullfile(filepath,filename));
        firstRow = excelData(1,:);
        nameColumnIdx = find(strcmp(firstRow,'Scan ID'));
        intTimeColumnIdx = find(strcmp(firstRow,'Int Time [us]'));
        O3ColumnIdx = find(strcmp(firstRow,'[O3]'));
        D2ColumnIdx = find(strcmp(firstRow,'[D2]'));
        COColumnIdx = find(strcmp(firstRow,'[CO]'));
        N2ColumnIdx = find(strcmp(firstRow,'[N2]'));
        NOColumnIdx = find(strcmp(firstRow,'[NO]'));
        O2ColumnIdx = find(strcmp(firstRow,'[O2]'));
        % Construct the columns
        nameColumn = excelData(2:end,nameColumnIdx);
        intTimeColumn = excelData(2:end,intTimeColumnIdx);
        O3Column = excelData(2:end,O3ColumnIdx);
        D2Column = excelData(2:end,D2ColumnIdx);
        COColumn = excelData(2:end,COColumnIdx);
        N2Column = excelData(2:end,N2ColumnIdx);
        NOColumn = excelData(2:end,NOColumnIdx);
        O2Column = excelData(2:end,O2ColumnIdx);
    end
    
    ttot = table();
    % Open the plot browsers
    for i = 1:length(plants)
        t = plants{i}.initialConditionsTable;
        %t=[];
        excelIdx = find(strcmp(nameColumn,plantNames{i}));
        if isempty(t) || ~isempty(excelIdx)
            varNames = {'O3','D2','CO','N2','NO','O2','intWindow'};
            rowNames = plantNames(i);
            if isempty(excelIdx)
                data = num2cell(zeros(1,numel(varNames)));
            else
                data = num2cell([O3Column{excelIdx} ...
                    D2Column{excelIdx} ...
                    COColumn{excelIdx} ...
                    N2Column{excelIdx} ...
                    NOColumn{excelIdx} ...
                    O2Column{excelIdx} ...
                    intTimeColumn{excelIdx}]);
            end
            t = table(data{:},'RowNames',rowNames,'VariableNames',varNames);
            plants{i}.initialConditionsTable = t;
        else
            t.Properties.RowNames = plantNames(i);
        end
        if isempty(ttot)
            ttot = t;
        else
            ttot = vertcat(ttot,t);
        end
        %plants{i}.exportDOCOglobals();
    end
    
    tout = uiedittable(ttot);
    
    for i = 1:length(plants)
        plants{i}.initialConditionsTable = tout(strcmp(tout.Properties.RowNames,plantNames(i)),:);
    end
end
function openDialog(this)
    [filename,filepath] = uigetfile( ...
        {  '*.mat','MAT-files (*.mat)'; ...
           '*.pgo','PGOPHER-files (*.pgo)'; ...
           '*.par','HITRAN PAR-files (*.par)'; ...
           '*.*',  'All Files (*.*)'}, ...
           'Pick a file', ...
           'MultiSelect', 'on');

    if filepath == 0
        return
    end
       
    % Check to see if there is only one file
    if ischar(filename)
        filename = {filename};
    end
       
    % Iterate over files and import them one by one
    hwait = waitbar(0,'Loading Files...', 'WindowStyle', 'modal');
    for i = 1:numel(filename)
        % Load in the data file
        [~,fname,ext] = fileparts(filename{i});
        
        % Check to see if it's a pgopher file
        if strcmp(ext,'.pgo')
            % Import the file using the linelist
            h = fitspectraobjects.linelist('pgopherfile',fullfile(filepath,filename{i}));
            this.FitSpectraList.addItem(h,0,0,this.makeVariableName(fname));
        end
        
        % Check to see if it's a hitran par file
        if strcmp(ext,'.par')
            % Import the file using the linelist
            h = fitspectraobjects.linelist('hitranparfile',fullfile(filepath,filename{i}));
            this.FitSpectraList.addItem(h,0,0,this.makeVariableName(fname));
        end
        
        if strcmp(ext,'.mat')
            % Load the file
            data = load(fullfile(filepath,filename{i}));
            
            % Import the variables
            fields = fieldnames(data);
            for j = 1:numel(fields)
                switch class(data.(fields{j}))
                    case 'kineticsobject'
                        h = data.(fields{j});
                        if isempty(h.name)
                            this.SpectraList.addItem(h,0,0,fields{j});
                        else
                            this.SpectraList.addItem(h,0,0,this.makeVariableName(h.name));
                        end
                    case 'spectraobjects.spectraobject'
                        h = data.(fields{j});
                        if isempty(h.name)
                            this.SpectraList.addItem(h,0,0,fields{j});
                        else
                            this.SpectraList.addItem(h,0,0,this.makeVariableName(h.name));
                        end
                    case 'fitspectraobjects.linelist'
                        h = data.(fields{j});
                        if isempty(h.name)
                            this.FitSpectraList.addItem(h,0,0,fields{j});
                        else
                            this.FitSpectraList.addItem(h,0,0,this.makeVariableName(h.name));
                        end
                    case 'kineticsfitobject'
                        h = data.(fields{j});
                        if isempty(h.name)
                            this.FitsList.addItem(h,0,0,fields{j});
                        else
                            this.FitsList.addItem(h,0,0,this.makeVariableName(h.name));
                        end
                    case 'fitsobjects.fitsobject'
                        h = data.(fields{j});
                        if isempty(h.name)
                            this.FitsList.addItem(h,0,0,fields{j});
                        else
                            this.FitsList.addItem(h,0,0,this.makeVariableName(h.name));
                        end
                    case 'imagesobjects.imagesobject'
                        h = data.(fields{j});
                        if isempty(h.name)
                            this.ImagesList.addItem(h,0,0,fields{j});
                        else
                            this.ImagesList.addItem(h,0,0,this.makeVariableName(h.name));
                        end
                    case 'kineticsmodelsobjects.kineticsmodelobject'
                        h = data.(fields{j});
                        if isempty(h.name)
                            this.KineticsModelsList.addItem(h,0,0,fields{j});
                        else
                            this.KineticsModelsList.addItem(h,0,0,this.makeVariableName(h.name));
                        end
                end
            end
        end
        waitbar(i/numel(filename),hwait);
    end
    close(hwait);
end
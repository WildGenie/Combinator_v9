classdef KineticsModelsList < handle
    %PIDTOOLPLANTLIST
    
    % Author(s): Baljeet Singh 18-Oct-2013
    % Copyright 2013 The MathWorks, Inc.
    
    properties (SetObservable = true, AbortSet = true)
        LocalWorkspace
        SampleTime
        TimeUnit
    end
    properties (SetObservable = true, Dependent = true)
        SelectedPlantIndex
    end
    properties
        PlantNames = {}
        StatusBar
    end
    properties (Dependent = true)
        Plants
        NumPlants
        SampledPlants
        SelectedPlant
        SelectedPlantName
        SelectedPlantSampleTime
        SelectedPlantTimeUnit
        SelectedPlantNUP
        SelectedPlantInspectorData
    end
    properties (Access = private)
        NUPData
        InspectorData
        SelectedPlantIndex_ = 0
        SelectedPlant_
        enabledWSListener = true
        LocalWorkspaceView
    end
    properties (SetAccess = private)
        isSelectedPlantAdded
    end
    events
        OpenLoopRelinearizationRequested
        ClosedLoopRelinearizationRequested
        PlantIdentificationRequested
        PlantsEvent
        ImportRequested
    end
    methods
        function this = KineticsModelsList(varargin)
            %PIDTOOLPLANTLIST
            
            this.LocalWorkspace = toolpack.databrowser.LocalWorkspaceModel;
            if nargin > 0
                for i = 1:nargin
                    G = varargin{i};
                    if ~isempty(inputname(i))
                        name = inputname(i);
                    elseif ~isempty(G.Name)
                        name = G.Name;
                    else
                        name = 'Plant';
                    end
                    this.addPlant(G, 0,[], name);
                end
            end
        end
        function set.LocalWorkspace(this, val)
            %SET
            this.LocalWorkspace = val;
            addlistener(this.LocalWorkspace, 'ComponentChanged', @(~, evnt) localWorkspaceChangeCallback(this, evnt));
        end
        function setWorkspace(this, val)
            %SET
            this.LocalWorkspace = val;
        end
        function addItem(this, val, NUP, inspectordata, name)
            % Spectra Properties
            %name = 'spectra1';
            
            allnames = this.PlantNames;
            k = 1;
            while ismember(name, allnames)
                name = sprintf('%s%d','Plant',k);
                k = k+1;
            end
            if ~isempty(this.StatusBar)
                this.StatusBar.reset;
                this.StatusBar.showWaitBar(ctrlMsgUtils.message('Control:pidtool:strAddingPlantInfo',name));
                this.StatusBar.ParentTool = 'pidtuner';
            end
            this.PlantNames = [this.PlantNames; name];
            this.enabledWSListener = false;
            this.LocalWorkspace.assignin(name, val);
            this.enabledWSListener = true;
            if nargin >= 3
                this.NUPData = setfield(this.NUPData, name, NUP);
            else
                this.NUPData = setfield(this.NUPData, name, 0);
            end
            if nargin < 4
                inspectordata = [];
            end
            this.InspectorData = setfield(this.InspectorData, name, inspectordata); %#ok<*SFLD>
        end
        function removePlant(this, plantname)
            %REMOVEPLANT
            
            id = find(strcmp(this.PlantNames, plantname));
            if id == this.SelectedPlantIndex
                warndlg(pidtool.utPIDgetStrings('cst','strCannotRemovePlant'));
                this.enabledWSListener = false;
                this.LocalWorkspace.assignin(this.SelectedPlantName, this.SelectedPlant);
                this.enabledWSListener = true;
                return
            elseif id < this.SelectedPlantIndex
                this.SelectedPlantIndex_ = this.SelectedPlantIndex_ - 1;
            end
            this.enabledWSListener = false;
            this.LocalWorkspace.clear(plantname);
            this.enabledWSListener = true;
            this.PlantNames(id) = [];
            this.NUPData = rmfield(this.NUPData, plantname);
            notify(this, 'PlantsEvent', pidtool.desktop.pidtuner.tc.PlantsEventData(false, id, false));
        end
        function renamePlant(this, oldname, newname)
            %RENAMEPLANT
            
            if ismember(newname,this.PlantNames)
                if any(strmatch(oldname,this.LocalWorkspace.who, 'exact')) % this is to support renaming through API
                    this.enabledWSListener = false;
                    this.LocalWorkspace.rename(oldname,newname);
                    this.enabledWSListener = true;
                end
                if strcmp(oldname,this.SelectedPlantName)
                    id = find(strcmp(this.PlantNames, newname));
                    this.SelectedPlantIndex_ = id; % this is to enable deleting of oldplant
                end
                
                this.removePlant(oldname);
                id = find(strcmp(this.PlantNames, newname));
                notify(this, 'PlantsEvent', pidtool.desktop.pidtuner.tc.PlantsEventData(false, false, id)); %#ok<FNDSB>
                this.SelectedPlantIndex = this.SelectedPlantIndex; % this is to refresh all plants data in GUI
            else
                id = find(strcmp(this.PlantNames, oldname));
                this.PlantNames{id} = newname;
                NUP = getfield(this.NUPData, oldname); %#ok<*GFLD>
                this.NUPData = rmfield(this.NUPData, oldname);
                this.NUPData = setfield(this.NUPData, newname, NUP);
                if any(strmatch(oldname,this.LocalWorkspace.who, 'exact')) % this is to support renaming through API
                    this.enabledWSListener = false;
                    this.LocalWorkspace.rename(oldname,newname);
                    this.enabledWSListener = true;
                end
                notify(this, 'PlantsEvent', pidtool.desktop.pidtuner.tc.PlantsEventData(false, false, id));
            end
        end
        function val = get.Plants(this)
            %GET
            
            n = this.NumPlants;
            val = cell(n,1);
            wsstate = this.LocalWorkspace.getState();
            for i = 1:n
                plantname = this.PlantNames{i};
                G = wsstate.(plantname);
                val{i} = G;
            end
        end
        function set.SelectedPlantIndex(this, val)
            %SET
            
            if val <= this.NumPlants
                this.SelectedPlantIndex_ = val;
                if val > 0
                    G = this.LocalWorkspace.getValue(this.SelectedPlantName);
                else
                    G = tf([]);
                end
                G.InputName = 'u';
                G.OutputName = 'y';
                this.SelectedPlant_ = G;
                if ~((this.isSelectedPlantAdded) && (val == this.NumPlants))
                    this.isSelectedPlantAdded = false;
                end
            else
                error('Index exceeds number of Plants');
            end
        end
        function val = get.SelectedPlant(this)
            %GET
            
            if isempty(this.SelectedPlant_)
                if this.SelectedPlantIndex > 0
                    val = this.LocalWorkspace.getValue(this.SelectedPlantName);
                else
                    val = tf(nan);
                end
            else
                val = this.SelectedPlant_;
            end
            if ~isempty(this.TimeUnit) && ~strcmp(val.TimeUnit,this.TimeUnit)
                TU = this.TimeUnit;
                val = localSamplePlantsForTimeUnit({val}, TU);
                val = val{1};
            end
            if ~isempty(this.SampleTime) && val.Ts ~= this.SampleTime
                TS = this.SampleTime;
                val = localSamplePlantsForSampleTime({val}, TS);
                val = val{1};
            end
        end
        function set.SelectedPlant(this, val)
            %SET
            
            id = find(strcmp(this.PlantNames, val));
            if isempty(id)
                error('Specified plant does not exist in the plant-list');
            else
                this.SelectedPlantIndex = id;
            end
        end
        function val = get.SelectedPlantIndex(this)
            %GET
            
            val = this.SelectedPlantIndex_;
        end
        function val = get.SelectedPlantName(this)
            %GET
            
            if this.SelectedPlantIndex > 0
                val = this.PlantNames{this.SelectedPlantIndex};
            else
                val = '';
            end
        end
        function val = get.NumPlants(this)
            %GET
            
            val = length(this.PlantNames);
        end
        function val = get.SelectedPlantSampleTime(this)
            %GET
            
            val = getTs(this.SelectedPlant);
        end
        function val = get.SelectedPlantTimeUnit(this)
            %GET
            
            val = this.SelectedPlant.TimeUnit;
        end
        function val = get.SelectedPlantNUP(this)
            %GET
            
            val = getfield(this.NUPData, this.SelectedPlantName);
        end
        function val = get.SelectedPlantInspectorData(this)
            %GET
            
            val = getfield(this.InspectorData, this.SelectedPlantName);
        end
        function val = get.SampledPlants(this)
            %GET
            
            plants = this.Plants;
            if ~isempty(this.SampleTime)
                TS = this.SampleTime;
            else
                TS = this.SelectedPlant.Ts;
            end
            if ~isempty(this.TimeUnit)
                TU = this.TimeUnit;
            else
                TU = this.SelectedPlantTimeUnit;
            end
            plants = localSamplePlantsForTimeUnit(plants, TU);
            val = localSamplePlantsForSampleTime(plants, TS);
        end
        function hfig = openPlotBrowsers(this, plantids)
            plantids
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
                hfig = plants{i}.plotbrowser();
            end
        end
        function [dupplants, dupids] = exportPlants(this, plantids, force)
            %EXPORTPLANTS
            
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
            for i = 1:length(plants)
                plant = plants{i};
                plantname = this.PlantNames{idx(i)};
                if (evalin('base',['exist(''', plantname,''', ''var'');']) == 0)
                    assignin('base', plantname, plant);
                else
                    if force
                        assignin('base', plantname, plant);
                    else
                        dupids = [dupids; idx(i)]; %#ok<AGROW>
                    end
                end
            end
            dupplants = this.PlantNames(dupids);
        end
        function out = isSelectedPlantZero(this)
            %ISSELECTEDPLANTZERO
            
            G = this.SelectedPlant;
            try
                out = (isstatic(G) && dcgain(G)==0);
            catch
                out = false;
            end
        end
        function out = isSelectedPlantLinearized(this)
            out = ~isempty(getfield(this.InspectorData, this.SelectedPlantName));
        end
    end
end
function localWorkspaceChangeCallback(this, evnt)
%LOCALWORKSPACECHANGECALLBACK

if this.enabledWSListener
    plantnames = this.PlantNames;
    WSplantnames = this.LocalWorkspace.getWho;
    if evnt.WSRename
        renamedplant = this.LocalWorkspace.getDatabase.Data.OUT{1};
        newname = this.LocalWorkspace.getDatabase.Data.IN{1};
        this.renamePlant(renamedplant, newname);
    elseif evnt.WSDelete || evnt.WSClear
        removedplants = setdiff(plantnames, WSplantnames);
        for i = 1:length(removedplants)
            this.removePlant(removedplants{i});
        end
    elseif evnt.WSChange % An item was added
        for i = 1:length(WSplantnames)
            if sum(strcmp(WSplantnames{i},this.PlantNames)) == 0
                this.addItem(this.LocalWorkspace.getValue(WSplantnames{i}),0,0,WSplantnames{i});
            end
        end
    end
end
end

function val = localSamplePlantsForSampleTime(plants, TS)
WarningState = warning('off'); %#ok<WNOFF>
n = length(plants);
val = cell(n,1);
if TS == 0
    for i = 1:n
        if plants{i}.Ts <= 0
            val{i} =  plants{i};
        else
            if isa(plants{i}, 'frd')
                val{i} = tf(nan);
            elseif isa(plants{i}, 'idproc')
                val{i} = d2c(zpk(plants{i}), 'Tustin');
            else
                val{i} = d2c(plants{i}, 'Tustin');
            end
        end
        val{i}.InputName = 'u';
        val{i}.OutputName = 'y';
    end
else
    for i = 1:n
        if plants{i}.Ts == TS || plants{i}.Ts == -1
            val{i} =  plants{i};
        elseif plants{i}.Ts == 0
            if isa(plants{i}, 'frd')
                val{i} = tf(nan);
            elseif isa(plants{i}, 'idproc')
                val{i} = c2d(zpk(plants{i}),TS,'Tustin');
            else
                val{i} = c2d(plants{i},TS,'Tustin');
            end
        else
            if isa(plants{i}, 'frd')
                val{i} = tf(nan);
            elseif isa(plants{i}, 'idproc')
                val{i} = d2d(zpk(plants{i}),TS, 'Tustin');
            else
                val{i} = d2d(plants{i},TS,'Tustin');
            end
        end
        val{i}.InputName = 'u';
        val{i}.OutputName = 'y';
    end
end
warning(WarningState);
end

function val = localSamplePlantsForTimeUnit(plants, TU)
n = length(plants);
val = cell(n,1);

for i = 1:n
    if ~strcmp(plants{i}.TimeUnit,TU)
        val{i} = chgTimeUnit(plants{i}, TU);
    else
        val{i} = plants{i};
    end
end
end
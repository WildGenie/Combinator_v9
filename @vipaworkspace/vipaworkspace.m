classdef vipaworkspace < handle
    %VIPAWORKSPACE
    
    % Author(s): Baljeet Singh 20-Nov-2013
    % Copyright 2013 The MathWorks, Inc.
    
    properties
        TPComponent
        DataBrowser
        ImagesList
        CalibrationList
        SpectraList
        FitSpectraList
        FitsList
		KineticsModelsList
        
        % Tabs
        hometab
        acquiretab
		calibrationtab
        fittingtab
        fitanalysistab
        figuretab
        
        stopAcquireBoolean = false;
        
		% VIPA Calibration Tool
		VIPACalibrationTool
		
        % Image Acquire Functions Library
        acquireOperations
        acquireFunctions
        singleImageAcquireFunctions
        kineticsImagesAcquireFunctions
        fitAnalysisFunctions
        
        % Acquire Functions
        acquireOperation
        acquireFunction % Takes no arguments, returns images or spectra, timestamps, {'images','spectra'}
        singleImageAcquireFunction % Takes no arguments, returns a single image
        kineticsImagesAcquireFunction % Takes no arguments, returns multiple images, timestamps
        fitAnalysisFunction % Takes three arguments: time, moleculeConcentrations, moleculeLabels
    end
    properties (SetAccess = private)
        Type = 'MATLAB'
        StatusBar
    end
    %properties(Access = private)
    properties
        Listeners
        GroupName
        MD
    end
    
    methods
        function this = vipaworkspace(varargin)
            %PIDTOOLDESKTOP
            %====================================================================================================(Plant List)
            this.ImagesList = vipadesktop.ImagesList();
            this.CalibrationList = vipadesktop.CalibrationList();
            this.SpectraList = vipadesktop.SpectraList();
            this.FitSpectraList = vipadesktop.FitSpectraList();
            this.FitsList = vipadesktop.FitsList();
			this.KineticsModelsList = vipadesktop.KineticsModelsList();
%             this.SpectraList2 = vipadesktop.SpectraList();
            this.DataBrowser = vipadesktop.VIPAdataBrowser(this);
            this.ImagesList.setWorkspace(this.DataBrowser.imagesWorkspace);
            %this.CalibrationList.setWorkspace(this.DataBrowser.calibrationWorkspace);
            this.SpectraList.setWorkspace(this.DataBrowser.spectraWorkspace);
            this.FitSpectraList.setWorkspace(this.DataBrowser.fitspectraWorkspace);
            this.FitsList.setWorkspace(this.DataBrowser.fitsWorkspace);
			this.KineticsModelsList.setWorkspace(this.DataBrowser.kineticsmodelsWorkspace);
            %this.SpectraList.addSpectra(0,0, 0,'test1');
%             this.SpectraList2.setDataBrowser(this.DataBrowser);
%             this.SpectraList2.addSpectra(0,0, 0,0);
            %=================================================================================================(Desktop Group)
            this.GroupName = tempname;
            this.TPComponent = vipadesktop.ToolGroup(this.GroupName,'VIPA Workspace');
            this.TPComponent.setDataBrowser(this.DataBrowser.View.getPanel);
            
            % Get Image Acquire Operations
            this.acquireOperations = {'staticReference','kineticsReference'};
            this.acquireOperation = this.acquireOperations{1};
            
            % Get Image Acquire functions
            acquireFunctionsPackage = what('acquireFunctions');
            singleImageAcquireFunctionsPackage = what('singleImageAcquireFunctions');
            kineticsImagesAcquireFunctionsPackage = what('kineticsImagesAcquireFunctions');
            fitAnalysisFunctionsPackage = what('fitAnalysisFunctions');
            
            this.acquireFunctions = {};
            for i = 1:numel(acquireFunctionsPackage.m)
                [~,b,~] = fileparts(acquireFunctionsPackage.m{i});
                this.acquireFunctions{end+1} = str2func(sprintf('%s.%s','acquireFunctions',b));
            end
            if numel(this.acquireFunctions) > 0
                this.acquireFunction = this.acquireFunctions{1};
            end
            
            this.singleImageAcquireFunctions = {};
            for i = 1:numel(singleImageAcquireFunctionsPackage.m)
                [~,b,~] = fileparts(singleImageAcquireFunctionsPackage.m{i});
                this.singleImageAcquireFunctions{end+1} = str2func(sprintf('%s.%s','singleImageAcquireFunctions',b));
            end
            if numel(this.singleImageAcquireFunctions) > 0
                this.singleImageAcquireFunction = this.singleImageAcquireFunctions{1};
            end
            
            this.kineticsImagesAcquireFunctions = {};
            for i = 1:numel(kineticsImagesAcquireFunctionsPackage.m)
                [~,b,~] = fileparts(kineticsImagesAcquireFunctionsPackage.m{i});
                this.kineticsImagesAcquireFunctions{end+1} = str2func(sprintf('%s.%s','kineticsImagesAcquireFunctions',b));
            end
            if numel(this.kineticsImagesAcquireFunctions) > 0
                this.kineticsImagesAcquireFunction = this.kineticsImagesAcquireFunctions{1};
            end
            
            this.fitAnalysisFunctions = {};
            for i = 1:numel(fitAnalysisFunctionsPackage.m)
                [~,b,~] = fileparts(fitAnalysisFunctionsPackage.m{i});
                this.fitAnalysisFunctions{end+1} = str2func(sprintf('%s.%s','fitAnalysisFunctions',b));
            end
            if numel(this.fitAnalysisFunctions) > 0
                this.fitAnalysisFunction = this.fitAnalysisFunctions{1};
            end
            
            % Tab Controls
            this.hometab = vipadesktop.hometab(this.TPComponent);
            this.TPComponent.add(this.hometab.TPComponent);
			
            this.acquiretab = vipadesktop.acquiretab(this.TPComponent,this.acquireFunctions,this.singleImageAcquireFunctions,this.kineticsImagesAcquireFunctions);
            this.TPComponent.add(this.acquiretab.TPComponent);
            addlistener(this.acquiretab,'AcquireFunctionBoxAction',@(~,~) this.setAcquireFunction(this.acquiretab.acquireFunctionComboBox.SelectedItem));
            addlistener(this.acquiretab,'AcquireOperationBoxAction',@(~,~) this.setAcquireOperation(this.acquiretab.acquireOperationComboBox.SelectedItem));
            
			this.VIPACalibrationTool = vipadesktop.VIPACalibrationTool(this.TPComponent);
            this.TPComponent.add(this.VIPACalibrationTool.tooltab);
			
            this.fittingtab = vipadesktop.fittingtab(this.TPComponent);
            this.TPComponent.add(this.fittingtab.TPComponent);
            
            this.fitanalysistab = vipadesktop.fitanalysistab(this.TPComponent,this.fitAnalysisFunctions);
            this.TPComponent.add(this.fitanalysistab.TPComponent);
            addlistener(this.fitanalysistab,'fitAnalysisFunctionBoxAction',@(~,~) this.setFitAnalysisFunction(this.fitanalysistab.fitAnalysisFunctionComboBox.SelectedItem));
            
            this.figuretab = vipadesktop.figuretab(this.TPComponent);
            this.TPComponent.add(this.figuretab.TPComponent);
            addlistener(this.hometab,'NewButtonPressed',@(~,~) this.newDialog());
            addlistener(this.hometab,'OpenButtonPressed',@(~,~) this.openDialog());
            addlistener(this.hometab,'OpenButtonKineticsObjectPressed',@(~,~) this.openDialogKineticsObject());
            addlistener(this.hometab,'SaveAllButtonPressed',@(~,~) this.saveAllDialog());
            
            % Add Spectrum acquire listener
            addlistener(this.acquiretab,'AcquireButtonPressed',@(~,~) this.acquire());
            addlistener(this.acquiretab,'AcquireSpectrumButtonPressed',@(~,~) this.acquireSpectrum());
			addlistener(this.acquiretab,'AverageSpectrumButtonPressed',@(~,~) this.averageSpectrum());
            addlistener(this.acquiretab,'StopAcquireButtonPressed',@(~,~) this.stopAcquire());
            
            %=====================================================================================================(PID Tuner)
            %this.PIDTuner = pidtool.desktop.PIDTuner(this, desiredtype, baselinecontroller);
            %=======================================================================================(Initial design and Open)
            this.open();
            drawnow;
%             if this.PIDTuner.TC.DataSourcePlot.hasBaseline && ~this.PIDTuner.TC.DataSourcePlot.showBaseline
%                 if strcmp(this.Type, 'MATLAB')
%                     this.PIDTuner.TC.setStatusText(pidtool.utPIDgetStrings('cst','tunerdlg_unstablebase_warning'),'warning');
%                 else
%                     this.PIDTuner.TC.setStatusText(pidtool.utPIDgetStrings('scd','tunerdlg_unstableblock_warning'),'warning');
%                 end
%             end
%             this.PIDTuner.TC.oneClick();
%             this.PIDTuner.updateMessagePanel();
%             %=====================================================================================================(Listeners)
             setClosingApprovalNeeded(this.TPComponent,true);
             addlistener(this.TPComponent, 'GroupAction',@(src, evnt) cbCloseGroup(this, evnt));
%             addlistener(this.TPComponent, 'ClientAction',@(src, evnt) cbClientAction(this, evnt));
%             addlistener(this.PlantList, 'OpenLoopRelinearizationRequested', ...
%                 @(es,ed)showOpenLoopRelinearizationTab(this));
%             addlistener(this.PlantList, 'ClosedLoopRelinearizationRequested', ...
%                 @(es,ed)showClosedLoopRelinearizationTab(this));
%             addlistener(this.PlantList, 'PlantIdentificationRequested', ...
%                 @(es,ed)showIdentificationTab(this));
            addlistener(this.DataBrowser, 'ComponentRequest', ...
                @(es,ed)cbPlantListBrowserRequest(this,ed));
        end
        function open(this)
            %OPEN
            this.TPComponent.open;
            groupwidth = 960;
            
            % Connect to statusbar
             this.MD = com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
             loc = com.mathworks.widgets.desk.DTLocation.createExternal( int16(100), int16(100), int16(groupwidth), int16(710));
             this.MD.setGroupLocation(this.TPComponent.Name, loc);
             Frame = this.MD.getFrameContainingGroup(this.GroupName);
             this.StatusBar = ctrluis.toolstrip.StatusMessage(Frame);

%             if ~strcmp(this.Type, 'MATLAB')
%                 this.SimulinkGateway.StatusBar = this.StatusBar;
%             end
%             db = this.MD.getClient('DataBrowserContainer', this.TPComponent.Name);
%             db.setMinimized(true);
        end
        function close(this)
            %CLOSE
            this.PIDTuner.isGroupActionClosing = true;
            %delete(this.PIDTuner.ResponsePlots);
            this.TPComponent.close;
        end
        function val = getPIDBlockHandle(this)
            %GETPIDBLOCKHANDLE
            val = this.SimulinkGateway.PIDBlockHandle;
        end
        function show(this)
            %SHOW
            if ~isempty( this.SimulinkGateway)
                this.SimulinkGateway.update();
            end
            this.TPComponent.open;
        end
        function configureTiling(this,src)
            
            if isempty(this.PIDTuner.ResponsePlots)
                return;
            end
            
            % get tile id of all pid tuner figures
            for i = 1:length(this.PIDTuner.ResponsePlots)
                pidfigurename = this.PIDTuner.ResponsePlots(i).Figure.Name;
                A(i) = this.MD.getClientLocation(pidfigurename).getTile;
            end
            
            % find tiles that have one and only one pid tuner figure
            a = unique(A);
            if length(a)==1
                pidtiles = a(length(A)==1);
            else
                pidtiles = a(hist(A,a)==1);
            end
            
            % find sysid tile
            if isempty(this.PlantIdentifier)
                sysidtile = -2;
            else
                sysidtile = this.MD.getClientLocation(this.PlantIdentifier.Figure.Name).getTile;
            end
            
            % find re-lin tool tile
            if isempty(this.ClosedLoopRelinearizer)
                cllintile = -2;
            else
                cllintile = this.MD.getClientLocation(this.ClosedLoopRelinearizer.Figure.Name).getTile;
            end
            
            % find tiles that have only one figure and the figure is for pid
            % tuner
            uniquepidtiles = pidtiles(pidtiles~=sysidtile & pidtiles~=cllintile);
            
            n = length(uniquepidtiles);
            N = this.MD.getDocumentTiledDimension(this.GroupName).width * this.MD.getDocumentTiledDimension(this.GroupName).height;
            
            if N==1 && n==1 % split screen
                this.MD.setDocumentArrangement(this.GroupName, this.MD.TILED, java.awt.Dimension(2,1));
            elseif N==2 && n==1 && ~isa(src,'pidtool.desktop.PIDTuner') % put new figure in non-pid tile
                if ~isempty(this.PlantIdentifier)
                    figure(this.PlantIdentifier.Figure);
                end
                if ~isempty(this.ClosedLoopRelinearizer)
                    figure(this.ClosedLoopRelinearizer.Figure);
                end
            end
        end
        
        % Get Set functions
        function setFitAnalysisFunction(this,functionString)
            this.fitAnalysisFunction = str2func(sprintf('%s.%s','fitAnalysisFunctions',functionString));
            
%             fitAnalysisFunctionsPackage = what('fitAnalysisFunctions');
%             this.fitAnalysisFunctions = {};
%             for i = 1:numel(fitAnalysisFunctionsPackage.m)
%                 [~,b,~] = fileparts(fitAnalysisFunctionsPackage.m{i});
%                 this.fitAnalysisFunctions{end+1} = str2func(sprintf('%s.%s','fitAnalysisFunctions',b));
%             end
%             if numel(this.fitAnalysisFunctions) > 0
%                 this.fitAnalysisFunction = this.fitAnalysisFunctions{1};
%             end
        end
        function setAcquireFunction(this,acquireFunctionString)
            this.acquireFunction = str2func(sprintf('%s.%s','acquireFunctions',acquireFunctionString));
        end
        function setAcquireOperation(this,acquireOperationString)
            this.acquireOperation = acquireOperationString;
        end
    end
end

%=================================================================================================================(Callbacks)
function cbCloseGroup(this, evnt)
    %CBCLOSEGROUP
    ET = evnt.EventData.EventType;
    if strcmp(ET, 'CLOSING')
        this.TPComponent.approveClose;
    end
    if strcmp(ET, 'CLOSED')
        L = this.Listeners;
        for ct = 1:numel(L)
            delete(L{ct})
        end
        delete(this);
    end
end

function cbPlantListBrowserRequest(this,ed)
end

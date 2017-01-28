classdef VIPAdataBrowser < handle
    %PLANTLISTBROWSER
    
    % Author(s): Baljeet Singh 05-Sep-2013
    % Copyright 2013 The MathWorks, Inc.
    
    properties
		Parent
        Model
        View
        imagesWorkspace
        imagesWorkspaceView
        spectraWorkspace
        spectraWorkspaceView
        fitsWorkspace
        fitsWorkspaceView
        fitspectraWorkspace
        fitspectraWorkspaceView
        calibrationWorkspace
        calibrationWorkspaceView
        kineticsmodelsWorkspace
        kineticsmodelsWorkspaceView
    end
    events
        ComponentRequest
    end
    methods
        function obj = VIPAdataBrowser(Parent)
            %PLANTLISTBROWSER
            this.Parent = Parent;
			
            % Construct the basic model
            obj.Model = vipadesktop.DataBrowserModel;%toolpack.databrowser.DataBrowserModel;
            obj.Model.remove('base');
            obj.Model.remove('filter');
            obj.Model.remove('preview');
            obj.Model.remove('local');
            
            % Add the necessary sections
            tc = vipadesktop.LocalWorkspaceModel;%toolpack.databrowser.LocalWorkspaceModel;
            tc.Name = 'images';
            tc.NewVariableFunction = @imagesobjects.imagesobject;
            tc.NewVariableBaseName = 'images';
            obj.Model.add(tc);
            tc = vipadesktop.LocalWorkspaceModel;%toolpack.databrowser.LocalWorkspaceModel;
            tc.Name = 'calibration';
            tc.NewVariableFunction = @calibrationobjects.vipacalibration;
            tc.NewVariableBaseName = 'calibration';
            %obj.Model.add(tc);
            tc = vipadesktop.LocalWorkspaceModel;%toolpack.databrowser.LocalWorkspaceModel;
            tc.Name = 'spectra';
            tc.NewVariableFunction = @spectraobjects.spectraobject;
            tc.NewVariableBaseName = 'spectra';
            obj.Model.add(tc);
            tc = vipadesktop.LocalWorkspaceModel;%toolpack.databrowser.LocalWorkspaceModel;
            tc.Name = 'fitspectra';
            tc.NewVariableFunction = @fitspectraobjects.linelist;
            tc.NewVariableBaseName = 'linelist';
            obj.Model.add(tc);
            tc = vipadesktop.LocalWorkspaceModel;%toolpack.databrowser.LocalWorkspaceModel;
            tc.Name = 'fits';
            tc.NewVariableFunction = @fitsobjects.fitsobject;
            tc.NewVariableBaseName = 'fits';
            obj.Model.add(tc);
            tc = vipadesktop.LocalWorkspaceModel;%toolpack.databrowser.LocalWorkspaceModel;
            tc.Name = 'kineticsmodels';
            tc.NewVariableFunction = @kineticsmodelobjects.simbiologymodelobject;
            tc.NewVariableBaseName = 'kineticsmodels';
            obj.Model.add(tc);
            
            % Set View Parameters
            obj.View = vipadesktop.DataBrowserView(obj.Model);%toolpack.databrowser.DataBrowserView(obj.Model);
            setTitle(getComponent(obj.View,'images'),'Images');
            %setTitle(getComponent(obj.View,'calibration'),'Calibration');
            setTitle(getComponent(obj.View,'spectra'),'Spectra');
            setTitle(getComponent(obj.View,'fitspectra'),'Fit Spectra');
            setTitle(getComponent(obj.View,'fits'),'Fits');
            setTitle(getComponent(obj.View,'kineticsmodels'),'Kinetics Models');
            reset(obj.View);
            
            % Set internal parameters
            obj.imagesWorkspace = obj.Model.getComponent('images');
            obj.imagesWorkspaceView = obj.View.getComponent('images');
            obj.calibrationWorkspace = obj.Model.getComponent('calibration');
            %obj.calibrationWorkspaceView = obj.View.getComponent('calibration');
            obj.spectraWorkspace = obj.Model.getComponent('spectra');
            obj.spectraWorkspaceView = obj.View.getComponent('spectra');
            obj.fitspectraWorkspace = obj.Model.getComponent('fitspectra');
            obj.fitspectraWorkspaceView = obj.View.getComponent('fitspectra');
            obj.fitsWorkspace = obj.Model.getComponent('fits');
            obj.fitsWorkspaceView = obj.View.getComponent('fits');
            obj.kineticsmodelsWorkspace = obj.Model.getComponent('kineticsmodels');
            obj.kineticsmodelsWorkspaceView = obj.View.getComponent('kineticsmodels');
            
            % Set Images popup parameters
            selectionPopupMenu = obj.imagesWorkspaceView.getSelectionPopupMenu;
            nonselectionPopupMenu = obj.imagesWorkspaceView.getNoSelectionPopupMenu;
            WarningState = warning('off','MATLAB:Containers:Map:NoKeyToRemove');
            selectionPopupMenu.removeMenuItem('RecordCopyingMenuItem');
			
			% Add Images context menu items
			menuitems = vipadesktop.getpackagemfiles('imagesobjects.contextmenu');
			for i = numel(menuitems):-1:1
				s.Text = eval(sprintf('%s.menuitemText',menuitems{i}));
				s.Name =  eval(sprintf('%s.menuitemName',menuitems{i}));
				f = str2func(sprintf('%s.menucallback',menuitems{i}));
				s.Callback =  @(selecteditems) f(this.Parent,selecteditems);
				s.MultiSelection = eval(sprintf('%s.menuitemMultiSelection',menuitems{i}));
				selectionPopupMenu.addMenuItem(s,1);
			end
			
            %nonselectionPopupMenu.removeMenuItem('RecordCreationMenuItem');
            nonselectionPopupMenu.removeMenuItem('PasteMenuItem');
            warning(WarningState);
            hideColumn(obj.imagesWorkspaceView,'Value');
            hideColumn(obj.imagesWorkspaceView,'Class');
            hideColumn(obj.imagesWorkspaceView,'Size');
            hideColumn(obj.imagesWorkspaceView,'Bytes');
            
            % Set Spectra popup parameters
            selectionPopupMenu = obj.spectraWorkspaceView.getSelectionPopupMenu;
            nonselectionPopupMenu = obj.spectraWorkspaceView.getNoSelectionPopupMenu;
            WarningState = warning('off','MATLAB:Containers:Map:NoKeyToRemove');
            selectionPopupMenu.removeMenuItem('RecordCopyingMenuItem');
            
			% Add menu items from contextmenu directory
			menuitems = vipadesktop.getpackagemfiles('spectraobjects.contextmenu');
			for i = numel(menuitems):-1:1
				s.Text = eval(sprintf('%s.menuitemText',menuitems{i}));
				s.Name =  eval(sprintf('%s.menuitemName',menuitems{i}));
				f = str2func(sprintf('%s.menucallback',menuitems{i}));
				s.Callback =  @(selecteditems) f(this.Parent,selecteditems);
				s.MultiSelection = eval(sprintf('%s.menuitemMultiSelection',menuitems{i}));
				selectionPopupMenu.addMenuItem(s,1);
			end
			
            %nonselectionPopupMenu.removeMenuItem('RecordCreationMenuItem');
            nonselectionPopupMenu.removeMenuItem('PasteMenuItem');
            warning(WarningState);
            hideColumn(obj.spectraWorkspaceView,'Value');
            hideColumn(obj.spectraWorkspaceView,'Class');
            hideColumn(obj.spectraWorkspaceView,'Size');
            hideColumn(obj.spectraWorkspaceView,'Bytes');
            
            % Set Fit Spectra popup parameters
            selectionPopupMenu = obj.fitspectraWorkspaceView.getSelectionPopupMenu;
            nonselectionPopupMenu = obj.fitspectraWorkspaceView.getNoSelectionPopupMenu;
            WarningState = warning('off','MATLAB:Containers:Map:NoKeyToRemove');
            selectionPopupMenu.removeMenuItem('RecordCopyingMenuItem');
			
			% Add menu items from contextmenu directory
			menuitems = vipadesktop.getpackagemfiles('fitspectraobjects.contextmenu');
			for i = numel(menuitems):-1:1
				s.Text = eval(sprintf('%s.menuitemText',menuitems{i}));
				s.Name =  eval(sprintf('%s.menuitemName',menuitems{i}));
				f = str2func(sprintf('%s.menucallback',menuitems{i}));
				s.Callback =  @(selecteditems) f(this.Parent,selecteditems);
				s.MultiSelection = eval(sprintf('%s.menuitemMultiSelection',menuitems{i}));
				selectionPopupMenu.addMenuItem(s,1);
			end
			
            %nonselectionPopupMenu.removeMenuItem('RecordCreationMenuItem');
            nonselectionPopupMenu.removeMenuItem('PasteMenuItem');
            warning(WarningState);
            hideColumn(obj.fitspectraWorkspaceView,'Value');
            hideColumn(obj.fitspectraWorkspaceView,'Class');
            hideColumn(obj.fitspectraWorkspaceView,'Size');
            hideColumn(obj.fitspectraWorkspaceView,'Bytes');
            
            % Set Fits popup parameters
            selectionPopupMenu = obj.fitsWorkspaceView.getSelectionPopupMenu;
            nonselectionPopupMenu = obj.fitsWorkspaceView.getNoSelectionPopupMenu;
            WarningState = warning('off','MATLAB:Containers:Map:NoKeyToRemove');
            selectionPopupMenu.removeMenuItem('RecordCopyingMenuItem');
			
			% Add menu items from contextmenu directory
			menuitems = vipadesktop.getpackagemfiles('fitsobjects.contextmenu');
			for i = numel(menuitems):-1:1
				s.Text = eval(sprintf('%s.menuitemText',menuitems{i}));
				s.Name =  eval(sprintf('%s.menuitemName',menuitems{i}));
				f = str2func(sprintf('%s.menucallback',menuitems{i}));
				s.Callback =  @(selecteditems) f(this.Parent,selecteditems);
				s.MultiSelection = eval(sprintf('%s.menuitemMultiSelection',menuitems{i}));
				selectionPopupMenu.addMenuItem(s,1);
			end
			
            %nonselectionPopupMenu.removeMenuItem('RecordCreationMenuItem');
            nonselectionPopupMenu.removeMenuItem('PasteMenuItem');
            warning(WarningState);
            hideColumn(obj.fitsWorkspaceView,'Value');
            hideColumn(obj.fitsWorkspaceView,'Class');
            hideColumn(obj.fitsWorkspaceView,'Size');
            hideColumn(obj.fitsWorkspaceView,'Bytes');
            
            % Set Kinetics Models Parameters
            selectionPopupMenu = obj.kineticsmodelsWorkspaceView.getSelectionPopupMenu;
            nonselectionPopupMenu = obj.kineticsmodelsWorkspaceView.getNoSelectionPopupMenu;
            WarningState = warning('off','MATLAB:Containers:Map:NoKeyToRemove');
            selectionPopupMenu.removeMenuItem('RecordCopyingMenuItem');

			% Add menu items from contextmenu directory
			menuitems = vipadesktop.getpackagemfiles('kineticsmodelsobjects.contextmenu');
			for i = numel(menuitems):-1:1
				s.Text = eval(sprintf('%s.menuitemText',menuitems{i}));
				s.Name =  eval(sprintf('%s.menuitemName',menuitems{i}));
				f = str2func(sprintf('%s.menucallback',menuitems{i}));
				s.Callback =  @(selecteditems) f(this.Parent,selecteditems);
				s.MultiSelection = eval(sprintf('%s.menuitemMultiSelection',menuitems{i}));
				selectionPopupMenu.addMenuItem(s,1);
			end
			
            %nonselectionPopupMenu.removeMenuItem('RecordCreationMenuItem');
            nonselectionPopupMenu.removeMenuItem('PasteMenuItem');
            warning(WarningState);
            hideColumn(obj.kineticsmodelsWorkspaceView,'Value');
            hideColumn(obj.kineticsmodelsWorkspaceView,'Class');
            hideColumn(obj.kineticsmodelsWorkspaceView,'Size');
            hideColumn(obj.kineticsmodelsWorkspaceView,'Bytes');
        end
    end
end
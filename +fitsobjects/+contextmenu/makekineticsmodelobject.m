classdef makekineticsmodelobject
	properties (Constant = true)
		menuitemName = 'makekineticsmodelobject';
		menuitemText = 'Make Kinetics Model Object';
		menuitemMultiSelection = true;
	end

	methods (Static)
		function menucallback(Parent,SelectedItems)
			WorkspaceList = Parent.FitsList;
			
			% Get the objects
			if isempty(SelectedItems.Variables)
				return
			end
			if isnumeric(SelectedItems.Variables)
				idx = SelectedItems.Variables;
			else
				idx = [];
				for i = 1:length(SelectedItems.Variables)
					idx = [idx;find(strcmp(WorkspaceList.PlantNames, SelectedItems.Variables{i}))]; %#ok<AGROW>
				end
			end
			plants = WorkspaceList.Plants(idx);
			plantnames = WorkspaceList.PlantNames(idx);
			dupids = [];

			obj = kineticsmodelsobjects.kineticsmodelobject();
			
			% Open the plot browsers
			for i = 1:length(plants)
				ind = obj.newentry(plantnames{i});
				obj.setkineticsdata(ind,plants{i}.t,plants{i}.fitbNames,plants{i}.fitb,plants{i}.fitbError,plants{i}.initialConditionsTable);
			end
			
			Parent.KineticsModelsList.addItem(obj,0,0,'kineticsobject1');
		end
	end
end
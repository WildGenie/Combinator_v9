classdef exporttobaseworkspace
	properties (Constant = true)
		menuitemName = 'exporttobaseworkspace';
		menuitemText = 'Export to Base Workspace';
		menuitemMultiSelection = true;
	end

	methods (Static)
		function menucallback(Parent,SelectedItems)
			WorkspaceList = Parent.KineticsModelsList;
			
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

			% Open the plot browsers
			for i = 1:length(idx)
				assignin('base',...
					WorkspaceList.PlantNames{idx(i)},...
					WorkspaceList.Plants{idx(i)});
			end
		end
	end
end
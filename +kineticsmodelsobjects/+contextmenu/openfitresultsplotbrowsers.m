classdef openfitresultsplotbrowsers
	properties (Constant = true)
		menuitemName = 'openfitresultsplotbrowsers';
		menuitemText = 'Open Fit Results Plot Browser(s)';
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
			plants = WorkspaceList.Plants(idx);
			plantnames = WorkspaceList.PlantNames(idx);
			dupids = [];

			% Open the plot browsers
			for i = 1:length(plants)
				hfig = plants{i}.fitresultsplotbrowser();
				set(hfig,'Name',sprintf('Kresult:%s',plantnames{i}));
				set(hfig,'NumberTitle','off');
				Parent.TPComponent.addFigure(hfig);
			end
		end
	end
end
classdef savetofile
	properties (Constant = true)
		menuitemName = 'savetofile';
		menuitemText = 'Save to File';
		menuitemMultiSelection = true;
	end

	methods (Static)
		function menucallback(Parent,SelectedItems)
			WorkspaceList = Parent.KineticsModelsList;
			
			WorkspaceList.saveToFile(SelectedItems.Variables);
		end
	end
end
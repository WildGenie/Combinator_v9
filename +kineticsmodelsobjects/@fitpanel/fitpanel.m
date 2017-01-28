classdef fitpanel < handle
    % Line Profile Browser Class
    properties
        % Parent imagesobject
        Parent
        
        % Handles
        figureHandle
		
		% UI Controls
		fitButton
		fitParameterTable
		fitEquationTable
		variablesTable
    end
    
	% Figure file: fitpanelgui.m
	%    
	
    methods
        function this = fitpanel(ParentObject)
            this.Parent = ParentObject;
            
			this.fitpanelgui();

            % Construct the figure
            if isempty(this.Parent.name)
				set(this.figureHandle,'CloseRequestFcn',@figCloseFunction);
			else
                set(this.figureHandle,'Name',sprintf('KPanel:%s',this.Parent.name),'NumberTitle','off','CloseRequestFcn',@figCloseFunction);
            end
			
            % Figure Close Function
            function figCloseFunction(src,callbackdata)
                delete(gcf);
                delete(this);
            end
        end
        function delete(obj)
            % Remove figure handles
            delete(obj.figureHandle);
        end
        function Update(this)
        end
		function updatefitparameters(this)
			this.Parent.fitLowerUpperStartingScope = this.fitParameterTable.Data;
		end
		function performfit(this)
			this.Parent.fitLowerUpperStartingScope = this.fitParameterTable.Data;
			this.Parent.performfit();
		end
    end
	
	methods (Static)
	end
end
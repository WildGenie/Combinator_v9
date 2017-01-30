classdef fitcoefficientsbrowser < handle
    % Line Profile Browser Class
    properties
        % Parent imagesobject
        Parent
        
        % Handles
        figureHandle
        axesHandle
        plotHandle
        sliderHandle
        h
        herrorminus
        herrorplus
        
        noImageBoolean
        
        options
    end
    
    methods
        function this = fitcoefficientsbrowser(ParentObject,options)
            this.Parent = ParentObject;
            this.options = options;
            
            % Construct the figure
            if isempty(this.Parent.name)
                this.figureHandle = figure('CloseRequestFcn',@figCloseFunction);
            else
                this.figureHandle = figure('Name',this.Parent.name,'NumberTitle','off','CloseRequestFcn',@figCloseFunction);
            end
            
            % Construct the plot and axes
            this.axesHandle = axes('Parent',this.figureHandle,'position',[0.13 0.20 0.79 0.72]);

            this.Update();
            
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
            this.imagePlot();
        end
        
        % Internal Functions
        function imagePlot(this)
%             if ishandle(this.plotHandle)
%                 delete(this.plotHandle)
%             end
            
            for i = 1:numel(this.Parent.fitbNames)
                ind = this.Parent.fitbNamesInd(i);
                he = errorbar(this.Parent.t,this.Parent.fitb(ind,:),this.Parent.fitbError(ind,:),'.-');
				addlistener(he,'MarkedClean',@(obj,~) seterrorbarwidths(obj,0.015));
                %plot(this.Parent.t,this.Parent.fitb(ind,:),'.-');
                hold on;
            end
            xlabel(this.axesHandle,'Time [\mus]');
            ylabel(this.axesHandle,'Fit Coefficient');
            legend(this.axesHandle,this.Parent.fitbNames);
        end
    end
end
classdef fitbrowser < handle
    % Line Profile Browser Class
    properties
        % Parent imagesobject
        Parent
        
        % Handles
        figureHandle
        axesHandle
        sliderHandle
		
		expPlotHandles
        simPlotHandles
        
        noImageBoolean
    end
    
    methods
        function this = fitbrowser(ParentObject)
            this.Parent = ParentObject;
            
            % Construct the figure
            if isempty(this.Parent.name)
                this.figureHandle = figure('CloseRequestFcn',@figCloseFunction);
            else
                this.figureHandle = figure('Name',this.Parent.name,'NumberTitle','off','CloseRequestFcn',@figCloseFunction);
            end
            
            % Construct the plot and axes
            this.axesHandle = axes('Parent',this.figureHandle,'position',[0.13 0.20 0.79 0.72]);
            this.sliderHandle = uicontrol('Parent',this.figureHandle,'Style','slider','Position',[81,10,419,23],...
              'value',1, 'min',1, 'max',1,'sliderstep',[1 1]);
            this.imagePlot();
            this.Update();
            set(this.sliderHandle,'Callback',@(es,ed) this.updateImagePlot());
			
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
            % Save the previous value
            oldSliderValue = round(get(this.sliderHandle,'Value'));
            oldSliderMax = this.sliderHandle.Max;

            % Reset the slider bounds
            newSliderMax = numel(this.Parent.kineticsdata);
            if newSliderMax == 0
                newSliderMax = 1;
            end
            if oldSliderMax == oldSliderValue || oldSliderValue > newSliderMax
                newSliderValue = newSliderMax;
            else
                newSliderValue = oldSliderValue;
            end

            % Apply the slider bounds
            this.sliderHandle.Value = newSliderValue;
            this.sliderHandle.Max = newSliderMax;
            this.sliderHandle.SliderStep = [1/newSliderMax 10/newSliderMax];

            % Hide the slider if necessary
            if newSliderMax == 1
                this.sliderHandle.Visible = 'off';
            else
                this.sliderHandle.Visible = 'on';
            end

            this.updateImagePlot();
        end
        
        % Internal Functions
        function imagePlot(this)
            ind = round(this.sliderHandle.Value);
            
            if false
            else
				% set the color order
                co = [  1 1 1;...
                        0    0.4470    0.7410;...
                        0.8500    0.3250    0.0980;...
                        0.4940    0.1840    0.5560;...
                        0.4660-0.1    0.6740-0.1    0.1880-0.1;...
                        0.6350    0.0780    0.1840];
                set(this.axesHandle,'ColorOrder',co);
				
				% get the number of molecules
				numplots = numel(this.Parent.kineticsdata(1).moleculenames);
				
				% Make the experiment plots
                this.expPlotHandles = [];
                for i = 1:numplots
                    this.expPlotHandles(i) = plot(this.axesHandle,NaN,NaN,'o','LineWidth',1.5);
                    hold(this.axesHandle,'on');
                end
				
				% Make the simulation plots
				this.axesHandle.ColorOrderIndex = 1;
                this.simPlotHandles = [];
                for i = 1:numplots
                    this.simPlotHandles(i) = plot(this.axesHandle,NaN,NaN,'-','LineWidth',1);
                    hold(this.axesHandle,'on');
                end
				
                hold(this.axesHandle,'off');
                %legend({this.Parent.fitbNames{:},this.Parent.fitbNames{:}},'interpreter','none');

				xlabel(this.axesHandle,'Time (\mus)');
				ylabel(this.axesHandle,'Concentration');
                this.noImageBoolean = false;
            end
        end
        function updateImagePlot(this)
            ind = round(this.sliderHandle.Value);
            
			for i = 1:numel(this.expPlotHandles)
				set(this.expPlotHandles(i),'XData',this.Parent.kineticsdata(ind).time);
				set(this.expPlotHandles(i),'YData',this.Parent.kineticsdata(ind).concs(i,:));
				chisqr = '';
			end
            
			if ~isempty(this.Parent.fitdata)
				% Plot the fit data as well
				for i = 1:numel(this.expPlotHandles)
					xfit = linspace(min(this.Parent.kineticsdata(ind).time),max(this.Parent.kineticsdata(ind).time),10000);
					set(this.simPlotHandles(i),'XData',xfit);
					set(this.simPlotHandles(i),'YData',this.Parent.fitdata(ind).f{i}(xfit));
				end
				chisqr = this.Parent.fitdata(ind).redchisqr;
			end
			
            title(this.axesHandle,sprintf('%s, \\chi^2:%f',this.Parent.kineticsdata(ind).name,chisqr));
        end
    end
end
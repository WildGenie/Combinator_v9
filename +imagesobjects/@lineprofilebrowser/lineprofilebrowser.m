classdef lineprofilebrowser < handle
    % Line Profile Browser Class
    properties
        % Parent imagesobject
        Parent
        
        % Line Profile Indices
        lineProfileIndicesX
        lineProfileIndicesY

        % Handles
        figureHandle
        axesHandle
        plotHandle
        sliderHandle

        % Context menu
        axesmenu

        % Toggles
        highPassOn = false;
    end
    
    methods
        function this = lineprofilebrowser(ParentObject)
            this.Parent = ParentObject;
            
            % Construct the figure
            if isempty(this.Parent.name)
                this.figureHandle = figure('CloseRequestFcn',@figCloseFunction);
            else
                this.figureHandle = figure('Name',this.Parent.name,'NumberTitle','off','CloseRequestFcn',@figCloseFunction);
            end
            
            % Get the line profile indices
            this.lineProfileIndicesX = round(size(this.Parent.images,2)/2)*ones(1,size(this.Parent.images,1));
            this.lineProfileIndicesY = 1:size(this.Parent.images,1);
            
            % Set the coordinates on the image
            h = figure;imagesc(this.Parent.images(:,:,1));
            [cx,cy,~] = improfile;
            this.lineProfileIndicesX = round(cy);
            this.lineProfileIndicesY = round(cx);
            close(h);

            % Construct the plot and axes
            this.axesHandle = axes('Parent',this.figureHandle,'position',[0.13 0.20 0.79 0.72]);
            this.plotHandle = this.lineProfilePlot(1);
            this.updateLineProfilePlot(round(1));
            this.sliderHandle = uicontrol('Parent',this.figureHandle,'Style','slider','Position',[81,10,419,23],...
              'value',1, 'min',1, 'max',numel(this.Parent.time),'sliderstep',[1/numel(this.Parent.time) 10/numel(this.Parent.time)]);
            if numel(this.Parent.time) == 1
                this.sliderHandle.Visible = 'off';
            end
            set(this.sliderHandle,'Callback',@(es,ed) this.updateLineProfilePlot(round(get(es,'Value'))));
            
            % Add a menu for the axes
            this.axesmenu = uicontextmenu();
            uimenu('Parent',this.axesmenu,'Label','Toggle High Pass','Callback',@(s,e) this.toggleHighPass());
            set(this.axesHandle,'UIContextMenu',this.axesmenu);

            % Figure Close Function
            function figCloseFunction(src,callbackdata)
                delete(gcf);
                delete(this);
            end
        end
        function Update(this)
            % Save the previous value
            oldSliderValue = round(get(this.sliderHandle,'Value'));
            oldSliderMax = this.sliderHandle.Max;

            % Reset the slider bounds
            newSliderMax = numel(this.Parent.time);
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
            
            this.updateLineProfilePlot(round(get(this.sliderHandle,'Value')));
        end
        
        % Internal Functions
        function toggleHighPass(this)
            if this.highPassOn == true
                this.highPassOn = false;
            else
                this.highPassOn = true;
            end

            this.Update();
        end
        function hp = lineProfilePlot(this,ind)
            indcs = sub2ind(size(this.Parent.images),this.lineProfileIndicesX,this.lineProfileIndicesY,ind*ones(size(this.lineProfileIndicesX)));
            x = 1:numel(this.lineProfileIndicesX);
            y = this.Parent.images(indcs);
            if this.highPassOn == true
                y = y - smooth(y,20);
            end
            hp = plot(x,y,'Parent',this.axesHandle);
            ylim([0 6000]);
        end
        function updateLineProfilePlot(this,ind)
            indcs = sub2ind(size(this.Parent.images),this.lineProfileIndicesX,this.lineProfileIndicesY,ind*ones(size(this.lineProfileIndicesX)));
            x = 1:numel(this.lineProfileIndicesX);
            y = this.Parent.images(indcs);
            if this.highPassOn == true
                y = y - smooth(y,20);
            end
            set(this.plotHandle,'XData',x);
            set(this.plotHandle,'YData',y);
            title(this.axesHandle,sprintf('Image %i,T = %i',ind,this.Parent.time(ind)));
        end
    end
end
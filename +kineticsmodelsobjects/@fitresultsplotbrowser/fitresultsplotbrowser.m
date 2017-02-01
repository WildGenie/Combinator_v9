classdef fitresultsplotbrowser < handle
    % Line Profile Browser Class
    properties
        % Parent imagesobject
        Parent
        
        % Handles
        figureHandle
        axesHandle
		plotHandle
        mlrPlotHandle
		trendlinePlotHandle
		trendlineTextboxHandle
		filterTextbox
		xAxisTextbox
		yAxisTextbox
		multipleLinearXTextbox
		multipleLinearYTextbox
		
		xAxisString = 'CO';
		yAxisString = 'Adoco.*1e6./CO';
    end
    
    methods
        function this = fitresultsplotbrowser(ParentObject)
            this.Parent = ParentObject;
            
            % Construct the figure
            if isempty(this.Parent.name)
                this.figureHandle = figure(...
										'CloseRequestFcn',@figCloseFunction,...
										'HandleVisibility','callback');
            else
                this.figureHandle = figure('Name',this.Parent.name,'NumberTitle','off',...
										'CloseRequestFcn',@figCloseFunction,...
										'HandleVisibility','callback');
            end
            
			% Construct the filter box
			this.xAxisTextbox = uicontrol(...
					'Parent',this.figureHandle,...
					'String',{  'CO' },...
					'Style','edit',...
					'Units','normalized',...
					'Position',[0.25 0.915 0.24 0.04],...
					'Callback',@(~,~) this.Update(),...
					'Children',[]);
			this.yAxisTextbox = uicontrol(...
					'Parent',this.figureHandle,...
					'String',{ 'Adoco.*1e6./CO' },...
					'Style','edit',...
					'Units','normalized',...
					'Position',[0.50 0.915 0.24 0.04],...
					'Callback',@(~,~) this.Update(),...
					'Children',[]);
			this.filterTextbox = uicontrol(...
					'Parent',this.figureHandle,...
					'String',{  '' },...
					'Style','edit',...
					'Units','normalized',...
					'Position',[0.25 0.87 0.49 0.04],...
					'Callback',@(~,~) this.Update(),...
					'Children',[]);
					
			% Construct the multiple linear regression boxes
			this.multipleLinearXTextbox = uicontrol(...
					'Parent',this.figureHandle,...
					'String',{  'CO,N2' },...
					'Style','edit',...
					'Units','normalized',...
					'Position',[0.75 0.915 0.2 0.04],...
					'Callback',@(~,~) this.Update(),...
					'Children',[]);
% 			this.multipleLinearYTextbox = uicontrol(...
% 					'Parent',this.figureHandle,...
% 					'String',{  'Adoco*1e6./CO' },...
% 					'Style','edit',...
% 					'Units','normalized',...
% 					'Position',[0.75 0.87 0.2 0.04],...
% 					'Callback',@(~,~) this.Update(),...
% 					'Children',[]);
			
            % Construct the plot and axes
            this.axesHandle = axes('Parent',this.figureHandle,'position',[0.13 0.12 0.79 0.72]);
			
			% Make textbox on axes
			this.trendlineTextboxHandle = annotation(this.figureHandle,'textbox',...
						[0.15 0.77 0.62 0.0533088235294117],...
						'String',{'test'},...
						'LineStyle','none',...
						'FitBoxToText','off');
			
            this.makePlot();
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
            this.updatePlot();
        end
        
        % Internal Functions
        function makePlot(this)
			% Make the experiment plots
			this.plotHandle = [];
			
			this.trendlinePlotHandle = plot(this.axesHandle,NaN,NaN,'-','LineWidth',2,'Color',[0.7 0.7 0.7]);
			hold(this.axesHandle,'on');
            this.mlrPlotHandle = plot(this.axesHandle,NaN,NaN,'o','LineWidth',1.5,'Color',[0.7 0.7 0.7]);
			this.plotHandle = errorbar(this.axesHandle,NaN,NaN,NaN,'bo','LineWidth',1.5);
			hold(this.axesHandle,'off');

			xlabel(this.axesHandle,'CO');
			ylabel(this.axesHandle,'k1a');
        end
        function updatePlot(this)
			
			filterString = this.filterTextbox.String;
			
			% get the data
			prestring = '@(';
			dataCols = {};
			dataErrorCols = {};
			for i = 1:numel(this.Parent.fitTable.Properties.VariableNames)
				if i == 1
					prestring = [prestring this.Parent.fitTable.Properties.VariableNames{i}];
				else
					prestring = [prestring ',' this.Parent.fitTable.Properties.VariableNames{i}];
				end
				dataCols{i} = this.Parent.fitTable.(i);
				dataErrorCols{i} = edouble(this.Parent.fitTable.(i),this.Parent.fitErrorTable.(i));
			end
			prestring = [prestring ') '];
			
			xAxisString = this.xAxisTextbox.String{1};
			yAxisString = this.yAxisTextbox.String{1};
			fx = str2func([prestring xAxisString]);
			fy = str2func([prestring yAxisString]);
            x = fx(dataCols{:});
            %y = fy(dataCols{:});
			yedouble = fy(dataErrorCols{:});
			y = yedouble.value;
			ye = yedouble.errorbar;
			%warning('Errorbars not correct')
			
			%%% Perform a multiple linear regression
            mlrString = '';
            mlrX = x;
            mlrY = nan(size(x));
            try
                mlrXstring = this.multipleLinearXTextbox.String{1};
                mlrYstring = this.yAxisTextbox.String{1};
                mlrfx = str2func([prestring '[' mlrXstring ']']);
                mlrfy = str2func([prestring '[' mlrYstring ']']);
				mlryedouble = mlrfy(dataErrorCols{:});
                %b = regress(mlrfy(dataCols{:}),mlrfx(dataCols{:}));
				[b,stdx,mse] = lscov(mlrfx(dataCols{:}),mlryedouble.value,mlryedouble.weight);
				bStdErr = stdx/min(1,sqrt(mse));
                mlrY = mlrfx(dataCols{:})*b;
                mlrString = [mlrYstring ' = '];
                C = strsplit(mlrXstring,',');
                for i = 1:numel(b)
                    if i==1
                        mlrString = [mlrString sprintf('%.2g(%.1g)',b(i),bStdErr(i)) '*' C{i}];
                    else
                        mlrString = [mlrString ' + ' sprintf('%.2g(%.1g)',b(i),bStdErr(i)) '*' C{i}];
                    end
                end
            catch err
				err
            end
            %%% END MLR
            
			if isempty(filterString{1})
				set(this.plotHandle,'XData',x);
				set(this.plotHandle,'YData',y);
				set(this.plotHandle,'LData',ye);
				set(this.plotHandle,'UData',ye);
				set(this.mlrPlotHandle,'XData',mlrX);
				set(this.mlrPlotHandle,'YData',mlrY);
			else
				ffilter = str2func([prestring filterString{1}]);
				ind = ffilter(dataCols{:});
				set(this.plotHandle,'XData',x(ind));
				set(this.plotHandle,'YData',y(ind));
				set(this.plotHandle,'LData',ye(ind));
				set(this.plotHandle,'UData',ye(ind));
				set(this.mlrPlotHandle,'XData',mlrX(ind));
				set(this.mlrPlotHandle,'YData',mlrY(ind));
            end
			
			%%% End multiple linear regression
			
			% Plot a trendline
			xx = linspace(min(get(this.plotHandle,'XData')),max(get(this.plotHandle,'XData')),1000);
			ws = warning('off','all');  % Turn off warning
			pp = polyfit(get(this.plotHandle,'XData'),get(this.plotHandle,'YData'),1);
			warning(ws)  % Turn it back on.
			yy = polyval(pp,xx);
			this.trendlineTextboxHandle.String = sprintf('%g*x + %g\n%s',pp(1),pp(2),mlrString);
			set(this.trendlinePlotHandle,'XData',xx);
			set(this.trendlinePlotHandle,'YData',yy);
			
			xlabel(this.axesHandle,xAxisString,'Interpreter','none');
			ylabel(this.axesHandle,yAxisString,'Interpreter','none');
        end
    end
end
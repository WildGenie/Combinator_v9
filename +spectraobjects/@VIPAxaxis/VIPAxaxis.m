classdef VIPAxaxis < handle
    %kineticsobject
    
    properties
        % 
        title;

		% Plot axes
        hf;
        hSim;
		axExp;
		hExp;
		axSim;
		hSimSelect;
		hDottedConnection;
        hExpStem;
        axSelect;
		
        % Spectrum Parameters
        yIn;

        % Line Paramters
        linePositions;
        lineHeights;

        % Selected Line Parameters
        linePositionsSim;
        lineHeightsSim;
        
        % Fitted Parameters
        xaxisParams; % Struct containing wavenum parameters
        
		% Temporary Linking Params
		expLinkIndx;

        % Simulation Parameters
        wavenumSim = [];
        crossSectionSim = [];
    end
    
	methods (Static)
		[hfig,hax1,hax2,hax3,hplot1,hstem2A,hDottedConnection,hstem2B,hstem3] = createVIPAxaxisFigure(figtitle,expStemCallback,simCallback);
	end
	
    methods
        function obj = VIPAxaxis(centerWavenum,vertPoly,horizPoly,yIn)
            obj.xaxisParams = struct();
            obj.xaxisParams.centerWavenum = centerWavenum;
            obj.xaxisParams.vertPoly = vertPoly;
            obj.xaxisParams.horizPoly = horizPoly;
            obj.yIn = yIn;
            obj.wavenumSim = [];
            obj.crossSectionSim = [];
        end

        function obj = setSimulationSpectrum(obj,wavenum,crossSection)
            obj.wavenumSim = wavenum;
            obj.crossSectionSim = crossSection;
        end

        function hf = fitbrowser(obj,varargin)
            if isempty(obj.title)
                [obj.hf,obj.axExp,obj.axSelect,obj.axSim,...
				obj.hExp,obj.hExpStem,obj.hDottedConnection,obj.hSimSelect,obj.hSim] = obj.createVIPAxaxisFigure('VIPA X Axis',@obj.callback_ExpStem,@obj.callback_Sim);
            else
                [obj.hf,obj.axExp,obj.axSelect,obj.axSim,...
				obj.hExp,obj.hExpStem,obj.hDottedConnection,obj.hSimSelect,obj.hSim] = obj.createVIPAxaxisFigure(obj.title,@obj.callback_ExpStem,@obj.callback_Sim);
            end
            cursorMode = datacursormode(obj.hf);
            set(cursorMode,'UpdateFcn',@(o,e) obj.datatipUpdateFunction(o,e));
            axmenu = uicontextmenu();
            set(obj.axExp,'UIContextMenu',axmenu);
			hbrush = brush(obj.hf);
			set(hbrush,'ActionPostCallback',@(~,~) obj.weightedMeanOfBrushedPoints(obj.axExp,obj.hExp,obj.hExpStem));
			
            %obj.hSim = obj.plotSim(obj.axSim);
            obj.updatePlotSim(obj.axSim,obj.hSim);

            hold(obj.axSim,'on');
            %obj.hSimSelect = obj.plotSimSelect(obj.axSelect);hold(obj.axSim,'off');
            obj.updatePlotSimSelect(obj.axSim,obj.hSimSelect);

            %obj.hExpStem = obj.plotExpStem(obj.axSelect);
            obj.updatePlotExpStem(obj.axExp,obj.hExpStem);

            %hold(obj.axExp,'on');
            %obj.hExp = obj.plotExp(obj.axExp);hold(obj.axExp,'off');
            obj.updatePlotExp(obj.axExp,obj.hExp);
            
            uimenu('Parent',axmenu,'Label','Weighted Mean of Brushed Points','Callback',@(s,e) obj.weightedMeanOfBrushedPoints(obj.axExp,obj.hExp,obj.hExpStem));
            %uimenu('Parent',axmenu,'Label','Auto Select Peaks','Callback',@(s,e) obj.autoSelectPeaksGUI(obj.axExp,obj.hExp,obj.hExpStem));
            %uimenu('Parent',axmenu,'Label','Find Corresponding Peaks','Callback',@(s,e) obj.findCorrespondingPeaksGUI(obj.axSim,obj.hSimSelect));
            uimenu('Parent',axmenu,'Label','Fit the Peaks','Callback',@(s,e) obj.fitYaxisGUI(obj.axExp,obj.hExp,obj.hExpStem));
            %uimenu('Parent',axmenu,'Label','Fit the Lineshape','Callback',@(s,e) obj.fitLineshape(obj.axExp,obj.hExp,obj.hExpStem));

			% Load icons
			load(cat(2,fileparts(which('spectraobjects.VIPAxaxis')),'\Icons.mat'));
			
			ht = uitoolbar(obj.hf);
			uipushtool(ht,'CData',icons.leftIcon,...
					 'TooltipString','Shift Frequency Left',...
					 'ClickedCallback',...
					 @obj.fitFrequencyAxisFigureShiftLeft);
			uipushtool(ht,'CData',icons.setWavelengthIcon,...
					 'TooltipString','Set Reference Wavelength',...
					 'ClickedCallback',...
					 @obj.fitFrequencyAxisFigureShiftSet);
			uipushtool(ht,'CData',icons.rightIcon,...
					 'TooltipString','Shift Frequency Right',...
					 'ClickedCallback',...
					 @obj.fitFrequencyAxisFigureShiftRight);
			uipushtool(ht,'CData',icons.fitIcon,...
					 'TooltipString','Fit Wavenumber',...
					 'ClickedCallback',...
					 @(s,e) obj.fitYaxisGUI(obj.axExp,obj.hExp,obj.hExpStem));
			%uipushtool(ht,'CData',icons.peakPickIcon,...
			%		 'TooltipString','Clear Picked Peaks',...
			%		 'ClickedCallback',...
			%		 @obj.clearPeaks);
			uipushtool(ht,'CData',icons.openIcon,...
					 'TooltipString','Load New Simulation Spectrum',...
					 'ClickedCallback',...
					 @obj.loadSimulationSpectrum);
			
            % Force figure menubar
            set( obj.hf, 'menubar', 'figure' );
			
			% Set 
			%if exist('setMenuAccelerator','file')==2
			%	setMenuAccelerator(obj.hf,'Tools','Zoom In','ctrl shift Z');
			%	setMenuAccelerator(obj.hf,'Tools','Brush','ctrl shift X');
            %end
            
            % Send the output
            hf = obj.hf;
        end
		function fitFrequencyAxisFigureShiftSet(self,hObject,eventdata)
            x = inputdlg({'Enter spectrum center wavenumber [cm-1]:','Enter Horiz span [cm-1]:','Enter Vert span [cm-1]:'}, 'Set Spectrum Center Wavenumber', [1 50],...
                {num2str(self.xaxisParams.centerWavenum),num2str(self.xaxisParams.horizPoly),num2str(self.xaxisParams.vertPoly)});
            self.xaxisParams.centerWavenum = str2num(x{1});
			self.xaxisParams.horizPoly = str2num(x{2});
			self.xaxisParams.vertPoly = str2num(x{3});
            self.updatePlotExp(self.axExp, self.hExp);
			self.updatePlotExpStem(self.axExp,self.hExpStem);
		end
		function fitFrequencyAxisFigureShiftLeft(self,hObject,eventdata)
            self.xaxisParams.centerWavenum = self.xaxisParams.centerWavenum - 5;
            self.updatePlotExp(self.axExp, self.hExp);
			self.updatePlotExpStem(self.axExp,self.hExpStem);
			self.updatePlotSimSelect(self.axSim,self.hSimSelect);
		end
		function fitFrequencyAxisFigureShiftRight(self,hObject,eventdata)
            self.xaxisParams.centerWavenum = self.xaxisParams.centerWavenum + 5;
            self.updatePlotExp(self.axExp, self.hExp);
			self.updatePlotExpStem(self.axExp,self.hExpStem);
			self.updatePlotSimSelect(self.axSim,self.hSimSelect);
		end
		function loadSimulationSpectrum(this,hObject,eventdata)
			% Choose a file
			[filename,filepath] = uigetfile( ...
				{  '*.mat','MAT-files (*.mat)'  }, ...
				   'Choose a calibration linelist', ...
				   'MultiSelect', 'off');

			if filepath == 0
				return
			end
			
            % Load the file
            data = load(fullfile(filepath,filename));
            
            % Import the variables
            fields = fieldnames(data);
			linelist_fields = {};
            for j = 1:numel(fields)
                if strcmp(class(data.(fields{j})),'fitspectraobjects.linelist')
					linelist_fields{end+1} = fields{j};
                end
            end
			
			% Check to see if there are 0 linelists
			if isempty(linelist_fields)
				uiwait(errordlg('No linelists in selected file','File Error: No Linelists'));
				return;
			end
			
			if numel(linelist_fields) > 1
				[Selection,ok] = listdlg('PromptString','Select a linelist:',...
										'SelectionMode','single',...
										'ListString',linelist_fields);
				if ok == 0
					return
				else
					ind = Selection;
				end
			else
				ind = 1;
            end
			
			% Load the linelist into the program
            this.wavenumSim = data.(linelist_fields{ind}).lineposition;
            this.crossSectionSim = data.(linelist_fields{ind}).linestrength;
			
			this.updatePlotSim(this.axSim,this.hSim);
		end
        function fitLineshape(obj,axExp,hExp,hExpStem)
            x = obj.createWavenumAxis( obj.xaxisParams.centerWavenum, obj.xaxisParams.vertPoly, obj.xaxisParams.horizPoly, size(obj.yIn) );
            y = obj.yIn;
            xx = interp1(1:numel(x),x(:),obj.linePositions);

            betas = zeros(4,numel(obj.linePositions));
            for i = 1:numel(obj.linePositions)
                fitx = x(abs(x-xx(i))<0.15)-xx(i);
                fity = y(abs(x-xx(i))<0.15);
                
                fitfun = @(beta,x) beta(1).*real(areaNormVoigt(x,0.0001,abs(beta(2))).*exp(1i.*beta(3)))+beta(4);
                beta0 = [1,0.02,0,0];
                [beta,R,J,CovB,MSE,ErrorModelInfo] = nlinfit(fitx,fity,fitfun,beta0);
                betas(:,i) = beta;

                figure;plot(fitx,fity);
                hold on; plot(fitx,fitfun(beta,fitx));
            end
            figure;plot(abs(betas'));
            mean(betas(2,:),2)
            legend({'A','FWHM L','Phase','Offset'})
        end
        function autoSelectPeaks(obj)
            % Construct x axis
            x = obj.createWavenumAxis( obj.xaxisParams.centerWavenum, obj.xaxisParams.vertPoly, obj.xaxisParams.horizPoly, size(obj.yIn) );
            minx = min(x(:));
            maxx = max(x(:));
            
            % Find candidate peaks
            peaksInWindow = obj.wavenumSim > minx & obj.wavenumSim < maxx;
            maxCrossSectionInWindow = max(obj.crossSectionSim(peaksInWindow));
            
            candidatePeakLocations = obj.wavenumSim(obj.crossSectionSim>maxCrossSectionInWindow/4 &...
                peaksInWindow);
            
            % Find the peaks and add them
            for i = 1:numel(candidatePeakLocations)
                % Find the max of the data within a 0.2 wavenum interval
                ind = find(abs(x - candidatePeakLocations(i)) < 0.20);
                y = reshape(obj.yIn,[],1);
                [~,indMaxRel] = max(y(ind));
                
                maxWavenum = x(ind(indMaxRel));
                
                brushedIdcs = find(abs(reshape(x,[],1) - maxWavenum) < 0.02);
                
                % Find the centroid of the peaks
                centroid = sum(brushedIdcs.*y(brushedIdcs))/sum(y(brushedIdcs));
                obj.linePositions(end+1) = centroid;
                obj.lineHeights(end+1) = interp1(brushedIdcs,y(brushedIdcs),centroid);
            end
        end
        function autoSelectPeaksGUI(obj,axExp,hExp,hExpStem)
            % Auto Select Peaks
            obj.autoSelectPeaks();
            
            % Update the plot
            obj.updatePlotExpStem(axExp,hExpStem);
        end
        function findCorrespondingPeaks(obj)
            obj.linePositionsSim = zeros(size(obj.linePositions));
            obj.lineHeightsSim = zeros(size(obj.linePositions));

            x = obj.createWavenumAxis( obj.xaxisParams.centerWavenum, obj.xaxisParams.vertPoly, obj.xaxisParams.horizPoly, size(obj.yIn) );
            xx = interp1(1:numel(x),x(:),obj.linePositions);

            for i = 1:numel(obj.linePositions)
                ind = find(abs(obj.wavenumSim - xx(i))<0.05);
                if ~isempty(ind)
                    [~,indmax] = max(obj.crossSectionSim(ind));
                    obj.linePositionsSim(i) = obj.wavenumSim(ind(indmax));
                    obj.lineHeightsSim(i) = obj.crossSectionSim(ind(indmax));
                else
                    obj.linePositionsSim(i) = NaN;
                    obj.lineHeightsSim(i) = NaN;
                end
            end
        end
        function findCorrespondingPeaksGUI(obj,axSim,hSimSelect)
            % Find Corresponding Peaks
            obj.findCorrespondingPeaks();
        
            % Update plot
            obj.updatePlotSimSelect(axSim,hSimSelect);
        end
        function weightedMeanOfBrushedPoints(obj,axExp,hExp,hExpStem)
            % Extract the brushed data
            brusheddata = get(hExp,'BrushData');
            brushedIdcs = find(brusheddata);
            y = get(hExp,'YData');
            centroid = sum(brushedIdcs.*y(brushedIdcs))/sum(y(brushedIdcs));
			obj.addExperimentalSelection(centroid,interp1(brushedIdcs,y(brushedIdcs),centroid))
            
            % Update the plot
            obj.updatePlotExpStem(axExp,hExpStem);
        end
		function expAxesUpFunction(obj)
			if strcmp(datacursormode(obj.axExp),'on')
				obj.weightedMeanOfBrushedPoints(obj,obj.axExp,obj.hExp,obj.hExpStem);
			end
		end
		function addExperimentalSelection(obj,xvalue,yvalue)
			numpts = numel(obj.linePositions);
			if numpts ~= numel(obj.lineHeights) || ...
			   numpts ~= numel(obj.linePositionsSim) || ...
			   numpts ~= numel(obj.linePositionsSim) || ...
			   numpts ~= numel(obj.lineHeightsSim)
			   error('Selection Arrays not equal length');
			end
			
            obj.linePositions(numpts+1) = xvalue;
            obj.lineHeights(numpts+1) = yvalue;
            obj.linePositionsSim(numpts+1) = xvalue;
            obj.lineHeightsSim(numpts+1) = yvalue;
		end
        function hExp = plotExp(obj, axExp)
            x = obj.createWavenumAxis( obj.xaxisParams.centerWavenum, obj.xaxisParams.vertPoly, obj.xaxisParams.horizPoly, size(obj.yIn) );
            hExp = plot(axExp,reshape(x,[],1),reshape(obj.yIn,[],1));
            set(axExp,'XLim',[min(x(:)), max(x(:))]);
        end
        function hExpStem = plotExpStem(this, axExp)
            hExpStem = stem(axExp,NaN,NaN,'Marker','none','Color','r','LineWidth',3,'ShowBaseline','off','ButtonDownFcn',@this.callback_ExpStem);
        end
        function hExp = updatePlotExp(obj, axExp, hExp)
            x = obj.createWavenumAxis( obj.xaxisParams.centerWavenum, obj.xaxisParams.vertPoly, obj.xaxisParams.horizPoly, size(obj.yIn) );
            set(hExp,'XData',reshape(x,[],1));
            set(hExp,'YData',reshape(obj.yIn,[],1));
			xlim(axExp,[min(x(:)) max(x(:))])
			
        end
        function hExpStem = updatePlotExpStem(obj, axExp, hExpStem)
            x = obj.createWavenumAxis( obj.xaxisParams.centerWavenum, obj.xaxisParams.vertPoly, obj.xaxisParams.horizPoly, size(obj.yIn) );
            xx = interp1(1:numel(x),x(:),obj.linePositions);
            yy = obj.lineHeights;
            if isempty(xx)
                xx = NaN;
                yy = NaN;
            end
            set(hExpStem,'XData',xx);
            set(hExpStem,'YData',ones(size(xx)));
        end
        function hSim  = plotSim(this, axSim)
            hSim = stem(axSim,NaN,NaN,'Marker','none','ButtonDownFcn',@this.callback_Sim);
        end
        function hSim  = updatePlotSim(obj, axSim, hSim)
            set(hSim,'XData',obj.wavenumSim);
            set(hSim,'YData',obj.crossSectionSim);
        end
        function hSimSelect  = plotSimSelect(obj, axSim)
            hSimSelect = stem(axSim,NaN,NaN,'Marker','none','Color','g','LineWidth',3);
        end
        function hSimSelect = updatePlotSimSelect(obj, axSim, hSimSelect)
            xx = obj.linePositionsSim;
            yy = obj.lineHeightsSim;
            if isempty(xx)
                xx = NaN;
                yy = NaN;
            end
            set(hSimSelect,'XData',xx);
            set(hSimSelect,'YData',-ones(size(xx)));
			
			% Update dotted lines
            x = obj.createWavenumAxis( obj.xaxisParams.centerWavenum, obj.xaxisParams.vertPoly, obj.xaxisParams.horizPoly, size(obj.yIn) );
            xx = interp1(1:numel(x),x(:),obj.linePositions);
			xx(isnan(obj.linePositionsSim)) = NaN;
			Xvals = [reshape(xx,1,[]); reshape(obj.linePositionsSim,1,[]); nan(1,numel(obj.linePositions))];
			Yvals = [ones(1,numel(obj.linePositions)); -ones(1,numel(obj.linePositions)); nan(1,numel(obj.linePositions))];
			if isempty(Xvals)
				set(obj.hDottedConnection,'XData',NaN);
				set(obj.hDottedConnection,'YData',NaN);
			else
				set(obj.hDottedConnection,'XData',reshape(Xvals,1,[]));
				set(obj.hDottedConnection,'YData',reshape(Yvals,1,[]));
			end
        end
        function fitYaxis(obj)
            nVert = numel(obj.xaxisParams.vertPoly);
            nHoriz = numel(obj.xaxisParams.horizPoly);
            wavenumFun = @(b,x) interp1(1:numel(obj.yIn),reshape(obj.createWavenumAxis( b(1),b(2:(1+nVert)),b((2+nVert):(1+nVert+nHoriz)),size(obj.yIn)),[],1),x);
            
            beta0 = [obj.xaxisParams.centerWavenum obj.xaxisParams.vertPoly(:)' obj.xaxisParams.horizPoly(:)'];
            opts = statset('nlinfit');
			
			switch numel(obj.linePositions)
				case 0
					return
				case 1
					[beta,R,J,CovB,MSE,ErrorModelInfo] = nlinfit(obj.linePositions,obj.linePositionsSim,@(b,x) wavenumFun([b beta0(2:end)],x),beta0(1),opts);
					beta = [beta beta0(2:end)];
				otherwise
					[beta,R,J,CovB,MSE,ErrorModelInfo] = nlinfit(obj.linePositions,obj.linePositionsSim,wavenumFun,beta0,opts);
			end
			
            % Set the relevant parameters
            obj.xaxisParams.centerWavenum = beta(1);
            obj.xaxisParams.vertPoly = beta(2:(1+nVert));
            obj.xaxisParams.horizPoly = beta((2+nVert):(1+nVert+nHoriz));
        end
        function [simPeaks,expPeaks] = compareSimExpPeaks(obj)
            x = obj.createWavenumAxis( obj.xaxisParams.centerWavenum, obj.xaxisParams.vertPoly, obj.xaxisParams.horizPoly, size(obj.yIn) );
            
            expPeaks = interp1(1:numel(x),reshape(x,[],1),obj.linePositions);
            simPeaks = obj.linePositionsSim;
        end
        function fitYaxisGUI(obj,axExp,hExp,hExpStem)
            % Fit Y axis
            obj.fitYaxis();

            % Update the plot
            obj.updatePlotExp(axExp, hExp);
            obj.updatePlotExpStem(axExp, hExpStem);
			obj.updatePlotSimSelect(obj.axSim,obj.hSimSelect);
            %figure;scatter(1:numel(linePositions),wavenumFun(linePositions))
        end
		function callback_ExpStem(obj,gcbo,eventdata)
			%find(event
            x = obj.createWavenumAxis( obj.xaxisParams.centerWavenum, obj.xaxisParams.vertPoly, obj.xaxisParams.horizPoly, size(obj.yIn) );
            xx = interp1(1:numel(x),x(:),obj.linePositions);
			xval = eventdata.IntersectionPoint(1);
			yval = eventdata.IntersectionPoint(2);
			obj.expLinkIndx = min(find(round(xx*100) == round(xval*100)));
		end
		function callback_Sim(obj,gcbo,eventdata)
			if ~isempty(obj.expLinkIndx)
				xval = eventdata.IntersectionPoint(1);
				yval = eventdata.IntersectionPoint(2);
				[~,indxSim] = min(abs(1000*xval-1000*obj.wavenumSim));
				
				% Save Positions
				if isempty(obj.linePositionsSim)
					obj.linePositionsSim = nan(size(obj.linePositions));
					obj.lineHeightsSim = nan(size(obj.linePositions));
				end
				obj.linePositionsSim(obj.expLinkIndx) = obj.wavenumSim(indxSim);
				obj.lineHeightsSim(obj.expLinkIndx) = obj.crossSectionSim(indxSim);
				
				obj.updatePlotSimSelect(obj.axSim,obj.hSimSelect);
				
				% Clear selection
				obj.expLinkIndx = [];
			end
		end
        function wavenum = getWavenum(obj)
            wavenum = obj.createWavenumAxis( obj.xaxisParams.centerWavenum, obj.xaxisParams.vertPoly, obj.xaxisParams.horizPoly, size(obj.yIn) );
        end
    end
end


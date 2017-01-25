classdef kineticsmodelobject < handle
    % Kinetics Modelling Object
	%   To use:
	%       obj = kineticsmodelobject;
	%   Add an entry:
	%       ind = newentry('entryname');
	%   Set kinetics data:
	%       obj.setkineticsdata(ind,{moleculenames},moleculeconcs,moleculeconcErrors);
	%   Set conditions:
	%       obj.setconditions(ind,'conditionname',value);
    
    properties
        name;
        
		kineticsdata;
		
		% Fitting variables
		
		
		fitVariableNames = {};
		fitVariableType = {};
		fitStartingPoint = [];
		fitFunction;
		fitFunctionOutputs = {};
		
		tempfitFunctions = [];
		
		% Fit results
		fitdata = struct([]);
		fitTable = [];
		
		fitb = [];
		fitbError = [];
    end
    properties (Transient = true)
        % Live Image Views
        plotHandles;
    end
    methods
        function obj = kineticsmodelobject(varargin)
			obj.kineticsdata = struct('name',{},'time',{},'moleculenames',{},'concs',{},'concsError',{},'conditionsTable',{});
			
			% Temporary hard-coded stuff
			intBox = 50;
			ODfitFun = @(OD0,~,~,rODloss,rrelax,t)-(OD0.*rrelax.*ebox(t,rODloss,intBox))./(rODloss-rrelax)+(OD0.*rrelax.*ebox(t,rrelax,intBox))./(rODloss-rrelax);
			DOCOfitFun = @(OD0,r1a,rDOCOloss,rODloss,rrelax,t)(OD0.*r1a.*rrelax.*ebox(t,rDOCOloss,intBox))./((rDOCOloss-rODloss).*(rDOCOloss-rrelax))-(OD0.*r1a.*rrelax.*ebox(t,rODloss,intBox))./((rDOCOloss-rODloss).*(rODloss-rrelax))+(OD0.*r1a.*rrelax.*ebox(t,rrelax,intBox))./((rDOCOloss-rrelax).*(rODloss-rrelax));
			obj.tempfitFunctions = {ODfitFun, DOCOfitFun};
        end
        function hf = fitbrowser(obj,varargin)
            if ~isempty(obj.plotHandles)
                obj.plotHandles = obj.plotHandles(cellfun(@isvalid,obj.plotHandles)); % Clean up the plot handles
            else
                obj.plotHandles = {};
            end
            if ~isempty(obj.plotHandles)
                n = numel(obj.plotHandles);
                obj.plotHandles{n+1} = kineticsmodelsobjects.fitbrowser(obj);
                hf = obj.plotHandles{n+1}.figureHandle;
            else
                obj.plotHandles = {kineticsmodelsobjects.fitbrowser(obj)};
                hf = obj.plotHandles{1}.figureHandle;
            end
        end
        function delete(obj)
            % Remove deleted plot handles
            if ~isempty(obj.plotHandles)
                obj.plotHandles = obj.plotHandles(cellfun(@isvalid,obj.plotHandles)); % Clean up the plot handles
            else
                obj.plotHandles = {};
            end
            
            for i = 1:numel(obj.plotHandles)
                delete(obj.plotHandles{i});
            end
        end
		function ind = newentry(obj,entryname)
			ind = numel(obj.kineticsdata)+1;
			obj.kineticsdata(ind).name = entryname;
		end
		function ind = setkineticsdata(obj,ind,time,fitbNames,fitb,fitbError,initialConditionsTable)
			obj.kineticsdata(ind).time = time;
			obj.kineticsdata(ind).moleculenames = fitbNames;
			obj.kineticsdata(ind).concs = fitb;
			obj.kineticsdata(ind).concsError = fitbError;
			obj.kineticsdata(ind).conditionsTable = initialConditionsTable;
		end
        function updatePlots(obj)
            % Remove deleted plot handles
            if ~isempty(obj.plotHandles)
                obj.plotHandles = obj.plotHandles(cellfun(@isvalid,obj.plotHandles)); % Clean up the plot handles
            else
                obj.plotHandles = {};
            end
            
            for i = 1:numel(obj.plotHandles)
                obj.plotHandles{i}.Update();
            end
        end
		function bfit = performfit(obj)
			k_relax = 5e-13;
		
			fitStruct = struct('name',{},'O3',{},'D2',{},'CO',{},'N2',{},'intTime',{},'r1a',{},'r1aE',{});
		
			CO = zeros(size(obj.kineticsdata));
			intBox = ones(size(obj.kineticsdata))*50;
			for i = 1:numel(obj.kineticsdata)
				
				% Set initial conditions
				fitStruct(i).O3 = obj.kineticsdata(i).conditionsTable.O3;
				fitStruct(i).D2 = obj.kineticsdata(i).conditionsTable.D2*7.4e16/50;
				fitStruct(i).CO = obj.kineticsdata(i).conditionsTable.CO*7.4e16/50;
				fitStruct(i).N2 = obj.kineticsdata(i).conditionsTable.N2*7.4e16/50*1000;
				fitStruct(i).intTime = obj.kineticsdata(i).conditionsTable.intWindow;
				CO(i) = fitStruct(i).CO;
				
				time = obj.kineticsdata(i).time;
				ODidx = 1;
				DOCOidx = 2;
				pathlength = 5348;
				ebox = @expbox;
				ODtrace = obj.kineticsdata(i).concs(ODidx,:);
				ODtraceErr = obj.kineticsdata(i).concsError(ODidx,:);
				DOCOtrace = obj.kineticsdata(i).concs(DOCOidx,:);
				DOCOtraceErr = obj.kineticsdata(i).concsError(DOCOidx,:);
			
				ODfitFun = @(OD0,rODloss,rrelax,intBox,t)-(OD0.*rrelax.*ebox(t,rODloss,intBox))./(rODloss-rrelax)+(OD0.*rrelax.*ebox(t,rrelax,intBox))./(rODloss-rrelax);
				DOCOfitFun = @(OD0,r1a,rDOCOloss,rODloss,rrelax,intBox,t)(OD0.*r1a.*rrelax.*ebox(t,rDOCOloss,intBox))./((rDOCOloss-rODloss).*(rDOCOloss-rrelax))-(OD0.*r1a.*rrelax.*ebox(t,rODloss,intBox))./((rDOCOloss-rODloss).*(rODloss-rrelax))+(OD0.*r1a.*rrelax.*ebox(t,rrelax,intBox))./((rDOCOloss-rrelax).*(rODloss-rrelax));
				
				% SIMPLE RATE EQUATION
				fitindcs3 = time <= 200;
				
				%f = @(OD0,r1a,rDOCOloss,rODloss,rrelax,t) [ODfitFun(OD0,rODloss,rrelax,intBox,t) DOCOfitFun(OD0,r1a,rDOCOloss,rODloss,rrelax,intBox,t)];
				f_SIMPLERATE_DOCO = @(t,b) DOCOfitFun(b(1),b(2),b(3),b(4),CO(i).*k_relax/1e6,intBox(i),t);
				f_SIMPLERATE_OD = @(t,b) ODfitFun(b(1),b(4),CO(i).*k_relax/1e6,intBox(i),t);
				f = @(b) [(f_SIMPLERATE_OD(time(fitindcs3),b)-ODtrace(fitindcs3)/1e16)./(ODtraceErr(fitindcs3)/1e16) (f_SIMPLERATE_DOCO(time(fitindcs3),b)-DOCOtrace(fitindcs3)/1e16)./(DOCOtraceErr(fitindcs3)/1e16)];
				lb = [-inf 0 0 0];
				ub = [inf inf inf inf];
				b0 = [1    0.005    0.01    0.001];
				options = optimoptions(@lsqnonlin,'Algorithm','trust-region-reflective','Display','iter');
				options.TolFun = 1e-6;
				[b_SIMPLERATE,resnorm,residual,~,~,~,J] = lsqnonlin(f,b0,lb,ub,options);
				ebars = diff(nlparci(b_SIMPLERATE,residual,'jacobian',J),1,2)/2;
				f = {@(t) f_SIMPLERATE_OD(t,b_SIMPLERATE)*1e16,@(t) f_SIMPLERATE_DOCO(t,b_SIMPLERATE)*1e16,@(t) nan(size(t))};
				
				obj.fitdata(i).f = f;
				obj.fitdata(i).redchisqr = resnorm;
				fitStruct(i).name = obj.kineticsdata(i).name;
				fitStruct(i).r1a = b_SIMPLERATE(2)*1e6;
				fitStruct(i).r1aE = ebars(2)*1e6;
			end
			
			obj.fitTable = struct2table(fitStruct);
		end
		function plot(obj)
			teval = linspace(min(obj.t),max(obj.t),50000);
			fitData = reshape(obj.fitFunction(obj.fitb,teval),numel(teval),[]);
		
			hf = figure;
			for i = 1:2%size(obj.concentrations,1)
				plot(obj.t,obj.concentrations(i,:),'x'); hold on;
				plot(teval,fitData(:,i)*1e15);
			end
		end
    end
end


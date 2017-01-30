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
		
		% Fit Parameters
		fitEquations = {};
		fitLowerUpperStartingScope = [];
		fitParameterNames = {};
		fitOptions
		
		% Fit results
		fitdata = struct([]);
		fitTable = [];
		fitErrorTable = [];
		conditionsTable = [];
		
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
			
			% Hard code the lower, upper, scope
			obj.fitParameterNames = {'a1','a2','b1','b2','b3','Adoco','rLoss','Ad2o','d2oLoss'};
			obj.fitEquations = {};
			obj.fitLowerUpperStartingScope = ...
				[0 0 0 0 0 0 0 0 0;...
				 inf 1 inf inf inf inf inf inf inf;...
				 8    0.15    0.1    0.002    0.22    0.0329    0.0428 0.1 0;...
				 1 1 1 1 0 1 0 1 0];
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
        function hf = fitresultsplotbrowser(obj,varargin)
            if ~isempty(obj.plotHandles)
                obj.plotHandles = obj.plotHandles(cellfun(@isvalid,obj.plotHandles)); % Clean up the plot handles
            else
                obj.plotHandles = {};
            end
            if ~isempty(obj.plotHandles)
                n = numel(obj.plotHandles);
                obj.plotHandles{n+1} = kineticsmodelsobjects.fitresultsplotbrowser(obj);
                hf = obj.plotHandles{n+1}.figureHandle;
            else
                obj.plotHandles = {kineticsmodelsobjects.fitresultsplotbrowser(obj)};
                hf = obj.plotHandles{1}.figureHandle;
            end
        end
        function hf = fitpanel(obj,varargin)
            if ~isempty(obj.plotHandles)
                obj.plotHandles = obj.plotHandles(cellfun(@isvalid,obj.plotHandles)); % Clean up the plot handles
            else
                obj.plotHandles = {};
            end
            if ~isempty(obj.plotHandles)
                n = numel(obj.plotHandles);
                obj.plotHandles{n+1} = kineticsmodelsobjects.fitpanel(obj);
                hf = obj.plotHandles{n+1}.figureHandle;
            else
                obj.plotHandles = {kineticsmodelsobjects.fitpanel(obj)};
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


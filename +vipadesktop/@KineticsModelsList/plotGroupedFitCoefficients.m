function hs = plotGroupedFitCoefficients(this, plantids)
    % Get the spectra objects
    if isempty(plantids)
        return
    end
    if isnumeric(plantids)
        idx = plantids;
    else
        idx = [];
        for i = 1:length(plantids)
            idx = [idx;find(strcmp(this.PlantNames, plantids{i}))]; %#ok<AGROW>
        end
    end
    plants = this.Plants(idx);
    plantNames = this.PlantNames(idx);
    dupids = [];

    % Group the fit coefficients
    figureHandles = [];
    axesHandles = [];
    plotCoeffNames = {};
    plotLabels = {};
    for i = 1:length(plants)
        time = plants{i}.t;
        fitCoeffs = plants{i}.fitb;
		fitCoeffErrors = plants{i}.fitbError;
        fitCoeffNames = plants{i}.fitbNames;
        %[time,fitCoeffs,fitCoeffNames] = plants{i}.getfitcoefficients();
        for j = 1:numel(fitCoeffNames)
            idx = find(strcmp(fitCoeffNames{j},plotCoeffNames));
            if isempty(idx)
                idx = numel(plotCoeffNames) + 1;
                h = figure;
                ha = axes;
                figureHandles(idx) = h;
                axesHandles(idx) = ha;
                plotCoeffNames{idx} = fitCoeffNames{j};
                plotLabels{idx} = {};
                set(h,'name',fitCoeffNames{j},'numbertitle','off')
            end
            %errorbar(time,fitCoeffs(j,:),fitCoeffErrors(j,:),'.-','Parent',axesHandles(idx)); hold on;
            scatter(time,fitCoeffs(j,:),'o','Parent',axesHandles(idx)); hold on;
            title(fitCoeffNames{j});
            
            plotLabels{idx} = {plotLabels{idx}{:},strrep(plantNames{i},'_','\_')};
            
%             leg = legend;
%             if isempty(leg)
%                 legend(strrep(this.PlantNames{i},'_','\_'));
%             else
%                 legend(leg.String{:},strrep(this.PlantNames{i},'_','\_'));
%             end
        end
    end

    for i = 1:numel(axesHandles)
        legend(axesHandles(i),plotLabels{i});
    end
    hs = figureHandles;
end
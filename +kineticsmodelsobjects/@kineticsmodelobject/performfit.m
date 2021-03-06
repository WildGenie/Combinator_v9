function bfit = performfit(obj)
	%% This function uses the parameters:
	%      this.
	%           fitParameterNames
	%           kineticsdata
	%           fitLowerUpperStartingScope
            obj.fitOptions = optimoptions(@lsqnonlin);
            obj.fitOptions.Algorithm = 'trust-region-reflective';
            obj.fitOptions.Display = 'off';%'iter';
            obj.fitOptions.MaxFunEvals = 100000;
            obj.fitOptions.MaxIter = 400;
            obj.fitOptions.TolFun = 1e-8;
    
	fitStructInit = {};
	for i = 1:numel(obj.fitParameterNames)
		fitStructInit{2*i-1} = obj.fitParameterNames{i};
		fitStructInit{2*i} = {};
	end
	n = numel(fitStructInit);
	for i = 1:numel(obj.kineticsdata(1).conditionsTable.Properties.VariableNames)
		fitStructInit{n+2*i-1} = obj.kineticsdata(1).conditionsTable.Properties.VariableNames{i};
		fitStructInit{n+2*i} = {};
	end
	
	fitStruct = struct(fitStructInit{:});
	fitErrorStruct = struct(fitStructInit{:});

	CO = zeros(size(obj.kineticsdata));
	intBox = zeros(size(obj.kineticsdata));
	funs = {};
	fsim = {};
	for i = 1:numel(obj.kineticsdata)
		
		% Set initial conditions
		for j = 1:numel(obj.kineticsdata(i).conditionsTable.Properties.VariableNames)
			fitStruct(i).(obj.kineticsdata(i).conditionsTable.Properties.VariableNames{j}) = ...
						obj.kineticsdata(i).conditionsTable.(j);
			fitErrorStruct(i).(obj.kineticsdata(i).conditionsTable.Properties.VariableNames{j}) = ...
						0*obj.kineticsdata(i).conditionsTable.(j);
        end
		
		time = obj.kineticsdata(i).time;
        
        %%% FIXED DOCO RATE EQUATIONS
            CO(i) = fitStruct(i).CO;
			intBox(i) = fitStruct(i).intWindow;
            ODidx = min(find(strcmp(obj.kineticsdata(i).moleculenames,'OD')));
            DOCOidx =  min(find(strcmp(obj.kineticsdata(i).moleculenames,'DOCO')));
			D2Oidx =  min(find(strcmp(obj.kineticsdata(i).moleculenames,'D2O')));

            ODtrace = obj.kineticsdata(i).concs(ODidx,:);
            ODtraceErr = obj.kineticsdata(i).concsError(ODidx,:);
            DOCOtrace = obj.kineticsdata(i).concs(DOCOidx,:);
            DOCOtraceErr = obj.kineticsdata(i).concsError(DOCOidx,:);
			D2Otrace = obj.kineticsdata(i).concs(D2Oidx,:);
			D2OtraceErr = obj.kineticsdata(i).concsError(D2Oidx,:);
			
            % SIMPLE RATE EQUATION
            fitindcs3 = time <= 300;

            f_SIMPLERATE_DOCO = @(t,b) DOCOfitFunction(b(1),b(2),b(3),b(4),CO(i).*b(5)/1e18,b(6),b(7),intBox(i),t);
            f_SIMPLERATE_OD = @(t,b) ODfitFunction(b(1),b(2),b(3),b(4),CO(i).*b(5)/1e18,b(6),b(7),intBox(i),t);
			f_SIMPLERATE_D2O = @(t,b) DOCOfitFunction(b(1),b(2),b(3),b(4),CO(i).*b(5)/1e18,b(8),b(9),intBox(i),t);
            f = @(b) [(f_SIMPLERATE_OD(time(fitindcs3),b)-ODtrace(fitindcs3)/1e16)./(ODtraceErr(fitindcs3)/1e16) ...
					(f_SIMPLERATE_DOCO(time(fitindcs3),b)-DOCOtrace(fitindcs3)/1e16)./(DOCOtraceErr(fitindcs3)/1e16) ...
					(f_SIMPLERATE_D2O(time(fitindcs3),b)-D2Otrace(fitindcs3)/1e16)./(D2OtraceErr(fitindcs3)/1e16)];
        %%% END FIXED DOCO RATE EQUATIONS
		
		funs{i} = f;

		fsim{i} = repmat({@(t,b) nan(size(t))},1,numel(obj.kineticsdata(i).moleculenames));
		fsim{i}{ODidx} = @(t,b) f_SIMPLERATE_OD(t,b)*1e16;
		fsim{i}{DOCOidx} = @(t,b) f_SIMPLERATE_DOCO(t,b)*1e16;
		fsim{i}{D2Oidx} = @(t,b) f_SIMPLERATE_D2O(t,b)*1e16;
    end

    fitstring = 'doco';
    switch fitstring
        case 'global'
            % GLOBAL FIT
            lb0 = obj.fitLowerUpperStartingScope(1,:);
            ub0 = obj.fitLowerUpperStartingScope(2,:);
            b0 = obj.fitLowerUpperStartingScope(3,:);
            fitscope = obj.fitLowerUpperStartingScope(4,:);
            [beta,betaError] = lsqnonlinGlobalWithFixedParams(funs,fitscope,b0,lb0,ub0,obj.fitOptions);

            for i = 1:numel(funs)
                % Set the params
                beta_single = beta(((i-1)*numel(b0)+1):(i*numel(b0)));
                for k = 1:numel(obj.fitParameterNames)
                    fitStruct(i).(obj.fitParameterNames{k}) = beta_single(k);
                end

                % Set the function
                obj.fitdata(i).f = cellfun(@(f) {@(t) f(t,beta_single)},fsim{i});
                obj.fitdata(i).redchisqr = feval(@(x) sum(x)./(numel(x)-sum(obj.fitLowerUpperStartingScope(4,:)==1)),funs{i}(beta_single).^2);
            end
        case 'local'
            % LOCAL FIT
            for i = 1:numel(funs)
                lb = obj.fitLowerUpperStartingScope(1,:);
                ub = obj.fitLowerUpperStartingScope(2,:);
                b0 = obj.fitLowerUpperStartingScope(3,:);

                [b_SIMPLERATE,ebars] = lsqnonlinWithFixedParams(funs{i},obj.fitLowerUpperStartingScope(4,:)==1,b0,lb,ub,obj.fitOptions);

                obj.fitdata(i).f = cellfun(@(f) {@(t) f(t,b_SIMPLERATE)},fsim{i});
                obj.fitdata(i).redchisqr = feval(@(x) sum(x)./(numel(x)-sum(obj.fitLowerUpperStartingScope(4,:)==1)),funs{i}(b_SIMPLERATE).^2);
                for j = 1:numel(obj.fitParameterNames)
                    fitStruct(i).(obj.fitParameterNames{j}) = b_SIMPLERATE(j);
                end
            end
        case 'doco'
            for i = 1:numel(funs)
                %%% DOCO FITTING
                    time = obj.kineticsdata(i).time;
                    CO(i) = fitStruct(i).CO;
                    ODidx = min(find(strcmp(obj.kineticsdata(i).moleculenames,'OD')));
                    DOCOidx =  min(find(strcmp(obj.kineticsdata(i).moleculenames,'DOCO')));
                    D2Oidx =  min(find(strcmp(obj.kineticsdata(i).moleculenames,'D2O')));

                    ODtrace = obj.kineticsdata(i).concs(ODidx,:);
                    ODtraceErr = obj.kineticsdata(i).concsError(ODidx,:);
                    DOCOtrace = obj.kineticsdata(i).concs(DOCOidx,:);
                    DOCOtraceErr = obj.kineticsdata(i).concsError(DOCOidx,:);
                    D2Otrace = obj.kineticsdata(i).concs(D2Oidx,:);
                    D2OtraceErr = obj.kineticsdata(i).concsError(D2Oidx,:);

                    % SIMPLE RATE EQUATION
                    fitindcs3 = time <= 300;

                    f_SIMPLERATE_DOCO = @(t,b) DOCOfitFunction(b(1),b(2),b(3),b(4),CO(i).*b(5)/1e18,b(6),b(7),intBox(i),t);
                    f_SIMPLERATE_OD = @(t,b) ODfitFunction(b(1),b(2),b(3),b(4),CO(i).*b(5)/1e18,b(6),b(7),intBox(i),t);
					f_SIMPLERATE_D2O = @(t,b) DOCOfitFunction(b(1),b(2),b(3),b(4),CO(i).*b(5)/1e18,b(8),b(9),intBox(i),t);
                    fod = @(b) (f_SIMPLERATE_OD(time(fitindcs3),b)-ODtrace(fitindcs3)/1e16)./(ODtraceErr(fitindcs3)/1e16);
                    fdoco = @(b) (f_SIMPLERATE_DOCO(time(fitindcs3),b)-DOCOtrace(fitindcs3)/1e16)./(DOCOtraceErr(fitindcs3)/1e16);
					fd2o = @(b) (f_SIMPLERATE_D2O(time(fitindcs3),b)-D2Otrace(fitindcs3)/1e16)./(D2OtraceErr(fitindcs3)/1e16);
                %%% END FIXED DOCO RATE EQUATIONS
                
                lb = obj.fitLowerUpperStartingScope(1,:);
                ub = obj.fitLowerUpperStartingScope(2,:);
                b0 = obj.fitLowerUpperStartingScope(3,:);
                fitindcs = logical(obj.fitLowerUpperStartingScope(4,:));
                
                odmask = logical([1 1 1 1 1 0 0 0 0]);
                docomask = logical([0 0 0 0 0 1 1 0 0]);
				d2omask = logical([0 0 0 0 0 0 0 1 1]);
                [b_OD,ebars_OD] = lsqnonlinWithFixedParams(fod,fitindcs & odmask,b0,lb,ub,obj.fitOptions);
                [b_SIMPLERATE,ebars_DOCO] = lsqnonlinWithFixedParams(@(b) [fdoco(b) fd2o(b)],fitindcs & (docomask | d2omask),b_OD,lb,ub,obj.fitOptions);
				
				ebars = sqrt(ebars_OD.^2 + ebars_DOCO.^2);
                
                obj.fitdata(i).f = cellfun(@(f) {@(t) f(t,b_SIMPLERATE)},fsim{i});
                obj.fitdata(i).redchisqr = feval(@(x) sum(x)./(numel(x)-sum(obj.fitLowerUpperStartingScope(4,:)==1)),funs{i}(b_SIMPLERATE).^2);
                for j = 1:numel(obj.fitParameterNames)
                    fitStruct(i).(obj.fitParameterNames{j}) = b_SIMPLERATE(j);
					fitErrorStruct(i).(obj.fitParameterNames{j}) = ebars(j);
                end
            end
    end
	
	obj.fitTable = struct2table(fitStruct);
	obj.fitErrorTable = struct2table(fitErrorStruct);
    
    % Set the row names
    rownames = {};
    for i = 1:numel(obj.kineticsdata)
       rownames{i} = obj.kineticsdata(i).name; 
    end
    obj.fitTable.Properties.RowNames = rownames;
	obj.fitErrorTable.Properties.RowNames = rownames;
    
	disp(obj.fitTable);
	disp(obj.fitErrorTable);
	
	obj.updatePlots();
	
	function y = ODfitFunction( A,alpha,b1,b2,b3,Adoco,rLoss,intTime,t)
       a1 = A*alpha./(expbox(10,b1,intTime)-expbox(10,b3,intTime))/2;
       a2 = A*(1-alpha)./(expbox(10,b2,intTime)-expbox(10,b3,intTime))/2;
	   y = a1*expbox(t,b1,intTime)+a2*expbox(t,b2,intTime)-(a1+a2)*expbox(t,b3,intTime);

	end
	function y = DOCOfitFunction( A,alpha,b1,b2,b3,Adoco,rLoss,intTime,t)
       a1 = A*alpha./(expbox(10,b1,intTime)-expbox(10,b3,intTime))/2;
       a2 = A*(1-alpha)./(expbox(10,b2,intTime)-expbox(10,b3,intTime))/2;
	   y = Adoco*(...
		   (-1)*a1.*(expbox(t,b1,intTime)-expbox(t,rLoss,intTime))./(b1-rLoss) + ...
		   (-1)*a2.*(expbox(t,b2,intTime)-expbox(t,rLoss,intTime))./(b2-rLoss) + ...
		   (a1 + a2).*(expbox(t,b3,intTime)-expbox(t,rLoss,intTime))./(b3-rLoss));
	   
	end
end

function [beta,betaError] = lsqnonlinGlobalWithFixedParams(fun,fitscope,beta0,lowerLim,upperLim,options)
	% fun should be array of function
	% fitscope should be numeric: 0 - fixed, 1 - local, 2 - global
	global_indcs = find(fitscope == 0 | fitscope == 2);
	global_lb = lowerLim(fitscope == 0 | fitscope == 2);
	global_ub = upperLim(fitscope == 0 | fitscope == 2);
	global_beta0 = beta0(fitscope == 0 | fitscope == 2);
	global_fitindcs = logical(fitscope(fitscope == 0 | fitscope == 2));
	local_indcs = find(fitscope == 1);
	local_lb = lowerLim(fitscope == 1);
	local_ub = upperLim(fitscope == 1);
	local_beta0 = beta0(fitscope == 1);
	local_fitindcs = logical(fitscope(fitscope == 1));
	
	lb2 = cat(2,global_lb,repmat(local_lb,1,numel(fun)));
	ub2 = cat(2,global_ub,repmat(local_ub,1,numel(fun)));
	gbeta0 = cat(2,global_beta0,repmat(local_beta0,1,numel(fun)));
	fitindcs = cat(2,global_fitindcs,repmat(local_fitindcs,1,numel(fun)));
	
	fitfun = @(b) localfits(fun,@(a,i) mappingfun(a,i,global_indcs,local_indcs),b);
	[betafit,betafitError] = lsqnonlinWithFixedParams(fitfun,fitindcs,gbeta0,lb2,ub2,options);
	
	beta = zeros(1,numel(beta0)*numel(fun));
	betaError = zeros(1,numel(beta0)*numel(fun));
	for l = 1:numel(fun)
		beta(((l-1)*numel(beta0)+1):(l*numel(beta0))) = mappingfun(betafit,l,global_indcs,local_indcs);
		betaError(((l-1)*numel(beta0)+1):(l*numel(beta0))) = mappingfun(betafitError,l,global_indcs,local_indcs);
	end
	
	function bout = mappingfun(bin,i,global_indcs,local_indcs)
		global_start = 1;
		global_n = numel(global_indcs);
		local_start = global_start + global_n + (i-1)*numel(local_indcs);
		local_n = numel(local_indcs);
		bout = zeros(1,local_n+global_n);
		
		bout(global_indcs) = bin(global_start:(global_start+global_n-1));
		bout(local_indcs) = bin(local_start:(local_start+local_n-1));
	end
	
	function chiRMS = localfits(funs,mappingfun,b)
		%nparams = numel(b)/numel(funs);
		chiRMS = [];
		for j = 1:numel(funs)
			chiRMS = cat(2,chiRMS,funs{j}(mappingfun(b,j)));
		end
	end
end

function [beta,betaError] = lsqnonlinWithFixedParams(fun,fitindcs,beta0,lowerLim,upperLim,options)
	beta = beta0;
	betaError = zeros(size(beta0));
	S.type = '()';
	S.subs = {logical(fitindcs)};
	[beta(fitindcs),resnorm,residual,~,~,~,J] = lsqnonlin(@(b) fun(subsasgn(beta0,S,b)),beta0(fitindcs),...
						lowerLim(fitindcs),upperLim(fitindcs),options);
	betaError(fitindcs) = diff(nlparci(beta(fitindcs),residual,'jacobian',J),1,2)/2;
end
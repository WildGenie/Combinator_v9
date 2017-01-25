function DOCO_v32_COandN2figures(fitobjnames,fitobjs)

    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  %%  DEFINE CONSTANTS AND VARIANTS      %%
    %  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    variants = sbiovariant('fvariant');
    addcontent(variants, {'parameter', 'f', 'value', 0.15});
    addcontent(variants, {'parameter', 'OverallScale', 'value', 0.15});
    addcontent(variants, {'parameter', 'ODscale', 'value', 1});
    addcontent(variants, {'parameter', 'DOCOscale', 'value', 1});
    addcontent(variants, {'parameter', 'D2Oscale', 'value', 1});
    addcontent(variants, {'parameter', 'tpump', 'value', 25000});
    addcontent(variants, {'parameter', 'HOCO_LOSS.k', 'value', 10000});
    %addcontent(variants, {'parameter', 'HOCO_O3_OH_CO_O3.k_HOCO_O3_OH_CO_O3','value',0});
    addcontent(variants, {'parameter', 'HOCO_O3_OH_CO_O3.k_HOCO_O3_OH_CO_O3', 'value', 2.4e-11});
    %addcontent(variants, {'species', 'O2', 'InitialAmount', 1e20});
    
    % Define the reaction rates
    k1b = 7.5e-14;
    k1aN2 = 6.54588e-33;
    k1aCO = 1.61386e-32;
    addcontent(variants, {'parameter', 'k1aN2', 'value', k1aN2});
    addcontent(variants, {'parameter', 'k1aCO', 'value', k1aCO});
    addcontent(variants, {'parameter', 'OH_CO_H_CO2.k1b', 'value', k1b});
    
    % Define OD relaxation constant
    k_relax = 5e-13;
    
    % Define cavity parameters
    pathlength = 5348;

    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  %%  CHOOSE DATA FOR PLOTS AND ANALYSIS    %%
    %  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Data for analysis
    MdataNames = {...
        'v_20160210_CO_1',...
        'v_20160210_CO_2',...
        'v_20160210_CO_3',...
        'v_20160210_CO_4',...
        'v_20160210_CO_5',...
        'v_20160210_CO_6',...
        'v_20160209_CO_1',...
        'v_20160209_CO_2',...
        'v_20160209_CO_3',...
        'v_20160209_CO_4',...
        'v_20160209_CO_5',...
        'v_20160318_ShortInt1',...
        'v_20160318_ShortInt2',...
        'v_20160318_ShortInt3',...
        'v_20160317_ShortInt1',...
        'v_20160317_ShortInt2',...
        'v_20160317_ShortInt3',...
        'v_20160315_ShortInt1',...
        'v_20160315_ShortInt3',...
        'v_20160307_N2_1',...
        'v_20160307_N2_2',...
        'v_20160307_N2_3',...
        'v_20160307_N2_4',...
        'v_20160307_N2_5',...
        'v_20160307_N2_6',...
        'v_20160307_N2_7',...
        'v_20160307_N2_8',...
        'v_20160322_HighN2_2',...
        'v_20160322_HighN2_3',...
        };
    
    % Data for plots
    simulationFitPlotNames = {...
        'v_20160209_CO_3',...
        'v_20160210_CO_4',...
        };
    O3dataNames = {...
        'v_20160216_O3_1',...
        'v_20160216_O3_2',...
        'v_20160216_O3_3',...
        'v_20160216_O3_4',...
        'v_20160216_O3_5',...
        'v_20160224_O3_1',...
        'v_20160224_O3_2',...
        'v_20160224_O3_3',...
        'v_20160224_O3_4',...
        'v_20160224_O3_5',...
        'v_20160224_O3_6',...
        };
    D2dataNames = {...
        'v_20160212_D2_1',...
        'v_20160212_D2_2',...
        'v_20160212_D2_3',...
        'v_20160212_D2_4',...
        'v_20160212_D2_5',...
        };
    N2dataNames = {...
        'v_20160307_N2_1',...
        'v_20160307_N2_2',...
        'v_20160307_N2_3',...
        'v_20160307_N2_4',...
        'v_20160307_N2_5',...
        'v_20160307_N2_6',...
        'v_20160307_N2_7',...
        'v_20160307_N2_8',...
        'v_20160322_HighN2_2',...
        'v_20160322_HighN2_3',...
        };
    COdataNames = {...
        'v_20160210_CO_1',...
        'v_20160210_CO_2',...
        'v_20160210_CO_3',...
        'v_20160210_CO_4',...
        'v_20160210_CO_5',...
        'v_20160210_CO_6',...
        'v_20160209_CO_1',...
        'v_20160209_CO_2',...
        'v_20160209_CO_3',...
        'v_20160209_CO_4',...
        'v_20160209_CO_5',...
        'v_20160318_ShortInt1',...
        'v_20160318_ShortInt2',...
        'v_20160318_ShortInt3',...
        'v_20160317_ShortInt1',...
        'v_20160317_ShortInt2',...
        'v_20160317_ShortInt3',...
        'v_20160315_ShortInt1',...
        'v_20160315_ShortInt3',...
        };
    
    O3dataIndcs = [];
    for i = 1:numel(O3dataNames)
        tempind = find(strcmp(O3dataNames{i},fitobjnames));
        if ~isempty(tempind)
            O3dataIndcs(end+1) = tempind(1);
        end
    end
    D2dataIndcs = [];
    for i = 1:numel(D2dataNames)
        tempind = find(strcmp(D2dataNames{i},fitobjnames));
        if ~isempty(tempind)
            D2dataIndcs(end+1) = tempind(1);
        end
    end
    N2dataIndcs = [];
    for i = 1:numel(N2dataNames)
        tempind = find(strcmp(N2dataNames{i},fitobjnames));
        if ~isempty(tempind)
            N2dataIndcs(end+1) = tempind(1);
        end
    end
    COdataIndcs = [];
    for i = 1:numel(COdataNames)
        tempind = find(strcmp(COdataNames{i},fitobjnames));
        if ~isempty(tempind)
            COdataIndcs(end+1) = tempind(1);
        end
    end
    MdataIndcs = [];
    for i = 1:numel(MdataNames)
        tempind = find(strcmp(MdataNames{i},fitobjnames));
        if ~isempty(tempind)
            MdataIndcs(end+1) = tempind(1);
        end
    end

    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  %%  CONSTRUCT THE EARLY RATE MODEL     %%
    %  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%     syms DOCO(t) OD(t) ODe(t)
%     syms OD0 r1a rDOCOloss rrelax rODloss
%     DOCOeqn = diff(DOCO) == r1a*OD - rDOCOloss*DOCO;
%     ODeqn = diff(OD) == rrelax*ODe - rODloss*OD;
%     ODeeqn = diff(ODe) == -rrelax*ODe;
%     c1 = DOCO(0)==0;
%     c2 = OD(0)==0;
%     c3 = ODe(0)==OD0;
%     S = dsolve(DOCOeqn,ODeqn,ODeeqn,c1,c2,c3);
%     DOCOfitFun = matlabFunction(S.DOCO);
%     ODfitFun = matlabFunction(S.OD);
    
    ODfitFun = @(OD0,rODloss,rrelax,intBox,t)-(OD0.*rrelax.*ebox(t,rODloss,intBox))./(rODloss-rrelax)+(OD0.*rrelax.*ebox(t,rrelax,intBox))./(rODloss-rrelax);
    DOCOfitFun = @(OD0,r1a,rDOCOloss,rODloss,rrelax,intBox,t)(OD0.*r1a.*rrelax.*ebox(t,rDOCOloss,intBox))./((rDOCOloss-rODloss).*(rDOCOloss-rrelax))-(OD0.*r1a.*rrelax.*ebox(t,rODloss,intBox))./((rDOCOloss-rODloss).*(rODloss-rrelax))+(OD0.*r1a.*rrelax.*ebox(t,rrelax,intBox))./((rDOCOloss-rrelax).*(rODloss-rrelax));
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  %%  PREALLOCATE VARIABLES              %%
    %  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    intTimes = zeros(size(fitobjs));
    xCO = ezeros(size(fitobjs));
    xN2 = ezeros(size(fitobjs));
    xO3 = ezeros(size(fitobjs));
    xD2 = ezeros(size(fitobjs));
    y = ezeros(size(fitobjs));
    yysim = zeros(size(fitobjs));
    yysimExpRatio = zeros(size(fitobjs));
    yysimExpDOCORatio = zeros(size(fitobjs));
    yysimExpODRatio = zeros(size(fitobjs));
    yysimSensRatio = zeros(size(fitobjs));

    % VALUES OF d([DOCO])/dt
    dDOCOdt_CUBIC = ezeros(size(fitobjs));
    dDOCOdt_QUADRATIC = ezeros(size(fitobjs));
    dDOCOdt_QUADRATIC_RELAX = ezeros(size(fitobjs));
    dDOCOdt_LINEAR = ezeros(size(fitobjs));
    dDOCOdt_EXPONENTIAL = ezeros(size(fitobjs));
    dDOCOdt_EXPCONV = ezeros(size(fitobjs));
    dDOCOdt_EXPCONV_TOFFSET = ezeros(size(fitobjs));
    dDOCOdtsim_CUBIC = zeros(size(fitobjs));
    dDOCOdtsim_QUADRATIC = zeros(size(fitobjs));
    dDOCOdtsim_LINEAR = zeros(size(fitobjs));
    dDOCOdtsim_EXPONENTIAL = zeros(size(fitobjs));
    
    Afit = zeros(size(fitobjs));
    r1a = zeros(size(fitobjs));
    rDOCOloss = zeros(size(fitobjs));
    rODloss = zeros(size(fitobjs));
    
    % VALUES OF OD
    OD_MEAN = ezeros(size(fitobjs));
    
    % Define the fit data
    for i = 1:length(fitobjs)
        if i == 1
            dataToFit = fitobjs{i}.getTable(1,pathlength);
        else
            dataToFit = union(dataToFit,fitobjs{i}.getTable(i,pathlength));
        end
        %plants{i}.exportDOCOglobals();
    end
    data = runsimbiologyscanincurrentworkspace(dataToFit,variants);
    hwait = waitbar(0,'Running Analysis...', 'WindowStyle', 'modal');
    for ii = 1:numel(fitobjs)
        fitobject = fitobjs{ii};
        
        CO = fitobject.initialConditionsTable.CO;
        N2 = fitobject.initialConditionsTable.N2;
        O3 = fitobject.initialConditionsTable.O3;
        D2 = fitobject.initialConditionsTable.D2;
        
        try
            intBox = fitobject.initialConditionsTable.intWindow;
        catch ee
            intBox = 50;
        end
        
        % Evaluate a slope for the first two OD points
        ODidx = find(strcmp('OD',fitobject.fitbNames));
        DOCOidx = find(strcmp('trans-DOCO',fitobject.fitbNames));
        time = fitobject.t;
        ODtrace = fitobject.fitb(fitobject.fitbNamesInd(ODidx),:)/pathlength;
        ODtraceErr = fitobject.fitbError(fitobject.fitbNamesInd(ODidx),:)/pathlength;
        DOCOtrace = fitobject.fitb(fitobject.fitbNamesInd(DOCOidx),:)/pathlength;
        DOCOtraceErr = fitobject.fitbError(fitobject.fitbNamesInd(DOCOidx),:)/pathlength;

        % Find the first two time points
        time2 = time;
        time2(time < 0) = NaN;
        [~,firstidx] = nanmin(time2);
        time3 = time2;
        time3(firstidx) = NaN;
        [~,secondidx] = nanmin(time3);
        dt = (time(secondidx) - time(firstidx))/1e6;
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %  %% CALCULATE THE RATE MODEL RESPONSE                  %%
        %  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [t,ysim,names] = getdata(data(ii));
        
        [~,ind,~] = unique(t);
        xint = linspace(min(t)-intBox,max(t)-intBox,2e5);
        yintbox = zeros(numel(xint),size(ysim,2));
        ysimbox = zeros(numel(time),size(ysim,2));
        for i = 1:numel(names)
            yyy = ysim(:,i);
            yint = interp1(t(ind)-intBox,yyy(ind),xint);
            windowSize = round(intBox/(xint(2)-xint(1)));
            yintbox(:,i) = filter((1/windowSize)*ones(1,windowSize),1,yint);
            ysimbox(:,i) = interp1(xint,yintbox(:,i),time);
        end
        
        % Get the proper indices for the data
        odsimInd = find(strcmp(names,'ODscaled'));
        docosimInd = find(strcmp(names,'DOCOscaled'));
        
        docoRealSlope = (interp1(t(ind),ysim(ind,docosimInd),2)-interp1(t(ind),ysim(ind,docosimInd),1))/1e-6;
        odReal = interp1(t(ind),ysim(ind,odsimInd),1.5);
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %  %% CALCULATE THE DOCO SLOPE USING DIFFERENT FUNCTIONS %%
        %  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % ALL FITS
            DOCOfitIndcs = 4:7;
            DOCOscalefactor = 1e12;
            [xData, yData, weights] = prepareCurveData( time(DOCOfitIndcs)'-time(DOCOfitIndcs(1))',DOCOtrace(DOCOfitIndcs)'/DOCOscalefactor,1./(DOCOtraceErr(DOCOfitIndcs)'/DOCOscalefactor).^2 );
            [xData, yDataSim] = prepareCurveData( time(DOCOfitIndcs)'-time(DOCOfitIndcs(1))',ysimbox(DOCOfitIndcs,docosimInd)./DOCOscalefactor );
            
            
            % LINEAR
            M_LINEAR = [(xData+intBox/2)];
            [b_LINEAR,stdb_LINEAR,mse_LINEAR] = lscov(M_LINEAR,yData,weights);
            bsim_LINEAR = lscov(M_LINEAR,yDataSim);
            dDOCOdt_LINEAR(ii) = edouble(b_LINEAR(1),stdb_LINEAR(1)/min(1,sqrt(mse_LINEAR)))*DOCOscalefactor*1e6;
            dDOCOdtsim_LINEAR(ii) = bsim_LINEAR(1)*DOCOscalefactor*1e6;
            
            % QUADRATIC
            M_QUADRATIC = [(xData+intBox/2) (xData.^2+intBox.*xData+intBox.^2/3)];
            [b_QUADRATIC,stdb_QUADRATIC,mse_QUADRATIC] = lscov(M_QUADRATIC,yData,weights);
            bsim_QUADRATIC = lscov(M_QUADRATIC,yDataSim);
            dDOCOdt_QUADRATIC(ii) = edouble(b_QUADRATIC(1),stdb_QUADRATIC(1)/min(1,sqrt(mse_QUADRATIC)))*DOCOscalefactor*1e6;
            dDOCOdtsim_QUADRATIC(ii) = bsim_QUADRATIC(1)*DOCOscalefactor*1e6;
            
            % QUADRATIC_RELAX
            t_relax = 1./CO./k_relax*1e6; % in us
            M_QUADRATIC_RELAX = [boxpoly2(xData-t_relax,1,0,intBox) boxpoly2(xData-t_relax,0,1,intBox)];
            f_QUADRATIC_RELAX = @(x,b) boxpoly2(x-t_relax,b(1),b(2),intBox);
            [b_QUADRATIC_RELAX,stdb_QUADRATIC_RELAX,mse_QUADRATIC_RELAX] = lscov(M_QUADRATIC_RELAX,yData,weights);
            %bsim_QUADRATIC_RELAX = lscov(M_QUADRATIC_RELAX,yDataSim);
            dDOCOdt_QUADRATIC_RELAX(ii) = edouble(b_QUADRATIC_RELAX(1),stdb_QUADRATIC_RELAX(1)/min(1,sqrt(mse_QUADRATIC_RELAX)))*DOCOscalefactor*1e6;
            %dDOCOdtsim_QUADRATIC_RELAX(ii) = bsim_QUADRATIC_RELAX(1)*DOCOscalefactor*1e6;
            
            % CUBIC
            M_CUBIC = [(xData+intBox/2) (xData.^2+intBox.*xData+intBox.^2/3) (xData.^3+3/2*intBox.*xData.^2+intBox.^2*xData+intBox.^3/4)];
            [b_CUBIC,stdb_CUBIC,mse_CUBIC] = lscov(M_CUBIC,yData,weights);
            bsim_CUBIC = lscov(M_CUBIC,yDataSim);
            dDOCOdt_CUBIC(ii) = edouble(b_CUBIC(1),stdb_CUBIC(1)/min(1,sqrt(mse_CUBIC)))*DOCOscalefactor*1e6;
            dDOCOdtsim_CUBIC(ii) = bsim_CUBIC(1)*DOCOscalefactor*1e6;
        
            % EXPONENTIAL
            ft_EXPONENTIAL = fittype( 'a/b*(1-exp(-b*x)*(1-exp(-b*delta))/b/delta)', 'independent', 'x', 'dependent', 'y','problem','delta' );
            opts = fitoptions( 'Method', 'NonlinearLeastSquares',...
                'Lower',[0,0],...
                'Upper',[Inf,Inf],...
                'StartPoint',[1000 1000]);
            opts.weights = weights;
            [fitresult_EXPONENTIAL, gof, output] = fit( xData, yData, ft_EXPONENTIAL, opts,'problem',intBox );
            ci = diff(confint(fitresult_EXPONENTIAL,0.68),[],1)/2;
            dDOCOdt_EXPONENTIAL(ii) = edouble(fitresult_EXPONENTIAL.a,ci(1))*DOCOscalefactor*1e6;
            
            % ALL FITS
            DOCOfitIndcs2 = 1:9;
            DOCOscalefactor = 1e12;
            [xData2, yData2, weights2] = prepareCurveData( time(DOCOfitIndcs2)',DOCOtrace(DOCOfitIndcs2)'/DOCOscalefactor,1./(DOCOtraceErr(DOCOfitIndcs2)'/DOCOscalefactor).^2 );
            %[xData, yDataSim] = prepareCurveData( time(DOCOfitIndcs),ysimbox(DOCOfitIndcs,docosimInd)/DOCOscalefactor );
            
            % EXPONENTIAL CONV
            ft_EXPCONV = fittype( 'a/b*(ebox(x,0,delta)-ebox(x,b,delta))', 'independent', 'x', 'dependent', 'y','problem','delta' );
            opts = fitoptions( 'Method', 'NonlinearLeastSquares',...
                'Lower',[-Inf,0],...
                'Upper',[Inf,Inf],...
                'StartPoint',[max(xData2)*0.1 0.1]);
            opts.weights = weights2;
            [fitresult, gof, output] = fit( xData2, yData2, ft_EXPCONV, opts,'problem',intBox );
            ci = diff(confint(fitresult,0.68),[],1)/2;
            dDOCOdt_EXPCONV(ii) = edouble(fitresult.a,ci(1))*DOCOscalefactor*1e6;
            
            % EXPONENTIAL
            ft_EXPCONV_TOFFSET = fittype( 'a/b*(ebox(x-tau,0,delta)-ebox(x-tau,b,delta))', 'independent', 'x', 'dependent', 'y','problem','delta' );
            opts = fitoptions( 'Method', 'NonlinearLeastSquares',...
                'Lower',[-Inf,0,-Inf],...
                'Upper',[Inf,Inf,Inf],...
                'StartPoint',[max(xData2)*0.05 0.05 5]);
            opts.weights = weights2;
            [fitresult, gof, output] = fit( xData2, yData2, ft_EXPCONV_TOFFSET, opts,'problem',intBox );
            ci = diff(confint(fitresult,0.68),[],1)/2;
            dDOCOdt_EXPCONV_TOFFSET(ii) = edouble(fitresult.a,ci(1))*DOCOscalefactor*1e6;
            
            % SIMPLE RATE EQUATION
            if intBox == 10
                fitindcs3 = 1:12;
            else
                fitindcs3 = 1:30;
            end
            %f = @(OD0,r1a,rDOCOloss,rODloss,rrelax,t) [ODfitFun(OD0,rODloss,rrelax,intBox,t) DOCOfitFun(OD0,r1a,rDOCOloss,rODloss,rrelax,intBox,t)];
            f_SIMPLERATE_DOCO = @(t,b) DOCOfitFun(b(1),b(2),b(3),b(4),CO.*k_relax/1e6,intBox,t);
            f_SIMPLERATE_OD = @(t,b) ODfitFun(b(1),b(4),CO.*k_relax/1e6,intBox,t);
            f = @(b) [f_SIMPLERATE_OD(time(fitindcs3),b)-ODtrace(fitindcs3)/1e12 f_SIMPLERATE_DOCO(time(fitindcs3),b)-DOCOtrace(fitindcs3)/1e12];
            lb = [-inf 0 0 0];
            ub = [inf inf inf inf];
            b0 = [1    0.005    0.01    0.001];
            options = optimoptions(@lsqnonlin,'Algorithm','trust-region-reflective');
            options.TolFun = 1e-6;
            [b_SIMPLERATE,~,residual,~,~,~,J] = lsqnonlin(f,b0,lb,ub,options);
			CI = nlparci(b_SIMPLERATE,residual,'jacobian',J);
            Afit(ii) = b_SIMPLERATE(1)*1e12;
            r1a(ii) = b_SIMPLERATE(2)*1e6;
            rDOCOloss(ii) = b_SIMPLERATE(3)*1e6;
            rODloss(ii) = b_SIMPLERATE(4)*1e6;
            
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %  %% FIT THE DOCO, OD TO MODELOBJ IF NECESSARY          %%
        %  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if 1==0
            disp 'simbio fit'
            f = sbiomodelfunction(fitobject.getTable(1,pathlength));
            f
            return
            %ft_SIMBIO = fittype( , 'independent', 'x', 'dependent', 'y','problem','delta' );
        end

        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %  %% CALCULATE THE OD VALUE USING DIFFERENT FUNCTIONS %%
        %  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        ind3od = 4:7;
        xDataod = time(ind3od)';
        MOD3 = [ones(size(xDataod)) xDataod];
        [bOD,stdbOD,mseOD] = lscov(MOD3,(ODtrace(ind3od))'/1e12,1./(ODtraceErr(ind3od)/1e12).^2);
        bODsim = lscov(MOD3,(ysimbox(ind3od,odsimInd))/1e12);
        %chisqr = sum((DOCOtrace(ind3)/1e12-b'*M').^2./(ODtraceErr(ind3)/1e12).^2)/(5-2-1)
        ODmean3 = edouble(bOD(1),stdbOD(1)/min(1,sqrt(mseOD)))*1e12;
        ODmean3sim = bODsim(1)*1e12;
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %  %% PLOT THE DATA + FIT                              %% (FIG 1A)
        %  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if 1==0
            % Params for spectral plots
            xlims = [2660 2710];
            ylims = [-0.005 0.005];
            expoffset = -0.0045;
            fitoffset = 0.001;
            figh = 400;
            figw = 800;
            figure('Position', [100, 100, figw,figh]); 
            subplot(3,1,1); htop = gca;
            subplot(3,1,2); hmiddle = gca;
            subplot(3,1,3); hbottom = gca;
            y0 = 0.15;
            x0 = 0.10;
            xf = 0.95;
            ploth = 0.24;
            plotspacing = 0.05;
            ay = 0.045;
            set(hbottom,'Position',[x0 y0 xf-x0 ploth]);
            set(hmiddle,'Position',[x0 y0+ploth+plotspacing xf-x0 ploth]);
            set(htop,'Position',[x0 y0+2*ploth+2*plotspacing xf-x0 ploth]);
            atop = annotation('textbox',[x0 y0+3*ploth+2*plotspacing-ay .3 .05],'String','text3','LineStyle','none','FontWeight','bold','FontSize',12);
            amiddle = annotation('textbox',[x0 y0+2*ploth+plotspacing-ay .3 .05],'String','text2','LineStyle','none','FontWeight','bold','FontSize',12);
            abottom = annotation('textbox',[x0 y0+ploth-ay .3 .05],'String','text1','LineStyle','none','FontWeight','bold','FontSize',12);
            plotlinewidth = 1;
            expplotcolor = [0.247 0.247 0.247];

            % Set top, middle, bottom indices
            indbottom = 1;
            indmiddle = 10;
            indtop = 26;

            % Construct the top plot for the figure
            axes(htop);
            ind = indtop;
            atop.String = sprintf('%i \\mus',fitobject.t(ind));
            plot(fitobject.wavenum(:),expoffset+reshape(fitobject.y(:,:,ind),[],1)-min(reshape(fitobject.y(:,:,ind),[],1)),'Color',expplotcolor,'LineWidth',plotlinewidth);
            hold(gca,'on');
            colorder = [  1 1 1;...
                    0    0.4470    0.7410;...
                    0.8500    0.3250    0.0980;...
                    0.4940    0.1840    0.5560;...
                    0.4660    0.6740    0.1880;...
                    0.6350    0.0780    0.1840];
            set(gca,'ColorOrder',colorder);
            for i = 1:numel(fitobject.fitbNames)
                indx = fitobject.fitbNamesInd(i);
                [scaleout, fitcolor, scaleouttext] = getscalingfactor(fitobject.fitbNames{i});
                yyyy = fitobject.fitM(:,indx).*fitobject.fitb(indx,ind);
                if ~isempty(fitcolor)
                    plot(gca,fitobject.wavenum(:),-scaleout*(yyyy-min(yyyy))-fitoffset,'-','LineWidth',plotlinewidth,'Color',fitcolor);
                else
                    %plot(gca,fitobject.wavenum(:),-scaleout*(y-min(y))-fitoffset,'-','LineWidth',plotlinewidth);
                end
                hold on;
            end
            hold off;
            xlim(xlims);
            ylim(ylims);
            set(gca,'XTickLabel',[]);
            %set(gca,'YTick',[]);
            %legend({'Experiment',fitobject.fitbNames{:}});

            % Construct the middle plot for the figure
            axes(hmiddle);
            ind = indmiddle;
            amiddle.String = sprintf('%i \\mus',fitobject.t(ind));
            plot(fitobject.wavenum(:),expoffset+reshape(fitobject.y(:,:,ind),[],1)-min(reshape(fitobject.y(:,:,ind),[],1)),'Color',expplotcolor,'LineWidth',plotlinewidth);
            hold(gca,'on');
            colorder = [  1 1 1;...
                    0    0.4470    0.7410;...
                    0.8500    0.3250    0.0980;...
                    0.4940    0.1840    0.5560;...
                    0.4660    0.6740    0.1880;...
                    0.6350    0.0780    0.1840];
            set(gca,'ColorOrder',colorder);
            for i = 1:numel(fitobject.fitbNames)
                indx = fitobject.fitbNamesInd(i);
                [scaleout, fitcolor, scaleouttext] = getscalingfactor(fitobject.fitbNames{i});
                yyyy = fitobject.fitM(:,indx).*fitobject.fitb(indx,ind);
                if ~isempty(fitcolor)
                    plot(gca,fitobject.wavenum(:),-scaleout*(yyyy-min(yyyy))-fitoffset,'-','LineWidth',plotlinewidth,'Color',fitcolor);
                else
                    %plot(gca,fitobject.wavenum(:),-scaleout*(y-min(y))-fitoffset,'-','LineWidth',plotlinewidth);
                end
                hold on;
            end
            hold off;
            %legend({'Experiment',fitobject.fitbNames{:}});
            xlim(xlims);
            ylim(ylims);
            set(gca,'XTickLabel',[]);
            ylabel('Absorbance');

            % Construct the bottom plot for the figure
            axes(hbottom);
            ind = indbottom;
            abottom.String = sprintf('%i \\mus',fitobject.t(ind));
            plot(fitobject.wavenum(:),expoffset+reshape(fitobject.y(:,:,ind),[],1)-min(reshape(fitobject.y(:,:,ind),[],1)),'Color',expplotcolor,'LineWidth',plotlinewidth);
            hold(gca,'on');
            colorder = [  1 1 1;...
                    0    0.4470    0.7410;...
                    0.8500    0.3250    0.0980;...
                    0.4940    0.1840    0.5560;...
                    0.4660    0.6740    0.1880;...
                    0.6350    0.0780    0.1840];
            set(gca,'ColorOrder',colorder);
            legnames = {};
            for i = 1:numel(fitobject.fitbNames)
                indx = fitobject.fitbNamesInd(i);
                [scaleout, fitcolor, legendtext] = getscalingfactor(fitobject.fitbNames{i});
                yyyy = fitobject.fitM(:,indx).*fitobject.fitb(indx,ind);
                if ~isempty(fitcolor)
                    legnames = {legnames{:},legendtext};
                    plot(gca,fitobject.wavenum(:),-scaleout*(yyyy-min(yyyy))-fitoffset,'-','LineWidth',plotlinewidth,'Color',fitcolor);
                else
                    %plot(gca,fitobject.wavenum(:),-scaleout*(y-min(y))-fitoffset,'-','LineWidth',plotlinewidth);
                end
                hold on;
            end
            hold off;
            xlim(xlims);
            ylim(ylims);
            %set(gca,'YTick',[]);
            %legend({'Experiment',fitobject.fitbNames{:}});
            %tightfig
            xlabel 'Wavenumber [cm^{-1}]';
            %legend({['Exp                 ' char(30)],legnames{:}},'Orientation','horizontal','Box','off','Position',[0.33 0.302 0.514 0.08]);

            set(hbottom,'FontSize',13);
            set(hmiddle,'FontSize',13);
            set(htop,'FontSize',13);
        end
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %  %% PLOT THE DATA V RATE EQUATION MODEL              %% (FIGs 4)
        %  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if 1==1%any(strcmp(simulationFitPlotNames,fitobjnames{ii}))
            % Simulation is constructed earlier
            %   ysimbox(:,i),odsimind, docosimind
            ODsimtrace = yintbox(:,odsimInd);
            DOCOsimtrace = yintbox(:,docosimInd);
            odscalefactor = max(ODtrace)/max(ODsimtrace);
            
%             % Get the simulation data
%             [t,ysim,names] = getdata(data(1));
%             x = t-intBox;
%             xint = linspace(min(x),max(x),1e6);
%             [~,ind,~] = unique(x);
%             odsimind = 
%             
%             yprime = [];
%             yprimenames = {};
%             for i = 1:numel(names)
%                 [scaleout, fitcolor, legendtext] = getscalingfactor(names{i});
%                 if ~isempty(fitcolor)
%                     legnames = {legnames{:},legendtext};
%                     yyyy = scaleout*odscalingfactor*ysim(:,i);
%                     yint = interp1(x(ind),yyyy(ind),xint);
%                     windowSize = round(intBox/(xint(2)-xint(1)));
%                     yyyyintbox = filter((1/windowSize)*ones(1,windowSize),1,yint);
%                     yprime(:,end+1) = interp1(xint,yyyyintbox,x);
%                     yprimenames{end+1} = 
%                     plot(x,yprime,'-','Color',fitcolor);
%                 end
%                 
%                 hold on;
%             end
            
            figh = 400;
            figw = 800;
            figure('Position', [100, 100, figw,figh]);
            axes();
            legnames = {};
            for i = 1:numel(fitobject.fitbNames)
                ind = fitobject.fitbNamesInd(i);
                [scaleout, fitcolor, legendtext] = getscalingfactor(fitobject.fitbNames{i});
                if ~isempty(fitcolor)
                    legnames = {legnames{:},legendtext};
                    indt = (fitobject.t <= 1000);
                    xxxx = fitobject.t;
                    yyyy = scaleout*fitobject.fitb(ind,:)/pathlength;
                    dyyyy = scaleout*fitobject.fitbError(ind,:)/pathlength;
                    errorbar(xxxx(indt),yyyy(indt),dyyyy(indt),'o','Color',fitcolor);
                end
                hold on;
            end
            
            plot(xint,odscalefactor*yintbox(:,odsimInd));
            plot(xint,odscalefactor*yintbox(:,docosimInd));

            xlabel('Time (\mus)');
            scaleyaxis(1e-12);
            ylabel('Concentration/10^{12} (molecules cm^{-3})');
            legend(legnames{:});
            set(gca,'FontSize',12);
            xlim([-60 1000]);
        end
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %  %% PLOT THE EARLY RISE OF DOCO, OD                  %% (FIG 1BC)
        %  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if 1==1%strcmp(fitobjnames{ii},'v_20160315_ShortInt1')
            figh = 400;
            figw = 600;
            figure('Position', [100, 100, figw,figh]); 
            smallplotlinewidth = 1;
            subplot(2,1,1); htop = gca;
            subplot(2,1,2); hbottom = gca;
            set(htop,'Position',[0.157094594594595 0.583837209302326 0.814189189189189 0.341162790697675]);
            set(hbottom,'Position',[0.157094594594595 0.2 0.812500000000001 0.341162790697674]);
            
            ind3 = DOCOfitIndcs;
            % Plot DOCO
            xxxsim = linspace(min(xData),max(xData),100)';
            Mxxx = [(xxxsim+intBox/2) (xxxsim.^2+intBox.*xxxsim+intBox.^2/3)];
            indxxx = find(time<1000 & time>=-25);
            axes(htop); errorbar(time(indxxx),DOCOtrace(indxxx)/1e12,DOCOtraceErr(indxxx)/1e12,'.','LineWidth',smallplotlinewidth,'DisplayName','Exp','Color',[0.850980392156863 0.325490196078431 0.0980392156862745]); hold on;
            plot(linspace(-50,1000,1000),f_SIMPLERATE_DOCO(linspace(-50,1000,1000),b_SIMPLERATE),'LineWidth',smallplotlinewidth,'DisplayName','Exp Fit2','Color','k');
            plot(xxxsim,(b_QUADRATIC')*(Mxxx'),'LineWidth',smallplotlinewidth,'DisplayName','Q Fit','Color','r');
            %plot(linspace(-50,100,100),f_QUADRATIC_RELAX(linspace(-50,100,100),b_QUADRATIC_RELAX),'LineWidth',smallplotlinewidth,'DisplayName','Q_{relax} Fit','Color','m');

            %plot(time(indxxx),ysimbox(indxxx,docosimInd)/1e12,'.','LineWidth',smallplotlinewidth,'DisplayName','Sim','Color',[0.850980392156863 0.325490196078431 0.0980392156862745]);
            %plot(xxxsim,(bsim')*(Mxxx'),'LineWidth',smallplotlinewidth,'DisplayName','Sim Fit','Color',[0.850980392156863 0.325490196078431 0.0980392156862745]);
            %plot(xxxsim,fitresult(xxxsim),'-','LineWidth',smallplotlinewidth,'DisplayName','Exp Fit','Color','b');
            xlim([-30 1000]);
            %ylim([0 0.45]);
            set(gca,'FontSize',12);
            set(gca,'XTickLabel',[]);
            ylabel({'[DOCO]\times10^{-12}','(mlc cm{-3})'});
            %legend1 = legend(htop,'show');
            %set(legend1,...
            %    'Position',[0.315867121915692 0.59672838996836 0.62837837012233 0.0617283936635947],...
            %    'Orientation','horizontal',...
            %    'EdgeColor',[1 1 1]);
            % Plot OD
            MxxxOD = [ones(size(xxxsim)) xxxsim];
            title(fitobjnames{ii},'interpreter','none')
            axes(hbottom); errorbar(time(indxxx),ODtrace(indxxx)/1e12,ODtraceErr(indxxx)/1e12,'.','LineWidth',smallplotlinewidth,'DisplayName','Exp','Color',[0.850980392156863 0.325490196078431 0.0980392156862745]); hold on;
            plot(linspace(-50,1000,1000),f_SIMPLERATE_OD(linspace(-50,1000,1000),b_SIMPLERATE),'LineWidth',smallplotlinewidth,'DisplayName','Exp Fit2','Color','k');
            %plot(xxxsim,(bOD')*(MxxxOD'),'LineWidth',smallplotlinewidth,'DisplayName','Exp Fit','Color',[0.850980392156863 0.325490196078431 0.0980392156862745]);
            %plot(time(indxxx),ysimbox(indxxx,odsimInd)/1e12,'.','LineWidth',smallplotlinewidth,'Color',[0.850980392156863 0.325490196078431 0.0980392156862745]);
            %plot(xxxsim,(bODsim')*(MxxxOD'),'LineWidth',smallplotlinewidth,'DisplayName','Sim Fit','Color',[0.850980392156863 0.325490196078431 0.0980392156862745]);
            xlim([-30 1000]);
            %ylim([0 4]);
            set(gca,'FontSize',12);
            xlabel('Time (\mus)');
            ylabel({'[OD]\times10^{-12}';'(mlc cm{-3})'});
            %annotation(gcf,'rectangle',[0.261000000000001 0.3875 0.169 0.125],'LineStyle','--');
        end
        
        i = 1;
        
        OD_MEAN(ii) = (edouble(ODtrace(secondidx+i),ODtraceErr(secondidx+i))+edouble(ODtrace(firstidx+i),ODtraceErr(firstidx+i)))/2;
        ODmeansim = (ysimbox(secondidx+i,odsimInd)+ysimbox(firstidx+i,odsimInd))/2;
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %  %%  SAVE SOME VALUES FOR LATER         %%
        %  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         yysimExpDOCORatio(ii) = dDOCOdtsim_QUADRATIC(ii)/docoRealSlope;
         yysimExpODRatio(ii) = ODmeansim/odReal;
         yysimExpRatio(ii) = (dDOCOdtsim_QUADRATIC(ii)/ODmeansim)/(docoRealSlope/odReal);
         yysimSensRatio(ii) = (docoRealSlope/odReal)/(k1aN2*N2+k1aCO*CO)/CO;
         yysim(ii) = (dDOCOdtsim_QUADRATIC(ii)/ODmeansim);
         y(ii) = dDOCOdt_QUADRATIC(ii)/OD_MEAN(ii);
         xCO(ii) = edouble(1,0)*CO;
         xN2(ii) = edouble(1,0)*N2;
         xO3(ii) = edouble(1,0)*O3;
         xD2(ii) = edouble(1,0)*D2;
         intTimes(ii) = intBox;
         
        %% Update the waitbar
         waitbar(ii/numel(fitobjs),hwait);
    end
    close(hwait);

    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  %%  SAVE A FEW VARS TO THE BASE WORKSPACE        %%
    %  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %evalin('base','clc');
    w = warning ('off','all');
    putvar(...
        intTimes,...
        xCO,...
        xN2,...
        xO3,...
        xD2,...
        y,...
        yysim,...
        yysimExpRatio,...
        yysimExpDOCORatio,...
        yysimExpODRatio,...
        yysimSensRatio);

%     % VALUES OF d([DOCO])/dt
      putvar(...
        dDOCOdt_CUBIC,...
        dDOCOdt_QUADRATIC,...
        dDOCOdt_QUADRATIC_RELAX,...
        dDOCOdt_LINEAR,...
        dDOCOdt_EXPONENTIAL,...
        dDOCOdt_EXPCONV,...
        dDOCOdt_EXPCONV_TOFFSET,...
        dDOCOdtsim_CUBIC,...
        dDOCOdtsim_QUADRATIC,...
        dDOCOdtsim_LINEAR,...
        dDOCOdtsim_EXPONENTIAL);
     
     putvar(...
         Afit,...
         r1a,...
         rDOCOloss,...
         rODloss);
     
%     % VALUES OF OD
     purvar(OD_MEAN);
    warning(w)
    return
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  %%  MULTIPLE LINEAR REG + STATS        %%
    %  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Set the indices
    % Data for analysis
    FittingDataNames = {...
        'v_20160210_CO_1',...
        'v_20160210_CO_2',...
        'v_20160210_CO_3',...
        'v_20160210_CO_4',...
        'v_20160210_CO_5',...
        'v_20160210_CO_6',...
        'v_20160209_CO_1',...
        'v_20160209_CO_2',...
        'v_20160209_CO_3',...
        'v_20160209_CO_4',...
        'v_20160209_CO_5',...
        'v_20160318_ShortInt1',...
        'v_20160318_ShortInt2',...
        'v_20160318_ShortInt3',...
        'v_20160317_ShortInt1',...
        'v_20160317_ShortInt2',...
        'v_20160317_ShortInt3',...
        'v_20160315_ShortInt1',...
        'v_20160315_ShortInt3',...
        'v_20160307_N2_1',...
        'v_20160307_N2_2',...
        'v_20160307_N2_3',...
        'v_20160307_N2_4',...
        'v_20160307_N2_5',...
        'v_20160307_N2_6',...
        'v_20160307_N2_7',...
        'v_20160307_N2_8',...
        'v_20160322_HighN2_2',...
        'v_20160322_HighN2_3',...
        };
    
    FittingDataIndcs = [];
    for i = 1:numel(FittingDataNames)
        tempind = find(strcmp(FittingDataNames{i},fitobjnames));
        if ~isempty(tempind) & xCO.value(i) > 0%5e17
            FittingDataIndcs(end+1) = tempind(1);
        end
    end
    
    % Set up fittype and options.
    X = [xCO.value(FittingDataIndcs).^2 xCO.value(FittingDataIndcs).*xN2.value(FittingDataIndcs)];
    [b,bstd,mse] = lscov(X,y.value(FittingDataIndcs),1./y.errorbar(FittingDataIndcs).^2);
    ysim = b'*X';
    redChiSqr = sum((y.value(FittingDataIndcs)'-ysim).^2./y.errorbar(FittingDataIndcs)'.^2)/(numel(y)-2-1);
    
    fprintf('b = \n');
    for i=1:numel(b)
        fprintf('%g +- %g\n',b(i),bstd(i));
    end
    fprintf('mse = %g\n',sqrt(mse));
    fprintf('redChiSqr = %g\n',redChiSqr);
    return
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  %%  DOCOdot FUNCTIONAL FORM PLOT       %%
    %  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if any(COdataIndcs)
        figure;plot(xCO(COdataIndcs),dDOCOdt_QUADRATIC_RELAX(COdataIndcs)./dDOCOdt_QUADRATIC(COdataIndcs),'ko','DisplayName','Quadratic','MarkerFaceColor','k','MarkerEdgeColor','k');
        xlabel('CO Concentration (molecule cm^{-3})');
        ylabel('relax/norelax');
        legend;
        set(gca,'FontSize',15);
    end
    
    if any(COdataIndcs)
        figure;plot(xCO(COdataIndcs),dDOCOdt_QUADRATIC(COdataIndcs),'ko','DisplayName','Quadratic','MarkerFaceColor','k','MarkerEdgeColor','k');hold on;
        plot(xCO(COdataIndcs),dDOCOdt_LINEAR(COdataIndcs),'rs','DisplayName','Linear','MarkerFaceColor','r','MarkerEdgeColor','r');
        plot(xCO(COdataIndcs),dDOCOdt_CUBIC(COdataIndcs),'gx','DisplayName','Cubic','MarkerFaceColor','g','MarkerEdgeColor','g');
        plot(xCO(COdataIndcs),dDOCOdt_EXPONENTIAL(COdataIndcs),'bd','DisplayName','Exponential','MarkerFaceColor','b','MarkerEdgeColor','b');
        plot(xCO(COdataIndcs),dDOCOdt_EXPCONV(COdataIndcs),'md','DisplayName','Exp Conv','MarkerFaceColor','m','MarkerEdgeColor','m');
        plot(xCO(COdataIndcs),dDOCOdt_EXPCONV_TOFFSET(COdataIndcs),'kd','DisplayName','Exp Conv + Toffset','MarkerFaceColor','k','MarkerEdgeColor','k');
        xlabel('[CO] (molecule cm^{-3})');
        ylabel('d[DOCO]/dt (molecule cm^{-3} s^{-1})');
        legend;
        set(gca,'FontSize',15);
    end

    if any(N2dataIndcs)
        figure;plot(xN2(N2dataIndcs),dDOCOdt_QUADRATIC(N2dataIndcs),'ko','DisplayName','Quadratic','MarkerFaceColor','k','MarkerEdgeColor','k');hold on;
        plot(xN2(N2dataIndcs),dDOCOdt_LINEAR(N2dataIndcs),'rs','DisplayName','Linear','MarkerFaceColor','r','MarkerEdgeColor','r');
        plot(xN2(N2dataIndcs),dDOCOdt_CUBIC(N2dataIndcs),'gx','DisplayName','Cubic','MarkerFaceColor','g','MarkerEdgeColor','g');
        plot(xN2(N2dataIndcs),dDOCOdt_EXPONENTIAL(N2dataIndcs),'bd','DisplayName','Exponential','MarkerFaceColor','b','MarkerEdgeColor','b');
        xlabel('[N_2] (molecule cm^{-3})');
        ylabel('d[DOCO]/dt (molecule cm^{-3} s^{-1})');
        legend;
        set(gca,'FontSize',15);
    end

    if any(D2dataIndcs)
        figure;plot(xD2(D2dataIndcs),dDOCOdt_QUADRATIC(D2dataIndcs),'ko','DisplayName','Quadratic','MarkerFaceColor','k','MarkerEdgeColor','k');hold on;
        plot(xD2(D2dataIndcs),dDOCOdt_LINEAR(D2dataIndcs),'rs','DisplayName','Linear','MarkerFaceColor','r','MarkerEdgeColor','r');
        plot(xD2(D2dataIndcs),dDOCOdt_CUBIC(D2dataIndcs),'gx','DisplayName','Cubic','MarkerFaceColor','g','MarkerEdgeColor','g');
        plot(xD2(D2dataIndcs),dDOCOdt_EXPONENTIAL(D2dataIndcs),'bd','DisplayName','Exponential','MarkerFaceColor','b','MarkerEdgeColor','b');
        xlabel('[D_2] (molecule cm^{-3})');
        ylabel('d[DOCO]/dt (molecule cm^{-3} s^{-1})');
        legend;
        set(gca,'FontSize',15);
    end

    if any(O3dataIndcs)
        figure;plot(xO3(O3dataIndcs)./1e15,dDOCOdt_QUADRATIC(O3dataIndcs),'ko','DisplayName','Quadratic','MarkerFaceColor','k','MarkerEdgeColor','k');hold on;
        plot(xO3(O3dataIndcs)./1e15,dDOCOdt_LINEAR(O3dataIndcs),'rs','DisplayName','Linear','MarkerFaceColor','r','MarkerEdgeColor','r');
        plot(xO3(O3dataIndcs)./1e15,dDOCOdt_CUBIC(O3dataIndcs),'gx','DisplayName','Cubic','MarkerFaceColor','g','MarkerEdgeColor','g');
        plot(xO3(O3dataIndcs)./1e15,dDOCOdt_EXPONENTIAL(O3dataIndcs),'bd','DisplayName','Exponential','MarkerFaceColor','b','MarkerEdgeColor','b');
        xlabel('[O_3]/10^{15} (molecule cm^{-3})');
        ylabel('d[DOCO]/dt (molecule cm^{-3} s^{-1})');
        legend;
        set(gca,'FontSize',15);
    end
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  %% CO SCAN PLOTS (y0*CO)               %%
    %  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if any(COdataIndcs)
        COlinex = linspace(0,max(xCO.value(COdataIndcs)),100);
        N2val = mean(xN2.value(COdataIndcs));
        COliney = b(1)*COlinex.^2 + b(2)*COlinex*N2val;

        indcs50 = COdataIndcs(intTimes(COdataIndcs)==50);
        indcs25 = COdataIndcs(intTimes(COdataIndcs)==25);
        indcs10 = COdataIndcs(intTimes(COdataIndcs)==10);
        
        figure;
        plot(xCO(indcs50)./1e17,dDOCOdt_QUADRATIC(indcs50)./OD_MEAN(indcs50),'ko','MarkerFaceColor','none','MarkerEdgeColor','k','LineWidth',1);hold on;
        plot(xCO(indcs10)./1e17,dDOCOdt_QUADRATIC(indcs10)./OD_MEAN(indcs10),'bs','MarkerFaceColor','none','MarkerEdgeColor','b','LineWidth',1);
        xlabel('[CO]/10^{17} (molecules cm^{-3})');
        ylabel('DOCOdot/OD (s^{-1})');
        plot(COlinex./1e17,COliney,'r');
        set(gca,'FontSize',15);
    end
        
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  %% CO SCAN PLOTS (DIV BY CO)           %% (FIG 3A)
    %  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if any(COdataIndcs)
        COlinex = linspace(0,max(xCO.value(COdataIndcs)),100);
        N2val = mean(xN2.value(COdataIndcs));
        COliney = b(1)*COlinex.^2 + b(2)*COlinex*N2val;

        indcs50 = COdataIndcs(intTimes(COdataIndcs)==50);
        indcs25 = COdataIndcs(intTimes(COdataIndcs)==25);
        indcs10 = COdataIndcs(intTimes(COdataIndcs)==10);
        
        figure;
        plot(xCO(indcs50)./1e17,dDOCOdt_QUADRATIC(indcs50)./OD_MEAN(indcs50)'./xCO(indcs50).*1e14,'ko','MarkerFaceColor','none','MarkerEdgeColor','k','LineWidth',1);hold on;
        plot(xCO(indcs10)./1e17,dDOCOdt_QUADRATIC(indcs10)./OD_MEAN(indcs10)'./xCO(indcs10).*1e14,'bs','MarkerFaceColor','none','MarkerEdgeColor','b','LineWidth',1);
        xlabel('[CO]/10^{17} (molecules cm^{-3})');
        ylabel('y_0/10^{-14} (molecules^{-1} cm^3 s^{-1})');
        plot(COlinex./1e17,COliney./COlinex.*1e14,'r');
        set(gca,'FontSize',15);
    end
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  %% CO SCAN PLOTS (r1a/CO   )           %%
    %  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if any(COdataIndcs)
        COlinex = linspace(0,max(xCO.value(COdataIndcs)),100);
        N2val = mean(xN2.value(COdataIndcs));
        COliney = b(1)*COlinex.^2 + b(2)*COlinex*N2val;

        indcs50 = COdataIndcs(intTimes(COdataIndcs)==50);
        indcs25 = COdataIndcs(intTimes(COdataIndcs)==25);
        indcs10 = COdataIndcs(intTimes(COdataIndcs)==10);
        
        figure;
        plot(xCO(indcs50)./1e17,r1a(indcs50)./xCO.value(indcs50),'ko','MarkerFaceColor','none','MarkerEdgeColor','k','LineWidth',1);hold on;
        plot(xCO(indcs10)./1e17,r1a(indcs10)./xCO.value(indcs10),'bs','MarkerFaceColor','none','MarkerEdgeColor','b','LineWidth',1);
        xlabel('[CO]/10^{17} (molecules cm^{-3})');
        ylabel('r1a/CO (molecules^{-1} cm^3 s^{-1})');
        set(gca,'FontSize',15);
        
        figure;
        plot(xCO(indcs50)./1e17,r1a(indcs50)./(dDOCOdt_QUADRATIC.value(indcs50)./OD_MEAN.value(indcs50)),'ko','MarkerFaceColor','none','MarkerEdgeColor','k','LineWidth',1);hold on;
        plot(xCO(indcs10)./1e17,r1a(indcs10)./(dDOCOdt_QUADRATIC.value(indcs10)./OD_MEAN.value(indcs10)),'bs','MarkerFaceColor','none','MarkerEdgeColor','b','LineWidth',1);
        xlabel('[CO]/10^{17} (molecules cm^{-3})');
        ylabel('r1a/y0');
        set(gca,'FontSize',15);
        
        figure;
        plot(xCO(indcs50)./1e17,rDOCOloss(indcs50),'ko','MarkerFaceColor','none','MarkerEdgeColor','k','LineWidth',1);hold on;
        plot(xCO(indcs10)./1e17,rDOCOloss(indcs10),'bs','MarkerFaceColor','none','MarkerEdgeColor','b','LineWidth',1);
        xlabel('[CO]/10^{17} (molecules cm^{-3})');
        ylabel('rdocoloss');
        set(gca,'FontSize',15);
        
        figure;
        plot(xCO(indcs50)./1e17,rODloss(indcs50),'ko','MarkerFaceColor','none','MarkerEdgeColor','k','LineWidth',1);hold on;
        plot(xCO(indcs10)./1e17,rODloss(indcs10),'bs','MarkerFaceColor','none','MarkerEdgeColor','b','LineWidth',1);
        xlabel('[CO]/10^{17} (molecules cm^{-3})');
        ylabel('rodloss');
        set(gca,'FontSize',15);
    end
    
    if any(O3dataIndcs)
        
        indcs50 = O3dataIndcs(intTimes(O3dataIndcs)==50);
        indcs25 = O3dataIndcs(intTimes(O3dataIndcs)==25);
        indcs10 = O3dataIndcs(intTimes(O3dataIndcs)==10);
        
        figure;
        plot(xO3(indcs50),r1a(indcs50),'ko','MarkerFaceColor','none','MarkerEdgeColor','k','LineWidth',1);hold on;
        plot(xO3(indcs10),r1a(indcs10),'bs','MarkerFaceColor','none','MarkerEdgeColor','b','LineWidth',1);
        xlabel('[O_3] (molecules cm^{-3})');
        ylabel('r1a (molecules^{-1} cm^3 s^{-1})');
        set(gca,'FontSize',15);
        
        figure;
        plot(xO3(indcs50),rODloss(indcs50),'ko','MarkerFaceColor','none','MarkerEdgeColor','k','LineWidth',1);hold on;
        plot(xO3(indcs10),rODloss(indcs10),'bs','MarkerFaceColor','none','MarkerEdgeColor','b','LineWidth',1);
        xlabel('[O3] (molecules cm^{-3})');
        ylabel('rdocoloss');
        set(gca,'FontSize',15);
    end
    return
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  %% N2 SCAN PLOTS (y0*CO)               %%
    %  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if any(N2dataIndcs)
        N2linex = linspace(0,max(xN2.value(N2dataIndcs)),100);
        COval = mean(xCO.value(N2dataIndcs));
        N2liney = b(1)*COval.^2 + b(2)*COval*N2linex;

        indcs50 = N2dataIndcs(intTimes(N2dataIndcs)==50);
        indcs25 = N2dataIndcs(intTimes(N2dataIndcs)==25);
        indcs10 = N2dataIndcs(intTimes(N2dataIndcs)==10);
        
        figure;
        plot(xN2(indcs50)./1e17,dDOCOdt_QUADRATIC(indcs50)./OD_MEAN(indcs50),'ko','MarkerFaceColor','none','MarkerEdgeColor','k','LineWidth',1);hold on;
        plot(xN2(indcs10)./1e17,dDOCOdt_QUADRATIC(indcs10)./OD_MEAN(indcs10),'bs','MarkerFaceColor','none','MarkerEdgeColor','b','LineWidth',1);
        xlabel('[N2]/10^{17} (molecules cm^{-3})');
        ylabel('DOCOdot/OD (s^{-1})');
        plot(N2linex./1e17,N2liney,'r');
        set(gca,'FontSize',15);
    end
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  %% N2 SCAN PLOTS (DIV BY CO)           %% (FIG 3B)
    %  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if any(N2dataIndcs)
        N2linex = linspace(0,max(xN2.value(N2dataIndcs)),100);
        COval = mean(xCO.value(N2dataIndcs));
        N2liney = b(1)*COval.^2 + b(2)*COval*N2linex;

        indcs50 = N2dataIndcs(intTimes(N2dataIndcs)==50);
        indcs25 = N2dataIndcs(intTimes(N2dataIndcs)==25);
        indcs10 = N2dataIndcs(intTimes(N2dataIndcs)==10);

        figure;
        plot(xN2(indcs50)./1e17,dDOCOdt_QUADRATIC(indcs50)./OD_MEAN(indcs50)'./xCO(indcs50).*1e14,'ko','MarkerFaceColor','none','MarkerEdgeColor','k','LineWidth',1);hold on;
        plot(xN2(indcs10)./1e17,dDOCOdt_QUADRATIC(indcs10)./OD_MEAN(indcs10)'./xCO(indcs10).*1e14,'bs','MarkerFaceColor','none','MarkerEdgeColor','b','LineWidth',1);
        xlabel('[N2]/10^{17} (molecules cm^{-3})');
        ylabel('y_0/10^{-14} (molecules^{-1} cm^3 s^{-1})');
        plot(N2linex./1e17,N2liney./COval.*1e14,'r');
        set(gca,'FontSize',15);
    end
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  %% M SCAN PLOT (DIV BY CO)             %%
    %  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if any(MdataIndcs)
        rVal = (b(1)/b(2));
        Mlinex = linspace(0,max(rVal.*xCO.value(MdataIndcs)+xN2.value(MdataIndcs)),100);
        N2val = mean(xN2.value(MdataIndcs));
        Mliney = b(2)*Mlinex;

        indcs50 = MdataIndcs(intTimes(MdataIndcs)==50);
        indcs25 = MdataIndcs(intTimes(MdataIndcs)==25);
        indcs10 = MdataIndcs(intTimes(MdataIndcs)==10);

        figure;
        %yyaxis left
        plot((rVal.*xCO(indcs50)+xN2(indcs50))./1e17,dDOCOdt_QUADRATIC(indcs50)./OD_MEAN(indcs50)./xCO(indcs50).*1e14,'ko','MarkerFaceColor','none','MarkerEdgeColor','k','LineWidth',1);
        hold on;
        plot((rVal.*xCO(indcs10)+xN2(indcs10))./1e17,dDOCOdt_QUADRATIC(indcs10)./OD_MEAN(indcs10)./xCO(indcs10).*1e14,'bs','MarkerFaceColor','none','MarkerEdgeColor','b','LineWidth',1);
        xlabel('[M_{eff}]/10^{17} (molecules cm^{-3})');
        ylabel('y_0/10^{-14} (molecules^{-1} cm^3 s^{-1})');
        plot(Mlinex./1e17,Mliney.*1e14,'r');
        % Create second Y axes on the right.
        a1 = gca;
        a2 = axes('YAxisLocation', 'Right');
        % Hide second plot.
        set(a1,'box','off')
        set(a2,'box','off')
        set(a2, 'color', 'none');
        set(a2, 'XTick', []);
        % Set scala for second Y.
        set(a2, 'YLim', [min(get(a1,'YLim')) max(get(a1,'YLim'))].*1e-14./7.5e-14.*100);
        set(a1,'FontSize',14);
        set(a2,'FontSize',14);
        set(a2, 'Position', get(a1,'Position'));

        ylabel('DOCO Yield (%)');
    end
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  %% M SCAN PLOT WITH YIELD              %% (FIG 3C)
    %  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if any(MdataIndcs)
        rVal = (b(1)/b(2));
        Mlinex = linspace(0,max(rVal.*xCO.value(MdataIndcs)+xN2.value(MdataIndcs)),100);
        N2val = mean(xN2.value(MdataIndcs));
        Mliney = b(2)*Mlinex;

        indcs50 = MdataIndcs(intTimes(MdataIndcs)==50);
        indcs25 = MdataIndcs(intTimes(MdataIndcs)==25);
        indcs10 = MdataIndcs(intTimes(MdataIndcs)==10);

        figure;
        %yyaxis left
        k1_0 = 5e-14;
        y50 = dDOCOdt_QUADRATIC(indcs50)./OD_MEAN(indcs50)./xCO(indcs50);
        y10 = dDOCOdt_QUADRATIC(indcs10)./OD_MEAN(indcs10)./xCO(indcs10);
        plot((rVal.*xCO(indcs50)+xN2(indcs50))./1e17,100.*y50./(y50+k1_0),'ko','MarkerFaceColor','none','MarkerEdgeColor','k','LineWidth',1);
        hold on;
        plot((rVal.*xCO(indcs10)+xN2(indcs10))./1e17,100.*y10./(y10+k1_0),'bs','MarkerFaceColor','none','MarkerEdgeColor','b','LineWidth',1);
        xlabel('[M_{eff}]/10^{17} (molecules cm^{-3})');
        ylabel('DOCO Yield (%)');
        % Create second Y axes on the right.
        a1 = gca;
        % Hide second plot.
        set(a1,'box','off')
        set(a1,'FontSize',14);

        ylabel('DOCO Yield (%)');
    end
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  %% INT TIME RATIO PLOT                 %% (FIG S_IntTimePlot)
    %  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if any(COdataIndcs)
        COlinex = linspace(0,max(xCO.value(COdataIndcs)),100);
        N2val = mean(xN2.value(COdataIndcs));
        COliney = b(1)*COlinex.^2 + b(2)*COlinex*N2val;

        indcs50 = COdataIndcs(intTimes(COdataIndcs)==50);
        indcs25 = COdataIndcs(intTimes(COdataIndcs)==25);
        indcs10 = COdataIndcs(intTimes(COdataIndcs)==10);

        indcs50div = [];
        indcs10div = [];
        for i = 1:numel(indcs50)
            for j = 1:numel(indcs10)
                if xCO.value(indcs50(i)) == xCO.value(indcs10(j))
                    indcs50div(end+1) = indcs50(i);
                    indcs10div(end+1) = indcs10(j);
                end
            end
        end

        figure;
        plot(xCO(indcs50div)./1e17,dDOCOdt_QUADRATIC(indcs50div)./OD_MEAN(indcs50div)./(dDOCOdt_QUADRATIC(indcs10div)./OD_MEAN(indcs10div)),'ko','MarkerFaceColor','none','MarkerEdgeColor','k','LineWidth',1);
        xlabel('[CO]/10^{17} (molecules cm^{-3})');
        ylabel('r');
        set(gca,'FontSize',14);
    end
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  %% D2 SCAN PLOT                        %% (FIG S_D2plot)
    %  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if any(D2dataIndcs)
        COval = mean(xCO.value(D2dataIndcs));
        figure;plot(xD2(D2dataIndcs)./1e17,dDOCOdt_QUADRATIC(D2dataIndcs)./OD_MEAN(D2dataIndcs)./COval.*1e14,'ko','MarkerFaceColor','k','MarkerEdgeColor','k');
        xlabel('[D_2]/10^{17} (molecule cm^{-3})');
        ylabel('y_0/10^{14} (molecule^{-1} cm^3 s^{-1})');
        set(gca,'FontSize',14);
    end
    
    return
    
    %% Generate another O3 Plot
    COval = mean(xCO.value(O3dataIndcs));
    figure;plot(xO3(O3dataIndcs),y(O3dataIndcs),'ko','MarkerFaceColor','k','MarkerEdgeColor','k'); hold on;
    %plot(xO3(O3dataIndcs),yysim(O3dataIndcs)./COval.*1e14,'go','MarkerFaceColor','g','MarkerEdgeColor','g');
    xlabel('O3 Concentration (molecule cm^{-3})');
    ylabel('DOCOdot \times 10^{14} (molecule^{-1} cm^3 s^{-1})');
    set(gca,'FontSize',15);

    figure;plot(xO3(O3dataIndcs),y(O3dataIndcs)./COval.*1e14,'ko','MarkerFaceColor','k','MarkerEdgeColor','k'); hold on;
    plot(xO3(O3dataIndcs),yysim(O3dataIndcs)./COval.*1e14,'go','MarkerFaceColor','g','MarkerEdgeColor','g');
    xlabel('O3 Concentration (molecule cm^{-3})');
    ylabel('y \times 10^{14} (molecule^{-1} cm^3 s^{-1})');
    set(gca,'FontSize',15);
    figure;plot(xO3(O3dataIndcs),yDOCO_O3(O3dataIndcs),'ko','MarkerFaceColor','k','MarkerEdgeColor','k');
    xlabel('O3 Concentration (molecule cm^{-3})');
    ylabel('yDOCOLOSS \times 10^{14} (molecule^{-1} cm^3 s^{-1})');
    set(gca,'FontSize',15);
    figure;plot(xO3(O3dataIndcs).*yDOCO_LOSS(O3dataIndcs)./COval,y(O3dataIndcs)./COval,'ko','MarkerFaceColor','k','MarkerEdgeColor','k');
    xlabel('O3 Concentration (molecule cm^{-3})');
    ylabel('yyy (molecule^{-1} cm^3 s^{-1})');
    set(gca,'FontSize',15);
    
    %% Generate another D2 Plot
    COval = mean(xCO.value(D2dataIndcs));
    figure;plot(xD2(D2dataIndcs),y(D2dataIndcs)./COval.*1e14,'ko','MarkerFaceColor','k','MarkerEdgeColor','k');
    xlabel('D2 Concentration (molecule cm^{-3})');
    ylabel('y \times 10^{14} (molecule^{-1} cm^3 s^{-1})');
    %hold on;
    %plot(xD2,ysim,'ro');
    %plot(xfit,yfit,'Color','r','LineWidth',2);
    %plot(xfit,ci(:,1),'r--','LineWidth',1);
    %plot(xfit,ci(:,2),'r--','LineWidth',1);
    %scatter(xD2,yysim,'bo','MarkerFaceColor','b','MarkerEdgeColor','b');
    set(gca,'FontSize',14);
    
    %% Generate another N2 Plot with only N2 scans
    
    N2linex = linspace(0,max(xN2.value(N2dataIndcs)),100);
    COval = mean(xCO.value(N2dataIndcs));
    N2liney = b(1)*COval.^2 + b(2)*N2linex*COval + b(3)*mean(xO3.value(N2dataIndcs));

    figure;plot(xN2(N2dataIndcs)./1e17,y(N2dataIndcs)./1e4,'ko','MarkerFaceColor','none','MarkerEdgeColor','k','LineWidth',1);
    xlabel('[N2] \times 10^{-17} (molecule cm^{-3})');
    ylabel('(d[DOCO]_0/dt)/[OD]_0 \times 10^{-4} (s^{-1})');
    hold on;
    plot(N2linex./1e17,N2liney./1e4,'r');
    %plot(xfit,yfit,'Color','r','LineWidth',2);
    %plot(xfit,ci(:,1),'r--','LineWidth',1);
    %plot(xfit,ci(:,2),'r--','LineWidth',1);
    %scatter(xD2,yysim,'bo','MarkerFaceColor','b','MarkerEdgeColor','b');
    set(gca,'FontSize',14);
    
    %% Generate another N2 Plot with only N2 scans
    
    N2linex = linspace(0,max(xN2.value(N2dataIndcs)),100);
    COval = mean(xCO.value(N2dataIndcs));
    N2liney = b(1)*COval.^2 + b(2)*N2linex*COval + b(3)*mean(xO3.value(N2dataIndcs));

    figure;plot(xN2(N2dataIndcs)./1e17,y(N2dataIndcs)./xCO(N2dataIndcs).*1e14,'ko','MarkerFaceColor','none','MarkerEdgeColor','k','LineWidth',1);
    xlabel('[N2] \times 10^{-17} (molecule cm^{-3})');
    ylabel('y \times 10^{14} (molecule^{-1} cm^3 s^{-1})');
    hold on;
    plot(N2linex./1e17,N2liney./COval.*1e14,'r');
    %plot(xfit,yfit,'Color','r','LineWidth',2);
    %plot(xfit,ci(:,1),'r--','LineWidth',1);
    %plot(xfit,ci(:,2),'r--','LineWidth',1);
    %scatter(xD2,yysim,'bo','MarkerFaceColor','b','MarkerEdgeColor','b');
    set(gca,'FontSize',14);

    
    %% Generate another CO Plot with only CO scans
    COlinex = linspace(0,max(xCO.value(COdataIndcs)),100);
    N2val = mean(xN2.value(COdataIndcs));
    COliney = b(1)*COlinex.^2 + b(2)*COlinex*N2val + b(3)*mean(xO3.value(N2dataIndcs));
    
    indcs50 = COdataIndcs(intTimes(COdataIndcs)==50);
    indcs25 = COdataIndcs(intTimes(COdataIndcs)==25);
    indcs10 = COdataIndcs(intTimes(COdataIndcs)==10);
    
    figure;
    plot(xCO(indcs50)./1e17,dDOCOdt_QUADRATIC(indcs50)/OD_MEAN(indcs50)./1e4,'ko','MarkerFaceColor','none','MarkerEdgeColor','k','LineWidth',1);
    hold on;
    plot(xCO(indcs10)./1e17,dDOCOdt_QUADRATIC(indcs10)/OD_MEAN(indcs10)./1e4,'bo','MarkerFaceColor','none','MarkerEdgeColor','b','LineWidth',1);
    xlabel('[CO] \times 10^{-17} (molecule cm^{-3})');
    ylabel('(d[DOCO]_0/dt)/[OD]_0 \times 10^{-4} (s^{-1})');
    plot(COlinex./1e17,COliney./1e4,'r');
    set(gca,'FontSize',14);

    %% Generate another CO Plot with only CO scans
    COlinex = linspace(0,max(xCO.value(COdataIndcs)),100);
    N2val = mean(xN2.value(COdataIndcs));
    COliney = b(1)*COlinex.^2 + b(2)*COlinex*N2val + b(3)*mean(xO3.value(N2dataIndcs));
    
    indcs50 = COdataIndcs(intTimes(COdataIndcs)==50);
    indcs25 = COdataIndcs(intTimes(COdataIndcs)==25);
    indcs10 = COdataIndcs(intTimes(COdataIndcs)==10);
    
    figure;
    plot(xCO(indcs50)./1e17,dDOCOdt_QUADRATIC(indcs50)/OD_MEAN(indcs50)./xCO(indcs50).*1e14,'ko','MarkerFaceColor','none','MarkerEdgeColor','k','LineWidth',1);
    hold on;
    plot(xCO(indcs10)./1e17,dDOCOdt_QUADRATIC(indcs10)/OD_MEAN(indcs10)./xCO(indcs10).*1e14,'bs','MarkerFaceColor','none','MarkerEdgeColor','b','LineWidth',1);
    xlabel('[CO] \times 10^{-17} (molecules cm^{-3})');
    ylabel('y \times 10^{14} (molecules^{-1} cm^3 s^{-1})');
    plot(COlinex./1e17,COliney./COlinex.*1e14,'r');
    %plot(xfit,yfit,'Color','r','LineWidth',2);
    %plot(xfit,ci(:,1),'r--','LineWidth',1);
    %plot(xfit,ci(:,2),'r--','LineWidth',1);
    %scatter(xD2,yysim,'bo','MarkerFaceColor','b','MarkerEdgeColor','b');
    set(gca,'FontSize',14);
    return
    
    %% Generate another SYSTEMATIC CO Plot with only CO scans
    COlinex = linspace(0,max(xCO.value(COdataIndcs)),100);
    N2val = mean(xN2.value(COdataIndcs));
    COliney = b(1)*COlinex.^2 + b(2)*COlinex*N2val + b(3)*mean(xO3.value(N2dataIndcs));
    
    indcs50 = COdataIndcs(intTimes(COdataIndcs)==50);
    indcs25 = COdataIndcs(intTimes(COdataIndcs)==25);
    indcs10 = COdataIndcs(intTimes(COdataIndcs)==10);
    
    indcs50div = [];
    indcs10div = [];
    for i = 1:numel(indcs50)
        for j = 1:numel(indcs10)
            if xCO.value(indcs50(i)) == xCO.value(indcs10(j))
                indcs50div(end+1) = indcs50(i);
                indcs10div(end+1) = indcs10(j);
            end
        end
    end
    
    figure;
    plot(xCO(indcs50div)./1e17,y(indcs50div)./y(indcs10div),'ko','MarkerFaceColor','none','MarkerEdgeColor','k','LineWidth',1);
    %hold on;
    %plot(xCO(indcs10)./1e17,y(indcs10)./xCO(indcs10).*1e14,'bs','MarkerFaceColor','none','MarkerEdgeColor','b','LineWidth',1);
    xlabel('[CO] \times 10^{-17} (molecules cm^{-3})');
    ylabel('y \times 10^{14} (molecules^{-1} cm^3 s^{-1})');
    %plot(COlinex./1e17,COliney./COlinex.*1e14,'r');
    %plot(xfit,yfit,'Color','r','LineWidth',2);
    %plot(xfit,ci(:,1),'r--','LineWidth',1);
    %plot(xfit,ci(:,2),'r--','LineWidth',1);
    %scatter(xD2,yysim,'bo','MarkerFaceColor','b','MarkerEdgeColor','b');
    set(gca,'FontSize',14);
    
    %% Generate another plot with all scans
    rVal = (b(1)/b(2));
    Mlinex = linspace(0,max(rVal.*xCO.value(MdataIndcs)+xN2.value(MdataIndcs)),100);
    N2val = mean(xN2.value(MdataIndcs));
    Mliney = b(2)*Mlinex;
    
    indcs50 = dataIndcs(intTimes(MdataIndcs)==50);
    indcs25 = dataIndcs(intTimes(MdataIndcs)==25);
    indcs10 = dataIndcs(intTimes(MdataIndcs)==10);
    
    figure;
    %yyaxis left
    plot((rVal.*xCO(indcs50)+xN2(indcs50))./1e17,y(indcs50)./xCO(indcs50).*1e14,'ko','MarkerFaceColor','none','MarkerEdgeColor','k','LineWidth',1);
    hold on;
    plot((rVal.*xCO(indcs10)+xN2(indcs10))./1e17,y(indcs10)./xCO(indcs10).*1e14,'bs','MarkerFaceColor','none','MarkerEdgeColor','b','LineWidth',1);
    xlabel('[M_{eff}] \times 10^{-17} (molecules cm^{-3})');
    ylabel('y \times 10^{14} (molecules^{-1} cm^3 s^{-1})');
    plot(Mlinex./1e17,Mliney.*1e14,'r');
    % Create second Y axes on the right.
    a1 = gca;
    a2 = axes('YAxisLocation', 'Right');
    % Hide second plot.
    set(a1,'box','off')
    set(a2,'box','off')
    set(a2, 'color', 'none');
    set(a2, 'XTick', []);
    % Set scala for second Y.
    set(a2, 'YLim', [min(get(a1,'YLim')) max(get(a1,'YLim'))].*1e-14./7.5e-14.*100);
    set(a1,'FontSize',14);
    set(a2,'FontSize',14);
    set(a2, 'Position', get(a1,'Position'));
 
    ylabel('DOCO Yield (%)');
    
    %plot(xfit,yfit,'Color','r','LineWidth',2);
    %plot(xfit,ci(:,1),'r--','LineWidth',1);
    %plot(xfit,ci(:,2),'r--','LineWidth',1);
    %scatter(xD2,yysim,'bo','MarkerFaceColor','b','MarkerEdgeColor','b');
    
    return
    %% Generate another O3 Plot with only O3 scans
    O3linex = linspace(min(xO3.value(O3dataIndcs)),max(xO3.value(O3dataIndcs)),100);
    N2val = mean(xN2.value(O3dataIndcs));
    COval = mean(xCO.value(O3dataIndcs));
    O3liney = b(1)*COval.^2 + b(2)*COval*N2val + b(3)*O3linex*COval + 1e32*COval*b(4)./O3linex;
    
    indcs50 = O3dataIndcs(intTimes(O3dataIndcs)==50);
    indcs25 = O3dataIndcs(intTimes(O3dataIndcs)==25);
    indcs10 = O3dataIndcs(intTimes(O3dataIndcs)==10);
    
    figure;
    plot(xO3(indcs50),y(indcs50),'ko','MarkerFaceColor','k','MarkerEdgeColor','k');
    hold on;
    plot(xO3(indcs10),y(indcs10),'bo','MarkerFaceColor','b','MarkerEdgeColor','b');
    xlabel('O3 Concentration [mlc cm^{-3}]');
    ylabel('DOCO Rate Relative to OD [s^{-1}]');
    plot(O3linex,O3liney,'r');
    %plot(xfit,yfit,'Color','r','LineWidth',2);
    %plot(xfit,ci(:,1),'r--','LineWidth',1);
    %plot(xfit,ci(:,2),'r--','LineWidth',1);
    %scatter(xD2,yysim,'bo','MarkerFaceColor','b','MarkerEdgeColor','b');
    set(gca,'FontSize',14);

end

function y = boxpoly2(t,a,b,tau)
    y = zeros(size(t));
    y(t>=0) = a*(t(t>=0)+tau/2)+b*(t(t>=0).^2+tau.*t(t>=0)+tau.^2/3);
    y(t<0 & t>(-tau)) = a*(t(t<0 & t>(-tau))+tau).^2./2./tau + b*(t(t<0 & t>(-tau))+tau).^3./3./tau;
end

function [scaleout, fitcolor, legendtext] = getscalingfactor(fitname)
    switch fitname
        case 'DOCOscaled'
            scaleout = 1;
            legendtext = 'trans-DOCO Sim';
            fitcolor = [0.871    0.49    0.0];
        case 'ODscaled'
            scaleout = 1;
            legendtext = 'OD Sim';
            fitcolor = [0    0.4470    0.7410];
        case 'trans-DOCO'
            scaleout = 1;
            legendtext = 'trans-DOCO';
            fitcolor = [0.871    0.49    0.0];
        case 'OD'
            scaleout = 1;
            legendtext = 'OD';
            fitcolor = [0    0.4470    0.7410];
%         case 'D2O'
%             scaleout = 1;
%             legendtext = 'D_2O';
%             fitcolor = [0.4660    0.6740    0.1880];
%         case 'D2Oscaled'
%             scaleout = 1;
%             legendtext = 'D_2O Sim';
%             fitcolor = [0.4660    0.6740    0.1880];
        otherwise
            scaleout = 1;
            legendtext = '';
            fitcolor = [];
    end
end

function fout = sbiomodelfunction(dataToFit)
    % Need to provide modelobj, cs, variants, dataToFit
    modelobj = evalin('base','modelobj');
    cs = getconfigset(modelobj,'active');
    set(cs, 'StopTime', 100)

    % RUNSIMULATION simulate SimBiology model, modelobj, for each
    % individual in the dataset.

    % Data definition
    groupVar       	  = 'ID';
    independentVar 	  = 'time';
    dependentVar   	  = {'OD','trans_DOCO','D2O'};
    doseVar        	  = {'O3','D2','CO','N2'};
    rateVar        	  = {'','','',''};
    timeUnits      	  = 'microsecond';
    doseUnits      	  = {'molecule','molecule','molecule','molecule'};
    rateUnits      	  = {'','','',''};
    dependentVarUnits = {'molecule','molecule','molecule'};

    % Model Definition
    responseVar(1) = modelobj.Compartments(1).Species(16);
    responseVar(2) = modelobj.Compartments(1).Species(17);
    responseVar(3) = modelobj.Compartments(1).Species(18);
    doseTargets    = {'[HOCO Reaction Cell].O3','[HOCO Reaction Cell].D2','[HOCO Reaction Cell].CO','[HOCO Reaction Cell].N2'};

    % Handle Unit Conversion
    [dataToFit, dependentVar, unitConversionMap] = handleUnitConversion(dataToFit, cs, dependentVar, dependentVarUnits, responseVar);

    % Configure StatesToLog.
    originalStatesToLog = get(cs.RuntimeOptions, 'StatesToLog');
    set(cs.RuntimeOptions, 'StatesToLog', responseVar);

    % Configure StopTime.
    originalStopTime = get(cs, 'StopTime');

    % Cleanup code to restore StatesToLog and StopTime.
    cleanup = onCleanup(@() restore(cs, originalStatesToLog, originalStopTime));

    % Extract the group names. A dose will be created for each group. The 
    % dose will be applied to the model. The model will be simulated using
    % that dose.
    groupNames = getGroupNames(dataToFit, groupVar);

    % Initialize the output.
    data = cell(length(groupNames), 1);

    % Simulate the next individual in the data set.
    groupName = groupNames{j};
    doseObjs  = cell(1, length(doseVar));
    csMaxTime = 0;
    
    % Create a dose for each dose variable.
    for i = 1:length(doseVar) 
        % Construct the dose.
        name           = ['dose' num2str(i)];
        [obj, maxTime] = constructDoseFromDataSet(dataToFit, name, groupVar, independentVar, doseVar{i}, rateVar{i}, groupName);
        
        % Store the highest time in the dose.
        if (maxTime > csMaxTime)
            csMaxTime = maxTime;
        end
        
        % Configure units.
        if ~isempty(obj)
            set(obj, 'TimeUnits', timeUnits);
            set(obj, 'AmountUnits', doseUnits{i});
            set(obj, 'RateUnits', rateUnits{i});
            doseObjs{i} = obj;
        end
        
        set(obj, 'Target', doseTargets{i});
    end
    
    % Convert into an array.
    doseObjs = [doseObjs{:}];    
   
    if ~isempty(doseObjs)
        set(cs, 'StopTime', csMaxTime);
    else
        set(cs, 'StopTime', originalStopTime);
    end
    
    % Simulate the model.
    warning('off','SimBiology:DimAnalysisNotDone_MatlabFcn');
    fout = @(variants,dataLabels) sbiosimulatebox(modelobj, cs, variants, doseObjs, dataLabels);
end

function ysimbox = sbiosimulatebox(modelobj, cs, variants, doseObjs,dataLabels)
    data = sbiosimulate(modelobj, cs, variants, doseObjs);
    [t,ysim,names] = getdata(data);

    ysimbox = zeros(numel(time),numel(dataLabels));
    for i = 1:numel(names)
        iname = find(strcmp(names,dataLabels));
        if any(strcmp(names,dataLabels))
            yyy = ysim(:,i);
            [~,ind,~] = unique(t);
            xint = linspace(min(t),max(t),2e5);
            yint = interp1(t(ind),yyy(ind),xint);
            windowSize = round(50/(xint(2)-xint(1)));
            yintbox = filter((1/windowSize)*ones(1,windowSize),1,yint);
            ysimbox(:,iname) = interp1(xint,yintbox,time+intBox);
        end
    end
end

function restore(cs, originalStatesToLog, originalStopTime)

% Restore StatesToLog.
set(cs.RuntimeOptions, 'StatesToLog', originalStatesToLog);

% Restore StopTime.
set(cs, 'StopTime', originalStopTime);
end

% ---------------------------------------------------------
function groupNames = getGroupNames(dataset, groupLabel)

if isempty(groupLabel)
    groupNames = {''};
else
    groupNames = unique(dataset.(groupLabel), 'stable');
    
    if (isnumeric(groupNames))
        groupNames = num2cell(groupNames);
    end
end
end

% ---------------------------------------------------------
function [doseObj, maxTime] = constructDoseFromDataSet(ds, name, id, time, dose, rate, groupValue)

% If ID is specified, extract it from the dataset.
if ~isempty(id)
    ds = getDataFromDataSet(ds, id, groupValue);
end

% Define the time, dose and rate data.
timeData = ds.(time);
doseData = ds.(dose);
maxTime  = max(timeData);

if ~isempty(rate)
    rateData = ds.(rate);
else
    rateData = zeros(length(timeData),1);
end

% Remove zeros.
removeIDX           = (doseData == 0);
timeData(removeIDX) = [];
doseData(removeIDX) = [];
rateData(removeIDX) = [];

% Remove the NaN values.
removeIDX           = isnan(doseData);
timeData(removeIDX) = [];
doseData(removeIDX) = [];
rateData(removeIDX) = [];

% Remove the Inf values.
removeIDX           = isinf(doseData);
timeData(removeIDX) = [];
doseData(removeIDX) = [];
rateData(removeIDX) = [];

% Sort the data.
[timeData, idx] = sort(timeData);
doseData        = doseData(idx);
rateData        = rateData(idx);

if ~isempty(doseData)
    % Create the object.
    doseObj        = sbiodose(name, 'schedule');
    doseObj.Time   = timeData;
    doseObj.Amount = doseData;
    doseObj.Rate   = rateData;
else
    doseObj = [];
end
end

% ---------------------------------------------------------
function ds = getDataFromDataSet(ds, id, groupValue)

% If ID is specified, extract it from the dataset.
if ~isempty(id)    
    idData = ds.(id);    
    if isnumeric(idData)
        if ischar(groupValue)
            groupValue = str2double(groupValue);
        end
        indices = (idData == groupValue);
    elseif iscellstr(idData)
        indices = strcmp(groupValue, idData);
    else
        indices = 0;
    end
    
    % Extract the new dataset.
    ds = ds(indices, :); 
end
end

% ----------------------------------------------------------
function [dataToFit, dataColumns, unitConversionMap] = handleUnitConversion(dataToFit, cs, dataColumns, dataColumnUnits, responses)
% If unit conversion is turned on build a map with the original dependent
% as key and the unit converted columnName as the value. This is then used
% by groupSimulationPlot to plot the correct responses when only some
% responses are selected in the Plots to generate.
unitConversionMap = containers.Map;
if (cs.CompileOptions.UnitConversion)
    for i=1:length(dataColumns)
        dataUnit  = dataColumnUnits{i};
        modelUnit = getUnitsForResponse(responses(i));
        if ~strcmp(dataUnit, modelUnit)
            
            newColumn   = getUniqueColumnName(dataColumns{i}, dataToFit.Properties.VarNames);            
            nextData    = dataToFit.(dataColumns{i});
            
            % Convert the units.
            try
                nextData = sbiounitcalculator(dataUnit, modelUnit, nextData);
            catch ex
                
            end
            
            % Add column to dataset.
            dataToFit.(newColumn)   = nextData;
            unitConversionMap( dataColumns{i}) = newColumn;       
            dataColumns{i}          = newColumn;
        end
    end
end
end

% ----------------------------------------------------------
function out = getUnitsForResponse(response)
    out = '';
    type = response.Type;
    switch(type)
        case 'species'
            out = response.InitialAmountUnits;
        case 'compartment'
            out = response.CapacityUnits;
        case  'parameter'
            out = response.ValueUnits;
    end
end
    
% ----------------------------------------------------------
function out = getUniqueColumnName(nameIn, columns)
    
out  = nameIn;
obj   = find(strcmp(columns, nameIn));
count = 1;

while ~isempty(obj)
    out   = sprintf('%s_%d', nameIn, count);
    count = count + 1;
    obj   = find(strcmp(columns, out));
end

end
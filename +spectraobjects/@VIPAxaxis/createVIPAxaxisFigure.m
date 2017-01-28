function [hfig,hax1,hax2,hax3,hplot1,hstem2A,hDottedConnection,hstem2B,hstem3] = createVIPAxaxisFigure(figtitle,expStemCallback,simCallback)

if nargin == 1
	% Create figure
	hfig = figure;
else
	hfig = figure('Name',figtitle,'NumberTitle','off');
end
	
% Create axes
hax1 = axes('Parent',hfig,...
    'Position',[0.0607142857142857 0.611904761904764 0.898214285714286 0.361904761904763]);
hplot1 = plot(NaN,NaN);
set(hax1,'XTickLabel','');

% Create axes
hax2 = axes('Parent',hfig,...
    'Position',[0.0607142857142856 0.497619047619048 0.898214285714286 0.114285714285721]);
hDottedConnection = plot(hax2,NaN,NaN,'LineStyle','--');hold(hax2,'on');
hstem2A = stem(hax2,NaN,NaN,'Marker','none','Color','r','LineWidth',3,'ShowBaseline','off','ButtonDownFcn',expStemCallback);
hstem2B = stem(hax2,NaN,NaN,'Marker','none','Color','g','LineWidth',3,'ShowBaseline','off'); hold(hax2,'off');
ylim(hax2,[-1 1]);
set(hax2,'XTickLabel','');
set(hax2,'YTickLabel','');
set(hax2,'XTick',[]);
set(hax2,'YTick',[]);

% Create axes
hax3 = axes('Parent',hfig,...
    'Position',[0.0607142857142856 0.0976190476190476 0.898214285714286 0.400000000000011]);
hstem3 = stem(hax3,NaN,NaN,'Marker','none','ButtonDownFcn',simCallback);

% Link the x axes
linkaxes([hax1 hax2 hax3],'x');
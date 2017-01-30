function fitpanelgui(obj)
% This is the machine-generated representation of a Handle Graphics object
% and its children.  Note that handle values may change when these objects
% are re-created. This may cause problems with any callbacks written to
% depend on the value of the handle at the time the object was saved.
% This problem is solved by saving the output as a FIG-file.
% 
% To reopen this object, just type the name of the M-file at the MATLAB
% prompt. The M-file and its associated MAT-file must be on your path.
% 
% NOTE: certain newer features in MATLAB may not have been saved in this
% M-file due to limitations of this format, which has been superseded by
% FIG-files.  Figures which have been annotated using the plot editor tools
% are incompatible with the M-file/MAT-file format, and should be saved as
% FIG-files.

appdata = [];
appdata.GUIDEOptions = struct(...
    'active_h', [], ...
    'taginfo', struct(...
    'figure', [], ...
    'text', [], ...
    'pushbutton', []), ...
    'override', 0, ...
    'release', [], ...
    'resize', 'none', ...
    'accessibility', 'callback', ...
    'mfile', 0, ...
    'callbacks', [], ...
    'singleton', [], ...
    'syscolorfig', [], ...
    'blocking', 0, ...
    'lastFilename', 'D:\Users\Bryce\Documents\GitHub\Combinator_v9\+kineticsmodelsobjects\@fitpanel\fitpanelguide.fig');
appdata.lastValidTag = 'figure1';
appdata.GUIDELayoutEditor = [];
appdata.initTags = struct(...
    'handle', [], ...
    'tag', 'figure1');

obj.figureHandle = figure(...
'Units','characters',...
'Position',[135.8 40.5384615384615 112 32.3076923076923],...
'PositionMode',get(0,'defaultfigurePositionMode'),...
'Visible',get(0,'defaultfigureVisible'),...
'Color',get(0,'defaultfigureColor'),...
'IntegerHandle','off',...
'MenuBar','none',...
'Name','fitpanel',...
'NumberTitle','off',...
'Resize','on',...
'PaperPosition',get(0,'defaultfigurePaperPosition'),...
'ScreenPixelsPerInchMode','manual',...
'ParentMode','manual',...
'HandleVisibility','callback',...
'Tag','figure1',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'pushbutton1';

obj.fitButton = uicontrol(...
'Parent',obj.figureHandle,...
'FontUnits',get(0,'defaultuicontrolFontUnits'),...
'Units','characters',...
'String','Fit!',...
'Style',get(0,'defaultuicontrolStyle'),...
'Position',[200 0.5 20.2 3.92307692307692],...
'Callback',@(hObject,eventdata) obj.performfit(),...
'Children',[],...
'ParentMode','manual',...
'Tag','pushbutton1',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

obj.fitParameterTable = uitable(...
'Parent',obj.figureHandle,...
'Units','characters',...
'Position',[19.8 5 200 7.76923076923077],...
'Data',obj.Parent.fitLowerUpperStartingScope,...
'ColumnName',obj.Parent.fitParameterNames,...
'RowName',{'Lower','Upper','Initial','Scope'},...
'ColumnEditable',true(1,size(obj.Parent.fitLowerUpperStartingScope,2)),...
'Children',[],...
'ParentMode','manual',...
'Tag','uitable1',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

data = zeros(4,3);
obj.fitEquationTable = uitable(...
'Parent',obj.figureHandle,...
'Units','characters',...
'Position',[19.8 15 200 7.76923076923077],...
'Data',data,...
'ColumnName',{'y=','expression','parameters'},...
'RowName',{'1','2','3','4'},...
'ColumnEditable',true(1,size(data,2)),...
'Children',[],...
'ParentMode','manual',...
'Tag','uitable1',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

data = zeros(4,1);
obj.variablesTable = uitable(...
'Parent',obj.figureHandle,...
'Units','characters',...
'Position',[225 5 30 20],...
'Data',data,...
'ColumnName',{'name'},...
'RowName',{'1','2','3','4'},...
'ColumnEditable',false(1,size(data,2)),...
'Children',[],...
'ParentMode','manual',...
'Tag','uitable1',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );



% --- Set application data first then calling the CreateFcn. 
function local_CreateFcn(hObject, eventdata, createfcn, appdata)

if ~isempty(appdata)
   names = fieldnames(appdata);
   for i=1:length(names)
       name = char(names(i));
       setappdata(hObject, name, getfield(appdata,name));
   end
end

if ~isempty(createfcn)
   if isa(createfcn,'function_handle')
       createfcn(hObject, eventdata);
   else
       eval(createfcn);
   end
end
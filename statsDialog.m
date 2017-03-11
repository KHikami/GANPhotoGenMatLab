function varargout = statsDialog(varargin)
% STATSDIALOG MATLAB code for statsDialog.fig
%      STATSDIALOG by itself, creates a new STATSDIALOG or raises the
%      existing singleton*.
%
%      H = STATSDIALOG returns the handle to a new STATSDIALOG or the handle to
%      the existing singleton*.
%
%      STATSDIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STATSDIALOG.M with the given input arguments.
%
%      STATSDIALOG('Property','Value',...) creates a new STATSDIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before statsDialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to statsDialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help statsDialog

% Last Modified by GUIDE v2.5 09-Mar-2017 11:29:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @statsDialog_OpeningFcn, ...
                   'gui_OutputFcn',  @statsDialog_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before statsDialog is made visible.
function statsDialog_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to statsDialog (see VARARGIN)

% Choose default command line output for statsDialog
handles.output = 'Yes';

% Update handles structure
guidata(hObject, handles);

% Insert custom Title and Text if specified by the user
% Hint: when choosing keywords, be sure they are not easily confused 
% with existing figure properties.  See the output of set(figure) for
% a list of figure properties.

if(nargin > 3)
    for index = 1:2:(nargin-3),
        if nargin-3==index, break, end
        switch lower(varargin{index})
            case 'title'
                set(hObject, 'Name', varargin{index+1});
            case 'statsgraph1'
                handles.data.stats1Data = varargin{index+1};
            case 'statsgraph2'
                handles.data.stats2Data = varargin{index+1};
            case 'statsgraph3'
                handles.data.stats3Data = varargin{index+1};
            case 'statsgraph4'
                handles.data.stats4Data = varargin{index+1};
        end
    end
end

% Determine the position of the dialog - centered on the callback figure
% if available, else, centered on the screen
FigPos=get(0,'DefaultFigurePosition');
OldUnits = get(hObject, 'Units');
set(hObject, 'Units', 'pixels');
OldPos = get(hObject,'Position');
FigWidth = OldPos(3);
FigHeight = OldPos(4);
if isempty(gcbf)
    ScreenUnits=get(0,'Units');
    set(0,'Units','pixels');
    ScreenSize=get(0,'ScreenSize');
    set(0,'Units',ScreenUnits);

    FigPos(1)=1/2*(ScreenSize(3)-FigWidth);
    FigPos(2)=2/3*(ScreenSize(4)-FigHeight);
else
    GCBFOldUnits = get(gcbf,'Units');
    set(gcbf,'Units','pixels');
    GCBFPos = get(gcbf,'Position');
    set(gcbf,'Units',GCBFOldUnits);
    FigPos(1:2) = [(GCBFPos(1) + GCBFPos(3) / 2) - FigWidth / 2, ...
                   (GCBFPos(2) + GCBFPos(4) / 2) - FigHeight / 2];
end
FigPos(3:4)=[FigWidth FigHeight];
set(hObject, 'Position', FigPos);
set(hObject, 'Units', OldUnits);

% Make the GUI modal
set(handles.figure1,'WindowStyle','modal')

%we can get so fancy with our graphs:
%https://www.mathworks.com/help/matlab/ref/scatter.html
stats1xval = handles.data.stats1Data(:,1);
stats1yval = handles.data.stats1Data(:,2);
axes(handles.statsGraph1);
scatter(stats1xval,stats1yval,'filled');
title(handles.statsGraph1,'Painter Iterations vs Time');
xlabel(handles.statsGraph1,'Iteration #');
ylabel(handles.statsGraph1,'Time(s)');

[minXval,maxXval] = getlimits(stats1xval);
[minYval,maxYval] = getlimits(stats1yval);
handles.statsGraph1.XLim = [minXval maxXval];
handles.statsGraph1.YLim =[minYval maxYval];
xticks = 1:maxXval;
handles.statsGraph1.XTick = xticks;
yticks = linspace(minYval,maxYval,10);
handles.statsGraph1.YTick = yticks;

stats2xval = handles.data.stats2Data(:,1);
stats2yval = handles.data.stats2Data(:,2);
axes(handles.statsGraph2);
scatter(stats2xval,stats2yval, 'cyan', 'filled');
title(handles.statsGraph2,'Painter Iterations vs Score');
xlabel(handles.statsGraph2,'Iteration #');
ylabel(handles.statsGraph2,'Score');

[minXval,maxXval] = getlimits(stats2xval);
[minYval,maxYval] = getlimits(stats2yval);
handles.statsGraph2.XLim = [minXval maxXval];
handles.statsGraph2.YLim =[minYval maxYval];
xticks = 1:maxXval;
handles.statsGraph2.XTick = xticks;
yticks = linspace(minYval,maxYval,10);
handles.statsGraph2.YTick = yticks;

stats3xval = handles.data.stats3Data(:,1);
stats3yval = handles.data.stats3Data(:,2);
axes(handles.statsGraph3);
scatter(stats3xval,stats3yval, 'magenta', 'filled');
title(handles.statsGraph3,'Identifier Iterations vs Time');
xlabel(handles.statsGraph3,'Iteration #');
ylabel(handles.statsGraph3,'Time(s)');

[minXval,maxXval] = getlimits(stats3xval);
[minYval,maxYval] = getlimits(stats3yval);
handles.statsGraph3.XLim = [minXval maxXval];
handles.statsGraph3.YLim =[minYval maxYval];
xticks = minXval:maxXval;
handles.statsGraph3.XTick = xticks;
yticks = linspace(minYval,maxYval,10);
handles.statsGraph3.YTick = yticks;

stats4xval = handles.data.stats4Data(:,1);
stats4yval = handles.data.stats4Data(:,2);
axes(handles.statsGraph4);
scatter(stats4xval,stats4yval, 'filled');
title('Unknown');
xlabel('Unknown');
ylabel('Unknown');

[minXval,maxXval] = getlimits(stats4xval);
[minYval,maxYval] = getlimits(stats4yval);
handles.statsGraph4.XLim = [minXval maxXval];
handles.statsGraph4.YLim =[minYval maxYval];
xticks = 1:maxXval;
handles.statsGraph4.XTick = xticks;
yticks = linspace(minYval,maxYval,10);
handles.statsGraph4.YTick = yticks;

% UIWAIT makes statsDialog wait for user response (see UIRESUME)
uiwait(handles.figure1);

function [minVal, maxVal] = getlimits(input)
%might want to change this to instead of being weighted by 1 by an offset
%of the range...
maxVal = max(input);
minVal = min(input);
if(minVal == maxVal)
    minVal = maxVal-0.01;
end
maxVal = maxVal+0.01;

% --- Outputs from this function are returned to the command line.
function varargout = statsDialog_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.figure1);

% --- Executes on button press in OkayButton.
function OkayButton_Callback(hObject, eventdata, handles)
% hObject    handle to OkayButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = get(hObject,'String');

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end

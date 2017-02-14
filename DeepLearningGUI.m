function varargout = DeepLearningGUI(varargin)
% DEEPLEARNINGGUI MATLAB code for DeepLearningGUI.fig
%      DEEPLEARNINGGUI, by itself, creates a new DEEPLEARNINGGUI or raises the existing
%      singleton*.
%
%      H = DEEPLEARNINGGUI returns the handle to a new DEEPLEARNINGGUI or the handle to
%      the existing singleton*.
%
%      DEEPLEARNINGGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DEEPLEARNINGGUI.M with the given input arguments.
%
%      DEEPLEARNINGGUI('Property','Value',...) creates a new DEEPLEARNINGGUI or raises
%      the existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DeepLearningGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DeepLearningGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DeepLearningGUI

% Last Modified by GUIDE v2.5 14-Feb-2017 10:58:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DeepLearningGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @DeepLearningGUI_OutputFcn, ...
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

% --- Executes just before DeepLearningGUI is made visible.
function DeepLearningGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DeepLearningGUI (see VARARGIN)

% Choose default command line output for DeepLearningGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

initialize_gui(hObject, handles, false);

% UIWAIT makes DeepLearningGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DeepLearningGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in train.
function train_Callback(hObject, eventdata, handles)
% hObject    handle to train (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%fill in the color map and shape map along with statistics for overall
%process

%also associate label with the generated training model
%handles is currently empty at this point... not too sure how to initialize
set(handles.statusText, 'String', 'Image Training Complete');

% --- Executes on button press in draw.
function draw_Callback(hObject, eventdata, handles)
% hObject    handle to draw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%returns the painted image generated

set(handles.statusText, 'String', 'Image Generation Complete');

% --------------------------------------------------------------------
function initialize_gui(fig_handle, handles, isreset)
%if modifying a field that is important to results => don't re-initialize
if isfield(handles, 'data') && ~isreset
    return;
end

%create handles for stuff that will change

handles.data.trainingFileName = ' ';
handles.data.numberOfIterations = 0;
handles.data.trainingLabel = 'random';
handles.data.drawingLabel = ' ';

set(handles.statusText, 'String', 'Ready for Selection');

% Update handles structure
guidata(handles.figure1, handles);

function unitgroup_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in unitgroup 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (hObject == handles.trainingRadioButton)
    %Make Training data fields selectable
else
    %Make draw data fields
end

function labelForImageToDraw_Callback(hObject, eventdata, handles)
% hObject    handle to labelForImageToDraw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%should do nothing or reset the text


% --- Executes during object creation, after setting all properties.
function labelForImageToDraw_CreateFcn(hObject, eventdata, handles)
% hObject    handle to labelForImageToDraw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

%should be filled in with the text that the user wants a drawing of
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function labelForTrainingImage_Callback(hObject, eventdata, handles)
% hObject    handle to labelForTrainingImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of labelForTrainingImage as text
%        str2double(get(hObject,'String')) returns contents of labelForTrainingImage as a double


% --- Executes during object creation, after setting all properties.
function labelForTrainingImage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to labelForTrainingImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

%initially blank and should only be available if Train selected
%to be passed in to the object identifier for training

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function trainingImage_Callback(hObject, eventdata, handles)
% hObject    handle to trainingImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trainingImage as text
%        str2double(get(hObject,'String')) returns contents of trainingImage as a double



% --- Executes during object creation, after setting all properties.
function trainingImage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trainingImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in browseForTrainImage.
function browseForTrainImage_Callback(hObject, eventdata, handles)
% hObject    handle to browseForTrainImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%create browse image functionality?

function numOfIterations_Callback(hObject, eventdata, handles)
% hObject    handle to numOfIterations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

numOfIt = str2double(get(hObject,'String'));

if(isnan(numOfIt))
    set(hObject, 'String', 0);
    set(handles.statusText, 'String', 'Bad Number Of Iterations');
    return;
end

handles.data.numberOfIterations = numOfIt;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function numOfIterations_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numOfIterations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

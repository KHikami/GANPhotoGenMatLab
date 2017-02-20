function varargout = DeepLearningGUI(varargin)

% DEEPLEARNINGGUI MATLAB code for DeepLearningGUI.fig
% you run this!!! not the .fig file!!! (Kept running into errors ^^")
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

% Last Modified by GUIDE v2.5 20-Feb-2017 11:03:28

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

%retrieve the data needed for storage
tFileName = handles.data.trainingImageFileName;
tLabel = handles.data.labelForTrainingImage;

clearDrawResults(handles);
clearIdentifyResults(handles);

%re-activate all the axes~
set(handles.colorMapPhoto, 'Visible', 'on');
set(handles.shapeMapPhoto, 'Visible', 'on');

%using a grayscale axes just for debugging of the filters
set(handles.grayScalePhoto, 'Visible', 'on');

%load the selected image (right now hardcoded to a photo in file) (but
%should take in tFileName)
ImToTrain = imread('GANPhotoGenMatLab\GoogleImages\GoogleVDay.jpg');

GrayScaleIm = rgb2gray(ImToTrain);
axes(handles.grayScalePhoto);
imshow(GrayScaleIm, []);

%fill in the color map and shape map along with statistics for overall
%process
ImColorMap = ColorMap(ImToTrain);
axes(handles.colorMapPhoto);
imshow(ImColorMap, []);

ImShapeMap = ShapeMap(ImToTrain);
axes(handles.shapeMapPhoto);
imshow(ImShapeMap, []);

%need storage for the maps against the given label

%also associate label with the generated training model
%handles is currently empty at this point... not too sure how to initialize
set(handles.statusText, 'String', 'Image Training Complete');

function clearTrainResults(handles)
cla(handles.colorMapPhoto);
set(handles.colorMapPhoto, 'Visible', 'off');
axis off;

cla(handles.shapeMapPhoto);
set(handles.shapeMapPhoto, 'Visible', 'off');
axis off;

cla(handles.grayScalePhoto);
set(handles.grayScalePhoto, 'Visible', 'off');
axis off;


function clearDrawResults(handles)
cla(handles.paintedImagePhoto);
set(handles.paintedImagePhoto, 'Visible', 'off');
axis off;

function clearIdentifyResults(handles)
set(handles.labelOfObjectBeingIdentified, 'String', '');

% --- Executes on button press in draw.
function draw_Callback(hObject, eventdata, handles)
% hObject    handle to draw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%re-activate or clear all the axes we don't want to use
set(handles.paintedImagePhoto, 'Visible', 'on');

clearTrainResults(handles);
clearIdentifyResults(handles);

%returns the painted image generated (right now is just returning the photo
%I already have on file)
testLabel = 'GANPhotoGenMatLab\GoogleImages\GoogleVDay.jpg';

ImToPaint = GenerateImage(testLabel);

%loops over the number of iterations and runs object identifier against the
%generated image. keeps memory of previous generated image if new generated
%image has a lower score than previous.

axes(handles.paintedImagePhoto);
imshow(ImToPaint, []);

set(handles.statusText, 'String', 'Image Generation Complete');

% --------------------------------------------------------------------
function initialize_gui(fig_handle, handles, isreset)
%if modifying a field that is important to results => don't re-initialize
if isfield(handles, 'data') && ~isreset
    return;
end

%create handles for stuff that will change

handles.data.trainingImageFileName = ' ';
handles.data.numberOfIterations = 0;
handles.data.labelForTrainingImage = 'random';
handles.data.drawingLabel = ' ';
handles.data.trainingMode = 1;

set(handles.statusText, 'String', 'Ready for Selection');
set(handles.trainOrDrawUnitGroup, 'SelectedObject', handles.trainingRadioButton);

disableDrawingFields(handles);
disableIdentifyFields(handles);

set(handles.identifiedObjectPhoto, 'visible', 'off');
axis off;
set(handles.identifyScoreMatrix, 'visible', 'off');
axis off;
set(handles.paintedImagePhoto, 'visible', 'off');
axis off;
set(handles.colorMapPhoto, 'visible', 'off');
axis off;
set(handles.shapeMapPhoto, 'visible', 'off');
axis off;
set(handles.grayScalePhoto, 'visible', 'off');
axis off;


% Update handles structure
guidata(handles.figure1, handles);

function trainOrDrawUnitGroup_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in unitgroup 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (hObject == handles.trainingRadioButton)
    %Make Training data fields selectable
    enableTrainingFields(handles);
    disableDrawingFields(handles);
    disableIdentifyFields(handles);
    
elseif (hObject == handles.identifyRadioButton)
    disableDrawingFields(handles);
    disableTrainingFields(handles);
    enableIdentifyFields(handles);
else
    %Make draw data fields editable but training fields not editable
    disableTrainingFields(handles);
    disableIdentifyFields(handles);
    enableDrawingFields(handles);
end

function enableIdentifyFields(handles)
set(handles.identifyImage, 'Enable', 'on');
set(handles.identifyBrowse, 'Enable', 'on');
set(handles.identifyLabel, 'Enable', 'on');
set(handles.identifyButton, 'Enable', 'on');

function disableIdentifyFields(handles)
set(handles.identifyImage, 'Enable', 'off');
set(handles.identifyBrowse, 'Enable', 'off');
set(handles.identifyLabel, 'Enable', 'off');
set(handles.identifyButton, 'Enable', 'off');

emptyString = '';
set(handles.identifyLabel, 'String', emptyString);
set(handles.identifyImage, 'String', emptyString);

function disableDrawingFields(handles)
set(handles.labelForImageToDraw, 'Enable', 'off');
set(handles.numOfIterations, 'Enable', 'off');
set(handles.draw, 'Enable', 'off');

function enableDrawingFields(handles)
set(handles.labelForImageToDraw, 'Enable', 'on');
set(handles.numOfIterations, 'Enable', 'on');
set(handles.draw, 'Enable', 'on');


function enableTrainingFields(handles)
    handles.data.trainingMode = 1;
    set(handles.trainingImage, 'Enable', 'on');
    set(handles.browseForTrainImage, 'Enable', 'on');
    set(handles.labelForTrainingImage, 'Enable', 'on');
    set(handles.train, 'Enable', 'on');

function disableTrainingFields(handles)
%disables all the fields for Training
    handles.data.trainingMode = 0;
    set(handles.trainingImage, 'Enable', 'off');
    set(handles.browseForTrainImage, 'Enable', 'off');
    set(handles.labelForTrainingImage, 'Enable', 'off');
    set(handles.train, 'Enable', 'off');
    


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

%store the label for the given training image
handles.data.labelForTrainingImage = get(hObject, 'String');

guidata(hObject,handles);



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


%trainingImage = the file selected
function trainingImage_Callback(hObject, eventdata, handles)
% hObject    handle to trainingImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trainingImage as text
%        str2double(get(hObject,'String')) returns contents of trainingImage as a double

%store the location of the file selected
handles.data.trainingImageFileName = get(hObject, 'String');
guidata(hObject, handles);



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

%create browse image functionality/create pop up window to select a given
%image

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



function identifyImage_Callback(hObject, eventdata, handles)
% hObject    handle to identifyImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.data.imageToIdentify = get(hObject,'String');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function identifyImage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to identifyImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in identifyBrowse.
function identifyBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to identifyBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in identifyButton.
function identifyButton_Callback(hObject, eventdata, handles)
% hObject    handle to identifyButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

image = handles.data.imageToIdentify;
label = handles.data.labelToIdentify;
%use label to retrieve related color map and shape map. if none exist =>
%set status text to be no related template in memory. please train first.

%uses objectIdentifier against passed in image and identify hit with score

set(handles.labelOfObjectBeingIdentified, 'String', label);
set(handles.statusText, 'String', 'Object Identified');

function identifyLabel_Callback(hObject, eventdata, handles)
% hObject    handle to identifyLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.data.labelToIdentify = get(hObject,'String');
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function identifyLabel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to identifyLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

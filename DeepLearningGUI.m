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

% Last Modified by GUIDE v2.5 09-Mar-2017 10:04:42

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
ImToTrain = imread(tFileName);
numOfKeysInMap = length(handles.data.objectIdentifierMemoryMap);

isNewTrain = or(numOfKeysInMap == 0, ...
    not(isKey(handles.data.objectIdentifierMemoryMap, tLabel)));

startTime = now;

if(isNewTrain)
    colorMapToShow = ColorMap(ImToTrain);
    shapeMapToShow = ShapeMap(ImToTrain);
else
    %run identifier against new image to train against
    origData = handles.data.objectIdentifierMemoryMap(tLabel);
    [newDataScore, ~, inClass] = ObjectIdentifier(ImToTrain, ...
        origData.colorMap, origData.shapeMap);
    %do nothing with the identify image and possibly nothing with
    %inClass/hit
    
    if(inClass)
        %I can positively identify => do we want to skip?
        newColorMap = origData.colorMap;
        newShapeMap = origData.shapeMap;
    else
        %modify colormap and shape map to new stuff (backpropagate the error)
        %if misclassify
        [newColorMap, newShapeMap] = TrainIdentifier(origData.colorMap, origData.shapeMap,...
        ImToTrain, newDataScore, origData.numOfIterations);
    end
    
    colorMapToShow = newColorMap;
    shapeMapToShow = newShapeMap;
end


endTime = now;
timeForTrainRun = endTime - startTime;

GrayScaleIm = rgb2gray(ImToTrain);
axes(handles.grayScalePhoto);
imshow(GrayScaleIm, []);

PixelizedColorMap = Pixelize(colorMapToShow);
axes(handles.colorMapPhoto);
imshow(PixelizedColorMap/255);

axes(handles.shapeMapPhoto);
imshow(shapeMapToShow, []);

%if this label does not have a memory associated with it => create it
if(isNewTrain)
    trainMem = ObjectIdentifierMemory(colorMapToShow, shapeMapToShow);
else
    %update the color and shape map to be a combo/corrected version
    trainMem = handles.data.objectIdentifierMemoryMap(tLabel);
    trainMem = setMaps(trainMem, colorMapToShow, shapeMapToShow);
end

trainMem = addIteration(trainMem,timeForTrainRun);
handles.data.objectIdentifierMemoryMap(tLabel) = trainMem;

set(handles.statusText, 'String', 'Image Training Complete');
guidata(hObject,handles);

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
set(handles.avgDrawScore, 'String', '');
set(handles.totalGen, 'String', '');
set(handles.totalTrain, 'String', '');
set(handles.avgGenTime, 'String', '');
set(handles.avgTrainTime, 'String', '');
set(handles.drawScoreButton, 'Enable', 'off');
set(handles.drawScoreButton, 'Visible', 'off');
set(handles.statsButton, 'Enable', 'off');
set(handles.statsButton, 'Visible', 'off');

function clearIdentifyResults(handles)
set(handles.labelOfObjectBeingIdentified, 'String', '');
cla(handles.identifiedObjectPhoto);
set(handles.avgIdentifyScore, 'String', '');
set(handles.identifiedObjectPhoto, 'Visible', 'off');
set(handles.identifyScoreButton, 'Enable', 'off');
set(handles.identifyScoreButton, 'Visible', 'off');
axis off;

% --- Executes on button press in draw.
function draw_Callback(hObject, eventdata, handles)
% hObject    handle to draw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

clearTrainResults(handles);
clearIdentifyResults(handles);

drawLabel = handles.data.drawingLabel;
responseText = 'Image Generation Complete';

%grab respective train map if it exists...
numOfTrainEntries = length(handles.data.objectIdentifierMemoryMap);
noTrainData = or(numOfTrainEntries == 0, ...
    not(isKey(handles.data.objectIdentifierMemoryMap,drawLabel)));

if(noTrainData)
    responseText = 'Please train against label first before attempting to draw';
else
    %re-activate or clear all the axes we don't want to use
    set(handles.paintedImagePhoto, 'Visible', 'on');
    set(handles.drawScoreButton, 'Enable', 'on');
    set(handles.drawScoreButton, 'Visible', 'on');
    set(handles.statsButton, 'Enable', 'on');
    set(handles.statsButton, 'Visible', 'on');
    
    respectiveTrainMem = handles.data.objectIdentifierMemoryMap(drawLabel);
    trainColorMap = respectiveTrainMem.colorMap;
    trainShapeMap = respectiveTrainMem.shapeMap;
    numOfIt = handles.data.numberOfIterations;
    gen = handles.data.generator;
    
    for i = 1:numOfIt
        numOfPainterEntries = length(handles.data.painterMemoryMap);
        isNewPainting = or(numOfPainterEntries == 0, ...
            not(isKey(handles.data.painterMemoryMap, drawLabel)));
        if(isNewPainting)
            startV = rand(100,1);
            scoreToPropagate = 0;
        else
            startV = handles.data.painterMemoryMap(drawLabel).startingVector;
            scoreToPropagate = handles.data.painterMemoryMap(drawLabel).averageScore;
        end
        startTime = now;
        ImToPaint = GenerateImage(gen, startV, scoreToPropagate);
        %objectIdentifier run against ImToPaint (not too sure if we want to
        %use inClass for anything
        [drawScore, ~, ~] = ObjectIdentifier(ImToPaint, trainColorMap, trainShapeMap);
        %feed into generator the avg. score of drawScore
        endTime = now;
        timeForRun = endTime-startTime;
        
        if(isNewPainting)
            painterMem = PainterMemory(startV, drawScore, timeForRun);
        else
            painterMem = handles.data.painterMemoryMap(drawLabel);
            painterMem = updateBest(painterMem, startV, drawScore);
            painterMem = addIteration(painterMem,timeForRun);
        end

        handles.data.painterMemoryMap(drawLabel) = painterMem;
    end
    
    axes(handles.paintedImagePhoto);
    imshow(ImToPaint, []);
    
    handles.data.paintedScore = painterMem.vectorScore;

    numOfTrain = numOfIterations(respectiveTrainMem);
    avgTrain = averageIterationTime(respectiveTrainMem);
    numOfGen = numOfIterations(painterMem);
    avgGen = averageIterationTime(painterMem);
    avgScore = averageScore(painterMem);
    
    set(handles.totalGen, 'String', numOfGen);
    set(handles.totalTrain, 'String', numOfTrain);
    set(handles.avgGenTime, 'String', avgGen);
    set(handles.avgTrainTime, 'String', avgTrain);
    set(handles.avgDrawScore, 'String', avgScore);
    
    handles.data.currentDrawMemory = painterMem;
end

set(handles.statusText, 'String', responseText); 
guidata(hObject,handles);



% --------------------------------------------------------------------
function initialize_gui(fig_handle, handles, isreset)
%if modifying a field that is important to results => don't re-initialize
if isfield(handles, 'data') && ~isreset
    return;
end

%create handles for stuff that will change

%initialize all data fields
handles.data.trainingImageFileName = '';
handles.data.numberOfIterations = 0;
handles.data.labelForTrainingImage = '';
handles.data.drawingLabel = '';
handles.data.imageToIdentify = '';
handles.data.labelToIdentify = '';
%initializing a new map for labels to memory objects
handles.data.objectIdentifierMemoryMap = containers.Map();
handles.data.painterMemoryMap = containers.Map();
handles.data.paintedScore = [];
handles.data.identifiedScore = [];
handles.data.currentDrawMemory = '';
handles.data.generator = [];

%holds the memories of the object identifier
handles.data.objectIdentifierMemory = '';

%holds the memories fo the object generator
handles.data.objectGeneratorMemory = '';

set(handles.statusText, 'String', 'Ready for Selection');
set(handles.trainOrDrawUnitGroup, 'SelectedObject', handles.trainingRadioButton);

disableDrawingFields(handles);
disableIdentifyFields(handles);

set(handles.identifiedObjectPhoto, 'visible', 'off');
axis off;
set(handles.paintedImagePhoto, 'visible', 'off');
axis off;
set(handles.colorMapPhoto, 'visible', 'off');
axis off;
set(handles.shapeMapPhoto, 'visible', 'off');
axis off;
set(handles.grayScalePhoto, 'visible', 'off');
axis off;
set(handles.drawScoreButton, 'Enable', 'off');
set(handles.drawScoreButton, 'Visible', 'off');
set(handles.statsButton, 'Enable', 'off');
set(handles.statsButton, 'Visible', 'off');
set(handles.identifyScoreButton, 'Enable', 'off');
set(handles.identifyScoreButton, 'Visible', 'off');
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
set(handles.labelForImageToDraw, 'String', '');
set(handles.numOfIterations, 'Enable', 'off');
set(handles.numOfIterations, 'String', '');
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
    
    set(handles.trainingImage, 'String', '');
    set(handles.labelForTrainingImage, 'String', '');
    


function labelForImageToDraw_Callback(hObject, eventdata, handles)
% hObject    handle to labelForImageToDraw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.data.drawingLabel = get(hObject,'String');
guidata(hObject,handles);


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

%might want to filter uigetfile to only grab image files
%also need to append filename to pathname to then be able to retrieve the
%file
[tempFileName,tempPathName] = uigetfile({'*.jpg'; '*.jpeg'; '*.bmp'; '*.png'}, 'File Selector');
if(not(tempFileName == 0))
    handles.data.trainingImageFileName = strcat(tempPathName, tempFileName);
    set(handles.trainingImage, 'String', strcat(tempPathName,tempFileName));
end

guidata(hObject,handles);

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

[tempFileName,tempPathName] = uigetfile({'*.jpg'; '*.jpeg'; '*.bmp'; '*.png'}, 'File Selector');
if(not(tempFileName == 0))
    handles.data.imageToIdentify = strcat(tempPathName, tempFileName);
    set(handles.identifyImage, 'String', strcat(tempPathName,tempFileName));
end

guidata(hObject,handles);


% --- Executes on button press in identifyButton.
function identifyButton_Callback(hObject, eventdata, handles)
% hObject    handle to identifyButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

image = handles.data.imageToIdentify;
label = handles.data.labelToIdentify;
%use label to retrieve related color map and shape map. if none exist =>
%set status text to be no related template in memory. please train first.
returnText = 'Object Identified';

clearTrainResults(handles);
clearDrawResults(handles);

numOfTrainEntries = length(handles.data.objectIdentifierMemoryMap);
if(or(numOfTrainEntries == 0, not(isKey(handles.data.objectIdentifierMemoryMap, label))))
    returnText = 'Please first train Object Identifier against label';
else
    %uses objectIdentifier against passed in image and identify hit with score
    set(handles.identifiedObjectPhoto, 'Visible', 'on');
    set(handles.identifyScoreButton,'Visible','on');
    set(handles.identifyScoreButton, 'Enable','on');
    ImToIdentify = imread(image);
    
    trainData = handles.data.objectIdentifierMemoryMap(label);
    [identifyScore, identifyBox, inClass] = ObjectIdentifier(ImToIdentify, trainData.colorMap,...
        trainData.shapeMap);
    
    handles.data.identifiedScore = identifyScore;
    
    if(inClass == 0)
        returnText = 'Target Object not identified';
        deadImage = rgb2gray(ImToIdentify);
        axes(handles.identifiedObjectPhoto);
        imshow(deadImage, []);
    else
        axes(handles.identifiedObjectPhoto);
        imshow(ImToIdentify, []);
        
        %hold on;
        %h = rectangle('Position', identifyBox, 'EdgeColor', [1 0 0], ...
        %'LineWidth', 3);
        %hold off;
    end
    
    [sh, sw] = size(identifyScore);
    totalScore = sum(reshape(identifyScore, 1,sh*sw));
    avgScore = totalScore/(sh*sw);
    set(handles.avgIdentifyScore, 'String', avgScore);
    set(handles.labelOfObjectBeingIdentified, 'String', label);
    
end

set(handles.statusText, 'String', returnText);

%need to store the identify score for the score button to use
guidata(hObject, handles);

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


% --- Executes on button press in identifyScoreButton.
function identifyScoreButton_Callback(hObject, eventdata, handles)
% hObject    handle to identifyScoreButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

identifyScore = handles.data.identifiedScore;
pos_size = get(handles.figure1, 'Position');
displayScore('Title', 'Identified Object Score', 'Score', identifyScore);




% --- Executes on button press in drawScoreButton.
function drawScoreButton_Callback(hObject, eventdata, handles)
% hObject    handle to drawScoreButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dataScore = handles.data.paintedScore;
pos_size = get(handles.figure1, 'Position');
displayScore('Title', 'Painting Score', 'Score', dataScore);


%having trouble plotting stuff... please do not use for now
% --- Executes on button press in statsButton.
function statsButton_Callback(hObject, eventdata, handles)
% hObject    handle to statsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%can't be empty here
drawingMemory = handles.data.currentDrawMemory;
stats1 = drawingMemory.iterationTimePlot;
stats2 = drawingMemory.iterationScorePlot;
trainMemory = handles.data.objectIdentifierMemoryMap(handles.data.drawingLabel);
stats3 = trainMemory.iterationPlot;
stats4 = handles.data.objectIdentifierMemoryMap;
pos_size = get(handles.figure1, 'Position'); 
statsDialog('Title', 'Painting Statistics', ...
    'statsGraph1', stats1, 'statsGraph2', stats2, 'statsGraph3', stats3, ...
    'statsGraph4', stats4);

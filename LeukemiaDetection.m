function varargout = LeukemiaDetection(varargin)
% LEUKEMIADETECTION MATLAB code for LeukemiaDetection.fig
%      LEUKEMIADETECTION, by itself, creates a new LEUKEMIADETECTION or raises the existing
%      singleton*.
%
%      H = LEUKEMIADETECTION returns the handle to a new LEUKEMIADETECTION or the handle to
%      the existing singleton*.
%
%      LEUKEMIADETECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LEUKEMIADETECTION.M with the given input arguments.
%
%      LEUKEMIADETECTION('Property','Value',...) creates a new LEUKEMIADETECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before LeukemiaDetection_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to LeukemiaDetection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LeukemiaDetection

% Last Modified by GUIDE v2.5 16-Dec-2018 15:44:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LeukemiaDetection_OpeningFcn, ...
                   'gui_OutputFcn',  @LeukemiaDetection_OutputFcn, ...
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


% --- Executes just before LeukemiaDetection is made visible.
function LeukemiaDetection_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LeukemiaDetection (see VARARGIN)

% Choose default command line output for LeukemiaDetection
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes LeukemiaDetection wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = LeukemiaDetection_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in loadImg.
function loadImg_Callback(hObject, eventdata, handles)
% hObject    handle to loadImg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.exportData,'Visible','off');

[file,path] = uigetfile({'*.jpg'; '*.png'}, 'Select An Image');
if isequal(file,0)
   disp('User selected Cancel');
else
   selectedfile = fullfile(path,file);
   %%Reading in the image
    myImage = imread(selectedfile);
   
   % call process function
   cellsSegmentation(handles, myImage, "rgb");
   cellsSegmentation(handles, myImage, "cmyk");
   cellsSegmentation(handles, myImage, "ycbcr");
   
   %% Show alert result
   success = msgbox('Process done.','Success');
   
   %% Show export data button
   set(handles.exportData,'Visible','on');
end

% --- Executes on button press in loadCamera.
function loadCamera_Callback(hObject, eventdata, handles)
% hObject    handle to loadCamera (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of loadCamera

set(handles.exportData,'Visible','off');

a = imaqhwinfo;
[camera_name, camera_id, format] = getCameraInfo(a);
global vid;
vid = videoinput(camera_name, camera_id, format);

% Set the properties of the video object
set(vid, 'FramesPerTrigger', Inf);
set(vid, 'ReturnedColorspace', 'rgb')
vid.FrameGrabInterval = 5;

%start the video aquisition here
start(vid)

set(handles.captureImg,'Visible','on');

% Set a loop that stop after 100 frames of aquisition
axes(handles.rgb1);
while(vid.FramesAcquired<=200)
    myImage = getsnapshot(vid);
    
    %%Extracting the blue plane 
    bPlane = myImage(:,:,3)  - 0.5*(myImage(:,:,1)) - 0.5*(myImage(:,:,2));
    %%Extract out purple cells
    BW = bPlane > 29;
    %%Remove noise 100 pixels or less
    BW2 = bwareaopen(BW, 100);
    
    % first display the original image
    imshow(myImage), hold on

    %% Label connected components
    [L Ne]=bwlabel(BW2);
    propied=regionprops(L,'BoundingBox'); 
    imshow(myImage);

    %% Get the totalcellsRGB number of cells that have been added with bounding box
    whitecount = size(propied,1);

    %% Added bounding box to the white blood cells
    hold on
    for n=1:whitecount
      rectangle('Position',propied(n).BoundingBox,'EdgeColor','g','LineWidth',2)
    end
    hold off
end

% Stop the video aquisition.
stop(vid);

% Flush all the image data stored in the memory buffer.
flushdata(vid);

% --- Executes on button press in captureImg.
function captureImg_Callback(hObject, eventdata, handles)
% hObject    handle to captureImg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of captureImg
global vid;

% capture image
%inputimage = getframe(handles.rgb1);
inputimage = getsnapshot(vid);

% Stop the video aquisition.
stop(vid);
% Flush all the image data stored in the memory buffer.
flushdata(vid);
cla;

set(handles.captureImg,'Visible','off');

% call process function
cellsSegmentation(handles, inputimage, "rgb");
cellsSegmentation(handles, inputimage, "cmyk");
cellsSegmentation(handles, inputimage, "ycbcr");

%% Show alert result
success = msgbox('Process done.','Success');

function cellsSegmentation(handles, myImage, colorspace)

% load image and convert color space
myImage = convertColorSpace(colorspace, myImage);

%% WHITE BLOOD CELLS
if colorspace == "cmyk"
        axes(handles.cmyk1);
        WBC = handles.wbcCMYK;
        RBC = handles.rbcCMYK;
elseif colorspace == "ycbcr"
        axes(handles.ycbcr1);
        WBC = handles.wbcYCbCr;
        RBC = handles.rbcYCbCr;
else
        axes(handles.rgb1);
        WBC = handles.wbcRGB;
        RBC = handles.rbcRGB;
end
imshow(myImage);
set(handles.wbcText, 'string', 'Loaded Blood Smears Image');
pause(1);

%%Extracting the blue plane 
if colorspace == "cmyk"
    bPlane = myImage(:,:,1)- 0.4*(myImage(:,:,3)) - 0.6*(myImage(:,:,2));
else
    bPlane = myImage(:,:,3)  - 0.5*(myImage(:,:,1)) - 0.5*(myImage(:,:,2));
end
imshow(bPlane);
set(handles.wbcText, 'string', 'Extracted White Blood Cells');
pause(1);

%%Extract out purple cells
BW = bPlane > 29;
imshow(BW);
set(handles.wbcText, 'string', 'Enhanced Image');
pause(1);

%%Remove noise 100 pixels or less
BW2 = bwareaopen(BW, 100);
imshow(BW2);
set(handles.wbcText, 'string', 'Noise Removed');
pause(1);

%%Calculate area of regions
cellStats = regionprops(BW2, 'all');
cellAreas = [cellStats(:).Area];

%% create new figure to output superimposed images
% first display the original image
imshow(myImage), hold on

%% Label connected components
[L Ne]=bwlabel(BW2);
propied=regionprops(L,'BoundingBox'); 
himage = imshow(BW2);

%% Get the totalcellsRGB number of cells that have been added with bounding box
whitecount = size(propied,1);

%% Added bounding box to the white blood cells
hold on
for n=1:whitecount
  rectangle('Position',propied(n).BoundingBox,'EdgeColor','g','LineWidth',2)
end
hold off

%% Superimpose the two image
set(himage, 'AlphaData', 0.5);

%% set totalcellsRGB white blood cells detected
set(handles.wbcText, 'string', 'Process Done');
set(WBC, 'string', whitecount);
pause(2);


%% RED BLOOD CELLS
if colorspace == "cmyk"
        axes(handles.cmyk2);
elseif colorspace == "ycbcr"
        axes(handles.ycbcr2);
else
        axes(handles.rgb2);
end
imshow(myImage);
set(handles.rbcText, 'string', 'Loaded Blood Smears Image');
pause(1);

%% Extracting the red plane 
if colorspace == "cmyk"
    rPlane = myImage(:,:,3)  - 0.5*(myImage(:,:,1)) - 0.5*(myImage(:,:,2));
else
    rPlane = myImage(:,:,1)- 0.4*(myImage(:,:,3)) - 0.6*(myImage(:,:,2));
end
imshow(rPlane);
set(handles.rbcText, 'string', 'Extracted Red Blood Cells');
pause(1);

%% Extract out red cells
BWr = rPlane > 19;
imshow(BWr);
set(handles.rbcText, 'string', 'Enhanced Image');
pause(1);

%%Remove noise 100 pixels or less
BWr2 = bwareaopen(BWr, 100);
imshow(BWr2);
set(handles.rbcText, 'string', 'Noise Removed');
pause(1);

%%Calculate area of regions
cellStatsr = regionprops(BWr2, 'all');
cellAreasr = [cellStatsr(:).Area];

%% create new figure to output superimposed images
% first display the original image
imshow(myImage), hold on

%% Label connected components
[Lr Ner]=bwlabel(BWr2);
propiedr=regionprops(Lr,'BoundingBox'); 
himager = imshow(BWr2);

%% Get the totalcellsRGB number of cells that have been added with bounding box
redcount = size(propiedr,1);

%% Added bounding box to the red blood cells
hold on
for n=1:redcount
  rectangle('Position',propiedr(n).BoundingBox,'EdgeColor','r','LineWidth',2)
end
hold off

%% Superimpose the two image
set(himager, 'AlphaData', 0.5);

%% set totalcellsRGB white blood cells detected
set(handles.rbcText, 'string', 'Process Done');
set(RBC, 'string', redcount);
pause(1);

%% Calculate percentages
totalCells = whitecount + redcount;
wbcPercent = (whitecount ./ totalCells) .* 100;
rbcPercent = (redcount ./ totalCells) .* 100;

if colorspace == "cmyk" 
    totalCellsHandle = handles.totalcellsCMYK;
    WBCPercentHandle = handles.wbcpercentCMYK;
    RBCPercentHandle = handles.rbcpercentCMYK;
    resultTextHandle = handles.resultTextCMYK;
elseif colorspace == "ycbcr"
    totalCellsHandle = handles.totalcellsYCbCr;
    WBCPercentHandle = handles.wbcpercentYCbCr;
    RBCPercentHandle = handles.rbcpercentYCbCr;
    resultTextHandle = handles.resultTextYCbCr;    
else
    totalCellsHandle = handles.totalcellsRGB;
    WBCPercentHandle = handles.wbcpercentRGB;
    RBCPercentHandle = handles.rbcpercentRGB;
    resultTextHandle = handles.resultTextRGB;
end

set(totalCellsHandle, 'string', totalCells);
set(WBCPercentHandle, 'string', sprintf('%i%%',vpa(wbcPercent)));
set(RBCPercentHandle, 'string', sprintf('%i%%',vpa(rbcPercent)));

if vpa(wbcPercent) >= 20
    set(resultTextHandle, 'string', 'POTENTIAL LEUKEMIA DETECTED');
else
    set(resultTextHandle, 'string', 'Normal');
end


function myImage = convertColorSpace(color, myImage)
% convert RGB to other color space
if color == "cmyk"
        cform = makecform('srgb2cmyk');
        myImage = applycform(myImage,cform); 
        myImage = myImage(:,:,1:3);
elseif color == "ycbcr"
        myImage = rgb2ycbcr(myImage);
else
        myImage = myImage;
end

function exportData

% --- Executes on button press in exportData.
function exportData_Callback(hObject, eventdata, handles)
% hObject    handle to exportData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of exportData

%% Get all result data
cmykWbc = get(handles.wbcCMYK,'String');
cmykRbc = get(handles.rbcCMYK,'String');
cmykTotal = get(handles.totalcellsCMYK,'String');
cmykWbcP = get(handles.wbcpercentCMYK,'String');
cmykRbcP = get(handles.rbcpercentCMYK,'String');

yvbcrWbc = get(handles.wbcYCbCr,'String');
ycbcrRbc = get(handles.rbcYCbCr,'String');
ycbcrTotal = get(handles.totalcellsYCbCr,'String');
ycbcrWbcP = get(handles.wbcpercentYCbCr,'String');
ycbcrRbcP = get(handles.rbcpercentYCbCr,'String');

rgbWbc = get(handles.wbcRGB,'String');
rgbRbc = get(handles.rbcRGB,'String');
rgbTotal = get(handles.totalcellsRGB,'String');
rgbWbcP = get(handles.wbcpercentRGB,'String');
rgbRbcP = get(handles.rbcpercentRGB,'String');

%% Create tables
cmykTable = table('CMYK',cmykWbc,cmykRbc,cmykTotal,cmykWbcP,cmykRbcP);
cmykTable.Properties.VariableNames = {'ColorSpace' 'WBCs' 'RBCs' 'Total' 'WBCsPercent' 'RBCsPercent'};

ycbcrTable = table('YcBcR',yvbcrWbc,ycbcrRbc,ycbcrTotal,ycbcrWbcP,ycbcrRbcP);
ycbcrTable.Properties.VariableNames = {'ColorSpace' 'WBCs' 'RBCs' 'Total' 'WBCsPercent' 'RBCsPercent'};

rgbTable = table('RGB',rgbWbc,rgbRbc,rgbTotal,rgbWbcP,rgbRbcP);
rgbTable.Properties.VariableNames = {'ColorSpace' 'WBCs' 'RBCs' 'Total' 'WBCsPercent' 'RBCsPercent'};

% write to excel file
writetable(rgbTable,'LeukemiaResults.xlsx','Sheet',1);
writetable(cmykTable,'LeukemiaResults.xlsx','Sheet',2);
writetable(ycbcrTable,'LeukemiaResults.xlsx','Sheet',3);

%% Show alert result
success = msgbox('Data exported into Excel File.','Success');

function totalcellsRGB_Callback(hObject, eventdata, handles)
% hObject    handle to totalcellsRGB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of totalcellsRGB as text
%        str2double(get(hObject,'String')) returns contents of totalcellsRGB as a double


% --- Executes during object creation, after setting all properties.
function totalcellsRGB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to totalcellsRGB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function wbcpercentRGB_Callback(hObject, eventdata, handles)
% hObject    handle to wbcpercentRGB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of wbcpercentRGB as text
%        str2double(get(hObject,'String')) returns contents of wbcpercentRGB as a double


% --- Executes during object creation, after setting all properties.
function wbcpercentRGB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wbcpercentRGB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rbcpercentRGB_Callback(hObject, eventdata, handles)
% hObject    handle to rbcpercentRGB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rbcpercentRGB as text
%        str2double(get(hObject,'String')) returns contents of rbcpercentRGB as a double


% --- Executes during object creation, after setting all properties.
function rbcpercentRGB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rbcpercentRGB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function totalcellsCMYK_Callback(hObject, eventdata, handles)
% hObject    handle to totalcellsCMYK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of totalcellsCMYK as text
%        str2double(get(hObject,'String')) returns contents of totalcellsCMYK as a double


% --- Executes during object creation, after setting all properties.
function totalcellsCMYK_CreateFcn(hObject, eventdata, handles)
% hObject    handle to totalcellsCMYK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function wbcpercentCMYK_Callback(hObject, eventdata, handles)
% hObject    handle to wbcpercentCMYK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of wbcpercentCMYK as text
%        str2double(get(hObject,'String')) returns contents of wbcpercentCMYK as a double


% --- Executes during object creation, after setting all properties.
function wbcpercentCMYK_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wbcpercentCMYK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rbcpercentCMYK_Callback(hObject, eventdata, handles)
% hObject    handle to rbcpercentCMYK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rbcpercentCMYK as text
%        str2double(get(hObject,'String')) returns contents of rbcpercentCMYK as a double


% --- Executes during object creation, after setting all properties.
function rbcpercentCMYK_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rbcpercentCMYK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function totalcellsYCbCr_Callback(hObject, eventdata, handles)
% hObject    handle to totalcellsYCbCr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of totalcellsYCbCr as text
%        str2double(get(hObject,'String')) returns contents of totalcellsYCbCr as a double


% --- Executes during object creation, after setting all properties.
function totalcellsYCbCr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to totalcellsYCbCr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function wbcpercentYCbCr_Callback(hObject, eventdata, handles)
% hObject    handle to wbcpercentYCbCr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of wbcpercentYCbCr as text
%        str2double(get(hObject,'String')) returns contents of wbcpercentYCbCr as a double


% --- Executes during object creation, after setting all properties.
function wbcpercentYCbCr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wbcpercentYCbCr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rbcpercentYCbCr_Callback(hObject, eventdata, handles)
% hObject    handle to rbcpercentYCbCr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rbcpercentYCbCr as text
%        str2double(get(hObject,'String')) returns contents of rbcpercentYCbCr as a double


% --- Executes during object creation, after setting all properties.
function rbcpercentYCbCr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rbcpercentYCbCr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function wbcRGB_Callback(hObject, eventdata, handles)
% hObject    handle to wbcRGB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of wbcRGB as text
%        str2double(get(hObject,'String')) returns contents of wbcRGB as a double


% --- Executes during object creation, after setting all properties.
function wbcRGB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wbcRGB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rbcRGB_Callback(hObject, eventdata, handles)
% hObject    handle to rbcRGB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rbcRGB as text
%        str2double(get(hObject,'String')) returns contents of rbcRGB as a double


% --- Executes during object creation, after setting all properties.
function rbcRGB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rbcRGB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function wbcCMYK_Callback(hObject, eventdata, handles)
% hObject    handle to wbcCMYK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of wbcCMYK as text
%        str2double(get(hObject,'String')) returns contents of wbcCMYK as a double


% --- Executes during object creation, after setting all properties.
function wbcCMYK_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wbcCMYK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rbcCMYK_Callback(hObject, eventdata, handles)
% hObject    handle to rbcCMYK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rbcCMYK as text
%        str2double(get(hObject,'String')) returns contents of rbcCMYK as a double


% --- Executes during object creation, after setting all properties.
function rbcCMYK_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rbcCMYK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function wbcYCbCr_Callback(hObject, eventdata, handles)
% hObject    handle to wbcYCbCr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of wbcYCbCr as text
%        str2double(get(hObject,'String')) returns contents of wbcYCbCr as a double


% --- Executes during object creation, after setting all properties.
function wbcYCbCr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wbcYCbCr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rbcYCbCr_Callback(hObject, eventdata, handles)
% hObject    handle to rbcYCbCr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rbcYCbCr as text
%        str2double(get(hObject,'String')) returns contents of rbcYCbCr as a double


% --- Executes during object creation, after setting all properties.
function rbcYCbCr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rbcYCbCr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
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

% Last Modified by GUIDE v2.5 25-Nov-2018 20:15:16

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
[file,path] = uigetfile({'*.jpg'; '*.png'}, 'Select An Image');
if isequal(file,0)
   disp('User selected Cancel');
else
   selectedfile = fullfile(path,file);
   %%Reading in the image
    myImage = imread(selectedfile);
   
   %% WHITE BLOOD CELLS
    axes(handles.axes1);
    imshow(myImage);
    set(handles.wbcText, 'string', 'Loaded Blood Smears Image');
    pause(1);
    
    %%Extracting the blue plane 
    bPlane = myImage(:,:,3)  - 0.5*(myImage(:,:,1)) - 0.5*(myImage(:,:,2));
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

    %% Get the total number of cells that have been added with bounding box
    whitecount = size(propied,1);

    %% Added bounding box to the white blood cells
    hold on
    for n=1:whitecount
      rectangle('Position',propied(n).BoundingBox,'EdgeColor','g','LineWidth',2)
    end
    hold off

    %% Superimpose the two image
    set(himage, 'AlphaData', 0.5);
    
    %% set total white blood cells detected
    set(handles.wbcText, 'string', sprintf('%i White Blood Cells Detected',whitecount));
    pause(2);
    
    
    %% RED BLOOD CELLS
    axes(handles.axes2);
    imshow(myImage);
    set(handles.rbcText, 'string', 'Loaded Blood Smears Image');
    pause(1);
    
    %% Extracting the red plane 
    rPlane = myImage(:,:,1)- 0.4*(myImage(:,:,3)) - 0.6*(myImage(:,:,2));
    imshow(rPlane);
    set(handles.rbcText, 'string', 'Extracted Red Blood Cells');
    pause(1);
    
    %% Extract out red cells
    BWr = rPlane > 19;
    imshow(BW);
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

    %% Get the total number of cells that have been added with bounding box
    redcount = size(propiedr,1);

    %% Added bounding box to the red blood cells
    hold on
    for n=1:redcount
      rectangle('Position',propiedr(n).BoundingBox,'EdgeColor','r','LineWidth',2)
    end
    hold off

    %% Superimpose the two image
    set(himager, 'AlphaData', 0.5);

    %% set total white blood cells detected
    set(handles.rbcText, 'string', sprintf('%i Red Blood Cells Detected',redcount));
    pause(2);
    

end


function total_Callback(hObject, eventdata, handles)
% hObject    handle to total (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of total as text
%        str2double(get(hObject,'String')) returns contents of total as a double


% --- Executes during object creation, after setting all properties.
function total_CreateFcn(hObject, eventdata, handles)
% hObject    handle to total (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function wbcpercent_Callback(hObject, eventdata, handles)
% hObject    handle to wbcpercent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of wbcpercent as text
%        str2double(get(hObject,'String')) returns contents of wbcpercent as a double


% --- Executes during object creation, after setting all properties.
function wbcpercent_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wbcpercent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rbcpercent_Callback(hObject, eventdata, handles)
% hObject    handle to rbcpercent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rbcpercent as text
%        str2double(get(hObject,'String')) returns contents of rbcpercent as a double


% --- Executes during object creation, after setting all properties.
function rbcpercent_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rbcpercent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

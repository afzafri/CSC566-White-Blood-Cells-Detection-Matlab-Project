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

function varargout = TrackViewer4(varargin)
% TRACKVIEWER4 M-file for TrackViewer4.fig
%      TRACKVIEWER4, by itself, creates a new TRACKVIEWER4 or raises the existing
%      singleton*.
%
%      H = TRACKVIEWER4 returns the handle to a new TRACKVIEWER4 or the handle to
%      the existing singleton*.
%
%      TRACKVIEWER4('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRACKVIEWER4.M with the given input arguments.
%
%      TRACKVIEWER4('Property','Value',...) creates a new TRACKVIEWER4 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TrackViewer4_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  allcells_radio inputs are passed to TrackViewer4_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TrackViewer4

% Last Modified by GUIDE v2.5 23-Feb-2012 14:07:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @TrackViewer4_OpeningFcn, ...
    'gui_OutputFcn',  @TrackViewer4_OutputFcn, ...
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


% --- Executes just before TrackViewer4 is made visible.
function TrackViewer4_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TrackViewer4 (see VARARGIN)

global DataIF

% Choose default command line output for TrackViewer4
handles.output = hObject;


%check that required .m files are on path, display warning
requiredFiles={'StructDlg','averagePlot','singleCellPlot'};
missingstring=checkForRequiredFiles(requiredFiles);
if ~isempty(missingstring)
    set(handles.message_text,'String',missingstring,'ForegroundColor', 'r');
end

% initialise a few stuff
handles.chemin = pwd;
handles.channel2display = [1 1 0];
handles.LoadImages2memory = 0;
handles.PictNbSliderValue = 1;
handles.showSingleCell=0;
set(handles.Figureplot_slider,'Enable','off');
set(handles.Figureplot_slider,'Visible','off');
handles.useRatioForPlot=1;
set(handles.radiobutton28,'Value',1);
handles.showCells=0;
set(handles.allCells_radio,'Value',1);
set(handles.CCC_radio,'Value',1);
set(handles.showNuc,'Value',1);
set(handles.showFluor1,'Value',1);
handles.CCCexpt=1; handles.confocalexpt=0;
handles.showNucPlot=1; handles.showFluor1Plot=1;
handles.showFluor2Plot=0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TrackViewer4 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = TrackViewer4_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in LoadImages_pushbutton.
function LoadImages_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to LoadImages_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global DataIF dataTrack;
DataIF=[]; dataTrack=[];


% tmp.CCCexpt={'{yes}|no'};
% tmp=StructDlg(tmp);
% if strcmp(tmp.CCCexpt,'yes')
%     handles.CCCexpt=1;
% else
%     handles.CCCexpt=0;
% end


if handles.CCCexpt
    % get path of the experiment folder
    [chemin] = uigetdir(handles.chemin,'pick a folder');
    if chemin~=0
        handles.chemin = chemin;
        
        % decompose chemin
        findBackSlash = strfind(chemin, filesep);
        chamberName = chemin(findBackSlash(length(findBackSlash))+1:length(chemin));
        handles.chamberName = chamberName;
        DateOfExperiment = chemin(findBackSlash(length(findBackSlash)-1)+1:findBackSlash(length(findBackSlash))-1);
        s1.imagedirectory=chemin;
        s1.smadKeyWord='green';
        s1.nucKeyWord='red';
    else
        return;
    end
elseif ~handles.confocalexpt
    S.imagedirectory={{'uigetdir(''.'')'}};
    S.matfile={{'uigetfile(''./S3s4out.mat'')'}};
    S.nucKeyWord='3_w2GFP User_s4';
    S.smadKeyWord='3_w3RFP_s4';
    s1=StructDlg(S);
    if isempty(s1)
        return;
    end
    handles.chemin=s1.imagedirectory;
else
    S.imagefile={{'uigetfile(''./*.lsm'')'}};
    S.matfile={{'uigetfile(''./*.mat'')'}};
    S.chan2use=[2 1];
    s1=StructDlg(S);
    if isempty(s1)
        return;
    end
end

%read in the image files
handles=readImageFiles(handles,s1);

%image and image window size definition
handles.ActualImageSize = size(DataIF(1).red);
if max(size(DataIF(1).red)) > 1000
    handles.ImageScaleFactor = 2;
else
    handles.ImageScaleFactor=1;
end
handles.ImageWindowSize = handles.ActualImageSize / handles.ImageScaleFactor;

% resize the image window to the appropriate size
set(handles.MainFigure,'Position',[2 180 handles.ImageWindowSize(2) handles.ImageWindowSize(1)])

% initialise pictNb_slider
NbFichier = length(DataIF);
set(handles.pictNb_slider,'Max',NbFichier,'Min',1,'Value',1,'SliderStep',[1/(NbFichier-1) 10/(NbFichier-1)]);
handles.currentImageIndex = 1;
handles.Zoomin = 0;

if handles.CCCexpt
    cd(chemin)
    cd ..
    handles.experimentFolder = pwd;
    matFileName = dir(['*' chamberName '*.mat']);
    s1.matfile=matFileName.name;
end

%try
%read in the matfile
handles=readMatFile(handles,s1.matfile);
%CellFiltering_SelectionChangeFcn(hObject, eventdata, handles)
%uipanel15_SelectionChangeFcn(hObject, eventdata, handles)
cells2=dataTrack.allCells;
handles=updateFilteredCells(handles,cells2);
handles=UpdatePlotDisplay(hObject,handles);
UpdateImageDisplay(hObject,handles);

% catch
% set(handles.message_text,'String','did not find the mat file');
% handles.OKdatatrack =0;
% end

cd(handles.chemin)

% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in red_checkbox.
function red_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to red_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of red_checkbox
handles.channel2display(1) = get(hObject,'Value');

% Update handles structure
guidata(hObject, handles);

% Update display

UpdateImageDisplay(hObject,handles);

% --- Executes on button press in green_checkbox.
function green_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to green_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of green_checkbox

handles.channel2display(2) = get(hObject,'Value');

% Update handles structure
guidata(hObject, handles);

% Update display

UpdateImageDisplay(hObject,handles);

% --- Executes on button press in blue_checkbox.
function blue_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to blue_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of blue_checkbox

handles.channel2display(3) = get(hObject,'Value');

% Update handles structure
guidata(hObject, handles);

% Update display

UpdateImageDisplay(hObject,handles);
% --- Executes on slider movement.





function pictNb_slider_Callback(hObject, eventdata, handles)
% hObject    handle to pictNb_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global DataIF dataTrack

handles.PictNbSliderValue = round(get(hObject,'Value'));
handles.currentImageIndex = handles.PictNbSliderValue;

% load image into memory if it is not already
if ~handles.LoadImages2memory && isempty(DataIF(handles.currentImageIndex).red)
    
    red = imread([handles.chemin filesep DataIF(handles.currentImageIndex).RedImagesNames]);
    DataIF(handles.currentImageIndex).red = imadjust(red,stretchlim(red,[0.1 0.999]));
    
    green = imread([handles.chemin filesep DataIF(handles.currentImageIndex).GreenImagesNames]);
    DataIF(handles.currentImageIndex).green = imadjust(green,stretchlim(green,[0.1 0.999]));
end

% update image window
handles = UpdateImageDisplay(hObject,handles);

% return data in the workspace, if they are available
if handles.OKdatatrack
    currentPeak = dataTrack.peaks{handles.currentImageIndex};
    assignin('base','pic',currentPeak);
end

% Update handles structure
guidata(hObject, handles);

%% --- Executes during object creation, after setting allCells_radio properties.
function pictNb_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pictNb_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after allCells_radio CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function handles = UpdateImageDisplay(hObject,handles)

global DataIF dataTrack

currentStats = dataTrack.statsArray{handles.currentImageIndex};
currentGoodCell = dataTrack.FilteredCells(handles.cell2display);
handles.onFrames = currentGoodCell.onframes;
xyRange =  currentGoodCell.xyrange;

set(handles.text1,'String',DataIF(handles.currentImageIndex).RedImagesNames);

redDisp = DataIF(handles.currentImageIndex).red*handles.channel2display(1);
greenDisp = DataIF(handles.currentImageIndex).green*handles.channel2display(2);
blueDisp = zeros(size(redDisp));

maxscale = max(max(DataIF(handles.currentImageIndex).red));

if handles.channel2display(3)
ncells = length(currentStats);
for ii=1:ncells
    blueDisp(currentStats(ii).PixelIdxList)=maxscale;
end
end

if handles.Zoomin
    
    xyrange = round(dataTrack.FilteredCells(handles.cell2display).xyrange);
    
    rect = [xyrange(1) xyrange(3) xyrange(2)-xyrange(1) xyrange(4)-xyrange(3)];
    redDisp = imcrop(redDisp,rect);
    greenDisp = imcrop(greenDisp,rect);
    
end


RGB = cat(3,redDisp,greenDisp,blueDisp);
axes(handles.MainFigure)
imshow(RGB)

hold on;

if handles.OKdatatrack % if track data are loaded, try to spot cells in the picture
    
    if handles.showCells % display the position of all the cells
        cellsInFrame = dataTrack.peaks{handles.currentImageIndex};
        
        if handles.Zoomin
            inds = cellsInFrame(:,1) > xyRange(1) & cellsInFrame(:,1) < xyRange(2) & cellsInFrame(:,2) > xyRange(3) & cellsInFrame(:,2) < xyRange(4);
            cellsInFrame = cellsInFrame(inds,:);
            xPos = cellsInFrame(:,1)- xyRange(1);
            yPos = cellsInFrame(:,2)- xyRange(3);
            
        else
            xPos = cellsInFrame(:,1);
            yPos = cellsInFrame(:,2);
        end
        
        cellNumber = cellsInFrame(:,end); % could be replace by the 8th column to get the cellID (index in the cell2 array)
        plot(xPos,yPos,'b.','MarkerSize',12)
        text(xPos,yPos-10,num2str(cellNumber),'Color','w');
        
    else % put a mark on the current cell
        
        if  sum(handles.onFrames == handles.PictNbSliderValue)
            [idx,valeur] = find (currentGoodCell.onframes == handles.PictNbSliderValue);
            
            cdata = currentGoodCell.data(valeur,:);
            cfdata = currentGoodCell.fdata(valeur,:);
            
            if handles.Zoomin
                xPos=cdata(1)-xyRange(1);
                yPos=cdata(2)-xyRange(3);
            else
                xPos=cdata(1);
                yPos=cdata(2);
            end
            
            plot(xPos,yPos,'r.','MarkerSize',12);
            text(xPos,yPos-10,num2str(cfdata(2)/cfdata(3),2),'Color','m');
        end
        
        
    end
end
drawnow;
hold off;

%  Update the highlighted point in the PlotDisplay
if handles.OKdatatrack
    cells = dataTrack.FilteredCells;
    ii = handles.cell2display;
    frameNbIdx = find(cells(ii).onframes == handles.currentImageIndex);
    pictimes = dataTrack.pictimes;
end

if handles.showSingleCell
    frameNum=cells(ii).onframes(frameNbIdx);
    dataind=frameNbIdx;
else
    frameNum=handles.currentImageIndex;
    dataind=frameNum;
end

if handles.showFluor1Plot
    set(handles.plotCursorFluor1,'XData',dataTrack.pictimes(frameNum),'YData',handles.avgreturnFluor1(dataind));
end
if handles.showNucPlot
    set(handles.plotCursorNuc,'XData',dataTrack.pictimes(frameNum),'YData',handles.avgreturnNuc(dataind));
end




% Update handles structure
% guidata(hObject, handles);
% --- Executes on button press in Load2mem_checkbox.
function Load2mem_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to Load2mem_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.LoadImages2memory = get(hObject,'Value'); %returns toggle state of Load2mem_checkbox

% Update handles structure
guidata(hObject, handles);
% update single cell plot
% UpdatePlotDisplay(handles)


% --- Executes on slider movement.
function Figureplot_slider_Callback(hObject, eventdata, handles)
% hObject    handle to Figureplot_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global dataTrack
% get cell number
handles.cell2display = round(get(hObject,'Value'));

currentGoodCell = dataTrack.FilteredCells(handles.cell2display);
handles.onFrames = currentGoodCell.onframes;
handles.currentImageIndex = currentGoodCell.onframes(1);

%go to the first frame where this cell is present
handles.PictNbSliderValue = currentGoodCell.onframes(1);
set(handles.pictNb_slider,'Value',handles.PictNbSliderValue);

handles.What2plot = 'single';

% Update plots and handles structure
handles = UpdatePlotDisplay(hObject,handles);
handles = UpdateImageDisplay(hObject,handles);

guidata(hObject, handles);



% --- Executes during object creation, after setting allCells_radio properties.
function Figureplot_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Figureplot_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after allCells_radio CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in MakeAveragePlot_pushbutton.
function handles = MakeAveragePlot_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to MakeAveragePlot_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dataTrack
% options for averagePlot

plotcols=[2 3];
ps='k.-';
mkhandle=1;
includefeedings=1;

% data for averagePlot

cells = dataTrack.allCells;
feedings = dataTrack.feedings;
pictimes = dataTrack.pictimes;


axes(handles.FigurePlot);

if handles.showFluor1Plot
    if handles.useRatioForPlot==1
        [avgreturn,curseur] = averagePlot2(cells,pictimes,[2],'PlotStyle','g.-','frameNb',handles.currentImageIndex);
    elseif handles.useRatioForPlot==2
        [avgreturn,curseur] = averagePlot2(cells,pictimes,[2 1],'PlotStyle','g.-','frameNb',handles.currentImageIndex);
    elseif handles.useRatioForPlot==3
        [avgreturn,curseur] = averagePlot2(cells,pictimes,[2 3],'PlotStyle','g.-','frameNb',handles.currentImageIndex);
    end
end
handles.What2plot = 'average';
handles.plotCursor =  curseur;
handles.avgreturn = avgreturn;

if handles.showNucPlot
    if handles.useRatioForPlot==1
        [avgreturn,curseur] = averagePlot2(cells,pictimes,[1],'PlotStyle','r.-','frameNb',handles.currentImageIndex);
    elseif handles.useRatioForPlot==2 || handles.useRatioForPlot==3
        [avgreturn,curseur] = averagePlot2(cells,pictimes,[1 1],'PlotStyle','r.-','frameNb',handles.currentImageIndex);
    end
end
set(handles.text_plot,'String','average plot');



% Update handles structure et plots
guidata(hObject, handles);
% return data in the workspace
% assignin('base','cell',cells);

% --- Executes on button press in Zoomin_checkbox.
function Zoomin_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to Zoomin_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.OKdatatrack
    handles.Zoomin =  get(hObject,'Value');% returns toggle state of Zoomin_checkbox
end


handles = UpdatePlotDisplay(hObject,handles);
handles = UpdateImageDisplay(hObject,handles);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in showFilteredCells_pushbutton.
function showGoodCells_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to showFilteredCells_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of CCCcheckbox

handles.showCells=get(hObject,'Value');% returns toggle state of showGoodCells_checkbox

handles = UpdatePlotDisplay(hObject,handles);
handles = UpdateImageDisplay(hObject,handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in showGrowth_pushbutton.
function showGrowth_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to showGrowth_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global DataIF dataTrack
figure(2)
plotGrowth(dataTrack)

% --- Executes on button press in ExportPlot_pushbutton.
function ExportPlot_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ExportPlot_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global DataIF dataTrack
if handles.OKdatatrack
    
    switch handles.What2plot
        case 'single'
            cells = dataTrack.FilteredCells;
            feedings = dataTrack.feedings;
            pictimes = dataTrack.pictimes;
            % paxes = handles.FigurePlot;
            ii = handles.cell2display;
            
            figure(1)
            clf
            A = axes;
            singleCellPlot(cells,ii,pictimes,A,feedings,1,1)
            
            % Create xlabel
            xlabel('time (hours)','FontSize',14);
            
            % Create ylabel
            ylabel('Smad nuc/cyto (green)','FontSize',14);
            
            figTitle = [[handles.chemin ' cell nb ' int2str(ii)]];
            figTitle = strrep(figTitle,'Z:\110502\','')
            figTitle = strrep(strrep( strrep(figTitle,' ','-'),'Z:\',''),'\','-');
            
            title(figTitle)
            
            
        case 'average'
            % options for averagePlot
            
            plotcols=[2 3];
            ps='k.-';
            mkhandle=0;
            includefeedings=1;
            
            % data for averagePlot
            
            cells = dataTrack.FilteredCells;
            feedings = dataTrack.feedings;
            pictimes = dataTrack.pictimes;
            
            
            
            figure(1)
            clf
            
            averagePlot(cells,plotcols,pictimes,feedings,ps,mkhandle,1);
            
            % Create xlabel
            xlabel('time (hours)','FontSize',24);
            
            % Create ylabel
            ylabel('Smad4 nuc/cyto','FontSize',24);
            
            % title
            figTitle = [handles.chemin ' Average Plot'];
            figTitle = strrep(figTitle,'Z:\110502\','');
            figTitle = strrep(strrep( strrep(figTitle,' ','-'),'Z:\',''),'\','-');
            %             title(figTitle)
            set(gca,'XLim',[0 25])
            set(gca,'YLim',[0.6 1.3])
            set(gca,'FontSize',16)
    end
    
    
    % savename = ['Z:\110502\graphs\' strrep(figTitle,'\','')];
    %
    %  saveas(gcf, savename, 'jpg')
    
end

% --- Executes on button press in RunSegmentCell_pushbutton.
function RunSegmentCell_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to RunSegmentCell_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global DataIF dataTrack

setUserParamCCC10x([1024 1344])

% try
%     eval(paramfile);
% catch
%     error('Could not evaluate paramfile command');
% end
red = imread([handles.chemin filesep DataIF(handles.currentImageIndex).RedImagesNames]);
green = imread([handles.chemin filesep DataIF(handles.currentImageIndex).GreenImagesNames]);

nuc = green;
fimg = red;
%
% nuc = red;
% fimg = green;

[maskC statsN]=segmentCells(nuc,fimg);
[tmp statsN]=addCellAvr2Stats(maskC,fimg,statsN);

plotHistStats( statsN, handles.currentImageIndex )

% --- Executes on button press in makeReport.
function makeReport_Callback(hObject, eventdata, handles)
% hObject    handle to makeReport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% matFileNames = dir([handles.experimentFolder '\Ch*out.mat'])
% global DataIF dataTrack
if handles.CCCexpt
    chamberNumbers = [1:1:96];
    
    count = 0;
    for ii = chamberNumbers
        
        ChNum = num2str(ii);
        if length(ChNum) == 1
            ChNum = ['0' ChNum]
        end
        
        matFileName = [handles.experimentFolder '\Ch' ChNum 'out.mat'];
        
        if exist(matFileName,'file')
            
            count = count + 1;
            
            if mod(count,6)==0
                figureNb = count/6
                subplotNb = 6;
            else
                figureNb = floor(count/6)+1;
                subplotNb = mod(count,6);
            end
            
            
            load(matFileName)
            
            inds = [cells.good]==1;
            FilteredCells = cells(inds);
            
            figTitle = strrep(matFileName,'out.mat','');
            
            % options for averagePlot
            
            plotcols=[2 3];
            ps='k.-';
            mkhandle=1;
            includefeedings=1;
            
            figure(figureNb)
            subplotNb;
            subplot(3,2,subplotNb)
            averagePlot(FilteredCells,plotcols,pictimes,feedings,ps,mkhandle,1);
            title(figTitle)
            % Create xlabel
            xlabel('time (hours)','FontSize',14);
            % Create ylabel
            ylabel('Smad nuc/cyto (green)','FontSize',14);
            % %     set X scal here
            %                  set(gca,'XLim',[0 30])
            
            %plot growth
            
            
            subplot(3,2,subplotNb+1)
            
            %         if ~isempty(dataCount)
            %             dataCount(1,:) = dataCount(1,:)-dataCount(1,end);
            %             plot(dataCount(1,:),dataCount(2,:),'b-',dataCount2(1,:),dataCount2(2,:),'r-');
            %         else
            %             plot(dataCount2(1,:),dataCount2(2,:),'r-');
            %         end
            %         count = count + 1;
            %         % Create xlabel
            %         xlabel('time (hours)','FontSize',14);
            %         % Create ylabel
            %         ylabel('cell number','FontSize',14);
            dataTrack.dataCount = dataCount;
            dataTrack.dataCount2 = dataCount2;
            dataTrack.dataCrowdExp = dataCrowdExp;
            dataTrack.dataCrowdSeed = dataCrowdSeed;
            dataTrack.feedings = feedings;
            plotGrowth(dataTrack)
            count = count + 1;
            title([figTitle '-growth'])
            
            
            
            set (gcf, 'PaperPosition',[0.25,0.25,8,10.5])
            set(gca,'YTickMode','auto')
            %         set(gca,'XLim',[0 30])
            saveas(gcf,[handles.experimentFolder filesep num2str(figureNb)],'pdf')
            
            %    legend(gca,'FontSize',20)
            
        end
        
        
    end
    
else
    set(handles.message_text,'String','sorry, available only for CCC experiments','ForegroundColor', 'r')
end

% --- Executes on button press in findCell_pushbutton.
function findCell_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to findCell_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global DataIF dataTrack

currentGoodCell = dataTrack.FilteredCells(handles.cell2display);
xyRange =  currentGoodCell.xyrange;

% set image window as current
axes(handles.MainFigure)

% get cell coordinates from graphic input
message='pick a cell';
a=axis;
h=text(a(1)+(a(2)-a(1))*0.15,a(3)+(a(4)-a(3))*0.6,sprintf(message),'FontWeight','bold','FontSize',9,'color','w');

[a0,b0]=ginput(1);
delete(h);

x0 = round(a0);
y0 = round(b0);

if handles.Zoomin%
    x0 = x0+xyRange(1);
    y0 = y0+xyRange(3);
end


if x0>handles.ActualImageSize(2) || y0>handles.ActualImageSize(1)
    disp('missed it , try again!')
else
    
    % find the closest cell to the coordinates in the peaks structure
    xy = dataTrack.peaks{1,handles.currentImageIndex}(:,1:2);
    dst = abs(xy(:,1) - x0) + abs(xy(:,2) - y0);
    [mn, ii] = min(dst);
    
    pickedCellid = dataTrack.peaks{1,handles.currentImageIndex}(ii,8);
    
end

if pickedCellid==-1
    set(handles.text_plot,'String','Cell not in cells array, cannot show data');
    return;
end

% store the new current cell in the handles structure
handles.cell2display = pickedCellid;

% switch to cell filtering "all cells"
set(handles.allCells_radio,'Value',1);
CellFiltering_SelectionChangeFcn(hObject, eventdata, handles)

% update the plot figure and its slider
set(handles.Figureplot_slider,'Value',handles.cell2display);
handles = UpdatePlotDisplay(hObject,handles);
handles.What2plot = 'single';
% Update image display and the handles structure
if handles.cell2display~=-1
    handles = UpdateImageDisplay(hObject,handles);
end
guidata(hObject, handles);



% --- Executes when selected object is changed in CellFiltering.
function CellFiltering_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in CellFiltering
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

global dataTrack

% v = fix(get(hObject, 'Value'));
% tag = get(hObject, 'Tag');



cells2 = dataTrack.allCells;
handles=updateFilteredCells(handles,cells2);
%   get(handles.CellFiltering)


% update the plot figure and its slider
set(handles.Figureplot_slider,'Value',handles.cell2display);
handles = UpdatePlotDisplay(hObject,handles);

% Update image display and the handles structure
handles = UpdateImageDisplay(hObject,handles);
guidata(hObject, handles);

function handles=updateFilteredCells(handles,cells2)

global dataTrack;

h=get(handles.CellFiltering);
tag = get(h.SelectedObject, 'Tag');
switch tag
    case 'allCells_radio'
        dataTrack.FilteredCells = cells2;
        %         update slider bar
        NbFilteredCells = length(dataTrack.FilteredCells);
        set(handles.Figureplot_slider,'Max',NbFilteredCells,'Min',1,'Value',handles.cell2display,'SliderStep',[1/(NbFilteredCells-1) 10/(NbFilteredCells-1)]);
    case 'GoodOnly_radio'
        inds = [cells2.good]==1;
        good = cells2(inds);
        dataTrack.FilteredCells = good;
        %         update slider bar
        NbFilteredCells = length(dataTrack.FilteredCells);
        set(handles.Figureplot_slider,'Max',NbFilteredCells,'Min',1,'Value',handles.cell2display,'SliderStep',[1/(NbFilteredCells-1) 10/(NbFilteredCells-1)]);
        handles.cell2display = 1;
        
    case 'MergedOnly_radio'
        
        for aa = 1:length(cells2)
            isMerged(aa) = ~isempty(cells2(aa).merge);
        end
        inds = isMerged==1;
        mergedCells = cells2(inds);
        dataTrack.FilteredCells = mergedCells;
        %         update slider bar
        NbFilteredCells = length(dataTrack.FilteredCells);
        handles.cell2display = 1;
        set(handles.Figureplot_slider,'Max',NbFilteredCells,'Min',1,'Value',handles.cell2display,'SliderStep',[1/(NbFilteredCells-1) 10/(NbFilteredCells-1)]);
        
        
end

% --- Executes on button press in CustomFiltering_pushButton.
function CustomFiltering_pushButton_Callback(hObject, eventdata, handles)
% hObject    handle to CustomFiltering_pushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global dataTrack

cells2 = dataTrack.FilteredCells;

name = 'enter a condtion to filter the cell structure';
prompt = 'use aa as the indice to loop over the "cell" structure. example to filter for the "merged" cells: ';
numlines = 1;
defaultanswer ={'~isempty(cells2(aa).merge)'};
answer=inputdlg(prompt,name,numlines,defaultanswer);
conditionInput = char(answer{1});

for aa = 1:length(cells2)
    
    %% define conditon here
    %          conditionVerified(aa) = ~isempty(cells2(aa).merge)';
    %% or get it form dialog box
    condition = ['conditionVerified(aa) = ' conditionInput];
    eval(condition);
    %
end

inds = conditionVerified==1;
customFilteredCells = cells2(inds);
dataTrack.FilteredCells = customFilteredCells;

%         update slider bar
handles.cell2display = 1;
NbFilteredCells = length(dataTrack.FilteredCells);
set(handles.Figureplot_slider,'Max',NbFilteredCells,'Min',1,'Value',handles.cell2display,'SliderStep',[1/(NbFilteredCells-1) 10/(NbFilteredCells-1)]);

% update the plot figure and its slider
set(handles.Figureplot_slider,'Value',handles.cell2display);
handles = UpdatePlotDisplay(hObject,handles);

% Update image display and the handles structure
handles = UpdateImageDisplay(hObject,handles);
guidata(hObject, handles);

function handles=readImageFiles(handles,s1)

global DataIF;
tic
if ~handles.confocalexpt
    chemin=s1.imagedirectory;
    
    [rangeG, listG] = folderFilesFromKeyword(s1.imagedirectory, s1.smadKeyWord);
    [rangeR, listR] = folderFilesFromKeyword(s1.imagedirectory, s1.nucKeyWord);
    [range,IR,IG] = intersect(rangeR,rangeG);
    GreenImagesNames = listG(IG);
    RedImagesNames = listR(IR);
    handles.onFrames = [1:length(RedImagesNames)];
    %
    
    % load images in memory
    if handles.LoadImages2memory
        
        for ii = 1:length(RedImagesNames)%using parfor (4 workers) here reduced the time to load 110 pictures from 49 to 33 seconds (loading images through network)
            
            DataIF(ii).RedImagesNames = RedImagesNames(ii).name;
            DataIF(ii).GreenImagesNames = GreenImagesNames(ii).name;
            
            red = imread([chemin filesep RedImagesNames(ii).name]);
            DataIF(ii).red = imadjust(red,stretchlim(red,[0.1 0.999]));
            
            green = imread([chemin filesep GreenImagesNames(ii).name]);
            DataIF(ii).green = imadjust(green,stretchlim(green,[0.1 0.999]));
        end
        
    else % only keep images names and display the first picture
        
        for ii = 1:length(RedImagesNames)
            
            DataIF(ii).RedImagesNames = RedImagesNames(ii).name;
            DataIF(ii).GreenImagesNames = GreenImagesNames(ii).name;
        end
        
        red = imread([chemin filesep RedImagesNames(1).name]);
        DataIF(1).red = imadjust(red,stretchlim(red,[0.1 0.999]));
        
        green = imread([chemin filesep GreenImagesNames(1).name]);
        DataIF(1).green = imadjust(green,stretchlim(green,[0.1 0.999]));
        
    end
else
    filename=s1.imagefile;
    handles.LoadImages2memory=1;
    set(handles.Load2mem_checkbox,'Value',1);
    set(handles.Load2mem_checkbox,'enable','off');
    fdata=lsminfo(filename);
    si=[fdata.DimensionX fdata.DimensionY];
    nz=fdata.DimensionZ;
    nt=fdata.DimensionTime;
    chan=s1.chan2use;
    %pictimes=(fdata.TimeStamps.TimeStamps)/3600;
    
    for tt=1:nt
        
        nucmax=zeros(si); nucmax=im2uint8(nucmax);
        sumall=0;
        for zz=1:nz
            imnum=(tt-1)*nz+zz;
            imnum=2*imnum-1;
            nucnow=tiffread27(filename,imnum);
            nucmax=max(nucmax,nucnow.data{chan(1)});
            sumframe=sum(sum(nucnow.data{chan(1)}));
            if sumframe > sumall
                sumall=sumframe;
                frametouse=zz;
            end
        end
        imnum=(tt-1)*nz+frametouse;
        imnum=2*imnum-1;
        imgs=tiffread27(filename,imnum);
        fimg=imgs.data{chan(2)};
        DataIF(tt).red=nucmax;
        DataIF(tt).green=fimg;
        DataIF(tt).RedImagesNames=filename;
        DataIF(tt).GreenImagesName=filename;
        
    end
    
    
end
toc





%%
function handles=readMatFile(handles,matfile)
global dataTrack;

peaks=[];
handles.matFileName=matfile;

load(handles.matFileName)


%     add x y range for of each cell for zoomin

for ii = 1:length(cells)
    if ~isempty(cells(ii).data)
        cells(ii).cellID = ii;
        
        px=cells(ii).data(:,1);
        py=cells(ii).data(:,2);
        maxx = max(px)+100;
        minx = min(px)-100;
        maxy = max(py)+100;
        miny = min(py)-100;
        
        if  maxx > handles.ActualImageSize(2)
            maxx = handles.ActualImageSize(2);
        end
        if  maxy > handles.ActualImageSize(1)
            maxy = handles.ActualImageSize(1);
        end
        if minx<0
            minx = 0;
        end
        if miny<0
            miny = 0;
        end
        cells(ii).xyrange = [minx maxx miny maxy];
    end
end

if handles.CCCexpt
    dataTrack.dataCount = dataCount;
    dataTrack.dataCount2 = dataCount2;
    dataTrack.feedings = feedings;
    
    if exist('dataCrowdExp','var')
        dataTrack.dataCrowdExp = dataCrowdExp;
        dataTrack.dataCrowdSeed = dataCrowdSeed;
    else
        dataTrack.dataCrowdExp = [];
        dataTrack.dataCrowdSeed = [];
    end
    
    
    if exist('births','var')
        dataTrack.births = births;
    else
        dataTrack.births = [];
    end
    
else
    dataTrack.feedings=[];
end

dataTrack.statsArray = statsArray;
dataTrack.allCells = cells;
dataTrack.pictimes = pictimes;
dataTrack.peaks = peaks;
set(handles.message_text,'String','found a mat file','ForegroundColor', 'k');
handles.cell2display = 1;
%     filtered cells only // will also update display
% CellFiltering_SelectionChangeFcn(hObject, eventdata, handles);
set(handles.allCells_radio,'Value',1);
handles.What2plot = 'undefined';
handles.OKdatatrack =1;


% --- Executes on button press in CCCcheckbox.
function CCCcheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to CCCcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CCCcheckbox

handles.CCCexpt=get(hObject,'Value');

% Update handles structure
guidata(hObject, handles);


% --- Executes when selected object is changed in loadimages.
function loadimages_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in loadimages
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'CCC_radio'
        handles.CCCexpt=1;
        handles.confocalexpt=0;
        set(handles.Load2mem_checkbox,'enable','on');
        
    case 'confocal_radio'
        handles.CCCexpt=0;
        handles.confocalexpt=1;
        set(handles.Load2mem_checkbox,'Value',1);
        set(handles.Load2mem_checkbox,'enable','off');
    case 'other_radio'
        handles.CCCexpt=0;
        handles.confocalexpt=0;
        set(handles.Load2mem_checkbox,'enable','on');
        
end
% Update handles structure
guidata(hObject, handles);

function missingstring=checkForRequiredFiles(requiredFiles)
%check that necessary .m files are on path. returns a string with
%names of missing files
q=1; missinginds=[];
for ii=1:length(requiredFiles)
    if ~exist(requiredFiles{ii},'file')
        disp(['warning: file ' requiredFiles{ii} ' required.']);
        missinginds=[missinginds ii];
    end
end


missingstring=[];
for ii=1:length(missinginds)
    missingstring=[missingstring requiredFiles{missinginds(ii)} ' '];
end
if ~isempty(missingstring)
    missingstring=['warning, missing files:' missingstring];
end

function plotGrowth(dataTrack)

dataCount1 = dataTrack.dataCount;
dataCount2 = dataTrack.dataCount2;
dataCrowdExp = dataTrack.dataCrowdExp ;
dataCrowdSeed = dataTrack.dataCrowdSeed;



if ~isempty(dataCount1)
    dataCount1(1,:) = dataCount1(1,:)-dataCount1(1,end);
    plot(dataCount1(1,:),dataCount1(2,:),'b-',dataCount2(1,:),dataCount2(2,:),'r-');
else
    
    plot(dataCount2(1,:),dataCount2(2,:),'r-');
end

hold on

if ~isempty(dataCrowdExp)
    dataCrowdExp(1,:) = dataCrowdExp(1,:)- dataCrowdExp(1,1);
    if ~isempty(dataCrowdSeed)
        dataCrowdSeed(1,:) = dataCrowdSeed(1,:)- dataCrowdSeed(1,end);
        plot(dataCrowdSeed(1,:),dataCrowdSeed(2,:),'g-',dataCrowdExp(1,:),dataCrowdExp(2,:),'g-');
    else
        plot(dataCrowdExp(1,:),dataCrowdExp(2,:),'g-');
    end
    
end
hold off

% Create xlabel
xlabel('time (hours)','FontSize',14);

% Create ylabel
ylabel('cell number','FontSize',14);


% assignin('base','allPeaks',piques);


% --- Executes on button press in StatsPeaks_pushbutton.
function StatsPeaks_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to StatsPeaks_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dataTrack;

getMaxstats(dataTrack.allCells,dataTrack.feedings,dataTrack.pictimes,dataTrack.dataCrowdExp,dataTrack.dataCrowdSeed,dataTrack.dataCount,dataTrack.dataCount2,handles.chemin)


% --- Executes on button press in showNuc.
function showNuc_Callback(hObject, eventdata, handles)
% hObject    handle to showNuc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showNuc
handles.showNucPlot=get(hObject,'Value');
handles = UpdatePlotDisplay(hObject,handles);
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in showFluor1.
function showFluor1_Callback(hObject, eventdata, handles)
% hObject    handle to showFluor1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showFluor1
handles.showFluor1Plot=get(hObject,'Value');
handles = UpdatePlotDisplay(hObject,handles);
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in showFluor2.
function showFluor2_Callback(hObject, eventdata, handles)
% hObject    handle to showFluor2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showFluor2
handles.showFluor2Plot=get(hObject,'Value');
handles = UpdatePlotDisplay(hObject,handles);
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in ratio_checkbox.
function ratio_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to ratio_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ratio_checkbox


% --- Executes when selected object is changed in uipanel15.
function uipanel15_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel15 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

checkval=get(hObject,'Tag');
if strcmp(checkval,'radiobutton28')
handles.useRatioForPlot=1;
elseif strcmp(checkval,'radiobutton29')
    handles.useRatioForPlot=2;
elseif strcmp(checkval,'radiobutton30')
    handles.useRatioForPlot=3;
end
handles = UpdatePlotDisplay(hObject,handles);
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in checkbox17.
function checkbox17_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox17
handles.showSingleCell=get(hObject,'Value');
if handles.showSingleCell==1
    set(handles.Figureplot_slider,'Enable','on');
    set(handles.Figureplot_slider,'Visible','on');

else
    set(handles.Figureplot_slider,'Enable','off');
    set(handles.Figureplot_slider,'Visible','off');
end
handles = UpdatePlotDisplay(hObject,handles);
% Update handles structure
guidata(hObject, handles);

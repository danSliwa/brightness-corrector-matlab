close all;
%% Input:
% Video:
doVideo = questdlg('Czy w³¹czyæ modu³ wideo? Uwaga, d³ugi czas przetwarzania!', ...
                   'Opcje Wideo', ...
                   'Tak','Nie','Nie');
if strcmp('Tak', doVideo)
modelList = {'Model Sigmoid','Model Beta','Model Gamma','Model Beta-Gamma','Model Preferred'};
[selectedModel, v] = listdlg('PromptString','Wybierz model do obróbki wideo:',...
                             'Name', 'Opcje wideo',...
                             'ListSize', [220 80],...
                             'SelectionMode','single',...
                             'ListString',modelList);
                         
    prompt = 'Podaj wartoœæ ratio dla video: ';
    vidRatio = inputdlg(prompt);
    vidRatio = str2double( cell2mat(vidRatio) );
    vidRatio = double(vidRatio);
    
    vidPath = 'image\KAMERA1.mp4';
    vid = VideoReader(vidPath);
    vidPath = erase(vidPath, '.mp4');
    
    if v == 0 % error, no model selected
        error('Nie wybrano ¿adnego modelu do obróbki wideo!');
    end
end
% Image:
loadNewImg = questdlg('Czy chcesz wczytaæ nowy obraz?', ...
                       'Opcje obrazu.', ...
                       'Tak','Nie','Nie');            
if strcmp('Tak', loadNewImg)
[filename, pathname] = uigetfile({'*.*'; '*.jpeg'; '*.jpg'; '*.png'},...
                                  'Wybierz obraz do przetwarzania:');
end
ise = evalin( 'base', 'exist(''filename'',''var'') == 1' ); % check if img was loaded
if ~ise
    error('Nie za³adowano ¿adnego obrazu!');
end
imgFile=fullfile(pathname,filename);
in = im2double(imread(imgFile));
inType = DetermineTypeOfImage(in);
%% Model list:
models.SigmoidModel = CameraModels.Sigmoid();
models.BetaModel = CameraModels.Beta();
models.GammaModel = CameraModels.Gamma();
models.BetaModelGammaModel = CameraModels.BetaGamma();
models.PreferredModel = CameraModels.Preferred();
%% Enhance:
currRatioMax = 7; % default value
out = ENHANCEImages(in, currRatioMax, models);
%% Plot initial images:
figOutImg = figure('units','pixels','outerposition',[0 0 1920 1080]); % Initialize figure
% ==== Initialize data struct and save it to figure: ==== %
data.out = out;
data.models = models;
data.originalImage = in;
data.in = in;
data.inType = DetermineTypeOfImage(in);
data.currRatioMax = currRatioMax;
data.userAcknowledged = false;
data.selectedView = 'Sigmoid';
data.lastSelectedView = 'Sigmoid';
data.doVideo = doVideo;
guidata(figOutImg, data);
% ======================================================= %
% Plot images for the first time:
PlotAgain(figOutImg);
%% Video:
if strcmp('Tak', doVideo)
    
    switch selectedModel 
        case 1
            modelVideo = models.SigmoidModel;
        case 2
            modelVideo = models.BetaModel;
        case 3
            modelVideo = models.GammaModel;
        case 4
            modelVideo = models.BetaModelGammaModel;
        case 5
            modelVideo = models.PreferredModel;
    end
    
   
    
    vidOut = Video(vid, modelVideo, vidRatio, [vidPath '_OUT']);
    DisplayVideo(vid, vidOut);
end
%% FUNCTIONS:
%% Image functions:
% Enhance images, all models:
function out = ENHANCEImages(in, ratioMax, models)
out.Sigmoid = ENHANCE(in, models.SigmoidModel, ratioMax);
out.Beta = ENHANCE(in, models.BetaModel, ratioMax);
out.Gamma = ENHANCE(in, models.GammaModel, ratioMax);
out.BetaGamma = ENHANCE(in, models.BetaModelGammaModel, ratioMax);
out.Preferred = ENHANCE(in, models.PreferredModel, ratioMax);
end
% Image switch helper function:
function HandleSwitchImage(src, eventdata, ~)
data = guidata(eventdata.Source); % read data from figure
selectedIndex = get(src, 'value');
selectedView = IndexToView(selectedIndex);
[data.selectedView, data.lastSelectedView] = SwitchImage(selectedView, data);
guidata(src.Parent, data); % write data to figure
end
% Help with view string:
function switchView = IndexToView(selectedIndex)
switch selectedIndex
    case 1
        switchView = 'Sigmoid';
    case 2
        switchView = 'Beta';
    case 3
        switchView = 'Gamma';
    case 4
        switchView = 'BetaGamma';
    case 5
        switchView = 'Preferred';
end
end
% Switch figure view function:
function [selectedView, lastSelectedView] = SwitchImage(view, data)
switch view
    case 'Sigmoid'
        selectedView = DisplayModelSigmoid(data);
        lastSelectedView = 'Sigmoid';
    case 'Beta'
        selectedView = DisplayModelBeta(data);
        lastSelectedView = 'Beta';
    case 'Gamma'
        selectedView = DisplayModelGamma(data);
        lastSelectedView = 'Gamma';
    case 'BetaGamma'
        selectedView = DisplayModelBetaGamma(data);
        lastSelectedView = 'BetaGamma';
    case 'Preferred'
        selectedView = DiplayModelPreferred(data);
        lastSelectedView = 'Preferred';
end

end

% Display image functions:
function selectedView = DisplayModelSigmoid(data)
subplot(2, 2, 2)
imshow(data.out.Sigmoid);
title('Obraz wyjœciowy - model Sigmoid');
subplot(2, 2, 4)
imhist(data.out.Sigmoid);
title('Histogram - model Sigmoid');
selectedView = 'Sigmoid';
end

function selectedView = DisplayModelBeta(data)
subplot(2, 2, 2)
imshow(data.out.Beta);
title('Obraz wyjœciowy - model Beta');
subplot(2, 2, 4)
imhist(data.out.Beta);
title('Histogram - model Beta');
selectedView = 'Beta';
end

function selectedView = DisplayModelGamma(data)
subplot(2, 2, 2)
imshow(data.out.Gamma);
title('Obraz wyjœciowy - model Gamma');
subplot(2, 2, 4)
imhist(data.out.Gamma);
title('Histogram - model Gamma');
selectedView = 'Gamma';
end

function selectedView = DisplayModelBetaGamma(data)
subplot(2, 2, 2)
imshow(data.out.BetaGamma);
title('Obraz wyjœciowy - model Beta-Gamma');
subplot(2, 2, 4)
imhist(data.out.BetaGamma);
title('Histogram - model Beta-Gamma');
selectedView = 'Beta-Gamma';
end

function selectedView = DiplayModelPreferred(data)
subplot(2, 2, 2)
imshow(data.out.Preferred);
title('Obraz wyjœciowy - model Preferred');
subplot(2, 2, 4)
imhist(data.out.Preferred);
title('Histogram - model Preferred');
selectedView = 'Preferred';
end

%% Ratio control functions:
function IncButtonPushed(src, eventdata)
data = guidata(eventdata.Source); % read data from figure
if ~data.userAcknowledged
    data.userAcknowledged = NotifyUserDialog();
end
data.currRatioMax = data.currRatioMax + 1;
data.out = ENHANCEImages(data.in, data.currRatioMax, data.models);
guidata(src.Parent, data); % write data to figure
PlotAgain(src.Parent); 
disp('ratio +1 byczku');
end

function DecButtonPushed(src, eventdata)
data = guidata(eventdata.Source);
if ~data.userAcknowledged
    data.userAcknowledged = NotifyUserDialog();
end
data = guidata(eventdata.Source);
data.currRatioMax = data.currRatioMax - 1;
data.out = ENHANCEImages(data.in, data.currRatioMax, data.models);
guidata(src.Parent, data);
PlotAgain(src.Parent); 
end

function ChangeRationButtonPushed(src, eventdata)
data = guidata(eventdata.Source);
prompt = {'Wpisz now¹ wartoœæ ratio:'};
dlgtitle = 'Nowe ratio';
definput = {'10'};
dims = [1 40];
opts.Interpreter = 'tex';
newRatio = inputdlg(prompt,dlgtitle,dims,definput,opts);
newRatio = str2double( cell2mat(newRatio) );
newRatio = double(newRatio);
data.currRatioMax = newRatio;
if ~data.userAcknowledged
    data.userAcknowledged = NotifyUserDialog();
end
data.out = ENHANCEImages(data.in, data.currRatioMax, data.models);
guidata(src.Parent, data);
PlotAgain(src.Parent); 
end

function userOut = NotifyUserDialog()
userKnows = questdlg('UWAGA! Dokonano zmiany ratio, proszê zaczekaæ na jego akutalizacjê i nie dokonywaæ kolejnych zmian!',...
                          'UWAGA!',... 
                          'OK','Nie pokazuj ponownie','OK');
if strcmp(userKnows, 'Nie pokazuj ponownie')
    userOut = true;
else
    userOut = false;
end
end
%% Next iteration function:
% Function that takes current enhanced image and makes in input for next
% set of enhanced images.
function IterateAlgorhitm(src, eventdata)
data = guidata(eventdata.Source);
figOutImg = src.Parent;
switch data.selectedView
    case 'Sigmoid'
        data.in = data.out.Sigmoid;
    case 'Beta'
        data.in = data.out.Beta;
    case 'Gamma'
        data.in = data.out.Gamma;
    case 'Beta-Gamma'
        data.in = data.out.BetaGamma;
    case 'Preferred'
        data.in = data.out.Preferred;
end

data.out = ENHANCEImages(data.in, data.currRatioMax, data.models);
guidata(figOutImg, data);
PlotAgain(figOutImg);
end
%% Show original function:
% Shows original image that was user input.
function ShowOriginalButton(~, eventdata)
data = guidata(eventdata.Source);
origImageFig = figure('units','normalized','outerposition',[0 0 0.25 0.25]);
imshow(data.originalImage);
title('Obraz oryginalny');
end
%% Main plotting function:
function PlotAgain(figOutImg)
data = guidata(figOutImg);

dim = [.2 .5 .3 .3];
annHandle = annotation('textbox',dim,...
                       'String',['Wartoœæ ratio: ' num2str(data.currRatioMax)],...
                       'FitBoxToText','on', 'FontSize', 16, 'Margin', 7,...
                       'BackgroundColor', 'White', 'LineWidth', 3,...
                       'Position', [0 0.5 0.14 0.05]);
                   
orgButtonH = uicontrol('Style','pushbutton','String','Poka¿ Orygina³', 'FontSize', 12,...
                      'BackgroundColor', 'yellow',...
                      'Position', [20 750 170 35],...
                      'Tooltip', 'Poka¿ oryginalny obraz wgrany przez u¿ytkownika',...
                      'Callback', @ShowOriginalButton);
                   
nexButtonH = uicontrol('Style','pushbutton','String','Kolejna iteracja...', 'FontSize', 12,...
                      'BackgroundColor', 'cyan',...
                      'Position', [20 710 190 35],...
                      'Tooltip', 'Bierze aktualnie wyœwietlany model do kolejnej iteracji algorytmu.',...
                      'Callback', @IterateAlgorhitm);
                  
nexButtonH.UserData = data;

incButtonH = uicontrol('Style','pushbutton','String','Ratio +1', 'FontSize', 12,...
                      'BackgroundColor', 'Green',...
                      'Position', [50 560 100 30],...  
                      'Callback', @IncButtonPushed);
                  
decButtonH = uicontrol('Style','pushbutton','String','Ratio -1', 'FontSize', 12,...
                      'BackgroundColor', 'Red',...
                      'Position', [50 530 100 30],...  
                      'Callback', @DecButtonPushed);
                  
chgButtonH = uicontrol('Style','pushbutton','String','WprowadŸ now¹ wartoœæ', 'FontSize', 12,...
                      'BackgroundColor', 'white',...
                      'Position', [1 440 190 35],...  
                      'Callback', @ChangeRationButtonPushed);
                  
subtitle('Wybierz model:');
popupHandle = uicontrol('Style', 'popup',...
                        'String', {'Model Sigmoid','Model Beta','Model Gamma','Model Beta-Gamma','Model Preferred'},...
                        'Position', [750 660 100 100],...
                        'Callback', @HandleSwitchImage);
                    
if strcmp(data.inType, 'light')
    lightAmount = 'za du¿e';
else
    lightAmount = 'za ma³e';
end

% Default figure:
subplot(2, 2, 1)
imshow(data.in);
title(['Obraz wejœciowy - ' lightAmount ' oœwietlenie']);

subplot(2, 2, 3)
imhist(data.in);
title('Histogram - Obraz wejœciowy ma³e oœwietlenie');

SwitchImage(data.lastSelectedView, data);
end

%% Video functions:
% Video enhance function:
function vidOut = Video(vid, model, ratioMax, videoToSaveFilename)
warning('off');
vidFrames = vid.NumberOfFrames;

vidOut = VideoWriter([videoToSaveFilename '_' model.name '.mp4'], 'MPEG-4');
vidOut.Quality = 100;
vidOut.FrameRate = vid.FrameRate;
processedFrames = 1;
open(vidOut);
for i = 1:vidFrames
    thisFrame = read(vid, i);
    enhFrame = ENHANCE(thisFrame, model, ratioMax);
    enhFrame = im2uint8(enhFrame);
    writeVideo(vidOut, enhFrame);
    fprintf('>>Processed %d out of %d frames.\n', processedFrames, vidFrames);
    processedFrames = processedFrames + 1;
end
close(vidOut);
disp('VIDEO PROCESSED!');
warning('on');
end

% Display video function:
function DisplayVideo(vidBefore, vidAfter)
vidBeforePath = [vidBefore.Path '\' vidBefore.Name];
vidAfterPath  = [vidAfter.Path  '\' vidAfter.Filename];

implay(vidBeforePath); 
implay(vidAfterPath); 
end
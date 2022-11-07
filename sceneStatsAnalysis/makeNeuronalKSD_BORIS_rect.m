%% Make kernel-smoothed densities

clear all
close all

% Define dirs
splPath = regexp(which('makeNeuronalKSD_BORIS'),filesep,'split');
topDir  = [filesep,fullfile(splPath{1:numel(splPath)-2}),filesep];
saveDir = [topDir,filesep,'SceneStatsAnalysis/savedKSDmatFiles_BORISdataset/'];


%% Grab all RF x/y locations
% load fitting results
V1 = load([topDir,'V1V2MTPopulations/resultsV1_final.mat']);
V2 = load([topDir,'V1V2MTPopulations/resultsV2_final.mat']);
MT = load([topDir,'V1V2MTPopulations/resultsMT_final.mat']);

% load MT metadata
T_MT = readtable([topDir,'V1V2MTPopulations/metadataMT.xlsx']);

% for each file name in experiments, find index from xls and get other data
for f = 1:length(MT.experiments)
    
    % get filename
    fname = MT.experiments{f}.fn;
    fname = fliplr(strtok(fliplr(fname),'_'));
    fname = fname(1:end-4);

    % find row in Greg's files
    this_row = find(strcmp(T_MT.FIleName,fname));
    
    % grab that from that row and assign it to this neuron
    % positive x is right in VF, positive y is up in VF
    MT.x_pos(f)             = T_MT.RF_x(this_row); % note this does not account for vergence, see Jenny's notes
    MT.y_pos(f)             = T_MT.RF_y(this_row);
    
end

% grab V1 RF location data, much simpler
for v = 1:length(V1.experiments)
    
    % positive x is to the animals left in their visual field so we flip to match MT data, positive y is up
    V1.x_pos(v) = -V1.experiments{v}.x_pos;
    V1.y_pos(v) = V1.experiments{v}.y_pos;
    
end

% grab V2 RF location data, much simpler
for v = 1:length(V2.experiments)
    
    % positive x is to the animals left in their visual field so we flip to match MT data, positive y is up
    V2.x_pos(v) = -V2.experiments{v}.x_pos;
    V2.y_pos(v) = V2.experiments{v}.y_pos;
    
end

%% Make alternative set of MT positions based on V1/V2 bounding box

% Find extreme values of x/y positions for V1/V2
xMax = max([V1.x_pos V2.x_pos]);
yMax = max([V1.y_pos V2.y_pos]);
xMin = min([V1.x_pos V2.x_pos]);
yMin = min([V1.y_pos V2.y_pos]);

% Select indices of MT neurons within these bounds
MTxIncMax = MT.x_pos < xMax;
MTyIncMax = MT.y_pos < yMax;
MTxIncMin = MT.x_pos > xMin;
MTyIncMin = MT.y_pos > yMin;

MTinc = MTxIncMax & MTyIncMax & MTxIncMin & MTyIncMin;

MT.x_posBnd = MT.x_pos(MTinc);
MT.y_posBnd = MT.y_pos(MTinc);


%% Make KSD plots of MT data based on V1/V2 bounding box

rangeMax = 10;          % Limit sampling window to +/-10deg around fixation point
% dx       = 0.02;        % Deg (from McCann dataset)
dx       = 10/103;      % Deg (from BORIS dataset)

supp1D   = -rangeMax:dx:rangeMax;
[gx,gy]  = meshgrid(supp1D,supp1D);
gxL      = gx(:);
gyL      = gy(:);
suppSz   = size(gx,1);

% MT density plot
V1V2Rectdensity = ksdensity([MT.x_posBnd' MT.y_posBnd'],[gxL gyL]);

V1V2RectMat = reshape(V1V2Rectdensity,[suppSz suppSz]);


%% Save these to plug into image stats script

save([saveDir,'V1V2Rect_BORIS.mat'],'V1V2RectMat','MT');

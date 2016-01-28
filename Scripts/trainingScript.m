%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script performs the component alignment for the trained DPMs. DPMs
% are trained using the original DPM code.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;
clear;

%% Convert DPMs to star graphs

% Please download the DPM and RRWM code and put them under the folder 'Libs', 
% and change the folder names when necessary.
disp('Setting up environment...');
addpath('../Libs/voc-release5');
startup;
addpath(genpath('../Functions'));
addpath(genpath('../Libs/RRWM_release_v1.22'));
addpath('../Libs/freezeColors');
addpath('../Libs/DrawLine');
addpath('../Libs/tight_subplot');
addpath('../Libs/SubAxis');
disp('Environment is set up.');

categoriesSketch = {'airplane', 'bicycle',	'standing bird',	'bus',	'car (sedan)',...
    'cat',	'chair',	'cow',	'table',	'dog',	'horse',	'motorbike', 'sheep',	'train'};

categoriesImage = {'aeroplane', 'bicycle',	'bird',	'bus',	'car',...
    'cat',	'chair',	'cow',	'diningtable',	'dog',	'horse',	'motorbike', 'sheep',	'train'};

numCate = length(categoriesSketch);
numComp = 6; %DPM component number

% The folders for the pre-trained DPMs and the storing paths for the
% converted star graphs.
imgDPMPath = '../Data/DPMs/Img/';
sketchDPMPath = '../Data/DPMs/Sketch/';

resultPath = '../Result';
if ~exist(resultPath, 'dir')
    mkdir(resultPath);
end

starGraphPath = '../Results/StarGraph/';
if ~exist(starGraphPath, 'dir')
    mkdir(starGraphPath);
end

% compute star graph for models
% sketches
if ~exist('../Results/StarGraph/sketchStars.mat','file')
    sketchStars = cell(numCate,1);
    for i = 1 : numCate
        fprintf('sketch Model:%d\n',i);
        modelFullPath = [sketchDPMPath,categoriesSketch{i},'_final.mat'];
        load(modelFullPath);
        sketchStars{i} = model2star(model);
    end
    sketchResultPath = [starGraphPath, 'sketchStars.mat'];
    save(sketchResultPath,'sketchStars');
else
    load('../Results/StarGraph/sketchStars.mat');
end

% images
if ~exist('../Results/StarGraph/imgStars.mat','file')
    imgStars = cell(numCate,1);
    for i = 1 : numCate
        fprintf('image Model:%d\n',i);
        modelFullPath = [imgDPMPath,categoriesImage{i},'_final.mat'];
        load(modelFullPath);
        imgStars{i} = model2star(model);
    end
    
    imgResultPath = [starGraphPath, 'imgStars.mat'];
    save(imgResultPath, 'imgStars');
else
    load('../Results/StarGraph/imgStars.mat')
end

%% Component alignment
% component comparing experiment
compCorrpsAll = zeros(numComp,numCate);
alignmentPath = '../Results/CompAlign/';
if ~exist(alignmentPath, 'dir')
    mkdir(alignmentPath);
end

for cateId = 1 : numCate
    fprintf('processing category: %s\n',categoriesSketch{cateId});
    path = [alignmentPath, categoriesSketch{cateId}, 'Rank.mat'];
    
    if ~exist(path, 'file')
        DPM1 = sketchStars{cateId};
        DPM2 = imgStars{cateId};
        
        numComp1 = size(DPM1,1);
        numComp2 = size(DPM2,1);
        scores = zeros(numComp1, numComp2);
        partCorrelations = cell(numComp1, numComp2);
        
        for i = 1 : numComp1
            for j = 1 : numComp2
                [scores(i,j),partCorrelations{i,j}] =  starMatching(DPM1{i},DPM2{j},8, 1, 0.5);
            end
        end
        
        [sortedScores,rank] = sort(scores,2,'descend');
        
        save(path,'rank','partCorrelations');
    else
        load(path);
    end
    %% visualize the results
    cls = categoriesImage{cateId};
    S = load([imgDPMPath,cls,'_final.mat']);
    modelImage = S.model;
    
    cls = categoriesSketch{cateId};
    S = load([sketchDPMPath,cls,'_final.mat']);
    modelSketch = S.model;
    
    
    final = {1:8};
    figure;
    components = 1;
    visualizemodel_customize(modelSketch, modelImage, components, rank(components,1), ...
        partCorrelations(components,1));
    
    figure;
    components = 3;
    visualizemodel_customize(modelSketch, modelImage, components, rank(components,1), ...
        partCorrelations(components,1));
    
    figure;
    components = 5;
    visualizemodel_customize(modelSketch, modelImage, components, rank(components,1), ...
        partCorrelations(components,1));
    
    % pause here to observe
    close all;
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script performs the fine-grained retrieval on the groundtruth dataset
% and produces the benchmark.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;
clear;

%% get the detections

% initializations
disp('Setting up environment...');
addpath('../Functions/Detection');
% Please download the DPM code and put it under the folder 'Libs'.
addpath(genpath('../Libs/voc-release5'));
disp('Environment is set up.');

categoriesSketch = {'airplane', 'bicycle',	'standing bird',	'bus',	'car (sedan)',...
    'cat', 'chair', 'cow', 'table',	'dog', 'horse',	'motorbike', 'sheep',	'train'};

categoriesImage = {'aeroplane', 'bicycle', 'bird',	'bus', 'car',...
    'cat', 'chair', 'cow', 'diningtable', 'dog', 'horse', 'motorbike', 'sheep',	'train'};

testPath = '../Data/Test/images/';
DPMPath = '../Data/DPMs/';
detPath = '../Results/Detection/';
if ~exist(detPath, 'dir')
    mkdir(detPath);
end
numCate = length(categoriesSketch);

%sketch
sketchDetFolder = [detPath,'Sketch/'];
if ~exist(sketchDetFolder, 'dir')
    mkdir(sketchDetFolder);
end

for i = 1 : numCate
    cls = categoriesSketch{i};
    sketchDetPath = [sketchDetFolder, cls, 'Det.mat'];
    
    if ~exist(sketchDetPath, 'file')
        fprintf('obtaining detections for category %s of the sketches.\n', cls);
        
        sketchPath = [testPath,cls,'/sketch/'];
        modelPath = [DPMPath, 'Sketch/', cls, '_final.mat'];
        
        detections = cateDPMdetect(sketchPath, modelPath);
        save(sketchDetPath,'detections');
    end
end

%image
imgDetFolder = [detPath, 'Img/'];
if ~exist(imgDetFolder, 'dir')
    mkdir(imgDetFolder);
end

for i = 1 : numCate
    cls = categoriesImage{i};
    imgDetPath = [imgDetFolder, cls, 'Det.mat'];
    
    if ~exist(imgDetPath, 'file')
        fprintf('obtaining detections for category %s of the images.\n', cls);
        
        imgPath = [testPath,categoriesSketch{i},'/img/'];
        modelPath = [DPMPath, 'Img/', cls, '_final.mat'];
        
        detections = cateDPMdetect(imgPath, modelPath);
        save(imgDetPath,'detections');
    end
end

%% retrieve on the detections
retrResultFolder = '../Results/Retrieval/';
if ~exist(retrResultFolder, 'dir')
    mkdir(retrResultFolder);
end
testSkNum = 3;

for cate = 1 : numCate
    imgCls = categoriesImage{cate};
    skCls = categoriesSketch{cate};
    path = [retrResultFolder,skCls,'Result.mat'];
    if ~exist(path, 'file')
        fprintf('Retrieval on category: %s\n', skCls);
        
        load(['../Results/CompAlign/',skCls,'Rank.mat']);
        S = load([sketchDetFolder, skCls, 'Det.mat']);
        detSketch = S.detections;
        S = load([imgDetFolder, imgCls, 'Det.mat']);
        detImg = S.detections;
        
        
        % pose retrieval
        % organize the images by its detecting component
        numOfComp = 6;
        detImgByComp = cell(numOfComp,1);
        count = ones(numOfComp,1);
        
        imgNodet = {};
        count_nodet = 1;
        for i = 1 : size(detImg,1)
            if size(detImg{i,1},1) ~= 0
                if size(detImg{i,2},1) ~= 0
                    comp = detImg{i,4};
                    detImgByComp{comp}{count(comp),1} = i;
                    detImgByComp{comp}{count(comp),2} = detImg{i,1};
                    detImgByComp{comp}{count(comp),3} = detImg{i,2};
                    
                    count(comp) = count(comp) + 1;
                else
                    imgNodet{count_nodet, 1} = i;
                    imgNodet{count_nodet, 2} = detImg{i,1};
                    imgNodet{count_nodet, 3} = detImg{i,2};
                    count_nodet = count_nodet+1;
                end
                
                fprintf('img index : %d/%d\n', i, size(detImg,1));
            end
        end
        
        % retrieve by sketch
        retResult = cell(size(detSketch,1),3);
        
        for i = 4 : 6
            fprintf('sketch index: %d/%d\n',i,size(detSketch,1));
            % sketch component
            if size(detSketch{i,2},1) ~= 0
                comp = detSketch{i,4};
                
                rankComp = rank(comp,:);
                
                imgSet = [];
                
                for j = 1 : size(rankComp,2)
                    tmpSet = detImgByComp{rankComp(j)};
                    if numel(tmpSet) ~= 0
                        % align the parts order of the sketch
                        newSkDet = detSketch{i,2};
                        
                        score = zeros(size(tmpSet,1),1);
                        for k = 1 : size(tmpSet,1)
                            fprintf('imageToMatch index: %d/%d\n',k,size(tmpSet,1));
                            oneImgDet = tmpSet{k,3};
                            [score(k),~ ]= starMatching(newSkDet,oneImgDet, 8, 0.2,0.5);
                        end
                        [~,ind] = sort(score,'descend');
                        tmpSet = tmpSet(ind,:);
                        
                        imgSet =[imgSet; tmpSet];
                    end
                end
                imgSet = [imgSet; imgNodet];
                
                retResult{i,1} = i;
                retResult{i,2} = imgSet;
                retResult{i,3} = detSketch{i,1};
            else
                retResult{i} = [];
            end
        end
        
        
        save(path,'retResult');
    end
end

%% evaluate the retrieved results
aspects = {'view','conf','body','zoom','all'};

% scores
tops = [5 10];
asp = 5; % choose the needed criterion(criteria)
aspect = aspects{asp};
ifDisp = 1;

for i = 1 : 2
    fprintf('Calculating scores (top %d):\n', tops(i));
    top = tops(i);
    evaluateScript;
end

disp('press any key to continue...');
pause;

% P-R curve
ifDisp = 0;
fprintf('Plotting P-R curves\n');
for asp = 1:5
    aspect = aspects{asp};
    fprintf('processing criterion: %s\n', aspect);
    scores = zeros(60,1);
    pres = zeros(60,1);
    for i = 1 : 60
        fprintf('processing top %d\n', i);
        top = i;
        evaluateScript;
        scores(i) = avgScore;
        pres(i) = avgPre;
    end
    
    markingPlotterScript;
end

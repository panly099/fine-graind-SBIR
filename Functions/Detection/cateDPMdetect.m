%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function detects object in the image and stores the detected star
% model and the file name
% Input :
%        storePath : the storing path of the images of one category.
%        modelPath : the model path.
% Output :
%        detections : the detected star graph of the images.
% Author : panly099@gmail.com
% Version : 1.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function detections = cateDPMdetect(storePath, modelPath)
%% detect and store
imgList = dir(storePath);
cropPath = [storePath, '../cropped/'];
if ~exist(cropPath,'dir')
    mkdir(cropPath)
end

S = load(modelPath);
model = S.model;
detections = cell(size(imgList,1)-2,5);

for i = 3 : size(imgList,1)
    fprintf('%d/%d\n', i-2, size(imgList,1)-2);
    
    imgPath = [storePath,imgList(i).name];
    im = imread(imgPath);
    % detect objects
    [ds, bs, trees, pyra] = imgdetect_customize(im, model, -1);
    

    % visualizations for different levels of feature pyramids
%     for k = 1 :pyra.num_levels
%         newImgHOG = pyra.feat{k}(:,:,19:27);
%         newImgEdgeMap = HOGpicture(newImgHOG, 20);
%         figure; imshow(newImgEdgeMap);
%     end
    %%
    
    top = nms(ds, 0.5);
    top = top(1:min(length(top), 1));
    ds = ds(top, :);
    bs = bs(top, :);
    trees = trees(top,:);
    
    if model.type == model_types.Grammar
        bs = [ds(:,1:4) bs];
    end
    
    if size(bs,1) ~= 0
        b = reduceboxes(model, bs);
        
        % obtain bbox
        bbox = bboxpred_get(model.bboxpred, ds,b);
        bbox = clipboxes(im, bbox);
        top = nms(bbox, 0.5);
        bbox = bbox(top,:);
        detections{i-2,3} = bbox(1:4);
        detections{i-2,4} = b(end-1);
%         croppedImg = im(bbox(2):bbox(4), bbox(1):bbox(3),:);
%         imshow(croppedImg);
%         croppedImgPath = [cropPath, imgList(i).name];
%         imwrite(croppedImg, croppedImgPath);
        
        % obtain root feature and root center
        valid = [3 6 7 8];
        trees = trees{1}(valid,11:19);
        rootSymbolInd = trees(1,1);
        rootFilterInd = model.symbols(rootSymbolInd).filter;
        rootWidth =  model.filters(rootFilterInd).size(2);
        rootHeight = model.filters(rootFilterInd).size(1);
        rootScale = trees(4,1);
        rootX = trees(2,1);
        rootY = trees(3,1);
        detections{i-2,2}{1,1} = ...
            pyra.feat{rootScale}(rootY:rootY+rootHeight-1,rootX:rootX+rootWidth-1,:);
        
        x1 = bbox(1);
        y1 = bbox(2);
        x2 = bbox(3);
        y2 = bbox(4);
        c = [(x2-x1)/2+x1;(y2-y1)/2+y1];
        
        % scale factor
        factor = 120/(b(7)-b(5));
        
        for p = 2 : 9
            % obtain part features and locations
            partSymbolInd = trees(1,p);
            partFilterInd = model.symbols(partSymbolInd).filter;
            partWidth =  model.filters(partFilterInd).size(2);
            partHeight = model.filters(partFilterInd).size(1);
            partScale = trees(4,p);
            partX = trees(2,p);
            partY = trees(3,p);
            
            x1 = b(1+(p-1)*4);
            y1 = b(2+(p-1)*4);
            x2 = b(3+(p-1)*4);
            y2 = b(4+(p-1)*4);
            cp = [(x2-x1)/2+x1;(y2-y1)/2+y1];
            
            [pyHeight,pyWidth,~] = size(pyra.feat{partScale});
            %             fprintf('X:%d, Y:%d,width:%d,height:%d,pyra height:%d, pyra width:%d\n',partX,partY,partWidth,partHeight,y,x);
            if partX < 1 || partX+partWidth-1 > pyWidth || partY <1 || partY+partHeight-1>pyHeight
                detections{i-2,2}{1,2}{p-1,1} = zeros(partHeight,partWidth,32);
                disp('Empty part!');
            else
                detections{i-2,2}{1,2}{p-1,1} = ...
                    pyra.feat{partScale}(partY:partY+partHeight-1,partX:partX+partWidth-1,:);
            end
            detections{i-2,2}{1,2}{p-1,2} = (cp - c) * factor;
        end 
    else
        detections{i-2,2} = [];
        detections{i-2,3} = [];
        detections{i-2,4} = [];
    end
    
end

for k = 3 : size(imgList,1)
    fprintf('%d/%d\n', k-2, size(imgList,1)-2);
    detections{k-2,1} = imgList(k).name;   
end 
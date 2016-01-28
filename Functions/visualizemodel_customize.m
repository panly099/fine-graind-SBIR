function visualizemodel_customize(model1, model2, components1, components2, PartCorrelations)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A modified version of the DPM visualization code to suit our need. 
% Input:
%   model1,model2: DPM models.
%   components1, components2: the corresponding components to show in each
%   model.
%   PartCorrelations: the part correlations of the two components.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AUTORIGHTS
% -------------------------------------------------------
% Copyright (C) 2011-2012 Ross Girshick
% Copyright (C) 2008, 2009, 2010 Pedro Felzenszwalb, Ross Girshick
% 
% This file is part of the voc-releaseX code
% (http://people.cs.uchicago.edu/~rbg/latent/)
% and is available under the terms of an MIT-like license
% provided in COPYING. Please retain this notice and
% COPYING if you use this file (or a portion of it) in
% your project.
% -------------------------------------------------------
clf;
nc = 3*length(components1);
k = 1;
for i = components1
    center1 = visualizecomponent(model1, i, 2*length(components1), k, 1, 1,PartCorrelations);
    k = k+1;
end

k = 1;
for i = components2
    center2 = visualizecomponent(model2, i, 2*length(components2), k, 1, 2,PartCorrelations);
    k = k+1;
end


for i = 1 : 8
%     plot([center1(i,1) center2(i,1)],[center1(i,2) center2(i,2)]);
    annotation('line',[center1(i,1) center2(i,1)],[center1(i,2) center2(i,2)],'Color','white','LineWidth',1);
end
% 


function center = visualizecomponent(model, c, nc, k, layer, modelId,PartCorrelations)
%% SECTION TIT
% DESCRIPTIVE TEXT
rhs = model.rules{model.start}(c).rhs;
root = -1;
parts = [];
defs = {};
anchors = {};
% assume the root filter is first on the rhs of the start rules
if model.symbols(rhs(1)).type == 'T'
  % handle case where there's no deformation model for the root
  root = model.symbols(rhs(1)).filter;
else
  % handle case where there is a deformation model for the root
  root = model.symbols(model.rules{rhs(1)}(layer).rhs).filter;
end
for i = 2:length(rhs)
  defs{end+1} = model_get_block(model, model.rules{rhs(i)}(layer).def);
  anchors{end+1} = model.rules{model.start}(c).anchor{i};
  fi = model.symbols(model.rules{rhs(i)}(layer).rhs).filter;
  parts = [parts fi];
end

  numparts = length(parts);
   
  anchors{end+1} = NaN;
  parts(end+1) = NaN;
if modelId == 2
    anchors = anchors(PartCorrelations{1});
    parts = parts(PartCorrelations{1});
end
% make picture of root filter
pad = 5;
bs = 20;
w = foldHOG(model_get_block(model, model.filters(root)));
% w = model_get_block(model, model.filters(root));
scale = max(w(:));

%%% original
im = HOGpicture(w, bs);
im = imresize(im, 2);
oriSize = size(im);
im = padarray(im, [pad pad], 0);
im = uint8(im * (255/scale));


% draw root

 center = zeros(numparts,2);
if numparts > 0
  subaxis(nc,2,modelId+2*(k-1),'SpacingHoriz', 0.03, 'SpacingVert',0, 'Padding', 0, 'Margin', 0);
else
  subaxis(nc,1,k,'SpacingHoriz', 0.03, 'SpacingVert',0, 'Padding', 0, 'Margin', 0);
end
imagesc(im);
colormap gray;
axis equal;
axis off;
freezeColors;

    im1 = im;
    im2 = im;
% draw parts and deformation model
if numparts > 0
  def_im = zeros(size(im));
  def_scale = 500;
  
  for i = 1:numparts
    flag = 0;
    % part filter
    if isnan(parts(i))
       partAssign = parts(end);
       flag = 1;
    else
       partAssign = parts(i);
    end
    w = model_get_block(model, model.filters(partAssign));    
    
    %%% original
    p = HOGpicture(foldHOG(w), bs);
    oriSize = size(p);
    p = padarray(p, [pad pad], 0);
    p = uint8(p * (255/scale));    

    % border original
    % gray scale
    p1 = p;
    p2 = p;
    p1(:,1:2*pad) = 128;
    p1(:,end-2*pad+1:end) = 128;
    p1(1:2*pad,:) = 128;
    p1(end-2*pad+1:end,:) = 128;
    
    % colored
    if flag == 0
        p2(:,1:2*pad) = 100+(i-1)*20;
        p2(:,end-2*pad+1:end) = 100+(i-1)*20;
        p2(1:2*pad,:) = 100+(i-1)*20;
        p2(end-2*pad+1:end,:) = 100+(i-1)*20;
    else
        p2(:,1:2*pad) = 0;
        p2(:,end-2*pad+1:end) = 0;
        p2(1:2*pad,:) = 0;
        p2(end-2*pad+1:end,:) = 0;
    end
    
    % paste into root

    % gray scale
    if isnan(anchors{i})
        anchorAssign = anchors{end};
    else
        anchorAssign = anchors{i};
    end
    x1 = (anchorAssign(1))*bs+1;
    y1 = (anchorAssign(2))*bs+1;
    x2 = x1 + size(p1, 2)-1;
    y2 = y1 + size(p1, 1)-1;
    im1(y1:y2, x1:x2) = p1;
    
    % colored
    x1 = (anchorAssign(1))*bs+1;
    y1 = (anchorAssign(2))*bs+1;
    x2 = x1 + size(p2, 2)-1;
    y2 = y1 + size(p2, 1)-1;
    im2(y1:y2, x1:x2) = p2;
    
    center(i,1) = x1+ floor(size(p2,2)/2) - 1;
    center(i,2) = size(im1,1) - ( y1 + floor(size(p2,1)/2) - 1);

  end

   % plot parts
  cp = subaxis(nc,2,modelId+2*k,'SpacingHoriz', 0.03, 'SpacingVert',0, 'Padding', 0, 'Margin', 0);
  imagesc(im2); 
   
  colormap jet;
  axis equal;
  axis off;
  
  [center(:,1), center(:,2)] = ds2nfu(cp, center(:,1), center(:,2));
end

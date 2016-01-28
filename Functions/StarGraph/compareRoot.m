%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function matches the root filter of two DPMs
% Input :
%       star1, star2 : the root filter of the DPMs
%       delta : the weight between the root appearance and the root aspect
%       ratio
% Output :
%       rootSim : the root similarity
% Author : yi.li@qmul.ac.uk
% Version : 1.0 2014/03/24 started
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rootSim = compareRoot(star1,star2,delta)
addpath('/import/geb-datasets/Yi/Cross-domain/Libs/histogram_distance');
%% obtain the sizes
[h1,w1,~] = size(star1);
[h2,w2,~] = size(star2);

h = min(h1,h2);
w = min(w1,w2);

asp1 = h1/w1;
asp2 = h2/w2;

aspDis = (exp(-(abs(asp1-asp2)*(max(h1,h2)/min(h1,h2)))))/200;

%% scale
star11 = imresize(star1, [h w]);
star22 = imresize(star2, [h w]);

% visualization
% pad = 2;
% bs = 20;
% w = foldHOG(star11);
% scale = max(w(:));
% 
% %%% original
% im = HOGpicture(w, bs);
% im = imresize(im, 2);
% im = padarray(im, [pad pad], 0);
% im = uint8(im * (255/scale));
% 
% figure;
% imshow(im);
% 
% w = foldHOG(star22);
% scale = max(w(:));
% 
% %%% original
% im = HOGpicture(w, bs);
% im = imresize(im, 2);
% im = padarray(im, [pad pad], 0);
% im = uint8(im * (255/scale));
% 
% figure;
% imshow(im);

% dot product
            tempScore = star11.*star22;
            rootSim = sum(tempScore(:));
% euclidean
%             tempScore = norm(part1(:)-part2(:));
% hist intersection
%             tempScore = histogram_intersection(part1(:)',part2(:)');

% delta = 0.3;
% fprintf('rootSim %f, aspect %f\n',rootSim, aspDis);
rootSim = delta * rootSim + (1-delta)* aspDis;
end

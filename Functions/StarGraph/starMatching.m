%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function compares two star graphs extracted from DPM models.
% Input : 
%       star1, star2 : Two star graphs. The star graph is a 1x2 cell array.
%       The first cell is the root filter. The second cell is a Nx2 cell
%       matrix. N is the number of parts. The column 1 is the HOG feature 
%       of one part and the column 2 is the part's location relative to the
%       center.
%       k : the number of neighbors for each part to look at.
%       gamma : the weight between the root and the parts.
%       delta : the weight between the root appearance and the root aspect
%       ratio.
% Output :
%       score : The matching score.
%       correspondence : correspondence of the parts.
% Author :  panly099@gmail.com
% Version : 1.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [score, correspondence] = starMatching(star1, star2, k, gamma, delta)
    %% RRWM Cho et al. ECCV2010
    nMethods = 0;
        nMethods = nMethods + 1;
        methods(nMethods).fhandle = @RRWM;
        methods(nMethods).variable = {'affinityMatrix', 'group1', 'group2'};
        methods(nMethods).param = {};
        methods(nMethods).strName = 'RRWM';
        methods(nMethods).color = 'r';
        methods(nMethods).lineStyle = '-';
        methods(nMethods).marker = 'o';
    
    %% main function
    rootSim = compareRoot(star1{1},star2{1},delta);
    problem = makeStarProblem(star1{2},star2{2},k);
    [~ ,partScore, ~ ,X ,~] = wrapper_GM(methods(1), problem);
    
    score = (1-gamma)*partScore + gamma*rootSim;
    correspondence = zeros(1,size(star1,1));
    
    if partScore ~= 0
        corrRaw = find(X);
        for i = 1 : size(star1{2},1)
            correspondence(i) = rem( corrRaw(i)-1, size(star1{2},1) ) + 1;
        end
    else
        correspondence = (1:8);
    end
end
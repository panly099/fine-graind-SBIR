%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script evaluates the retrieval results based on the ground truth
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
avgRanks = zeros(numCate,1);
avgMeanRanks = zeros(numCate,1);

GTPath = '../Data/Test/ratings/Ratings.mat';
load(GTPath);

topScores = zeros(numCate,1);
topPre = zeros(numCate,1);

for cate = 1 : numCate
    
    cls = categoriesSketch{cate};
    % load ground truth and retrieval results
    
    retrPath = [retrResultFolder,cls,'Result.mat'];
    load(retrPath);
    
    cateRating = rating{cate};
    
    ind = (1:4:20+1);
    view = cateRating(:,ind);
    
    ind = (2:4:20+2);
    conf = cateRating(:,ind);
    
    ind = (3:4:20+3);
    body = cateRating(:,ind);
    
    ind = (4:4:20+4);
    zoom = cateRating(:,ind);
    
    % get Rank
    score = zeros(testSkNum,1);
    precision = zeros(testSkNum,1);
    for s = 4 : 6
        ind = retResult{s,2}(1:top,1);
        ind = cell2mat(ind);
        
        switch aspect
            case 'view'
                skTopRating = view(ind, s);
                totalScore = 2;
            case 'conf'
                skTopRating = conf(ind, s);
                totalScore = 2;
            case 'body'
                skTopRating = body(ind, s);
                totalScore = 2;
            case 'zoom'
                skTopRating = zoom(ind, s);
                totalScore = 2;
            case 'all'
                skTopRating = cateRating(ind, (s-1)*4 + 1 : (s-1)*4 + 4);
                totalScore = 8;
        end
        
        score(s) = sum(skTopRating(:));
        precision(s) = mean (sum(skTopRating,2) / totalScore);
    end
    
    topScores(cate) = sum(score)/testSkNum;
    topPre(cate) = sum(precision)/testSkNum;
end

avgScore = sum(topScores)/numCate;
avgPre = sum(topPre)/numCate;

% output the scores
if ifDisp
    disp('Scores by category');
    for i = 1 : numCate
        fprintf('%.2f    %s\n', topScores(i), categoriesSketch{i});
    end
    
    fprintf('\n');
    fprintf('%.2f    Average score\n\n', avgScore);
end


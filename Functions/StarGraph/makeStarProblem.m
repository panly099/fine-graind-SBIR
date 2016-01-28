%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function initializes the parameters needed for RRWM
% Input :
%       star1, star2 : the star graph to be matched                        
%       k : the number of neighbors to look at            
% Output :
%       problem : the initialized parameters
%       
% Author : panly099@gmail.com                                                        
% Version : 1.0 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function problem = makeStarProblem(star1,star2,k)
    
    nP1 = size( star1, 1);
    nP2 = size( star2, 1);
    
    [nb1,~] = findNeighbor(star1(:,2),star2(:,2),k);
    
    E12 = ones(nP1,nP2);
    [L12(:,1), L12(:,2)] = find(E12);
    [group1, group2] = make_group12(L12);

    %% affinity matrix
    M = zeros(nP1*nP2);
    
    cov = 30^2;
    for i = 1 : nP1*nP2
        for j = 1 : nP1*nP2
            matchi1 = floor((i-1)/nP2) + 1;
            matchi2 = rem(i-1,nP2)+1;
            matchj1 = floor((j-1)/nP2) + 1;
            matchj2 = rem(j-1,nP2)+1;
            
            %  neighborhood checking
            if  (~any(matchi2 == nb1(matchi1,:)) || ~any(matchj2 == nb1(matchj1,:)))...
                     && (matchi1 ~= matchj1 && matchi2 ~= matchj2)
                M(i,j) = 0;
            else
                if matchi1 == matchj1 || matchi2 == matchj2
                    M(i,j) = 0;
                else
                    % geometry       
                    simGeoi = exp(-((star1{matchi1,2}(1) - star2{matchi2,2}(1))^2/cov+(star1{matchi1,2}(2) - star2{matchi2,2}(2))^2/cov));
                    simGeoj = exp(-((star1{matchj1,2}(1) - star2{matchj2,2}(1))^2/cov+(star1{matchj1,2}(2) - star2{matchj2,2}(2))^2/cov));
                    
                    %% appearance
                    simAppi = star1{matchi1,1}.*star2{matchi2,1};
                    simAppi = sum(simAppi(:));
                    simAppj = star1{matchj1,1}.*star2{matchj2,1};
                    simAppj = sum(simAppj(:));
                    
                    M(i,j) = simGeoi*simAppi + simGeoj*simAppj;
                end
            end
        end
    end
   
   M = max(M,0);     
    
    %% Return results
    problem.nP1 = nP1;
    problem.nP2 = nP2;
    problem.E12 = E12;
    problem.L12 = L12;
    problem.affinityMatrix = M;
    problem.group1 = group1;
    problem.group2 = group2;

    problem.GTbool = [];
end

function [neighbor1, neighbor2] = findNeighbor(star1,star2,k)
    star11 = cell2mat(star1);
    star11 = reshape(star11,[2,8])';
    star22 = cell2mat(star2);
    star22 = reshape(star22,[2,8])';
    distMx = pdist2(star11,star22);
    [distSortMx, ix] = sort(distMx,2); 
    neighbor1 = ix(:,1:k);
    
    distMx = pdist2(star22,star11);
    [distSortMx, ix] = sort(distMx,2); 
    neighbor2 = ix(:,1:k);
end

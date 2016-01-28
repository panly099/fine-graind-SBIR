%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function extracts the star graph representation of the mixture of
% components.
% Input : 
%        model : The DPM model.
% Output :
%        starGraph : The extracted star graph of the DPM model. It is 
%        composed of 2 cells. The first cell contains the root firlter. The
%        second cell is a cell array with each cell representing a 
%        component. Inside each cell, it is a Nx2 cell matrix, with the row
%        representing the number of parts, column 1 representing the HOG 
%        feature of the part and column 2 representing the relative 
%        location to the center.
%        
% Aurthor : Yi Li
% Version : 1.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function starGraph = model2star(model)
    %% initialization
    numOfComp = model.numfilters/9;
    numOfParts = 8;
    starGraph = cell( 2, 1 );
    partFilters = cell( numOfParts, 2);
    layer = 1;
    %% render the star graphs
    for i = 1 : numOfComp
        
        rhs = model.rules{model.start}(i).rhs;
        parts = [];
        anchors = {};
        coeff = {};
        % obtain the root filter
        % assume the root filter is first on the rhs of the start rules
        if model.symbols(rhs(1)).type == 'T'
            % handle case where there's no deformation model for the root
            root = model.symbols(rhs(1)).filter;
        else
            % handle case where there is a deformation model for the root
            root = model.symbols(model.rules{rhs(1)}(layer).rhs).filter;
        end
        
        % obtain the part filter
        for j = 2:length(rhs)
            anchors{end+1} = model.rules{model.start}(i).anchor{j};
            fi = model.symbols(model.rules{rhs(j)}(layer).rhs).filter;
           
            parts = [parts fi];
            coeff{end+1} = model.blocks(model.rules{rhs(j)}(layer).def.blocklabel).w;
        end
        
        % obtain the root center
        bs = 20;
        wFull = model_get_block(model, model.filters(root));
        w = foldHOG(model_get_block(model, model.filters(root)));
        im = HOGpicture(w, bs);
        im = imresize(im, 2);
        imSize = size(im);
        center = [floor(imSize(1)/2), floor(imSize(2)/2)];
        disp(center);
        
        starGraph{i}{1} = wFull;
        for j = 1 : numOfParts
            w = model_get_block(model, model.filters(parts(j)));
            
            %%% original
            p = HOGpicture(foldHOG(w), bs);
            
            % obtain the part center
            x1 = (anchors{j}(1))*bs+1;
            y1 = (anchors{j}(2))*bs+1;
            x2 = x1 + floor(size(p, 2)/2)-1;
            y2 = y1 + floor(size(p, 1)/2)-1;
            
            partFilters{j,1} = w;
            partFilters{j,2} = [ y2-center(1), x2-center(2) ];
            partFilters{j,3} = coeff{j};
        end
        starGraph{i}{2} = partFilters;
    end
end
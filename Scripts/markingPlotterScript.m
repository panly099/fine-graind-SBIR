%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script plots the P-R curve
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x = 1:3:60;
n = 60;
lineWidth = 3;
makerWidth = 5;
figure;
hold on;
axis([0 1 0 1])
fontsize = 14;
xlabel('Recall','FontSize', fontsize)
ylabel('Precision','FontSize',fontsize)


switch asp
    case 1
        title('Viewpoint','FontSize', fontsize);
    case 2
        title('Configuration','FontSize', fontsize);
    case 3
        title('Body feature','FontSize', fontsize);
    case 4
        title('Zoom','FontSize', fontsize);
    case 5
        title('4 Criteria','FontSize', fontsize);
end

scores = scores/max(scores);
scores = scores(x);
pres = pres(x);
plot(scores,pres,'-^r','LineWidth',lineWidth);
hold off;



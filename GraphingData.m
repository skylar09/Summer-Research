
close all;

load('a(array).mat');
load('timeA(array).mat');



figure


scatter(timeA, a, 'Marker','o', 'MarkerEdgeColor', 'black', 'MarkerFaceColor', 'cyan');
ylabel('Location of Line Midpoint');
xlabel('Time in Seconds');
title('Location of Line');










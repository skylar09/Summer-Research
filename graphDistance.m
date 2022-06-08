clf;
close all;
clear;

frameSkip = 10;
xCrop = 550;
yCrop = 250;
dxCrop = 800;
dyCrop = 800;

vidIn = VideoReader('withDetection30s.mp4');
%withDetection30s
%noDectetion30sec
%withDetetection30s(2)
%DistPumpHalf
count = 1;
midPointPlot = zeros(1, 1);
timeInFrames = zeros (1, 1);
frames = 0;






% import the video file






for i = 1:frameSkip:vidIn.NumFrames
    if i > vidIn.NumFrames
        break;
    end
    pic = read(vidIn, i);

    %% Line Dectetion

    grayImg = rgb2gray(pic);
    cropImg = imcrop(grayImg, [xCrop, yCrop, dxCrop, dyCrop]); 
    %pause(2);


    %line stuff
    BwLines = edge(cropImg,'sobel');


    %Display the transform, H, returned by the hough function.

    [H,theta,rho] = hough(BwLines);

    %Find the peaks in the Hough transform matrix, H, using the houghpeaks function.
    P = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));

    %Superimpose a plot on the image of the transform that identifies the peaks.
    x = theta(P(:,2));
    y = rho(P(:,1));


    %Find lines in the image using the houghlines function.(mess with)
    lines = houghlines(BwLines,theta,rho,P,'FillGap',100,'MinLength',7);


    max_len = 0;
    for k = 1:length(lines)
        xy = [lines(k).point1; lines(k).point2];



        len = norm(lines(k).point1 - lines(k).point2);
        if ( len > max_len)
            max_len = len;
            xy_long = xy;
        end
    end
    %endpoints of line in cropped image
    start_longLineCrop = [xy_long(1,1),xy_long(1,2)];
    end_longLineCrop = [xy_long(2,1), xy_long(2,2)];

    %endpoints of line in original image
    start_longLineOrigin = [xy_long(1,1)+xCrop, xy_long(1,2)+yCrop];
    end_longLineOrigin = [xy_long(2,1)+xCrop, xy_long(2,2)+yCrop];
    new = [start_longLineOrigin ; end_longLineOrigin];


    %line midpoint
    lineMidPoint = (((start_longLineOrigin(1)+end_longLineOrigin(1))/2));

    midImgX = 1920/2;

%{
    figure('visible','on')
    imshow(pic)
    hold on
    plot(new(:,1), new(:,2), 'LineWidth',2,'Color','red');
    %plotting start and end points on original imagine
    plot(start_longLineOrigin(1), start_longLineOrigin(2), 'x', 'LineWidth', 2,'Color', 'blue');
    plot(end_longLineOrigin(1), end_longLineOrigin(2), 'x', 'LineWidth', 2,'Color','green');



    plot(((start_longLineOrigin(1)+end_longLineOrigin(1))/2), ((start_longLineOrigin(2) + end_longLineOrigin(2))/2), 'x', 'LineWidth', 1, 'Color', 'cyan');

    hold off
%}



    
    midPointPlot(count, 1) = lineMidPoint(1);



    
    timeInFrames(count, 1) = frames;
    count = count + 1;
    frames = frames + frameSkip;

end
%%graph creation

    


%}

figure


scatter(timeInFrames, midPointPlot, 'Marker','o', 'MarkerEdgeColor', 'black', 'MarkerFaceColor', 'cyan');
%yline(midImgX);
ylim([500,1400]);
%yline(midImgX);
ylabel('Location of Line Midpoint');
xlabel('Time in Frames');
title('Location of Line With Tracking');







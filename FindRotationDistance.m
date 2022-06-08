
%% used to find a rotation distance but now that its found not needed

clf;
close all;
clear arduino;
clear servo;
arduino = arduino('COM4', 'Uno');
servo = servo(arduino,'D3');
newPos = 0.36;
writePosition(servo, newPos);

%midpoint of camera

turns = zeros(9,3);


xCrop = 500;
yCrop = 350;

dxCrop = 850;
dyCrop = 400;

%connects webcam to matlab and views video from camera

cam = webcam('NexiGo N60 FHD Webcam');
%'NexiGo N60 FHD Webcam'
%webcam size 1920, 1080
%'HP Wide Vision HD Camera'
%webcam size is 640, 360
preview(cam);
pause(3);
%takes one frame from video as image

closePreview(cam);


for i = 1:9
    close all;
    img = snapshot(cam);
    
    
    
    %saving snapshot as image and viewing that file
    imwrite(img, 'lineImg.jpg');
    screenShot = imread('lineImg.jpg');
    %image(screenShot);
    %video size is 1920x1080
    grayImg = rgb2gray(img);
    
    
    
    
    % imcrop[x, y, dx(width), dy(height)]
    cropImg = imcrop(grayImg, [xCrop, yCrop, dxCrop, dyCrop]); 
    
    
    
    imshow(cropImg);
    %pause(2);
    
    
    %line stuff
    BwLines = edge(cropImg,'sobel');
    imshow(BwLines);
    
    %Display the transform, H, returned by the hough function.
    
    [H,theta,rho] = hough(BwLines);
    figure
    imshow(imadjust(rescale(H)),[],...
           'XData',theta,...
           'YData',rho,...
           'InitialMagnification','fit');
    xlabel('\theta (degrees)')
    ylabel('\rho')
    axis on
    axis normal 
    hold on
    colormap(gca,hot)
    
    %Find the peaks in the Hough transform matrix, H, using the houghpeaks function.
    P = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
    
    %Superimpose a plot on the image of the transform that identifies the peaks.
    x = theta(P(:,2));
    y = rho(P(:,1));
    plot(x,y,'s','color','black');
    
    %Find lines in the image using the houghlines function.(mess with)
    lines = houghlines(BwLines,theta,rho,P,'FillGap',100,'MinLength',7);
    
    
    figure, imshow(cropImg), hold on
    max_len = 0;
    for k = 1:length(lines)
       xy = [lines(k).point1; lines(k).point2];
       % Determine the endpoints of the longest line segment
       len = norm(lines(k).point1 - lines(k).point2);
       if ( len > max_len)
          max_len = len;
          xy_long = xy;
       end
    end
    % highlight the longest line segment
    plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','red');
    %start and end of long line
    plot(xy_long(1,1),xy_long(1,2),'x','LineWidth',2,'Color','blue');
    plot(xy_long(2,1),xy_long(2,2),'x','LineWidth',2,'Color','green');
    %notes: algorithm to find longest line
    
    hold off;
    
    
    start_longLineCrop = [xy_long(1,1),xy_long(1,2)];
    end_longLineCrop = [xy_long(2,1), xy_long(2,2)];
    
    start_longLineOrigin = [xy_long(1,1)+xCrop, xy_long(1,2)+yCrop];
    end_longLineOrigin = [xy_long(2,1)+xCrop, xy_long(2,2)+yCrop];
    new = [start_longLineOrigin ; end_longLineOrigin];
    
    
    figure, imshow(img), hold on
    plot(new(:,1), new(:,2), 'LineWidth',2,'Color','red');
    %plotting start and end points on original imagine
    plot(start_longLineOrigin(1), start_longLineOrigin(2), 'x', 'LineWidth', 2,'Color', 'blue');
    plot(end_longLineOrigin(1), end_longLineOrigin(2), 'x', 'LineWidth', 2,'Color','green');
    
    %midpoint of line
    plot(((start_longLineOrigin(1)+end_longLineOrigin(1))/2), ((start_longLineOrigin(2) + end_longLineOrigin(2))/2), 'x', 'LineWidth', 1, 'Color', 'cyan');
    
    
    
    
    %center of image
    plot((1920/2),(1080/2), 'x', 'LineWidth', 2, 'Color', 'c');
    plot([xCrop ; xCrop+dxCrop], [yCrop ; yCrop], 'LineWidth',1,'Color','black');
    plot([xCrop, xCrop], [yCrop, yCrop+dyCrop], 'LineWidth',1,'Color','black');
    plot([xCrop, xCrop+dxCrop], [yCrop+dyCrop, yCrop+dyCrop], 'LineWidth',1,'Color','black');
    plot([xCrop+dxCrop, xCrop+dxCrop], [yCrop, yCrop+dyCrop], 'LineWidth',1,'Color','black');
    
    
    hold off;
    
    
    midPoint = (start_longLineOrigin(:) + end_longLineOrigin(:)).'/2;
    midImgX = 1920/2;
    
    
    %line midpoint
    turns(i, 1) = ((start_longLineOrigin(1)+end_longLineOrigin(1))/2);
    %image midpoint
    turns(i, 2) = midImgX;
    if i > 1
        turns(i, 3) = turns(i, 1) - turns(i-1, 1);
    end
    
    
    pause(1);
    writePosition(servo, newPos + 0.01);
    newPos = readPosition(servo);
    pause(2)
    %disp(((start_longLineOrigin(1)+end_longLineOrigin(1))/2));
end

close all;
clear arduino;
clear servo;
clearvars
arduino = arduino('COM4', 'Uno');
servo = servo(arduino,'D3');
newPos = 0.43;
writePosition(servo, newPos);

%variables for image cropping
xCrop = 550;
yCrop = 250;
dxCrop = 800;
dyCrop = 800;



%% used to find new rotation distance
% original distance from camera to harvard pump
originDist = 21;
%new distance from camera to harvard pump
newDist = 14.9;

%first rotation distance found
firstRotDist = 45.9625;


%new rotation distance
rotateDist = firstRotDist * (newDist/originDist);
disp(rotateDist);

%smallest degree turn on scale of [0-1]*180 (0-180)
smallestRot = 0.01;
% (0.01*180) = 1.8°




%% Opens webcam

%connects webcam to matlab and views video from camera
cam = webcam('NexiGo N60 FHD Webcam');
%'NexiGo N60 FHD Webcam'
%webcam size 1920, 1080

%'HP Wide Vision HD Camera'
%webcam size is 640, 360

preview(cam);
pause(3);

%%
%takes one frame from video as image
for i = 1:200
    img = snapshot(cam);

    %imshow(img);

    %saving snapshot as image and viewing that file
    imwrite(img, 'lineImg.jpg');
    screenShot = imread('lineImg.jpg');

    %converts img to grayscale
    grayImg = rgb2gray(img);

    % imcrop[x, y, dx(width), dy(height)]
    cropImg = imcrop(grayImg, [xCrop, yCrop, dxCrop, dyCrop]);

    %line stuff
    BwLines = edge(cropImg,'sobel');


    %Display the transform, H, returned by the hough function.

    [H,theta,rho] = hough(BwLines);

    %Find the peaks in the Hough transform matrix, H, using the houghpeaks function.
    P = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));

    %Find lines in the image using the houghlines function.
    lines = houghlines(BwLines,theta,rho,P,'FillGap',100,'MinLength',7);

    % Determine the endpoints of the longest line segment
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





    %midPoint = (start_longLineOrigin(:) + end_longLineOrigin(:)).'/2;
    lineMidPoint = (((start_longLineOrigin(1)+end_longLineOrigin(1))/2));
    midImgX = 1920/2;

    %actual tracking code
    currentPos = readPosition(servo);

    if midImgX > lineMidPoint(1)%if midpoint of the camera > midpoint of line
        diff = (midImgX - lineMidPoint(1));%find the difference between the two
        x1 = (diff / rotateDist); %x1 is the amount of rotations
        turnAmt1 = (x1 * smallestRot);%takes amount of rotations and multiplies by the smallest rotation distance
        writePosition(servo, currentPos + turnAmt1); %updates motor


    elseif midImgX < lineMidPoint(1)
        diff = (lineMidPoint(1) - midImgX);
        x2 = (diff/rotateDist);
        turnAmt2 = (x2 * smallestRot);
        writePosition(servo, currentPos - turnAmt2);


    end

    pause(0.85);




end

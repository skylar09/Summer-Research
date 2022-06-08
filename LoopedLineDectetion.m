clf;
close all;

%cam = webcam('HP Wide Vision HD Camera');
cam = webcam('NexiGo N60 FHD Webcam');
%saving snapshot as image and viewing that file
%imwrite(img, 'lineImg.jpg');
screenShot = imread('lineImg.jpg');
preview(cam);

clear arduino;
clear servo;
arduino = arduino('COM4', 'Uno');
servo = servo(arduino,'D3');

writePosition(servo, 0.4);

xCrop = 650;
yCrop = 350;

dxCrop = 700;
dyCrop = 400;

count = 0;
while count < 20 %midPoint(1) < midImg-10 || midPoint(1) > midImg+10






%takes one frame from video as image
img = snapshot(cam);





%video size is 1920x1080
grayImg = rgb2gray(img);



cropImg = imcrop(grayImg, [xCrop, yCrop, dxCrop, dyCrop]); 


%imshow(grayImg);
%pause(2);
%turnImg = imrotate(grayImg,33,'crop');

%line stuff
BwLines = edge(cropImg,'sobel');
%imshow(BwLines);

%Display the transform, H, returned by the hough function.

[H,theta,rho] = hough(BwLines);

%Find the peaks in the Hough transform matrix, H, using the houghpeaks function.
P = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));

%Superimpose a plot on the image of the transform that identifies the peaks.
x = theta(P(:,2));
y = rho(P(:,1));
%plot(x,y,'s','color','black');

%-----------------------------------------------------------------------
%Find lines in the image using the houghlines function.(mess with)
lines = houghlines(BwLines,theta,rho,P,'FillGap',100,'MinLength',7);


%figure, imshow(cropImg), hold on
max_len = 0;
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
 %  plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

  % Plot beginnings and ends of lines
   %plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','blue');
  % plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','yellow');



   % Determine the endpoints of the longest line segment
   len = norm(lines(k).point1 - lines(k).point2);
   if ( len > max_len)
      max_len = len;
      xy_long = xy;
   end
end

% highlight the longest line segment and its endpoints
%plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','red');

%start and end point of line
start_longLineCrop = [xy_long(1,1),xy_long(1,2)];
end_longLineCrop = [xy_long(2,1), xy_long(2,2)];

start_longLineOrigin = [xy_long(1,1)+xCrop, xy_long(1,2)+yCrop];
end_longLineOrigin = [xy_long(2,1)+xCrop, xy_long(2,2)+yCrop];
new = [start_longLineOrigin ; end_longLineOrigin];

%{
figure, imshow(img), hold on
plot(new(:,1), new(:,2), 'LineWidth',2,'Color','red');
%plotting start and end points on original imagine
plot(start_longLineOrigin(1), start_longLineOrigin(2), 'x', 'LineWidth', 2,'Color', 'blue');
plot(end_longLineOrigin(1), end_longLineOrigin(2), 'x', 'LineWidth', 2,'Color','green');
%}



midPoint = (start_longLineOrigin(:) + end_longLineOrigin(:)).'/2;
midImgX = 1920/2;

startPosition = readPosition(servo);
if midPoint(1) < midImgX
    writePosition(servo, (startPosition + 0.008));
elseif midPoint(1) > midImgX
    writePosition(servo, (startPosition - 0.008));
end

newPos = readPosition(servo);

%tuning the motor
%move closer to machine
%developed different amounts of rotation for distance line distance from 
%setup benchmark

pause(.1);
clf;
close all;
count = count+1;



end





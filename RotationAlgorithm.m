%% similar to Line dectetion except one iteration
clf;
close all;



a = zeros(100,1);

timeA = zeros(100,1);
midImgX = 1920/2;


xCrop = 650;
yCrop = 300;

dxCrop = 500;
dyCrop = 500;

cam = webcam('NexiGo N60 FHD Webcam');

time = 0;
%preview(cam);

for i = 1:+1:100


%takes one frame from video as image
img = snapshot(cam);
%saving snapshot as image and viewing that file
imwrite(img, 'screenshot1.jpg');


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


%Find lines in the image using the houghlines function.(mess with)
lines = houghlines(BwLines,theta,rho,P,'FillGap',100,'MinLength',7);


%figure, imshow(cropImg), hold on
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



%start and end point of line
start_longLineCrop = [xy_long(1,1),xy_long(1,2)];
end_longLineCrop = [xy_long(2,1), xy_long(2,2)];

start_longLineOrigin = [xy_long(1,1)+xCrop, xy_long(1,2)+yCrop];
end_longLineOrigin = [xy_long(2,1)+xCrop, xy_long(2,2)+yCrop];
new = [start_longLineOrigin ; end_longLineOrigin];

midPoint = (start_longLineOrigin(:) + end_longLineOrigin(:)).'/2;



a(i) = midPoint(1);

%pause(0.01);
time = time+0.1;
timeA(i) = time;
end












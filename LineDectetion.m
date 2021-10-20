clf;
close all;
%connects webcam to matlab and views video from camera

cam = webcam('NexiGo N60 FHD Webcam');

preview(cam);
pause(5);
%takes one frame from video as image

closePreview(cam);

img = snapshot(cam);

%imshow(img);

%saving snapshot as image and viewing that file
imwrite(img, 'lineImg.jpg');
screenShot = imread('lineImg.jpg');
%image(screenShot);
%video size is 1920x1080
grayImg = rgb2gray(img);
%crop image to be get rid of extra (mess with numbers)

cropImg = imcrop(grayImg, [600, 150, 600, 500]);
imshow(grayImg);
%pause(2);
%turnImg = imrotate(grayImg,33,'crop');

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
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

   % Plot beginnings and ends of lines
   plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','blue');
   plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','green');


   start_line = [xy(1,1),xy(1,2)];
   end_line = [xy(2,1) xy(2,2)];
   % Determine the endpoints of the longest line segment
   len = norm(lines(k).point1 - lines(k).point2);
   if ( len > max_len)
      max_len = len;
      xy_long = xy;
   end
end
% highlight the longest line segment
plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','red');

%notes: algorithm to find longest line







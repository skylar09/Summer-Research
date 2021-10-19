%connects webcam to matlab and views video from camera

cam = webcam('HP Wide Vision HD Camera');
preview(cam);
pause(5);

%takes one frame from video as image

closePreview(cam);
img = snapshot(cam);
imshow(img);

%saving snapshot as image and viewing that file
imwrite(img, 'me.jpg');
screenShot = imread('me.jpg');

image(screenShot);


clear all

pause('on');
a = arduino('COM3', 'Uno');
s = servo(a,'D9');
writePosition(s,0);
position0 = readPosition(s);

rotate = 0;
for i = 0:+1:5
    writePosition(s, rotate);
    pause(1);
    rotate = rotate+0.2;
end

%{
for angle = 0:0.2:1
    writePosition(s, angle);
    current_pos = readPosition(s);
    current_pos = current_pos*180;
    fprintf('Current motor position is %d degrees\n', current_pos);
    pause(2);
end
%}
for i = 5:-1:0
    rotate = rotate-0.2;
    writePosition(s, rotate);
    pause(1);
end

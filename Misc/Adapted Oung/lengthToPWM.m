function pwm = lengthToPWN(length)
    global rPulley mechRatio servoInc
    pwm = length ./ rPulley ./(2.*pi )*1000; % 1000 us is 360 degreerotation
    pwm = floor(pwm.*mechRatio./servoInc)*servoInc; %round to nearest increment
end
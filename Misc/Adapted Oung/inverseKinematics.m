function jointAng = inverseKinematics(xyz)
  %% inverseKinematics.m
  % Adapted from Stephen Oung's Arduino code. Takes user-defined x, y, and 
  % z coordinates and sees if Inverse Kinematics are possible gven those
  % coordinates

  disp('Inside inverseKinematics.m');
  jAng  = zeros(1,4);
  bestScore = 1080;
    
  jAng(1) = atan2(xyz(2) - offset(2), xyz(1) - offset(1));
  posToBase = sqrt((xyz(1) - a(1)*cos(jAng(1))).^2 + (xyz(2) - a(1)*sin(jAng(1))).^2 + (xyz(3)).^2);  

  if(posToBase > (a(2) + a(3) + a(4)) || jAng(1)<j1Lim(1) || jAng(1)>j1Lim(2))
    disp('Point outside of Workspace');
    jAng(1) = 0;
    jointAng = 'false'; 
  end

  
  for ori = -pi:0.1:pi;

    Dx = xyz(1) + a(4)*cos(jAng(1))*cos(ori);
    Dy = xyz(2) - a(4)*sin(jAng(1))*cos(ori);
    Dz = xyz(3) + a(4)*sin(ori);
    Bx = a(1)*cos(jAng(1)) + offset(1);
    By = -a(1)*sin(jAng(1)) + offset(2);
    Bz = 0 + offset(3);  

    DB = sqrt((Dx-Bx).^2 + (Dy-By).^2 + (Dz-Bz).^2);
    
    if(DB > a(3) + a(2))
      disp('Orientation not possible');
      continue;
    end
    
    jAng(3) = pi - acos((DB*DB - a(3)*a(3) - a(2)*a(2))/(-2*a(3)*a(2)));

    if(jAng(3)<j3Lim(1) || jAng(3)>j3Lim(2))
      disp('Joint 3 Exceeded Limits');
      jAng(3) = 0;
      continue;
    end

    angB = acos((a(3)*a(3) - a(2)*a(2) - DB*DB)/(-2*a(2)*DB));

    %considers difference cases for obtuse and acute angles
    if (Bx < Dx)
        jAng(2) = atan2((Dz-Bz), sqrt((Dx-Bx).^2 + (Dy-By).^2) - angB);
    else
        jAng(2) = pi/2 + angB;
    end
    
    if(jAng(2)<j2Lim(1) || jAng(2)>j2Lim(2))
      disp('Joint 2 Exceeded Limits');
      jAng(2) = 0;
      continue;
    end
      
    %considers difference cases for obtuse and acute angles 
    if (abs(ori) < (pi/2))
        jAng(4) = pi-jAng(2)-jAng(3)+ori;
    else
        jAng(4) = pi-jAng(2)-jAng(3)-ori;
    end
    
    
    if(jAng(4)<j4Lim(1) || jAng(4)>j4Lim(2))
      disp('Joint 4 Exceeded \n');
      jAng(4) = 0;
      continue;
    end
    
      %If the code makes it this far, then the orientation is possible
      %Need to asess the best orientation
      %Given the parameters, 
      %the angle in the piP > DIP
      %the angle in the piP > MCP
     
     score = abs(jAng(4)-jAng(3)) + abs(jAng(3) - jAng(2));

    if (bestScore > score)
      disp('Output Found');
      bestScore = score;
        
      jointAng(1) = jAng(1);
      jointAng(2) = jAng(2);
      jointAng(3) = jAng(3);
      jointAng(4) = jAng(4);
    end
    
  end   
end
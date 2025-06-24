function F= triX(x,L_ear,R_ear,neck,cable,L_dist,R_dist,neck_dist,cable_dist)
F= [((x(1) - L_ear(1))^2 + (x(2)- L_ear(2))^2 + (x(3)- L_ear(3))^2 -(L_dist^2));
    ((x(1) - R_ear(1))^2 + (x(2)- R_ear(2))^2 + (x(3)- R_ear(3))^2 -(R_dist^2));
    ((x(1) - neck(1))^2  + (x(2)- neck(2))^2  + (x(3)- neck(3))^2 -(neck_dist^2));
    ((x(1) - cable(1))^2  + (x(2)- cable(2))^2  + (x(3)- cable(3))^2 -(cable_dist^2))];
end
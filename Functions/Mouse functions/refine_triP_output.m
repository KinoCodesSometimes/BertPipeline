function[refined] = refine_triP_output(mouse3D)
%the fuction takes the 3D output from triP and then applies a correction to
%the last few remaining outliers based on the distance of the snout from
%the ears
frames = size(mouse3D,3);
L_dist = NaN(1,frames);
R_dist = NaN(1,frames);
neck_dist = NaN(1,frames);
cable_dist = NaN(1,frames);
for i_frame = 1:frames
    L_ear = mouse3D(2,:,i_frame);
    R_ear = mouse3D(3,:,i_frame);
    snout = mouse3D(1,:,i_frame);
    neck  = mouse3D(7,:,i_frame);
    cable = mouse3D(6,:,i_frame);
    L_dist(i_frame) = norm(snout-L_ear);
    R_dist(i_frame) = norm(snout-R_ear);
    neck_dist(i_frame) = norm(snout-neck);
    cable_dist(i_frame) = norm(snout-cable);
end

%% define outliers and get median distances
ear_mean = (L_dist + R_dist)/2;
[prct] = prctile(ear_mean,[2 98]);

L_dist_med = median(L_dist);
R_dist_med = median(R_dist);
neck_dist_med = median(neck_dist);
cable_dist_med = median(cable_dist);

%% loop over outlier frames
outliers = find(ear_mean<prct(1) | ear_mean>prct(2));
for i_out = 1:numel(outliers)
    frame = outliers(i_out);    
    L_ear = mouse3D(2,:,frame);
    R_ear = mouse3D(3,:,frame);
    neck  = mouse3D(7,:,frame);
    cable = mouse3D(6,:,frame);
    fun = @(x)triX(x,L_ear,R_ear,neck,cable,L_dist_med,R_dist_med,neck_dist_med,cable_dist_med);
    if (frame-5)>0 && (frame+5)<=frames
        x0 = median(mouse3D(1,:,[frame-5:frame-1 frame+1:frame+5]),3)';
        x = fsolve(fun,x0);
        mouse3D(1,:,outliers(i_out)) = x;
        clear x
    end
end
refined = mouse3D;
end
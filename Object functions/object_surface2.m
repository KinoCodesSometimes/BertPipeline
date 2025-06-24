function [pts3D, pts_base, pts_mid, pts_top] = object_surface2(x3D, object_type)
% Aim: given a set of object landmarks, compute a grid of points over the
% accessible surfaces of the object.
% Current code handles one type of object - this can be generalised in the
% future.
% RSP April 2022
%
% Inputs:
%   x3D - object_coordinates (Nlandmarks,3)
%   object_type
% Outputs:

switch object_type
    case 'half truncated cone'
        % There is a planar face and a curved face.
        % Assumptions about the landmarks...
        % Imagine object is oriented so that you are facing the planar side of the object):
        % i=1,2,3 = plane face: bot left corner, bot mid, bot right corner
        % i=4,5,6 = curved face: bot right/mid, bot mid, bot left/mid
        % i=7,8 = plane face: mid-height left edge, mid-height right edge
        % i=9,10,11 = plane face: top left corner, top mid, top right corner
        % i=12,13,14 = curved face: top right/mid, top mid, top left/mid
        
        % take horizontal sections through base mid and
        % describe the curved part of the top and bottom sections as quadratic Bezier curves.
        
        % Bezier control points for curved face at bottom, mid and top levels:
        % Bottom:
        cpbc = zeros(3);
        cpbc(:,1) = x3D(1,:)';
        cpbc(:,3) = x3D(3,:)';
        cpbc(:,2) = 2*x3D(5,:)' - .5*(cpbc(:,1)+cpbc(:,3));
        % Top:
        cptc = zeros(3);
        cptc(:,1) = x3D(9,:)';
        cptc(:,3) = x3D(11,:)';
        cptc(:,2) = 2*x3D(13,:)' - .5*(cptc(:,1)+cptc(:,3));
        % Middle:
        cpmc = .5*cpbc+.5*cptc;
        % Bezier control points for planar face:
        cpbs = cpbc(:,[1 3]);
        cpts = cptc(:,[1 3]);
        cpms = x3D(7:8,:)';
        % evaluate point along curves for plotting:
        Npts = 50;
        t = linspace(0,1,Npts);
        pts_base = [bezierquad(cpbc,t)'; bezierlin(cpbs,t)'];
        pts_top = [bezierquad(cptc,t)'; bezierlin(cpts,t)'];
        pts_mid = [bezierquad(cpmc,t)';bezierlin(cpms,t)'];
        % define grid over vertical faces of object:
        pts3D = [];
        for i = 1:size(pts_base,1)
            bezcp = [pts_base(i,:)' pts_top(i,:)'];
            pts3D = [pts3D bezierlin(bezcp,t)];
%             plot(pts2D(2,:),pts2D(1,:),'w.')
        end
        clear i
%             pts2D = P{cam}*[pts3D';ones(1,size(pts3D,1))];
%             pts2D = pts2D(1:2,:)./(ones(2,1)*pts2D(3,:));
    otherwise
        error('Unrecognised object type')
end
pts3D = pts3D.';
% figure
% subplot 121
% plot(pts_base(:,1),pts_base(:,2),'k.',pts_mid(:,1),pts_mid(:,2),'r.',pts_top(:,1),pts_top(:,2),'b.')
% axis square
% hold on
% plot(x3D(:,1),x3D(:,2),'ro')
% xlabel('x'), ylabel('y')
% subplot 122
% plot3(pts_base(:,1),pts_base(:,2),pts_base(:,3),'k.',pts_mid(:,1),pts_mid(:,2),pts_mid(:,3),'r.',pts_top(:,1),pts_top(:,2),pts_top(:,3),'b.')
% hold on
% ;
% c = [rand(1, 3)];
% trisurf(boundary(pts3D(:, 1), pts3D(:, 2), pts3D(:, 3)), ...
%     pts3D(:, 1), pts3D(:, 2), pts3D(:, 3), "FaceAlpha", .3, ...
%     "LineStyle", "none", "FaceColor", c)
% plot3(pts_base(:, 1), pts_base(:, 2), pts_base(:, 3), "Color", c, "LineWidth", 2)
% for i = 1:size(pts_base,1)
%     plot3([pts_base(i,1) pts_top(i,1)],[pts_base(i,2) pts_top(i,2)],[pts_base(i,3) pts_top(i,3)],'k-')
% end
% plot3(x3D(:,1),x3D(:,2),x3D(:,3),'ro')
% axis equal
% xlabel('x'), ylabel('y'), zlabel('z')

end

%% subfunctions

function [ B ] = bezierlin(CP,t)
    
N = size(CP,2)-1;
if N~=1
    error('Linear Bezier expected only')
end
Nt = numel(t);
Nc = size(CP,1);

B = (ones(Nc,1)*(1-t)).*(CP(:,1)*ones(1,Nt)) + ...
    (ones(Nc,1)*t).*(CP(:,2)*ones(1,Nt));
end

function [ B ] = bezierquad(CP,t)

N = size(CP,2)-1;
if N~=2
    error('Quadratic Bezier expected only')
end
Nt = numel(t);
Nc = size(CP,1);

B = (ones(Nc,1)*(1-t).^2).*(CP(:,1)*ones(1,Nt)) + ...
    (ones(Nc,1)*2*((1-t).*t)).*(CP(:,2)*ones(1,Nt)) + ...
    (ones(Nc,1)*t.^2).*(CP(:,3)*ones(1,Nt));
end

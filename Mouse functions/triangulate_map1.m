function [x3map,sigma3map] = triangulate_map1(x2,lhood,P,priormiu3cat,priorsigma3cat,options)
% AIM: Given 2D views of landmarks x2 (2,Nlm,Ncam), each with estimated
% likelihood lhood (Nlm,Ncam), with camera matrices P, and prior
% (priormiu3cat, 3Nlm,1), % priorsigma3cat, 3Nlm x 3Nlm),
% estimate (triangulate) the 3D coords of the landmark x3map using my
% maximum a posteriori (MAP) approach. (See notes of 21/7/22 ff).
%
% if prior pmtr inputs are empty, function does ML triangulation instead of MAP.
%
% RSP Aug 2022

% Prelims:
Ncam = numel(P);
[Ndim,Nlm,Ncam2] = size(x2);
if Ndim~=2
    error('Landmarks in x2 must be 2D')
end
if Ncam2~=Ncam
    error('Number of cameras inconsistent between P and x2')
end
[Nlm2,Ncam2] = size(lhood);
if Nlm2~=Nlm
    error('Number of landmarks inconsistent between lhood and x2')
end
if Ncam2~=Ncam
    error('Number of cameras inconsistent between P and lhood')
end
clear Ncam2 Nlm2

% Parameter defaults:
if ~isfield(options,'sigmamin')
    % SD of landmark (in image plane) corresponding to lhood=1
    options.sigmamin = 0.2; % cm
end
alpha = (2*pi)^-.5 / options.sigmamin; % notation of notes 26/7/22
if isempty(priormiu3cat) || isempty(priorsigma3cat)
   options.MAP = false;
%    disp('No priors, so running ML')
else
   options.MAP = true;
%    disp('Priors specified, so running MAP')
end
    
% Calculate camera centres and P+:
camC = zeros(3,Ncam);
Pinv = cell(size(P));
for i = 1:Ncam
    tmp = null(P{i});
    camC(:,i) = tmp(1:3)/tmp(4);
    Pinv{i} = pinv(P{i});
end
clear i tmp

% Calculate pmtrs of the Likelihood P(data_i|x3) miui3, Ci3 for each
% LM, for each camera:
miu3 = zeros(3,Nlm,Ncam);
C3inv = zeros(3,3,Nlm,Ncam);
v = zeros(3,3,Ncam);
lambda = zeros(3,Ncam);

% Calc miu3:
for i = 1:Ncam
    miu2 = x2(:,:,i);
    miu2hom = [miu2;ones(1,Nlm)];
    miu3hom = Pinv{i}*miu2hom;
    miu3(:,:,i) = miu3hom(1:3,:)./(ones(3,1)*miu3hom(4,:));
end
clear Pinv miu2 miu2hom miu3hom

% Calc C3inv:
x3ml = zeros(3,Nlm);
sigma3ml = zeros(3,3,Nlm);
lambda = zeros(3,Ncam);
for j = 1:Nlm
    for i = 1:Ncam
        % Calc C3inv:
        % first, calc ray for miu3 (landmark j, camera i):
        vtmp = miu3(:,j,i) - camC(:,i);
        % calc basis for image plane (axes don't matter since noise assumed isotropic in the plane)
        v(:,:,i) = orth([vtmp'; 1 0 0; 0 1 0]');
        clear vtmp
        % variance of P(data_i|x3) along the ray.  Infinite - arbitrary, large number.
        lambda(1,i) = 20;
        % SD of P(data_i|x3) in the image plane (isotropic)
        % See notes of 26/7/22:
        sigma = (2*pi)^-.5 /(alpha*lhood(j,i));    % assumes lhood is a measure of linear uncertainty
        % variance of P(data_i|x3) in the image plane:
        lambda(2:3,i) = sigma.^2;
%         C3(:,:,i) = v(:,:,i)*diag(lambda(:,i))*v(:,:,i)';
%         C3inv(:,:,i) = inv(C3(:,:,i));
        C3inv(:,:,j,i) = v(:,:,i)*diag([0 1./lambda(2:3,i)'])*v(:,:,i)';   %infinite variance (zero precision) along ray        
    end
    clear i vtmp v lambda sigma
end
clear j

% Catting the likelihood parameters
miu3cat = reshape(miu3,3*Nlm,Ncam);
C3invcat = zeros(3*Nlm,3*Nlm,Ncam);
for i = 1:Ncam
    tmp = cell(1,Nlm);
    for j = 1:Nlm
        tmp{j} = C3inv(:,:,j,i);
    end
    C3invcat(:,:,i) = blkdiag(tmp{:});
end
clear i tmp j

% Use eq2 of 20/7/22 to do ML/MAP triangulation:
if options.MAP
    priorC3invcat = inv(priorsigma3cat);
else
    priorC3invcat = zeros(3*Nlm);
    priormiu3cat = zeros(3*Nlm,1);
end
denom = sum(C3invcat,3) + priorC3invcat;
num = priorC3invcat*priormiu3cat;
for i = 1:Ncam
    num = num + C3invcat(:,:,i)*miu3cat(:,i);
end
clear i
x3mapcat = inv(denom)*num;   % MAP/ML estimate
sigma3mapcat = inv(denom);   % error covariance on x3ml

% DeCat for output:
x3map = reshape(x3mapcat,3,Nlm);
sigma3map = zeros(3,3,Nlm);
for j = 1:Nlm
    sigma3map(:,:,j) = sigma3mapcat((1:3)+3*(j-1),(1:3)+3*(j-1));
end
clear j
% for simplicity, return total error for each landmark:
sigma3map = squeeze(sqrt(sigma3map(1,1,:)+sigma3map(2,2,:)+sigma3map(3,3,:)));


end
function [miu3cat,sigma3cat] = triangulate_prior(x3,options)
%AIM: Given a sample of 3D landmarks x3 (3,Nlm,Nf), 
% estimate their "prior" distribution.
%
% RSP Aug 2022

% Prelims
[Ndim,Nlm,Nf] = size(x3);
if Ndim~=3
    error('Landmarks in x3 must be 3D')
end
% default options
if ~isfield(options,'doplot')
    options.doplot = false;
end

% Cat the vectors
x3cat = reshape(x3,3*Nlm,Nf);

% Basic (naive?) approach:
miu3cat = mean(x3cat')';
sigma3cat = cov(x3cat');

if options.doplot
    figure
    subplot(2,2,1)
    imagesc(sigma3cat), 
    colormap jet 
    colorbar
    title('Cov(x3cat)')
    subplot(2,2,2)
    [vec,val] = eig(sigma3cat);
    plot(diag(val),'.')
    title('Eigenvalue spectrum')
    subplot(2,2,3)
    semilogy(diag(val),'.')
    title('Log eigenvalues')
    subplot(2,2,4)
    plot(vec(:,end))
    title('max eigenvector')
end


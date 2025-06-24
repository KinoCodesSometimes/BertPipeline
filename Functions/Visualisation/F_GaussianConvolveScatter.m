function [PDF_2d, xbins, ybins, PDF_RGB] = F_GaussianConvolveScatter(XY, sd, varargin)
% F_GAUSSIANCONVOLVESCATTER Convolves each point in a scatter with a
% gaussian of sigma sd and generates the PDF of the distribution.


%% Processing the additional arguments
ArgValues = F_VararginSelection(["Mode", "Palette", "NBins"], ...
    {'string', 'matrix', 'double'}, ...
    {["Talk", "Default"], '', ''}, ...
    {"Default", [0, 0, 0], 500}, varargin{:});

% Determining the colormap for the visualisation
    if ArgValues{"Mode"} == "Talk" % BW if not specified for "Talks"
        if size(ArgValues{"Palette"}, 1) ==  1
            ArgValues{"Palette"} = gray;
        end
    else
        if size(ArgValues{"Palette"}, 1) == 1 % If no palette was specified in the default mode use Batlow
            addpath(genpath("C:\Users\JoaquinRusco\Documents\Joaquin -" + ...
                " Local PC\Matlab\AllFunctions"))
            load("batlow.mat")
            ArgValues{"Palette"} = batlow;
        end
    end

bin_size = (max(XY)-min(XY));
xbins = ...
    (min(XY(:, 1))-.2*bin_size(1)): ...
    (bin_size(1)/ArgValues{"NBins"}): ...
    (max(XY(:, 1)+.2*bin_size(1)));
ybins = ...
    (min(XY(:, 2))-.2*bin_size(2)): ...
    (bin_size(2)/ArgValues{"NBins"}): ...
    (max(XY(:, 2)+.2*bin_size(2)));
[n, m] = ndgrid(xbins, ybins);
centres = [m(:),n(:)];


%% Convolving
covmat = eye(2).*sd;
PDF = zeros(size(centres, 1), 1);

wb = waitbar(0, "Generating PDF function");
for i = 1:length(XY)
    waitbar(i/length(XY))
    PDF = PDF + mvnpdf(gpuArray(centres), XY(i, :), covmat);
end
close(wb)

% Reshaping the matrix
PDF_2d = gather(flip(reshape(PDF, length(ybins), []), 1));

% Generate the RGB visualization (adjust scaling)
a = gray2ind(...
    (PDF_2d - min(PDF_2d, [], 'all')) / ...
    (max(PDF_2d, [], 'all') - min(PDF_2d, [], 'all')), 256);

%% Visualising
PDF_RGB = ind2rgb(flip(a.', 2), ArgValues{"Palette"});
image(xbins, ybins, PDF_RGB);  % Plot the colored image with proper axes

% Ensure the y-axis is not flipped
set(gca, 'YDir', 'normal');

% Set axis scaling and ensure the image is not distorted
axis tight;  % Ensure the limits fit the data range

f = gca;
if ArgValues{"Mode"} == "Talk"
    f.FontWeight = 'bold';
    f.LineWidth = 2;
    f.FontSize = 15;
f.FontName = "bahnschrift";
end


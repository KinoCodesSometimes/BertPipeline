load("Rusco.mat");
n = 1000;
a = rand(n, 2);
a(:, 2) = a(:, 2).*5;
F_Scatter(a(:, 1), a(:, 2), "Talk", "XLabel", "X", "YLabel", "Y", "Size", rand(n, 1)*100, "Colour", datasample(Rusco,n,1))
% 
% scatter(a(:, 1), a(:, 2), rand(n, 1)*100, datasample(Rusco,n,1)*1.2 + .1, "filled")
% 
% 
% %% Talk mode
% hold on
% f = gca;
% h = findobj(f, 'Type', 'Scatter');
% %w_scat = scatter(f, h.XData, h.YData, h.SizeData.*1.5, [1, 1, 1], "filled");
% %uistack(w_scat, 'bottom')
% f.Color = 'k';
% f.FontName = "bahnschrift"
% f.YColor = 'w';
% f.XColor = 'w';
% f.FontWeight = 'bold';
% f.FontSize = 15;
% hold off

F_BatchFunMAD(@(x) F_MultiReXGB(x), "D:\Temp\CompleteDays.xlsx")
F_BatchFunMAD(@(x) F_TuneNeurons(x, "XGB_ReShuffled", "Full", 2000), "D:\Temp\CompleteDays.xlsx")

%%
F_BatchFunMAD(@(x) F_ExtractWaveforms(x), "D:\Temp\NC_data.xlsx")
F_BatchFunMAD(@(x) F_ReMotorVars_AND_XGB(x), "D:\Temp\NC_data.xlsx")
%%
Pass = F_BatchFunMAD_Out(@(x) x.Neurons.ROINeurons + x.Neurons.GoodUnits_Phy, 1, "D:\Temp\CompleteDays.xlsx");

PCs = F_BatchFunMAD_Out(@(x) F_RecomputePC_DiffModels(x), 1, "D:\Temp\CompleteDays.xlsx");

%%
%%
%%
Refined = F_BatchFunMAD_Out(@(x) x.Mouse.Refined, 3, "D:\Temp\CompleteDays.xlsx");

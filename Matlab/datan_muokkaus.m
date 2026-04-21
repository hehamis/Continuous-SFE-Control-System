close, clear all;
k = 12; % katkottujen datasettin määrä
folder = "2026_4_16_14_19_27.674 (CEMIS_MESI_paineheittelytesti_ajo_6.)\";
path = "C:\Users\OMISTAJA\Documents\TcXaeShell\TwinCAT Project1\Matlab\";
Dp = [];
Df = [];
Dv = [];
Dt = [];

for j = 1:k
    load(path + folder + "P_data_" + j + ".mat");
    if j == 1
        Dp = P_data;
    else
        P_data = P_data(2:end,1:9);
        Dp = [Dp;P_data];
    end
end
P_data = Dp;
save(path + folder + "P_data.mat");



for j = 1:k
    load(path + folder + "F_data_" + j + ".mat");
    if j == 1
        Df = F_data;
    else
        F_data = F_data(2:end,1:7);
        Df = [Df;F_data];
    end
end
F_data = Df;
save(path + folder + "F_data.mat");


for j = 1:k
    load(path + folder + "Valve_data_" + j + ".mat");
    if j == 1
        Dv = Valve_data;
    else
        Valve_data = Valve_data(2:end,1:8);
        Dv = [Dv;Valve_data];
    end
end
Valve_data = Dv;
save(path + folder + "Valve_data.mat");


for j = 1:k
    load(path + folder + "T_data_" + j + ".mat");
    if j == 1
        Dt = T_data;
    else
        T_data = T_data(2:end,1:9);
        Dt = [Dt;T_data];
    end
end
T_data = Dt;
save(path + folder + "T_data.mat");


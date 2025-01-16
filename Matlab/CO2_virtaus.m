clear; close all;
%% Ajo datan lataus: kopioi ajon päivämäärä ja nimi esim:"2024_11_1_13_17_57.109 (200bar_paprikaajo)" ja 
% liitä alla Matlab\tähän väliin/F_data.mat')
load('C:\Users\OMISTAJA\Documents\TcXaeShell\TwinCAT Project1\Matlab\2024_11_26_10_5_7.751 (Särmäkuisma 1)/F_data.mat')
%% CO2 keskivirtaus ja kokonaiskulutus
ajo = find(F_data(:,1) > 0); %CO2 pumppujen käynnissä olo aika
F = (F_data(ajo(1):ajo(end),1))./100;

k = size(F_data(ajo(1):ajo(end),6));
f = k(:,1);

M = 0;

for i = 1:f-1
    if F_data(i,6) == F_data(i+1,6)
        M = M;
    else
        M = M + 1;
    end
end

plot(F);
CO2keskivirtaus = mean(F);
CO2kokonaiskulutus = CO2keskivirtaus*M;





clear; close all;
%% Ajo datan lataus: kopioi ajon päivämäärä ja nimi esim:"2024_11_1_13_17_57.109 (200bar_paprikaajo)" ja 
kansio = "2026_4_20_12_3_58.489 (200426)"; % liitä ajo kansion nimi tähän Esim. kansio = "2024_11_1_13_17_57.109 (200bar_paprikaajo)")
load("C:\Users\OMISTAJA\Documents\TcXaeShell\TwinCAT Project1\Matlab\" + kansio + "/F_data.mat")
load("C:\Users\OMISTAJA\Documents\TcXaeShell\TwinCAT Project1\Matlab\" + kansio + "/P_data.mat")
%% CO2 keskivirtaus ja kokonaiskulutus
Pst = 400; %paineen asetusarvo
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

pajo = find(P_data(:,2) == Pst);
pajo2 = find(P_data(:,3) == Pst);
P = P_data(pajo2(1):pajo2(end),1:3);
figure(2);
plot(P_data(pajo(1):pajo(end),3)); hold on; plot(P_data(pajo(1):pajo(end),2)); hold off;

PE = ((Pst-P(:,3)).^2).^0.5;
PPmin = min(P(:,3));
PPmax = max(P(:,3));
Pmeanerror = mean(PE);
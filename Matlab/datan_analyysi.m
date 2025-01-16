clear all, close all
%% Datan lataus (muuta päivämäärä ja nimi halutuksi)
load('C:\Users\OMISTAJA\Documents\TcXaeShell\TwinCAT Project1\Matlab\2024_11_19_10_55_41.408 (200bar_paprikaajo_1h_40c_10%pitoisuus)/Valve_data.mat')
load('C:\Users\OMISTAJA\Documents\TcXaeShell\TwinCAT Project1\Matlab\2024_11_19_10_55_41.408 (200bar_paprikaajo_1h_40c_10%pitoisuus)/P_data.mat')
load('C:\Users\OMISTAJA\Documents\TcXaeShell\TwinCAT Project1\Matlab\2024_11_19_10_55_41.408 (200bar_paprikaajo_1h_40c_10%pitoisuus)/F_data.mat')
load('C:\Users\OMISTAJA\Documents\TcXaeShell\TwinCAT Project1\Matlab\2024_11_19_10_55_41.408 (200bar_paprikaajo_1h_40c_10%pitoisuus)/T_data.mat')
Pst = 200; % paineen setpoint
Tst = 40; % lämpötilan setpoint
%% CO2 keskivirtaus ja kokonaiskulutus
ajo = find(F_data(:,1) > 0); %CO2 pumppujen käynnissä olo aika
F = (F_data(ajo(1):ajo(end),1))./100;

jajo1 = find(T_data(:,1) == T_data(:,2)); %jatkuvatoiminen ajo
jajo2 = find(P_data(:,2) == Pst);
jF = (F_data(jajo1(1):jajo2(end),1))./100;
%% Minuuttien lasku CO2 kierrolle ja jatkuvatoimiselle ajolle
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
jk = size(F_data(jajo1(1):jajo2(end),6));
jf = jk(:,1);
jM = 0;
for ji = 1:jf-1
    if F_data(ji,6) == F_data(ji+1,6)
        jM = jM;
    else
        jM = jM + 1;
    end
end
jM = jM; % ekan pumppauksen edeltävä + viimeisen pumppauksen jälkeinen aika.
figure(1);
subplot(2,1,1);
plot(jF);
subplot(2,1,2);
plot(F);
CO2keskivirtaus = mean(F);
CO2kokonaiskulutus = CO2keskivirtaus*M;
jCO2keskivirtaus = mean(jF);
jCO2kokonaiskulutus = jCO2keskivirtaus*jM;

%% paine kuvaaja ja heittely
% p = find(Valve_data(:,2) > 0);
P = P_data(jajo1(1):jajo2(end),1:2);
E = ((Pst-P(:,1)).^2).^0.5;
Pmin = min(P(:,1));
Pmax = max(P(:,1));
meanerror = mean(E);
figure(2);
subplot(2,1,1);% koko ajo
plot(P_data(:,1),'b'); hold on; plot(P_data(:,2),'r'); hold off;
subplot(2,1,2);% jatkuvatoiminen ajo
plot(P(:,1),'b'); hold on; plot(P(:,2),'r'); hold off;

%% reaktorin lämpötila
t = find(T_data(:,2) == Tst);
T = T_data(t(1):t(end),1);
T0 = T - T(1); Tst0 = Tst - T(1); % lämpötilat lähtemään nollasta (ei toimi jos alkulämpötila setpointtia korkeampi)
Rtl = find(T0 == round(Tst0*0.1));
Rtu = find(T0 == round(Tst0*0.9));
Rt = min(Rtu) - min(Rtl); % nousuaika (sec) (ei välttämättä toimi jos aloitus lämpötila liian lähella setpointtia)
Os = max(T) - Tst; % setpointin ylitys (*C)
% c = ;
Tc = max(find(T < Tst*0.632)); % aikavakio (sec)
figure(3);
plot(T_data(:,1),'b'); hold on; plot(T_data(:,2),'r');
clear all, close all
%% Datan lataus (muuta päivämäärä ja nimi halutuksi)
kansio = "2026_4_15_10_42_32.332 (datan_keruun_testi_ajo_13)";
path = "C:\Users\OMISTAJA\Documents\TcXaeShell\TwinCAT Project1\Matlab\";
load(path + kansio + "/Valve_data.mat")
load(path + kansio + "/P_data.mat")
load(path + kansio + "/F_data.mat")
load(path + kansio + "/T_data.mat")
Pst = 200; % paineen setpoint
Tst = 40; % lämpötilan setpoint
syottovali = [6 30]; % ensimmäisen RA syoton intervalli (min s)
% if syottovali(:,2) < 30;
%     syottovali(:,1) = syottovali(:,1);
% else
%     syottovali(:,1) = syottovali(:,1) + 1;
% end
%% CO2 keskivirtaus ja kokonaiskulutus

ajost = find(F_data(:,1) > 0); %CO2 pumput käynnistyy
if P_data(end,2) == 80
    ajosto = find(P_data(:,2) == 80); %CO2 pumput pysähtyy
else
    ajosto = find(P_data(:,2) == Pst); %jos datan keruu pysäytetään ennen pumppujen pysäytystä
end
F = (F_data(ajost(1):ajosto(end),1))./100;
Fm = (F_data(ajost(1):ajosto(end),6));

% jajo1 = find(T_data(:,1) == T_data(:,2)); %jatkuvatoiminen ajo

% jajo1 = find(P_data(:,2) == 160); % käytä ennen 14.10.2025 tehdyissä ajoissa
jajo1 = find(P_data(:,2) == 81); % käytä 14.10.2025 jälkeen tehdyissä ajoissa
jajo2 = find(P_data(:,2) == Pst);
jF = (F_data(jajo1(1):jajo2(end),1))./100;
jFm = F_data(jajo1(1):jajo2(end),6);
%% Minuuttien lasku CO2 kierrolle ja jatkuvatoimiselle ajolle
k = size(Fm);
f = k(:,1);
M = 0;
for i = 1:f-1
    if Fm(i,1) == Fm(i+1,1)
        M = M;
    else
        M = M + 1;
    end
end
jk = size(jFm);
jf = jk(:,1);
jM = 0;
for ji = 1:jf-1
    if jFm(ji,1) == jFm(ji+1,1)
        jM = jM;
    else
        jM = jM + 1;
    end
end
jM = jM + (syottovali(:,1)) + (syottovali(:,2))./60; % ekan pumppauksen edeltävä.
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
% reaktorin paineen heittely
P = P_data(jajo1(1):jajo2(end),1:3); 
RE = ((Pst-P(:,1)).^2).^0.5;
RPmin = min(P(:,1));
RPmax = max(P(:,1));
Rmeanerror = mean(RE);
% pumpun paineen heittely (toimii vain 29.10.2025 jälkeen tehdyille ajoille)
PE = ((Pst-P(:,3)).^2).^0.5;
PPmin = min(P(:,3));
PPmax = max(P(:,3));
Pmeanerror = mean(PE);
figure(2);
% reaktorin paine
subplot(2,2,1);% koko ajo
plot(P_data(:,1),'b'); hold on; plot(P_data(:,2),'r'); hold off; title('reaktori: koko ajo');
subplot(2,2,3);% jatkuvatoiminen ajo
plot(P(:,1),'b'); hold on; plot(P(:,2),'r'); hold off; title('reaktori: jatk. ajo');
% pumppujen paine
% toimii vain 29.10.2025 jälkeen tehdyille ajoille
subplot(2,2,2);% koko ajo
plot(P_data(:,3),'b'); hold on; plot(P_data(:,2),'r'); hold off; title('pumppu: koko ajo');
subplot(2,2,4);% jatkuvatoiminen ajo
plot(P(:,3),'b'); hold on; plot(P(:,2),'r'); hold off; title('pumppu: jatk. ajo');

%% reaktorin lämpötila
t = find(T_data(:,2) == Tst);
T = T_data(t(1):t(end),1);
TO = T_data(t(1),1); % Alku lämpötila
Tmax = max(T_data(t(1):t(end),1)); % Lämpötila maksimi
T0 = T - T(1); Tst0 = Tst - T(1); % lämpötilat lähtemään nollasta (ei toimi jos alkulämpötila setpointtia korkeampi)
Rtl = find(T0 == round(Tst0*0.1));
Rtu = find(T0 == round(Tst0*0.9));
Rt = min(Rtu) - min(Rtl); % nousuaika (sec) (ei välttämättä toimi jos aloitus lämpötila liian lähella setpointtia)
Os = max(T) - Tst; % setpointin ylitys (*C)
keskilampotila = mean(T);
Tc = max(find(T < Tst*0.632)); % aikavakio (sec)
figure(3);
plot(T_data(:,1),'b'); hold on; plot(T_data(:,2),'r');
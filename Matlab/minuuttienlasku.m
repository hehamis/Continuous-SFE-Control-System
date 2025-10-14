
%% CO2 keskivirtaus ja kokonaiskulutus
ajo = find(F_data(:,1) > 0); %CO2 pumppujen käynnissä olo aika
F = (F_data(ajo(1):ajo(end),1))./100;

jajo = find(Valve_data(:,1) > 0); %raaka-aine pumpun käynnissä olo aika
jF = (F_data(jajo(1):jajo(end),1))./100;
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

jk = size(F_data(jajo(1):jajo(end),6));
jf = jk(:,1);

jM = 0;

for ji = 1:jf-1
    if F_data(ji,6) == F_data(ji+1,6)
        jM = jM;
    else
        jM = jM + 1;
    end
end



figure(1);
subplot(2,1,1);
plot(jF);
subplot(2,1,2);
plot(F);
CO2keskivirtaus = mean(F);
CO2kokonaiskulutus = CO2keskivirtaus*M;

jCO2keskivirtaus = mean(jF);
jCO2kokonaiskulutus = jCO2keskivirtaus*jM;

figure(2);
subplot(2,1,1);
plot(P_data(jajo(1):jajo(end),1)); hold on; plot(P_data(jajo(1):jajo(end),2)); hold off;
subplot(2,1,2);
plot(P_data(ajo(1):ajo(end),1)); hold on; plot(P_data(ajo(1):ajo(end),2)); hold off;


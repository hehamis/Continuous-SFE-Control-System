close, clear all;
load('C:\Users\OMISTAJA\Documents\TcXaeShell\TwinCAT Project1\Matlab\2024_11_26_10_5_7.751 (Särmäkuisma 1)/F_data.mat')
e = [];
k = size(F_data(:,7));
f = k(:,1);

for i = 0:f-2
    e(i+1,1) = F_data(i+2,7) - F_data(i+1,7);
end

E = abs(e);
h = find(E(:,1) < 10); % ignooraa 59 - 0
E = E(h,1);
maxE = max(E);
minE = min(E);
keskE = mean(E);
E = E-1;

k = size(E);
f = k(:,1);
d = [];

for j = 1:f-1
    d(1) = E(j);
    d(j+1) = d(j) + E(j+1);
end

k = size(F_data(:,6));
f = k(:,1);
Ajoaika = 0; % minuutteina

for l = 1:f-1
    if F_data(l,6) == F_data(l+1,6)
        Ajoaika = Ajoaika;
    else
        Ajoaika = Ajoaika + 1;
    end
end

hukattu_aika = (Ajoaika*60 - f)/60;
hukattu_aika_prosentteina = hukattu_aika / Ajoaika;

plot(E);
figure(2);
plot(d);




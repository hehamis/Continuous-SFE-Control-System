clear; clc; close all; warning('off');
% https://se.mathworks.com/matlabcentral/answers/217553-connect-matlab-twincat-trough-ads-dll-via-ethernet
%% Read ADS symbols from PLC
asm = NET.addAssembly('C:\TwinCAT\AdsApi\.NET\v4.0.30319\TwinCAT.Ads.dll');
import TwinCAT.Ads.*;
adsClt=TwinCAT.Ads.TcAdsClient;
adsClt.Connect('5.86.83.4.1.1',851); %('10.98.76.62.1.1',851);
matlabStartingSymbol = adsClt.ReadSymbolInfo('MATLAB.bMatlabStarting'); 
matlabRunningSymbol = adsClt.ReadSymbolInfo('MATLAB.bMatlabRunning');
stopMatlabSymbol = adsClt.ReadSymbolInfo('MATLAB.bStopMatlab');
stopMatlab = adsClt.ReadSymbol(stopMatlabSymbol); 
adsClt.WriteAny(matlabStartingSymbol.IndexGroup,matlabStartingSymbol.IndexOffset,true);
adsClt.WriteAny(matlabRunningSymbol.IndexGroup,matlabRunningSymbol.IndexOffset,true);

%% Log the starting time
disp('Logged starting time');
format shortg;
starttime = clock;
starthr = starttime(4);
startmin = starttime(5);
startsec = starttime(6);
timetitle = ['Starting time: ',...
    num2str(starthr),':',num2str(startmin),':',num2str(startsec)]; % Starting time title for plotting
format;

%% Initialize value vectors
n = 0; saveround = 0; % Iteration round variable
pvalues = []; currenttime = []; tvalues = [];  % NÄIHIN OIKEAT NIMER
foldername = ([num2str(starttime(1)),'_',num2str(starttime(2)),'_',...
    num2str(starttime(3)),'_',num2str(starthr),'_',num2str(startmin),'_',...
    num2str(startsec)]); % Foldername (date_time) for saving measured values
mkdir(fullfile(foldername)) % Make new folder under new name
currentFolder = fullfile(foldername); 
figure(1); hold on;
sgtitle(timetitle);
cd(currentFolder);
save("Starting_time","starttime")
cd('C:\Users\OMISTAJA\Documents\TcXaeShell\TwinCAT Project1\Matlab') % TÄHÄN OIKEA POLKU

%% Start continuously running program
disp('MATLAB started')
start = true;
outvalues = [];
a = 0;
n = 1;
started = false;
figure(1); hold on;
while stopMatlab ~= true
    stopMatlab = adsClt.ReadSymbol(stopMatlabSymbol);
    while started == false
        %% Connect to OPC-UA server
        disp('Connecting to OPC-UA server...')
        uaClient = opcua('169.254.172.138',4840);
        connect(uaClient);
        namespace = getNamespace(uaClient);
        allvar = getAllChildren(namespace(3));
        started = true;
    end
    disp('Starting data saving and plotting...')
    while started && stopMatlab ~= true
        %% Get timestamp from current time
        n = n + 1; % current iteration round
        round(n) = n; % Iteration rounds collected in an array (for plotting)
        timestamp = clock;
        %timestampmat(n,:) = num2str([round(timestamp(4),3,'significant') round(timestamp(5),3,'significant') round(timestamp(6),3,'significant')]);
        timestampmat(n,:) = [timestamp(4) timestamp(5) timestamp(6)]
        round(n) = n;
        %% Read symbols cyclically
        stopMatlab = adsClt.ReadSymbol(stopMatlabSymbol);
        %% Read measurement values
        iReactorTy =  findNodeByName(allvar,'iReactorTy','-once');% Reactor temperature value
        bReactorTu = findNodeByName(allvar,'bReactorTu','-once'); % Reactor temperature Contactor
        iReactorPy = findNodeByName(allvar,'iPressureScaledValue','-once'); % Reactor pressure

        %% Save and plot data
        % Reactor temperature
        tdata(n) = readValue(uaClient,iReactorTy)./10;
        tvalues(n) = double(tdata(:,n));
        T_data(n,:) = [tvalues(n) timestamp];
        subplot(2,1,1);
        plot(round,tvalues,"b-");
        xlabel("Second out of passing minute (s)"); ylabel("Reactor temperature (*C)");
        set(gca,"xticklabel",timestamp(:,6));

        % Reactor pressure 
        %pdata(n) = read(iReactorTy); % TÄHÄN OIKEA MUUTTUJA 
        pdata(n) = readValue(uaClient,iReactorPy);
        pvalues(n) = double(pdata(:,n));
        P_data(n,:) = [pvalues(n) timestamp];
        subplot(2,1,2);
        plot(round,pvalues,"b-");
        xlabel("Second out of passing minute (s)"); ylabel("Reactor pressure (bar)");
        set(gca,"xticklabel",timestamp(:,6));

        %% Save data every 30s
        saveround = saveround + 1; 
        if saveround ==  5
            cd(currentFolder); % Make new folder current
            save("T_data","T_data")
            save("P_data", "P_data")
            save("Total_runtime_(s)","n")
            save("Timestamps", "timestampmat")
            saveround = 0;
            cd('C:\Users\OMISTAJA\Documents\TcXaeShell\TwinCAT Project1\Matlab')
        end        
        pause(1);
    end
end
adsClt.WriteAny(matlabRunningSymbol.IndexGroup,matlabRunningSymbol.IndexOffset,false);
% % Plotting test 
% a = a + 1;
% outvalues(n) = a;
% asd = plot(outvalues,1:size(outvalues,2));
% if start == true
%     disp('Press ctrl+C to quit')
%     start = false;
% end
% n = n + 1;
% pause(1);

clear; clc; close all; warning('off');
% https://se.mathworks.com/matlabcentral/answers/217553-connect-matlab-twincat-trough-ads-dll-via-ethernet
%% Read ADS symbols from PLC
asm = NET.addAssembly('C:\TwinCAT\AdsApi\.NET\v4.0.30319\TwinCAT.Ads.dll');
import TwinCAT.Ads.*;
adsClt=TwinCAT.Ads.TcAdsClient;
adsClt.Connect('192.168.0.5.1.1',851); %('192.168.0.5.1.1',851); %('10.98.76.62.1.1',851);

matlabStartingSymbol = adsClt.ReadSymbolInfo('RunMATLAB.bMatlabStarting'); 
matlabRunningSymbol = adsClt.ReadSymbolInfo('RunMATLAB.bMatlabRunning');
stopMatlabSymbol = adsClt.ReadSymbolInfo('RunMATLAB.bStopMatlab');
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
% pvalues = []; currenttime = []; tvalues = [];  % NÄIHIN OIKEAT NIMER
% foldername = ([num2str(starttime(1)),'_',num2str(starttime(2)),'_',...
%     num2str(starttime(3)),'_',num2str(starthr),'_',num2str(startmin),'_',...
%     num2str(startsec)]); % Foldername (date_time) for saving measured values
% mkdir(fullfile(foldername)) % Make new folder under new name
% currentFolder = fullfile(foldername); 
% figure(1); hold on;
% sgtitle(timetitle);
% cd(currentFolder);
% save("Starting_time","starttime")
% cd('C:\Users\OMISTAJA\Desktop\SFE_ident_data') % TÄHÄN OIKEA POLKU

%% Start continuously running program
disp('MATLAB started')
start = true;
outvalues = [];
a = 0;
n = 1;
heartBeatCounter = 0;
started = false;
figure(1); hold on;
while stopMatlab ~= true
    stopMatlab = adsClt.ReadSymbol(stopMatlabSymbol);
    while started == false
        %% Connect to OPC-UA server
        disp('Connecting to OPC-UA server...')
        % uaClient = opcua('169.254.172.138',4840);
        % connect(uaClient);
        % namespace = getNamespace(uaClient);
        % allvar = getAllChildren(namespace(3));
        started = true;
    end
    disp('Starting data saving and plotting...')
    while started && stopMatlab ~= true
        %% Read symbols cyclically
        disp('Starting data saving and plotting...')
        stopMatlab = adsClt.ReadSymbol(stopMatlabSymbol);

        matlabHeartBeatSymbol = adsClt.ReadSymbolInfo('RunMATLAB.HeartBeatSwitch'); % LISÄTTY
        matlabHeartBeat = adsClt.ReadSymbol(matlabHeartBeatSymbol );  % LISÄTTY
        adsClt.WriteAny(matlabHeartBeatSymbol.IndexGroup,matlabHeartBeatSymbol.IndexOffset,~matlabHeartBeat); % LISÄTTY

        % % %% Read measurement values
        % % % Temperature 
        % % spT = double(readValue(uaClient,iTemperatureSetpoint));
        % % yT = double(readValue(uaClient,iInput))./10;
        % % uT = double(readValue(uaClient,bReactorTu));
        % % TempCon = double(readValue(uaClient,bTemperatureControlSwitch));
        % % % Temperature PID controller parameters
        % % PB = double(readValue(uaClient,iProportionalBand));
        % % Ti = double(readValue(uaClient,iIntegralTime));
        % % Td = double(readValue(uaClient,iDerivativeTime));
        % % bias = double(readValue(uaClient,iBias));
        % % iterationtime = double(readValue(uaClient,iCycleTime)); % Cycle time
        % % %disp(['Temperature: ' , num2str(yT)])
        % % % Level
        % % yH = double(readValue(uaClient,bReactorHy));
        % % yL = double(readValue(uaClient,bReactorLy));
        % % uL = double(readValue(uaClient,bReactorLu));
        % % LevelCon = double(readValue(uaClient,bLevelControlSwitch ));
        % 
        % %% Save and plot data
        % % Reactor pressure
        % pdata(n) = read(P_CO2); % TÄHÄN OIKEA MUUTTUJA
        % pvalues(n) = pdata(n).Value;
        % P_data(n,:) = [pvalues(n) timestamp];
        % subplot(4,2,1);
        % plot(round,pvalues,"b-");
        % xlabel("Second out of passing minute (s)"); ylabel("Reactor pressure (bar)");
        % set(gca,"xticklabel",timestamp(:,6));
        % % Reactor temperature

        % Plotting test 
        a = a + 1;
        outvalues(n) = a;
        asd = plot(outvalues,1:size(outvalues,2));
        if start == true
            disp('Press ctrl+C to quit')
            start = false;
        end
        n = n + 1;
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

clear; clc; close all; warning('off');
% https://se.mathworks.com/matlabcentral/answers/217553-connect-matlab-twincat-trough-ads-dll-via-ethernet
%% Read ADS symbols from PLC
asm = NET.addAssembly('C:\TwinCAT\AdsApi\.NET\v4.0.30319\TwinCAT.Ads.dll');
import TwinCAT.Ads.*;
adsClt=TwinCAT.Ads.TcAdsClient;
adsClt.Connect('5.86.83.4.1.1',851); %('10.98.76.62.1.1',851);
matlabStartingSymbol = adsClt.ReadSymbolInfo('RunMATLAB.bMatlabStarting'); 
matlabRunningSymbol = adsClt.ReadSymbolInfo('RunMATLAB.bMatlabRunning');
stopMatlabSymbol = adsClt.ReadSymbolInfo('RunMATLAB.bStopMatlab');
stopMatlab = adsClt.ReadSymbol(stopMatlabSymbol); 
adsClt.WriteAny(matlabStartingSymbol.IndexGroup,matlabStartingSymbol.IndexOffset,true);
adsClt.WriteAny(matlabRunningSymbol.IndexGroup,matlabRunningSymbol.IndexOffset,true);

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
        %% Connect to OPC-UA server
        disp('Connecting to OPC-UA server...')
        uaClient = opcua('169.254.172.138',4840);
        connect(uaClient);
        namespace = getNamespace(uaClient);
        allvar = getAllChildren(namespace(3));
        started = true;
        %% Initialize value vectors
        n = 0; saveround = 0; % Iteration round variable
        pvalues = []; currenttime = []; tvalues = [];  % NÄIHIN OIKEAT NIMER
        foldername = ([num2str(starttime(1)),'_',num2str(starttime(2)),'_',...
            num2str(starttime(3)),'_',num2str(starthr),'_',num2str(startmin),'_',...
            num2str(startsec)]); % Foldername (date_time) for saving measured values
        programNamePrefix =  findNodeByName(allvar,'OPC_ProgramNamePrefix','-once'); % Get program name prefix from plc
        prefix = readValue(uaClient,programNamePrefix);
        foldername = append(foldername," (", convertCharsToStrings(prefix), ")");
        mkdir(fullfile(foldername)) % Make new folder under new name
        currentFolder = fullfile(foldername); 
        figure(1); hold on;
        sgtitle(timetitle);
        cd(currentFolder);
        save("Starting_time","starttime")
        cd('C:\Users\OMISTAJA\Documents\TcXaeShell\TwinCAT Project1\Matlab') % TÄHÄN OIKEA POLKU

    end
    disp('Starting data saving and plotting...')
    while started && stopMatlab ~= true
        %% Monitor stop command from PLC and update hearbeat
        stopMatlab = adsClt.ReadSymbol(stopMatlabSymbol);
        matlabHeartBeatSymbol = adsClt.ReadSymbolInfo('RunMATLAB.HeartBeatSwitch'); % LISÄTTY
        matlabHeartBeat = adsClt.ReadSymbol(matlabHeartBeatSymbol );  % LISÄTTY
        adsClt.WriteAny(matlabHeartBeatSymbol.IndexGroup,matlabHeartBeatSymbol.IndexOffset,~matlabHeartBeat); % LISÄTTY

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
        iReactorTy =  findNodeByName(allvar,'OPC_ReactorTemperature','-once');% Reactor temperature value
        iReactorTsp = findNodeByName(allvar,'OPC_ReactorTemperatureSetpoint','-once'); 
        bReactorTu = findNodeByName(allvar,'OPC_TemperatureContactor','-once'); % Reactor temperature Contactor
        iReactorPy = findNodeByName(allvar,'OPC_ReactorPressure','-once'); % Reactor pressure
        bSlurryInlet = findNodeByName(allvar,'OPC_SlurryInletValve','-once');
        bSlurryOutlet = findNodeByName(allvar,'OPC_SlurryOutletValve','-once');
        iPumpingPressureSetpoint = findNodeByName(allvar,'OPC_PumpingPressureSetpoint','-once');
        iPreHeaterTemperature = findNodeByName(allvar,'OPC_PreHeaterTemperature','-once');
        iPreHeaterTemperatureSetpoint = findNodeByName(allvar,'OPC_PreHeaterTemperatureSetpoint','-once');
        iSeparatorTemperature = findNodeByName(allvar,'OPC_SeparatorTemperature','-once');
        iSeparatorTemperatureSetpoint = findNodeByName(allvar,'OPC_SeparatorTemperatureSetpoint','-once');
        iCO2VolumetricFlow = findNodeByName(allvar,'OPC_CO2VolumetricFlow','-once');

        %% Save and plot data
        %Slurry valves
        outletdata(n) = readValue(uaClient,bSlurryOutlet);
        inletdata(n) = readValue(uaClient,bSlurryInlet);
        outletvalues(n) = double(outletdata(:,n));
        inletvalues(n) = double(inletdata(:,n));
        Valve_data(n,:) = [outletvalues(n) inletvalues(n) timestamp];    

        % Reactor temperature
        tdata(n) = readValue(uaClient,iReactorTy)./10;
        tspdata(n) = readValue(uaClient, iReactorTsp);
        tudata(n) = readValue(uaClient, bReactorTu);
        tvalues(n) = double(tdata(:,n));
        tspvalues(n) = double(tspdata(:,n));
        tuvalues(n) = double(tudata(:,n));
        T_data(n,:) = [tvalues(n) tspvalues(n) tuvalues(n) timestamp];
        subplot(2,2,1);
        plot(round,tvalues,"b-");
        hold on;
        plot(round,tspvalues,"r-");
        xlabel("Second out of passing minute (s)"); ylabel("Reactor temperature (*C)");
        set(gca,"xticklabel",timestamp(:,6));
        hold off;

         % CO2 preheater temperature
        pretdata(n) = readValue(uaClient,iPreHeaterTemperature);
        pretspdata(n) = readValue(uaClient, iPreHeaterTemperatureSetpoint);
        pretvalues(n) = double(pretdata(:,n));
        pretspvalues(n) = double(pretspdata(:,n));
        TCO2_data(n,:) = [pretvalues(n) pretspvalues(n) timestamp];

        % Separator temperature
        stdata(n) = readValue(uaClient,iSeparatorTemperature);
        stspdata(n) = readValue(uaClient, iSeparatorTemperatureSetpoint);
        stvalues(n) = double(stdata(:,n));
        stspvalues(n) = double(stspdata(:,n));
        TS_data(n,:) = [stvalues(n) stspvalues(n) timestamp];
        subplot(2,2,2);
        plot(round,stvalues,"b-");
        hold on;
        plot(round,stspvalues,"r-");
        xlabel("Second out of passing minute (s)"); ylabel("Separator temperature (*C)");
        set(gca,"xticklabel",timestamp(:,6));
        hold off;

        % Reactor pressure 
        %pdata(n) = read(iReactorTy); % TÄHÄN OIKEA MUUTTUJA 
        pdata(n) = readValue(uaClient,iReactorPy);
        disp(readValue(uaClient,iReactorPy))
        pspdata(n) = readValue(uaClient,iPumpingPressureSetpoint); 
        pvalues(n) = double(pdata(:,n));
        pspvalues(n) = double(pspdata(:,n));
        P_data(n,:) = [pvalues(n) pspvalues(n) timestamp];
        subplot(2,2,3);
        plot(round,pvalues,"b-");
        hold on;
        plot(round,pspvalues,"r-");
        xlabel("Second out of passing minute (s)"); ylabel("Reactor pressure (bar)");
        set(gca,"xticklabel",timestamp(:,6));
 
        % CO2 flow
        %pdata(n) = read(iReactorTy); % TÄHÄN OIKEA MUUTTUJA 
        fdata(n) = readValue(uaClient,iCO2VolumetricFlow);
        fvalues(n) = double(fdata(:,n));
        F_data(n,:) = [fvalues(n) timestamp];
        subplot(2,2,4);
        plot(round,fvalues,"b-");
        xlabel("Second out of passing minute (s)"); ylabel("CO2 volumetric flow (cl/min)");
        set(gca,"xticklabel",timestamp(:,6));


        %% Save data every 30s
        saveround = saveround + 1; 
        if saveround ==  30
            cd(currentFolder); % Make new folder current
            save("T_data","T_data")
            save("TCO2_data","TCO2_data")
            save("TS_data","TS_data")
            save("P_data", "P_data")
            save("F_data", "F_data")
            save("Valve_data","Valve_data")
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

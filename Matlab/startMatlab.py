import matlab.engine
import time
import sys
#import pyads
import traceback
import logging

def startMatlab():
    while True:
        try:
            # Connect to plc and open connection
            #print("asd1")
            #plc = pyads.Connection('5.86.83.4.1.1',pyads.PORT_TC3PLC1)
            
            #plc.open()  
            
            # Start MATLAB engine
            eng = matlab.engine.start_matlab()
            eng.cd('C:/Users/OMISTAJA/Documents/TcXaeShell/TwinCAT Project1/Matlab', nargout=0)
            eng.startDataAcquisition(nargout=0)
            
            # Quit if MATLAB exits
            print("Quitting...")
            #time.sleep(1)
            #plc.write_by_name("MATLAB.bMatlabRunning", False)
            sys.exit(0);        
            
        except KeyboardInterrupt:
            print("Quitting...")
            #time.sleep(1)
            #plc.write_by_name("MATLAB.bMatlabRunning", False)
            sys.exit(0)        
        # except Exception as e:
            #if eng != []:
            #    eng.quit()
            # print("asd")
            # print("Quitting...")
            #time.sleep(1)
            # plc.write_by_name("MATLAB.bMatlabRunning", False)
            # sys.exit(0)

if __name__ == '__main__':
    while True:
        try:
            print("Starting MATLAB...")
            #time.sleep(1)
            break
        except KeyboardInterrupt:
            print("Quitting...")
            #time.sleep(1)
            sys.exit(0)
    startMatlab()

function toggleAKD(driveInput,AKDDrive)
%TOGGLEAKD toggles the software switch of the AKD drive to enabled/disabled
% toggleAKD(driveInput,AKDDrive) sends a command to the AKD drive to toggle
% the software state either to be enabled or disabled.
% 
% toggleAKD(1,AKDDrive) toggles the drive to enabled state
% toggleAKD(0,AKDDrive) toggles the drive to disabled state
%
% See also setMotionAKD, moveAKD

% Copyright (c) 2015, Erwin Hamminga and The University of Adelaide

% Thanks Kees Stroeken, author of ModBusYaskawa
% <http://www.mathworks.com/matlabcentral/fileexchange/44662>
% for the inspiration to construct this function.

tcpip_pipe=AKDDrive;

%% verify current state or enable
% define message values
transID = uint16(1);    % 16b Transaction Identifier 
ProtID = uint16(0);     % 16-bit Protocol ID (0 for ModBus) 
nBytes = uint16(6);     % 16-bit Number of 8-bit blocks of data to be sent (6) 
UnitID = uint8(0);      % 8-bit Unit ID (0) unit identifier (previous ‘device address’). The device is accessed directly via IP address, therefore this parameter
                        % has no function and may be set to 0xFF. Exception: If the communication is performed via gateway the device
                        % address must be set as before. 
FunCod = uint8(3);      % 8-bit Function code: read (3) 
Index = uint16(220);    % 16-bit Start address of the register (588) 
nRegisters = uint16(2); % 16-bit Number of registers (4)

% transfer actual message (order is important)
fwrite(tcpip_pipe, transID,'int16');
fwrite(tcpip_pipe, ProtID,'int16');
fwrite(tcpip_pipe, nBytes,'int16');
fwrite(tcpip_pipe, UnitID,'int8');
fwrite(tcpip_pipe, FunCod,'int8');
fwrite(tcpip_pipe, Index,'int16');
fwrite(tcpip_pipe, nRegisters,'int16');

while ~tcpip_pipe.BytesAvailable,end
tcpip_pipe.BytesAvailable;
drvMotionstat=uint8(fread(tcpip_pipe,tcpip_pipe.BytesAvailable)); %the result is produced in 8 bit integers, hence the "uint8"
%posRaw2=int8(fread(tcpip_pipe,tcpip_pipe.BytesAvailable));
% a pair of 8-bit integers needs to be combined into one 16-bit integer.
% This is done using typecast. The Swapbytes function is used to format 
% the output from little-endian to big-endian.
% driveStatus=typecast(drvMotionstat(length(drvMotionstat)-(length(drvMotionstat)-1):length(drvMotionstat)),'int32');
driveStatus=typecast(drvMotionstat(length(drvMotionstat)),'int8');
if driveStatus==0
    disp('Drive is currently disabled');
    if driveInput==1            % Enable the drive
        disp('Enabling drive');
        transID = uint16(transID+1);    % 16b Transaction Identifier 
        nBytes = uint16(11);     % 16-bit Number of 8-bit blocks of data to be sent (6) 
        FunCod = uint8(16);      % 8-bit Function code: read (3) or write (16) 
        Index = uint16(254);    % 16-bit Start address of the register (588) 
        nRegisters = uint16(2); % 16-bit Number of registers (4)
        DataSize = int8(4);
        DRV.EN = uint32(1); %software enable

        % transfer actual message (order is important)
        fwrite(tcpip_pipe, transID,'int16');
        fwrite(tcpip_pipe, ProtID,'int16');
        fwrite(tcpip_pipe, nBytes,'int16');
        fwrite(tcpip_pipe, UnitID,'int8');
        fwrite(tcpip_pipe, FunCod,'int8');
        fwrite(tcpip_pipe, Index,'int16');
        fwrite(tcpip_pipe, nRegisters,'int16');
        fwrite(tcpip_pipe, DataSize,'int8');
        fwrite(tcpip_pipe, DRV.EN,'int32');
        
        while ~tcpip_pipe.BytesAvailable,end
        tcpip_pipe.BytesAvailable;
        drvMotionstat=uint8(fread(tcpip_pipe,tcpip_pipe.BytesAvailable)); %the result is produced in 8 bit integers, hence the "uint8"
    end
else if driveStatus==1 && driveInput==1
        disp('Drive already enabled');
    end
end

if driveInput==0 && driveStatus==1
    disp('Disabling drive')
    transID = uint16(transID+1);    % 16b Transaction Identifier 
    nBytes = uint16(11);     % 16-bit Number of 8-bit blocks of data to be sent (6) 
    FunCod = uint8(16);      % 8-bit Function code: read (3) or write (16) 
    Index = uint16(236);    % 16-bit Start address of the register (588) 
    nRegisters = uint16(2); % 16-bit Number of registers (4)
    DataSize = int8(4);
    DRV.DIS = uint32(1); %software disable

    % transfer actual message (order is important)
    fwrite(tcpip_pipe, transID,'int16');
    fwrite(tcpip_pipe, ProtID,'int16');
    fwrite(tcpip_pipe, nBytes,'int16');
    fwrite(tcpip_pipe, UnitID,'int8');
    fwrite(tcpip_pipe, FunCod,'int8');
    fwrite(tcpip_pipe, Index,'int16');
    fwrite(tcpip_pipe, nRegisters,'int16');
    fwrite(tcpip_pipe, DataSize,'int8');
    fwrite(tcpip_pipe, DRV.DIS,'int32');
    
    while ~tcpip_pipe.BytesAvailable,end
    tcpip_pipe.BytesAvailable;
    drvMotionstat=uint8(fread(tcpip_pipe,tcpip_pipe.BytesAvailable)); %the result is produced in 8 bit integers, hence the "uint8"
end
    
% disp(['Current motion status is is: ',num2str(motionStatus)])
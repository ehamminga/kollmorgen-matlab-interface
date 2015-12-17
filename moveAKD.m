function moveAKD(posRequest,Traverse)
%MOVEAKD Move traverse to position set with function SetMotionAKD
% moveAKD(posRequest,Traverse) executes the motion task on the AKD drive to
% move the traverse to the position set with SetMotionAKD. Care should be
% taken that the requested position matches that of the position set with
% SetMotionAKD. The function uses the posRequest to verify whether the
% traverse has actually reached the position specified in the motion task.
%
% Example:
%   setMotionAKD(1000,TyM) sets the new position to 1000 mm
%   moveAKD(1000,TyM) executes motion task and waits until pos is reached.
% 
% See also setMotionAKD

% Copyright (c) 2015, Erwin Hamminga and The University of Adelaide

% Thanks Kees Stroeken, author of ModBusYaskawa
% <http://www.mathworks.com/matlabcentral/fileexchange/44662>
% for the inspiration to construct this function.

tcpip_pipe=Traverse;
%% Check if a motion task is still in progress
% define message values
transID = uint16(1);    % 16b Transaction Identifier 
ProtID = uint16(0);     % 16-bit Protocol ID (0 for ModBus) 
nBytes = uint16(6);     % 16-bit Number of 8-bit blocks of data to be sent (6) 
UnitID = uint8(0);      % 8-bit Unit ID (0) unit identifier (previous ‘device address’). The device is accessed directly via IP address, therefore this parameter
                        % has no function and may be set to 0xFF. Exception: If the communication is performed via gateway the device
                        % address must be set as before. 
FunCod = uint8(3);      % 8-bit Function code: read (3) 
Index = uint16(268);    % 16-bit Start address of the register (588) 
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
motionStatus=swapbytes(typecast(drvMotionstat(length(drvMotionstat)-3:length(drvMotionstat)),'int32'));
assert(motionStatus==0 || motionStatus==6 || motionStatus==34822,'Error: motion currently in progress')
% disp(['Current motion status is is: ',num2str(motionStatus)])

%% Read out position feedback (PL.FB)
% define message values
transID = uint16(1);    % 16b Transaction Identifier 
ProtID = uint16(0);     % 16-bit Protocol ID (0 for ModBus) 
nBytes = uint16(6);     % 16-bit Number of 8-bit blocks of data to be sent (6) 
UnitID = uint8(0);      % 8-bit Unit ID (0) unit identifier (previous ‘device address’). The device is accessed directly via IP address, therefore this parameter
                        % has no function and may be set to 0xFF. Exception: If the communication is performed via gateway the device
                        % address must be set as before. 
FunCod = uint8(3);      % 8-bit Function code: read (3) 
Index = uint16(588);    % 16-bit Start address of the register (588) 
nRegisters = uint16(4); % 16-bit Number of registers (4)

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
posRaw=uint8(fread(tcpip_pipe,tcpip_pipe.BytesAvailable)); %the result is produced in 8 bit integers, hence the "uint8"
%posRaw2=int8(fread(tcpip_pipe,tcpip_pipe.BytesAvailable));
% a pair of 8-bit integers needs to be combined into one 16-bit integer.
% This is done using typecast. The Swapbytes function is used to format 
% the output from little-endian to big-endian.
PL.FB=swapbytes(typecast(posRaw(length(posRaw)-(nRegisters*2-1):length(posRaw)),'int64'));
PL.FB=PL.FB/1000;
disp(['Current position is: ',num2str(PL.FB),' mm'])

%% execute motion task (MT.MOVE)
disp('Moving traverse to new position')
% define message values
transID = uint16(1);    % 16b Transaction Identifier 
ProtID = uint16(0);     % 16-bit Protocol ID (0 for ModBus) 
nBytes = uint16(11);     % 16-bit Number of 8-bit blocks of data to be sent (6) 
UnitID = uint8(0);      % 8-bit Unit ID (0) unit identifier (previous ‘device address’). The device is accessed directly via IP address, therefore this parameter
                        % has no function and may be set to 0xFF. Exception: If the communication is performed via gateway the device
                        % address must be set as before. 
FunCod = uint8(16);      % 8-bit Function code: read (3) or write (16) 
Index = uint16(544);    % 16-bit Start address of the register (588) 
nRegisters = uint16(2); % 16-bit Number of registers (4)
DataSize = int8(4);
MT.MOVE = int32(12); % choose motion task number

% transfer actual message (order is important)
fwrite(tcpip_pipe, transID,'int16');
fwrite(tcpip_pipe, ProtID,'int16');
fwrite(tcpip_pipe, nBytes,'int16');
fwrite(tcpip_pipe, UnitID,'int8');
fwrite(tcpip_pipe, FunCod,'int8');
fwrite(tcpip_pipe, Index,'int16');
fwrite(tcpip_pipe, nRegisters,'int16');
fwrite(tcpip_pipe, DataSize,'int8');
fwrite(tcpip_pipe, MT.MOVE,'int32');

while ~tcpip_pipe.BytesAvailable,end
tcpip_pipe.BytesAvailable;
res=uint8(fread(tcpip_pipe,tcpip_pipe.BytesAvailable)); %the result is produced in 8 bit integers, hence the "uint8"

% a pair of 8-bit integers needs to be combined into one 16-bit integer.
% This is done using typecast. The Swapbytes function is used to format 
% the output from little-endian to big-endian.
res_proc=swapbytes(typecast(res(length(res)-(nRegisters*2-1):length(res)),'int32'));

%% wait for task to finish

%posRequest = 700;
while PL.FB~=posRequest
    % Read out position feedback (PL.FB)
    % define message values
    transID = uint16(1);    % 16b Transaction Identifier 
    ProtID = uint16(0);     % 16-bit Protocol ID (0 for ModBus) 
    nBytes = uint16(6);     % 16-bit Number of 8-bit blocks of data to be sent (6) 
    UnitID = uint8(0);      % 8-bit Unit ID (0) unit identifier (previous ‘device address’). The device is accessed directly via IP address, therefore this parameter
                            % has no function and may be set to 0xFF. Exception: If the communication is performed via gateway the device
                            % address must be set as before. 
    FunCod = uint8(3);      % 8-bit Function code: read (3) 
    Index = uint16(588);    % 16-bit Start address of the register (588) 
    nRegisters = uint16(4); % 16-bit Number of registers (4)

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
    posRaw=uint8(fread(tcpip_pipe,tcpip_pipe.BytesAvailable)); %the result is produced in 8 bit integers, hence the "uint8"
    %posRaw2=int8(fread(tcpip_pipe,tcpip_pipe.BytesAvailable));
    % a pair of 8-bit integers needs to be combined into one 16-bit integer.
    % This is done using typecast. The Swapbytes function is used to format 
    % the output from little-endian to big-endian.
    PL.FB=swapbytes(typecast(posRaw(length(posRaw)-(nRegisters*2-1):length(posRaw)),'int64'));
    PL.FB=PL.FB/1000;
    disp(['Current position is: ',num2str(PL.FB),' mm'])
    pause(1);
    if posRequest==PL.FB
        disp('Position reached')
    end
end

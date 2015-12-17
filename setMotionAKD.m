function [newPos] = setMotionAKD(Position,Traverse)
%SETMOTIONAKD Set a position on the AKD drive
% setMotionAKD(Position,Traverse) takes a position in mm and constructs a
% motion task on the specified AKD drive. The position input can have a
% maximum accuracy of 3 decimals.
%
% The "Set motion task control" section defines whether the position input
% is either relative or absolute. This is currently set to absolute.
%
% Example:
%     setMotionAKD(1000.032,TyM) sets the motion task to an absolute
%     position of 1000.032 mm for the y-axis of the traverse.
% 
% The "Set motion task number" section appends the motion task with a
% number (currently set to 12) which will be overwritten every time this
% function is executed. When this function is executed, the resulting
% motion task will be visible in the Kollmorgen workbench under the
% corresponding number.
% 
% See also moveAKD

% Copyright (c) 2015, Erwin Hamminga and The University of Adelaide

%% Define constants
tcpip_pipe=Traverse;
ProtID = uint16(0);     % 16-bit Protocol ID (0 for ModBus)
UnitID = uint8(0);      % 8-bit Unit ID (0) unit identifier (previous ‘device address’). The device is accessed directly via IP address, therefore this parameter
                        % has no function and may be set to 0xFF. Exception: If the communication is performed via gateway the device
                        % address must be set as before.
pos = Position*1000;                   

%% Set motion task control (MT.CNTL)
% define message values
transID = uint16(1);    % 16b Transaction Identifier 
nBytes = uint16(11);     % 16-bit Number of 8-bit blocks of data to be sent (6) 

FunCod = uint8(16);      % 8-bit Function code: read (3) or write (16) 
Index = uint16(532);    % 16-bit Start address of the register (588) 
nRegisters = uint16(2); % 16-bit Number of registers (4)
DataSize = int8(4);
MT.CNTL = uint32(0); % relative pos(7) or absolute pos(0)

% transfer actual message (order is important)
fwrite(tcpip_pipe, transID,'int16');
fwrite(tcpip_pipe, ProtID,'int16');
fwrite(tcpip_pipe, nBytes,'int16');
fwrite(tcpip_pipe, UnitID,'int8');
fwrite(tcpip_pipe, FunCod,'int8');
fwrite(tcpip_pipe, Index,'int16');
fwrite(tcpip_pipe, nRegisters,'int16');
fwrite(tcpip_pipe, DataSize,'int8');
fwrite(tcpip_pipe, MT.CNTL,'int32');

while ~tcpip_pipe.BytesAvailable,end
tcpip_pipe.BytesAvailable;
res=uint8(fread(tcpip_pipe,tcpip_pipe.BytesAvailable)); %the result is produced in 8 bit integers, hence the "uint8"

% a pair of 8-bit integers needs to be combined into one 16-bit integer.
% This is done using typecast. The Swapbytes function is used to format 
% the output from little-endian to big-endian.
res_proc=swapbytes(typecast(res(length(res)-(nRegisters*2-1):length(res)),'int32'));

%% Set motion task number (MT.NUM)
% define message values
transID = uint16(transID+1);    % 16b Transaction Identifier 
nBytes = uint16(11);     % 16-bit Number of 8-bit blocks of data to be sent (6) 
FunCod = uint8(16);      % 8-bit Function code: read (3) or write (16) 
Index = uint16(548);    % 16-bit Start address of the register (588) 
nRegisters = uint16(2); % 16-bit Number of registers (4)
DataSize = int8(4);
MT.NUM = uint32(12);

% transfer actual message (order is important)
fwrite(tcpip_pipe, transID,'int16');
fwrite(tcpip_pipe, ProtID,'int16');
fwrite(tcpip_pipe, nBytes,'int16');
fwrite(tcpip_pipe, UnitID,'int8');
fwrite(tcpip_pipe, FunCod,'int8');
fwrite(tcpip_pipe, Index,'int16');
fwrite(tcpip_pipe, nRegisters,'int16');
fwrite(tcpip_pipe, DataSize,'int8');
fwrite(tcpip_pipe, MT.NUM,'int32');

while ~tcpip_pipe.BytesAvailable,end
tcpip_pipe.BytesAvailable;
res=uint8(fread(tcpip_pipe,tcpip_pipe.BytesAvailable)); %the result is produced in 8 bit integers, hence the "uint8"

% a pair of 8-bit integers needs to be combined into one 16-bit integer.
% This is done using typecast. The Swapbytes function is used to format 
% the output from little-endian to big-endian.
res_proc=swapbytes(typecast(res(length(res)-(nRegisters*2-1):length(res)),'int32'));

%% Set motion task velocity (MT.V) might try 64-bit
% define message values
transID = uint16(transID+1);    % 16b Transaction Identifier 
nBytes = uint16(11);     % 16-bit Number of 8-bit blocks of data to be sent (6) 
FunCod = uint8(16);      % 8-bit Function code: read (3) or write (16) 
Index = uint16(566);    % 16-bit Start address of the register (588) 
nRegisters = uint16(2); % 16-bit Number of registers (4)
DataSize = int8(4);
MT.V = 100000;  % actual velocity in rpm: MT.V/1000 with 3 dec. accuracy.

% transfer actual message (order is important)
fwrite(tcpip_pipe, transID,'int16');
fwrite(tcpip_pipe, ProtID,'int16');
fwrite(tcpip_pipe, nBytes,'int16');
fwrite(tcpip_pipe, UnitID,'int8');
fwrite(tcpip_pipe, FunCod,'int8');
fwrite(tcpip_pipe, Index,'int16');
fwrite(tcpip_pipe, nRegisters,'int16');
fwrite(tcpip_pipe, DataSize,'int8');
fwrite(tcpip_pipe, MT.V,'int32');

while ~tcpip_pipe.BytesAvailable,end
tcpip_pipe.BytesAvailable;
res=uint8(fread(tcpip_pipe,tcpip_pipe.BytesAvailable)); %the result is produced in 8 bit integers, hence the "uint8"

% a pair of 8-bit integers needs to be combined into one 16-bit integer.
% This is done using typecast. The Swapbytes function is used to format 
% the output from little-endian to big-endian.
res_proc=swapbytes(typecast(res(length(res)-(nRegisters*2-1):length(res)),'int32'));

%% Set motion task acceleration (MT.ACC)
% define message values
transID = uint16(transID+1);    % 16b Transaction Identifier 
nBytes = uint16(15);     % 16-bit Number of 8-bit blocks of data to be sent (6) 
FunCod = uint8(16);      % 8-bit Function code: read (3) or write (16) 
Index = uint16(526);    % 16-bit Start address of the register (588) 
nRegisters = uint16(4); % 16-bit Number of registers (4)
DataSize = int8(8);
MT.ACC = 10000000; %rpm/s, is read as MT.ACC/1000 with 3 dec. accuracy

% transfer actual message (order is important)
fwrite(tcpip_pipe, transID,'int16');
fwrite(tcpip_pipe, ProtID,'int16');
fwrite(tcpip_pipe, nBytes,'int16');
fwrite(tcpip_pipe, UnitID,'int8');
fwrite(tcpip_pipe, FunCod,'int8');
fwrite(tcpip_pipe, Index,'int16');
fwrite(tcpip_pipe, nRegisters,'int16');
fwrite(tcpip_pipe, DataSize,'int8');
fwrite(tcpip_pipe, 0,'uint16')
fwrite(tcpip_pipe, 0,'uint16')
fwrite(tcpip_pipe, MT.ACC,'uint32');

while ~tcpip_pipe.BytesAvailable,end
tcpip_pipe.BytesAvailable;
res=uint8(fread(tcpip_pipe,tcpip_pipe.BytesAvailable)); %the result is produced in 8 bit integers, hence the "uint8"

% a pair of 8-bit integers needs to be combined into one 16-bit integer.
% This is done using typecast. The Swapbytes function is used to format 
% the output from little-endian to big-endian.
res_proc=swapbytes(typecast(res(length(res)-(nRegisters*2-1):length(res)),'int32'));

%% Set motion task deceleration (MT.DEC)
% define message values
transID = uint16(transID+1);    % 16b Transaction Identifier 
nBytes = uint16(15);     % 16-bit Number of 8-bit blocks of data to be sent (6) 
FunCod = uint8(16);      % 8-bit Function code: read (3) or write (16) 
Index = uint16(536);    % 16-bit Start address of the register (588) 
nRegisters = uint16(4); % 16-bit Number of registers (4)
DataSize = int8(8);
MT.DEC = uint32(10000000); % rpm/s, is read as MT.DEC/1000 with 3 dec. accuracy

% transfer actual message (order is important)
fwrite(tcpip_pipe, transID,'int16');
fwrite(tcpip_pipe, ProtID,'int16');
fwrite(tcpip_pipe, nBytes,'int16');
fwrite(tcpip_pipe, UnitID,'int8');
fwrite(tcpip_pipe, FunCod,'int8');
fwrite(tcpip_pipe, Index,'int16');
fwrite(tcpip_pipe, nRegisters,'int16');
fwrite(tcpip_pipe, DataSize,'int8');
fwrite(tcpip_pipe, 0,'uint16')
fwrite(tcpip_pipe, 0,'uint16')
fwrite(tcpip_pipe, MT.DEC,'uint32');

while ~tcpip_pipe.BytesAvailable,end
tcpip_pipe.BytesAvailable;
res=uint8(fread(tcpip_pipe,tcpip_pipe.BytesAvailable)); %the result is produced in 8 bit integers, hence the "uint8"

% a pair of 8-bit integers needs to be combined into one 16-bit integer.
% This is done using typecast. The Swapbytes function is used to format 
% the output from little-endian to big-endian.
res_proc=swapbytes(typecast(res(length(res)-(nRegisters*2-1):length(res)),'int32'));

%% Set motion task position (MT.P)
% define message values
transID = uint16(transID+1);    % 16b Transaction Identifier 
FunCod = uint8(16);      % 8-bit Function code: read (3) 
Index = uint16(550);    % 16-bit Start address of the register (588) 
nRegisters = uint16(4); % 16-bit Number of registers (4)
MT.P = pos; % abs or rel depending on MT.CNTL setting. Actual pos: MT.P/1000 with 3 dec. accuracy
DataSize = uint8(8);
nBytes = uint16(15);     

% transfer actual message (order is important)
fwrite(tcpip_pipe, transID,'uint16');
fwrite(tcpip_pipe, ProtID,'uint16');
fwrite(tcpip_pipe, nBytes,'uint16');
fwrite(tcpip_pipe, UnitID,'uint8');
fwrite(tcpip_pipe, FunCod,'uint8');
fwrite(tcpip_pipe, Index,'uint16');
fwrite(tcpip_pipe, nRegisters,'uint16');
fwrite(tcpip_pipe, DataSize,'uint8');
fwrite(tcpip_pipe, 0,'uint16')
fwrite(tcpip_pipe, 0,'uint16')
fwrite(tcpip_pipe, MT.P,'uint32');

while ~tcpip_pipe.BytesAvailable,end
tcpip_pipe.BytesAvailable;
res=uint8(fread(tcpip_pipe,tcpip_pipe.BytesAvailable)); %the result is produced in 8 bit integers, hence the "uint8"

% a pair of 8-bit integers needs to be combined into one 16-bit integer.
% This is done using typecast. The Swapbytes function is used to format 
% the output from little-endian to big-endian.
res_proc=swapbytes(typecast(res(length(res)-(nRegisters*2-1):length(res)),'int32'));

%% Set motion task confirmation (MT.SET)
% define message values
transID = uint16(transID+1);    % 16b Transaction Identifier 
nBytes = uint16(11);     % 16-bit Number of 8-bit blocks of data to be sent (6) 
FunCod = uint8(16);      % 8-bit Function code: read (3) or write (16) 
Index = uint16(554);    % 16-bit Start address of the register (588) 
nRegisters = uint16(2); % 16-bit Number of registers (4)
DataSize = int8(4);
MT.SET = uint32(1); %set

% transfer actual message (order is important)
fwrite(tcpip_pipe, transID,'int16');
fwrite(tcpip_pipe, ProtID,'int16');
fwrite(tcpip_pipe, nBytes,'int16');
fwrite(tcpip_pipe, UnitID,'int8');
fwrite(tcpip_pipe, FunCod,'int8');
fwrite(tcpip_pipe, Index,'int16');
fwrite(tcpip_pipe, nRegisters,'int16');
fwrite(tcpip_pipe, DataSize,'int8');
fwrite(tcpip_pipe, MT.SET,'int32');

while ~tcpip_pipe.BytesAvailable,end
tcpip_pipe.BytesAvailable;
res=uint8(fread(tcpip_pipe,tcpip_pipe.BytesAvailable)); %the result is produced in 8 bit integers, hence the "uint8"

% a pair of 8-bit integers needs to be combined into one 16-bit integer.
% This is done using typecast. The Swapbytes function is used to format 
% the output from little-endian to big-endian.
res_proc=swapbytes(typecast(res(length(res)-(nRegisters*2-1):length(res)),'int32'));

%% display feedback
if MT.CNTL==0
    motionTaskCtrl='absolute';
else
    motionTaskCtrl='relative';
end
disp(['Motion task position set to ',num2str(Position),' mm ',motionTaskCtrl]);



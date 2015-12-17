function [tcpip_pipe]=openAKDip(IPADDR)
%OPENAKDIP Establishes a TCP/IP connection with the AKD drive
% openAKDip(IPADDR) establishes a link with a Kollmorgen AKD drive through
% TCP/IP and returns a traverse object.
%
% Example:
%   TyM=openAKDip('192.168.0.1');
%
% See also toggleAKD, setMotionAKD, moveAKD

% Copyright (c) 2015, Erwin Hamminga and The University of Adelaide
%%
PORT=502; %default port
tcpip_pipe=tcpip(IPADDR, PORT); %IP and Port of AKD drive 
set(tcpip_pipe, 'InputBufferSize', 512); 
tcpip_pipe.ByteOrder='bigEndian'; %to match modbus protocol
%%
try 
    if ~strcmp(tcpip_pipe.Status,'open') 
        fopen(tcpip_pipe); 
    end
    disp('TCP/IP Open'); % apparently, the channel is successfully opened.
catch err 
    disp('Error: Can''t open TCP/IP'); 
end


%% close connection
% fclose(tcpip_pipe);
%%
%{
Copyright (c) 2015, Erwin Hamminga
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in
      the documentation and/or other materials provided with the distribution

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
%}
% ENEEB client class.
%   contructor:
%   [obj] = Eneeb_client(HOST, PORT) creates a Eneeb_client object in the
%   HOST ip address and port PORT
%
%   Eneeb_client has 3 functions:
%       initialize(OBJ) connects to server defined in the OBJ.host and port
%       OBJ.port and waits for server to star sending data.
%
%       bytearrayread=readmessage(OBJ, datapoint_size) reads a message with
%       datapoint_size into bytearrayread.
%
%       close(OBJ) closes the OBJ client connection.
%
%   Example:
%
%       client=Eneeb_client(host, port);
%       client.initialize();
%       client.readmessage(datapoint_size);
%       client.close('');
%

classdef Eneeb_client < handle
    
    properties (SetAccess = private)
        host
        port
        
        max_retries = 50; % set to -1 for infinite
        message
        
        input_socket
        input_stream
        data_input_stream
        
    end
    
    methods
        % constructor
        function obj=Eneeb_client(host, port)
            obj.host=host;
            obj.port=port;
        end
        
        % create Eneeb_client.
        function [connected]=initialize(obj)
            connected=0;
            
            import java.net.Socket
            import java.io.*
            
            retry        = 0;
            obj.input_socket = [];
            
            while true
                retry = retry + 1;
                if ((obj.max_retries > 0) && (retry > obj.max_retries))
                    fprintf(1, '[CLIENT: ] Too many retries\n');
                    break;
                end
                
                try
                    fprintf(1, '[CLIENT: ] Retry %d connecting to %s:%d\n', ...
                        retry, obj.host, obj.port);
                    % throws if unable to connect
                    obj.input_socket = Socket(obj.host, obj.port);
                    
                    % get a buffered data input stream from the socket
                    obj.input_stream   = obj.input_socket.getInputStream;
                    obj.data_input_stream = DataInputStream(obj.input_stream);
                    
                    fprintf(1, '[CLIENT: ] Connected to server\n');
                    connected=1;
                    
                    break;
                    
                catch
                    if ~isempty(obj.input_socket)
                        
                        obj.input_socket.close;
                    end
                    % pause before retrying
                    pause(.5);
                end
            end
        end
        
        function close(obj)
            % close and cleanup.
            obj.input_socket.close;
            
            fprintf(1, '[CLIENT: ] Client closed connection.\n')
       
        end
        
        function bytearrayread=readmessage(obj, datapoint_size)
            % read data from the socket - wait a short time first

            
            while (obj.input_stream.available<datapoint_size)
                pause(.1); % to confirm
            end
            
            bytes_available = obj.input_stream.available;
            fprintf(1, '[CLIENT: ]  %d bytes available \n', bytes_available);
            obj.message = zeros(1, datapoint_size, 'int8');
            
            for i = 1:datapoint_size%bytes_available
                obj.message(i) = obj.data_input_stream.readByte;
            end
            
            bytearrayread=obj.message;
            
            % obj.message=char(obj.message);
            
            fprintf(1, '[CLIENT: ] done. \n')
            
        end
    end
end
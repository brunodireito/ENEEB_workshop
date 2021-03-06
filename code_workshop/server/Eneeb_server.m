% ENEEB server class.
%   contructor:
%   [obj] = Eneeb_server(HOST, PORT) creates a Eneeb_server object in the
%   HOST ip address and port PORT
%
%   Eneeb_server has 3 functions:
%       initialize(OBJ) initializes the server in the OBJ.host and port
%       OBJ.port and waits for a client to connect.
%
%       sendmessage(OBJ, MESSAGE) send a message with the variable MESSAGE
%       as a bytestream.
%
%       close(OBJ) closes the OBJ server connection.
%
%   Example:
%
%       server=Eneeb_server(host, port);
%       server.initialize();
%       server.sendmessage('Hello World');
%       server.close('');
%

classdef Eneeb_server < handle
    
    properties (SetAccess = private)
        host
        port
        
        % set to -1 for infinite.
        max_retries=10 
        
        % default message.
        message='hello world'
        
        server_socket
        output_socket
        output_stream
        data_output_stream
        
    end
    
    methods
        % constructor
        function obj=Eneeb_server(host, port)
            obj.host=host;
            obj.port=port;
        end
        
        % create Eneeb_server.
        function connected=initialize(obj)
            import java.net.ServerSocket
            import java.io.*
            
            connected=0;
            
            retry= 0;
            obj.server_socket  = [];
            obj.output_socket  = [];
            
            while true
                retry = retry + 1;
                try
                    if ((obj.max_retries > 0) && (retry > obj.max_retries))
                        fprintf(1, '[SERVER: ] Too many retries\n');
                        break;
                    end
                    
                    fprintf(1, ['[SERVER: ] Try %d waiting for client to connect to this ' ...
                        'host on port : %d\n'], retry, obj.port);
                    
                    % wait for 1 second for client to connect server socket
                    obj.server_socket=ServerSocket(obj.port);
                    obj.server_socket.setSoTimeout(1000);
                    
                    obj.output_socket=obj.server_socket.accept;
                    
                    
                    
                    obj.output_stream=obj.output_socket.getOutputStream;
                    obj.data_output_stream=DataOutputStream(obj.output_stream);
                    fprintf(1, '[SERVER: ] Client connected\n');
                    connected=1;
                    
                    break;
                    
                catch
                    if ~isempty(obj.server_socket)
                        obj.server_socket.close
                    end

                    % pause before retrying
                    pause(1);
                end
                
            end
        end
        
        function sendmessage(obj, message)
            % output the data over the DataOutputStream
            % Convert to stream of bytes
            fprintf(1, '[SERVER: ] Writing %d bytes\n', length(message))
            obj.data_output_stream.write(message);
            obj.data_output_stream.flush;
        end
        
        function close(obj)
            
            % close socket, clean up.
            obj.server_socket.close;
            obj.output_socket.close;
            
            fprintf(1, '[SERVER: ] Server closed.\n')
        end
    end
end
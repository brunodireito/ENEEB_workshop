
%% Initialize server

% Set vars.
host='localhost';
port=3000;

load('testing_dataset_workshop.mat')
bytearray=[];

%% [TODO:] CREATE server.
% hint: help Eneeb_server

% Create OBJ server and initialize.
% server=
% connected=server.
%%
server=Eneeb_server(host, port); % to_do
connected=server.initialize();  % to_do

if connected
    try
        
        for i=1:size(TEST,2)
            
            % float2byte datatype
            for f=1:length(TEST(:,i))
                bytearray=[bytearray typecast(TEST(f,i),'uint8')];
            end
            
            % bytearray size = 8 (bytes per sample) * 41 elements - need to send
            % 328 bytes per sample
            
            %% [TODO:] SEND MESSAGE (send message through server)
            % hint: help Eneeb_server
            
            % server.
            %%
            server.sendmessage(bytearray); % to_do

            pause(.25)
            
            fprintf('[SERVER: ] Sample # %i sent.\n', i);
            
            bytearray=[];
        end
        
        %% [TODO:] SEND MESSAGE informing that run ended.
        % hint: help zeros, Eneeb_server
        
        % server.;
        %%
        server.sendmessage(zeros(1,328)); % to_do

        fprintf('[SERVER: ] Last sample sent.\n');
        
        % Close server.
        server.close();
        
    catch ME
        server.close()
        rethrow(ME)
    end
end

%%
close all,
clear all,

addpath(genpath(fullfile('..','classification')));

%% ------------------------------------------------------------------------
% Setting up the system.
%
% Defining variables.

% connection.
host='localhost';

%% [TODO:] Define client side.
% hint: server port?
% port=
%%
port=3000; % to_do

%% [TODO:] Define client side.
% hint: server port?
% datapoint_size=
%%
datapoint_size=328; % to_do

bytearrayread='';
t_idx=1;
datapoint_byte=[];
% total number of samples that we will receive throughout the session.
numberpoints=2560;

%% [TODO:] Define the number of channels that we will receive per time point.
% hint: look at montage.
% numberchans=
%%
numberchans=40; % to_do

% data cleaning vars.
windowsize=20;
outlcoef=3;
movingavwindow=5;

% classification and feedback presentation.
% Load images
I1 = imread('hands_left-60_right-60.png');
I2 = imread('hands_left-100_right-60.png');
I3 = imread('hands_left-60_right-100.png');

% Start image
hf_c=figure('name','interface','position',[100 100 1000 600])

%% [TODO:] load classifier model previously trained.
% hint: help load.
% hint: 'classifier.mat'.
% load
%%
load('classifier.mat') %to_do

%% ------------------------------------------------------------------------

%% Initialize Client to begin receiving data

% initialize Client.
%% [TODO:] CREATE Client.
% hint: help Eneeb_client, host, port

% Create OBJ client and initialize.
% client=
% connected=
%%

client=Eneeb_client(host, port); % to_do
connected=client.initialize(); % to_do

if connected
    
    try
        
        %% Prepare plot for arriving data
       
        subplot(2,1,1);



        datareceivedchan=0;
        t = 0;
        h_plot=plot(t, datareceivedchan);
        
        set(h_plot, ...
            'LineWidth'       , 1           , ...
            'Marker'          , 'o'         , ...
            'MarkerSize'      , 6)
        
        set(gca, ...
            'Box'         , 'off'     , ...
            'TickDir'     , 'out'     , ...
            'TickLength'  , [.02 .02] , ...
            'XMinorTick'  , 'on'      , ...
            'YMinorTick'  , 'on'      , ...
            'YGrid'       , 'on'      , ...
            'XColor'      , [.3 .3 .3], ...
            'YColor'      , [.3 .3 .3], ...
            'XLim'        , [0,numberpoints],...
            'YLim'        , [-50,50],...
            'LineWidth'   , 1         );
        
        %% Let's go!
        % Once the connection is established, check for new data.
        
        % while receiveing data, continue.
        while 1
            
            % while receiveing datapoint, continue.
            
            %% [TODO:] read message from server.
            % hint: help Eneeb_client, datapoint_size
            
            % Use client and read message in server.
            % bytearrayread=client.
            %%
            bytearrayread=client.readmessage(datapoint_size); % to_do
            
            % If last point (Remember last message sent from server when finished!)
            if (sum(bytearrayread)==0)
                % datapoint complete.
                break;
            end
            
            %% If new data read.
            if ~isempty(bytearrayread)
                
                t=t+1;
                fprintf('[Client: ] Received sample %i.\n', t);
                
                % read datapoint.
                datapoint_byte{t}=bytearrayread;
                
                % cast to appropriate class.
                datapoints(t,:)=typecast(datapoint_byte{t}, 'double');
                
                %% update plot for chan 1.
                datareceivedchan(t)=datapoints(t,1);
                subplot(2,1,1); 
                set(h_plot, 'XData',1:t, 'YData', datareceivedchan);
                
                %% Real-time preprocessing. Proceed carefully.
                
                % Start cleaning after initial window.
                
                % Removing outliers.
                if t>windowsize % wait *windowsize* and start analyzing pattern.
                    
                    % We need to analyze the time course per channel. Iterate
                    % through channels.
                    for ch=1:numberchans
                        
                        % Outlier detection.
                        
                        % Get a segment of data for a specific chan.
                        datasegment(:,ch)=datapoints(t-windowsize:t,ch);
                        
                        % compute sliding window mean.
                        
                        %% [TODO:] compute average and std of the extrated segment of data (required to check for outliers - remember data_science.m)
                        % hint: mean, std
                        
                        % m_data=
                        % std_data=
                        %%
                        m_data=mean(datasegment(:,ch)); %to_do
                        std_data=std(datasegment(:,ch)); %to_do
                        
                        %% [TODO:] find ouliers based on window average and std - remember data_science.m)
                        % hint: find, abs, outlcoef, m_data, std_data
                        
                        % outliers_idxs=
                        %%
                        outliers_idxs=find(abs(m_data-datasegment(:,ch))>outlcoef*std_data);
                        
                        %                     if(~isempty(outliers_idxs))
                        %                         fprintf('found outliers in ch %i, idx %i \n', ch, t)
                        %                     end
                        
                        % Can you remember the alternatives?
                        for i =1:length(outliers_idxs)
                            if datasegment(outliers_idxs(i), ch) > m_data
                                datasegment(outliers_idxs(i), ch)=m_data+std_data*2.5;
                            else
                                datasegment(outliers_idxs(i), ch)=m_data-std_data*2.5;
                            end
                        end
                        
                        
                        % low pass filter - moving average of x samples (pr channel)
                        datasegmentcleaned(t, ch)=mean(datasegment(end-movingavwindow:end, ch));
                    end
                    
                    
                    %% Use classifier to predict imagery task
                    
                    %% [TODO:] Use trained classifier to predict next label
                    % hint: check loaded trained model
                    % hint: to predict the class of an event we can use model.predictFcn(datapoint)
                    
                    % yfit=
                    %%
                    yfit(t)=trainedClassifier.predictFcn(datasegmentcleaned(t, bestfeats)); %to_do
                    
                    if yfit(t)==datapoints(t,41)
                        fprintf('The classifier was correct for sample %i.\n', t);
                    else
                        fprintf('The classifier was incorrect for sample %i.\n', t);
                    end
                    
                    subplot(2,1,2); 
                    switch yfit(t)
                        case 0
                            image(I1);
                        case 1
                            image(I2);
                        case 2
                            image(I3);
                    end
                    
                end
                
                
            end
            
        end
        
        accuracy = sum(yfit==datapoints(:,41)')/numel(yfit) * 100;
        fprintf('The classifier was correct %.3f%% of times.\n', accuracy)
        
    catch ME
        client.close()
        rethrow(ME)
    end
    
    client.close()
    
end
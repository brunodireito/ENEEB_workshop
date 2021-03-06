%% Let's explore the training set.

% Load data.
% This dataset represents the output of the acquisition equipment during the training run.

addpath('data')
addpath(genpath('classification'))
load('training_dataset_workshop.mat')

% You should see TRAIN, chans_label 
% in MATLAB's Workspace.

%% What we know about the data:
sampling_freq=4;

%% Let's see what is inside each variable.
% traindata is a 41x1280

[train_rows, train_cols]=size(TRAIN);
[num_chans]=numel(chans_labels);

fprintf('Our training set has %i samples, and %i channels.\n', train_cols, num_chans);

%% Checking the training data.
% First we have to select a channel.

chan_idx=1;

%% Now we can plot it over time.

figure, 
plot(TRAIN(chan_idx,:))

%% Re-arrange the plot considering what we know.
% 
% Sampling_Freq=4Hz.
% 
% If possible , make a "prettier" plot.

int_t=100;
set(gca, ...
  'Box'         , 'off'     , ...
  'TickDir'     , 'out'     , ...
  'TickLength'  , [.02 .02] , ...
  'XMinorTick'  , 'on'      , ...
  'YMinorTick'  , 'on'      , ...
  'YGrid'       , 'on'      , ...
  'XColor'      , [.3 .3 .3], ...
  'YColor'      , [.3 .3 .3], ...
  'XTick'       , 0:int_t:train_cols+int_t, ...
  'XTickLabel'  , 0:int_t/sampling_freq:(train_cols+int_t)/sampling_freq, ...
  'LineWidth'   , 1         );

ylim=get(gca, 'ylim');

xlabel('data over time (seconds)')

title(sprintf('plot of channel %s \n', chans_labels{chan_idx}))
%% 
% If you look closely, the matrix TRAIN has 41 lines. The last one represents 
% the task.
% 
% Let's edit the figure and add the condition.

hold on;

idxs=find(diff(TRAIN(end,:)));
st_int=1;
colors=[255, 255, 255;
    190, 190, 190;
    90, 90, 90]/255;

for i=1:numel(idxs)
    end_int=idxs(i);
    
    p=patch([st_int end_int end_int st_int],...
        [ylim(1) ylim(1)  ylim(2) ylim(2)],...
        colors(TRAIN(end,st_int)+1,:));
    set(p, 'FaceAlpha', 0.1,...
           'EdgeColor', 'none')   
    st_int=end_int+1;
end

%% 
% There are several moments that represent outliers (data points that differ 
% significantly from other observations).
% 
% How can we identify them? clean them?

% [Example] Rule - values that are greater than 3 times the mean + STD
outlcoef=3;
                
% outlier detection.
datasegment=TRAIN(chan_idx,:);

% compute the mean and standard deviation of the entir signal.
m_data=mean(datasegment);
std_data=std(datasegment);

% Find elements that exceed by far the mean - e.g. x(i) > mean + 3*STD
outliers_idxs=find(abs(m_data-datasegment)>outlcoef*std_data);

% Replace elements by limit values
for i =1:length(outliers_idxs)
    if datasegment(outliers_idxs(i)) > m_data
        datasegment(outliers_idxs(i))=m_data+std_data*2.5;
    else
        datasegment(outliers_idxs(i))=m_data-std_data*2.5;
    end
end

plot(datasegment, 'r')

%% TO DISCUSS
% better alternative to substitute outliers?
for i =1:length(outliers_idxs)
    if datasegment(outliers_idxs(i)) > m_data
        datasegment(outliers_idxs(i))=mean([datasegment(outliers_idxs(i)-1) datasegment(outliers_idxs(i)+1)]);
    else
        datasegment(outliers_idxs(i))=mean([datasegment(outliers_idxs(i)-1) datasegment(outliers_idxs(i)+1)]);
    end
end

plot(datasegment, 'g')

%% Low pass filter to remove high frequency noise [not related with the task]
% moving average filter - sliding window.
% Set the number of points of the average.
movingavwindow=5;

% low pass filter - moving average of x samples (pr channel)
datasegmentcleaned=movmean(datasegment,movingavwindow);

%% Let's check what we have done to the data.
figure, plot(1:length(datasegment),TRAIN(chan_idx,:), 'g', 1:length(datasegment),datasegmentcleaned,'b');


%% Looks OK!
% Now we train the classifier - we will try to define a model that
% automatically identifies what the participant is thinking!

%% Training the classifier.

% Number of features available (Hbo and Hbr per channel, 20 channels = 40
% feats).
nfeats = 40;

datatrain=TRAIN(1:40,:)';
labelstrain=TRAIN(41,:)';

%% Feature Selection - Which are the best feats?
% Select the 10 best features availables. 
ntopfeats = 10;

% Feature Selection using two criteria - Fisher score,  Kruskal Wallis     
[ ~ , ~ , fs1] = FS_kruskal( datatrain , labelstrain , chans_labels , ntopfeats );
[ ~ , ~ , fs2] = FS_fisher( datatrain , labelstrain , chans_labels , ntopfeats );

% Plot intersection of feature selection methods
plotFSfig(fs1,fs2,nfeats,chans_labels)
bestfeats=unique([fs1',fs2']);

varslabels=chans_labels;
varslabels(41)={'response'};
%% Train model

% Let's use the trinaing set to train the classifier and help the model to
% create the best fit to decide the correct class for each timepoint.
[trainedClassifier, validationAccuracy] = trainSVMClassifier(TRAIN([bestfeats 41],:)', varslabels([bestfeats 41])');

fprintf('The accuracy in the training set is %.3f.\n', validationAccuracy);

%% Save the classifier 

% for use in the client in real-time.
save classifier.mat trainedClassifier bestfeats

copyfile classifier.mat client



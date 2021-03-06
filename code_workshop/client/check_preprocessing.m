% Check data. Raw vs. preprocessed.
figure, 

ch_idx=1;

plot(datapoints(:,ch_idx), 'bo-');
hold on;
plot(datasegmentcleaned(:,ch_idx), 'r-');
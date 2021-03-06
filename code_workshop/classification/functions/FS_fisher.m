function [ FSdata , column_names_new , selected_features ] = FS_fisher( data , labels , column_names, threshold )
%FISHER SCORE for Feature Selection
%Usage:
%   [FSdata,column_names_new,selected_features,print] = FS_fisher(data,labels,column_names,threshold)
%Input:
%   data (events x features)
%   labels (events x 1)
%   column_names (1 x colnum cell)
%   threshold (desired number of features)
%Output:
%   FSdata (data matrix with selected features)
%   column_names_new (cell with selected features' names)
%   selected_features (vector with selected features' index)
%   print (string for interface text feedback)

[~,colnum] = size(data);

F = zeros(colnum,1);

for i=1:colnum
    auxc0 = data(labels==0,i);
    auxc1 = data(labels==1,i);
    auxc2 = data(labels==2,i);
    
    f1 = ( (mean(auxc0)-mean(auxc1))^2 ) / ( var(auxc0)+var(auxc1) );
    f2 = ( (mean(auxc0)-mean(auxc2))^2 ) / ( var(auxc0)+var(auxc2) );
    f3 = ( (mean(auxc1)-mean(auxc2))^2 ) / ( var(auxc1)+var(auxc2) );
    
    F(i) =  (f1 + f2 + f3) / 3;
end

[F_s,F_ord] = sort(F,'descend');

selected_features = F_ord(1:threshold);
FSdata = data(:,sort(selected_features));
% column_names_new = column_names(selected_features);

% disp('Features selected:');
% T = table(num2cell(selected_features),cellstr(column_names_new'),num2cell(F_s(1:threshold)),'VariableNames',{'Column_index' 'Feature' 'Score'});
% disp(T);

selected_features = sort(selected_features);
column_names_new = column_names(selected_features);

% disp('Fisher Score Method completed.');

end
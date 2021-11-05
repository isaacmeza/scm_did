clear all
clc
%Read matrix
A = csvread('method_sd_kcal_2_1.csv');
%Replace zeros with Inf
A(A==0)=Inf;
%Minimum of A
[M,I] = min(A(:));
%ind2sub function to extract the row and column indices of A corresponding
%to the smallest element
[I_row, I_col] = ind2sub(size(A),I);
%Minimum value
min_val=min(min(A))
%Optimal cuts
left_cut=50+(I_row-1)*5
right_cut=150-(I_col-1)*5
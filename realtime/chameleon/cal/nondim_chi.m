function [kkb,outspec]=nondim_chi(k,inspec,chi,kb,D)
% function outspec=nondim_chi(inspec,chi,epsilon,nu,D) nondimensionalizes
% a temperature gradient spectrum and wavenumber

% first make all the matrices the same size:
big_chi=meshgrid(chi',inspec(1,:));
big_kb=meshgrid(kb',inspec(1,:));
big_D=meshgrid(D',inspec(1,:));
kkb=k./big_kb';
outspec=inspec.*big_kb'.*big_D'./big_chi';
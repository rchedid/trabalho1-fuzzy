% Código para separar manualmente as contrações do sinal

clc
clearvars;
close all;


Img = imread('C:\Users\Bruno\Desktop\trabalho1-fuzzy\BasesDeDados\Base2\Codigos\imagevectorize\ice001_l_1of1.bmp');

ImgVector = Img(:);

%{

caminho = 'C:\Users\Bruno\Desktop\trabalho1-fuzzy\BasesDeDados\Base2\Codigos\imagevectorize\';
arquivo = 'ice001_l_1of1';
extensao = '.bmp';

load(strcat(caminho,arquivo,extensao));
%load(strcat(caminho,arquivo,'_ann',extensao));

%}
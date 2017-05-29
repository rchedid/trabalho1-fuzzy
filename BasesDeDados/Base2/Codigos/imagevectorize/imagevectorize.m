% Código para separar manualmente as contrações do sinal

clc
clearvars;
close all;



I = imread('C:\Users\Bruno\Desktop\trabalho1-fuzzy\BasesDeDados\Base2\Codigos\imagevectorize\ice001_l_1of1.jpg');
whos I

[BW,I] = createMask(I)



I = rgb2gray(I)



I_gs = wiener2(I,[1.5 1.5]);



th = 190;

I(I>th)=255;

imshow(I);
%{


%[BW,mI] = createMask(I2 )

imshow(I_gs_th);






grabit('C:\Users\Bruno\Desktop\trabalho1-fuzzy\BasesDeDados\Base2\Codigos\imagevectorize\ice001_l_1of1.bmp')

caminho = 'C:\Users\Bruno\Desktop\trabalho1-fuzzy\BasesDeDados\Base2\Codigos\imagevectorize\';
arquivo = 'ice001_l_1of1';
extensao = '.bmp';

load(strcat(caminho,arquivo,extensao));
%load(strcat(caminho,arquivo,'_ann',extensao));

%}
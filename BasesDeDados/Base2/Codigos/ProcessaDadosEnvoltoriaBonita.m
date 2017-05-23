% Código para separar manualmente as contrações do sinal

clc
clear all;
close all;

caminho = '../Dados/';
arquivo = 'ice028_p_3of3m';
extensao = '.mat';

load(strcat(caminho,arquivo,extensao));
load(strcat(caminho,arquivo,'_ann',extensao));

ganho = 131.068;

sinal = val(2,:)/ganho - val(1,:)/ganho;
sinal = RetiraDC(sinal);
sinal = Retificar(sinal);
% sinal = FiltroPA(sinal, 0.1, 200, 5);
% sinal = FiltroPB(sinal, 0.45, 200, 5);
sinal = FiltroPF(sinal,0.1,1,200,10);

sinal = rms(sinal, 40, 15, 1);

sinal = MediaMovel(sinal, 0.004);
sinal = FiltroPB(sinal, 1, 200, 5);
%sinal = RetiraDC(sinal);


plot(sinal);
axis([0 size(sinal,2) 0 0.04]);






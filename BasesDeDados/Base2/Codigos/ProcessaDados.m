% Código para ????

clc
clear all;
close all;

caminho = 'C:\Icelandic\mio\';
arquivo = 'ice001_l_1of1m';
extensao = '.mat';

load(strcat(caminho,arquivo,extensao));
%%load(strcat(caminho,arquivo,'_ann',extensao));


ganho = 131.068;

k=0;
for i = 1:4
    for j = 1:3
        k = k+1;
        sinal_diferencial(k,:) = val((j+1)+4*(i-1),1:end)/ganho - val(j+4*(i-1),1:end)/ganho;
        
        sinal_diferencial(k,:) = FiltroPA(sinal_diferencial(k,:), 0.35, 200, 5);
        sinal_diferencial(k,:) = FiltroPB(sinal_diferencial(k,:), 1, 200, 5);
        sinal_diferencial(k,:) = Retificar(sinal_diferencial(k,:));
        
        
        sinal_diferencial(k,:) = MediaMovel(sinal_diferencial(k,:),0.0005);
        sinal_diferencial(k,:) = FiltroPB(sinal_diferencial(k,:), 0.1, 200, 5);
        %vetorTempo = (1:size(sinal_diferencial(k,inicio:fim),2))/taxaAquisicao;

    end
end




[X,Y] = meshgrid(1:1:12,0:1:700000-1);%size(sinal_diferencial,2)-1);
Z = sinal_diferencial(:,10000:1:710000-1)';
surf(X,Y,Z)
for j = 1:100000
    
    axis([1 12 1+j*500 20000+j*500 0 0.1]);
    
    drawnow;
    %pause(0.1);
end


%%
plot(sinal_diferencial(1,:));
for j = 1:100000
    
    axis([1+j*100 20000+j*100 0 0.1]);
    
    drawnow;
    %pause(0.1);
end



%%








% sinal = rms(sinal, 40, 15, 1);

% sinal = MediaMovel(sinal, 0.004);
% sinal = FiltroPB(sinal, 1, 200, 5);
%sinal = RetiraDC(sinal);
% 
% figure('pos',[50 50 900 600]);
% plot(sinal);
% axis([0 size(sinal,2) -0.5 0.5]);



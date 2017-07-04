% Código para manipular dados da base icelandic

clc
clearvars;
close all;

canal = 12;
mult = 400;
ylimsub = 0.05;

nome = 'ice011_p_1of3';

%% Carrega arquivo de tocodinamometria e miografia
path_toco = 'C:\Icelandic\toco\';
toco = '_toco';
sinal_toco = load(strcat(path_toco,nome,toco,'.dat'));
path_mio = 'C:\Icelandic\mio\';
sinal_mio = load(strcat(path_mio,nome,'m.mat'));
sinal_mio = struct2cell(sinal_mio);
sinal_mio = cat(1, sinal_mio{:});
% Ajusta comprimento do array de tocodinamometria para se igualar ao de
% eletromiografia
x = 1:1:size(sinal_toco,2);
xq = linspace(1,size(sinal_toco,2),size(sinal_mio,2));
samples = 1:1:size(sinal_mio,2);
sinal_toco = interp1(x,sinal_toco,xq);

%% Faz um bipolar "fake"
ganho = 131.068;

k=0;
for i = 1:4
    for j = 1:3
        k = k+1;
        sinal_mio_diferencial(k,:) = sinal_mio((j+1)+4*(i-1),1:end)/ganho - sinal_mio(j+4*(i-1),1:end)/ganho;
        
        sinal_mio_diferencial(k,:) = FiltroPA(sinal_mio_diferencial(k,:), 0.35, 200, 5);
        sinal_mio_diferencial(k,:) = FiltroPB(sinal_mio_diferencial(k,:), 1, 200, 5);
        sinal_mio_diferencial(k,:) = Retificar(sinal_mio_diferencial(k,:));        
        
        %sinal_diferencial(k,:) = MediaMovel(sinal_diferencial(k,:),0.0005);
        %sinal_diferencial(k,:) = FiltroPB(sinal_diferencial(k,:), 0.1, 200, 5);
        %vetorTempo = (1:size(sinal_diferencial(k,inicio:fim),2))/taxaAquisicao;
    end
end
figure
hold
plot(samples,(sinal_mio_diferencial(canal,:)*mult))
plot(samples,sinal_toco - min(sinal_toco),'linewidth',2)
%xlim([2500 size(samples,2) - 1000])
ylim([0 180]);
legend('Sinal EMG (mV)','Sinal Tocodinamômetro (mmHg)')
xlabel('Amostras');

figure
for n = 1:12
    
    subplot(12,1,n); 

    plot(samples,sinal_mio_diferencial(n,:))
    xlim([2500 size(samples,2)])
    ylim([0 ylimsub])
    
end

%% filtro





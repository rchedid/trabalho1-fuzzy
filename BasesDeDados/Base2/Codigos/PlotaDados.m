% Código para plotar dados da base EHGDB

clc
clear all;
close all;

%ice002_p_1of3m.mat -> Arquivo que foi plotado as imagens do trab

%OBS: Ao trocar de arquivo deve-se alterar o axis dos plots RAW

load('../Dados/ice028_p_2of3m.mat');

% PARAMETROS
taxaAquisicao = 200;
baixa = 0.8;
alta = 3;
ordem = 5;
ganho = 131.068;
offset = 16;
step = 0.06;

% Ajuste dos sinais (retirando distorcao causada pelo filtro anti-aliasing)
inicio = 2000;
fim = size(val,2) - 2000;

%%%% VISUALIZACAO DOS 16 CANAIS MONOPOLARES
figure('pos',[50 50 900 600]);
hold on;

for i = 1:16
    sinalRAW = val(i,inicio:fim)/ganho;
    sinalRAW = sinalRAW - mean(sinalRAW);
    vetorTempo = (1:size(sinalRAW,2))/taxaAquisicao;
    legenda = int2str(i);
    plot(vetorTempo,sinalRAW,'DisplayName',legenda);
end

title('16 monopolar channels RAW');
xlabel('Time (s)');
ylabel('Signals (mV)');
axis([0 4000 -10 11]);
lgd = legend('show');
lgd.FontSize = 16;

sinalRAW = RetiraDC(sinalRAW);
sinalFiltrado = FiltroPA(sinalRAW, 0.1, 200, 2);
%sinalFiltrado = FiltroPA(sinalFiltrado, 0.1, 200, 2);

%FFT
figure('pos',[50 50 900 600]);

sinalFiltrado = sinalFiltrado(30000:end); %Retira parte distorcida pelo filtro

L=length(sinalFiltrado);
NFFT=1048576; %NFFT-point DFT	 	 
X=fft(sinalFiltrado,NFFT); %compute DFT using FFT	
% X(1) = 0; %Retira Freq 0
Px=X.*conj(X)/(NFFT*L); %Power of each freq components	 
fVals=taxaAquisicao*(0:NFFT/2-1)/NFFT;	
plot(fVals,Px(1:NFFT/2),'b','LineSmoothing','on','LineWidth',1);	 	 
title('One Sided Power Spectral Density');	 	 
xlabel('Frequency (Hz)')	 	 
ylabel('PSD');
axis([0 100 0 0.0000001]);

figure('pos',[50 50 900 600]);
plot(sinalFiltrado);
	

%%
%%%% VISUALIZACAO EM DETALHE DE 1 CANAL RAW
figure('pos',[50 50 900 600]);

canal = 1;

sinalRAW = val(canal,inicio:fim)/ganho;
vetorTempo = (1:size(sinalRAW,2))/taxaAquisicao;
legenda = int2str(canal);
plot(vetorTempo,sinalRAW,'DisplayName',legenda);
    
title('Channel 1 RAW');
xlabel('Time (s)');
ylabel('Signals (mV)');
axis([0 4000 8 22]);
lgd = legend('show');
lgd.FontSize = 16;

% Detalhe do ECG no sinal
figure('pos',[50 50 900 600]);
plot(vetorTempo,sinalRAW,'DisplayName',legenda);
    
title('Channel 1 RAW - ECG on signal');
xlabel('Time (s)');
ylabel('Signals (mV)');
axis([2700 2710 10.8 11.3]);
lgd = legend('show');
lgd.FontSize = 16;

%%
%%%% VISUALIZACAO DOS 16 CANAIS MONOPOLARES FILTRADOS
figure('pos',[50 50 900 600]);
hold on;

for i = 1:16 
    sinal = val(i,1:end)/ganho; % Sinal em mV
    sinal = sinal - sinal(1); % Retira offset
    [b,a] = butter(ordem,baixa/(taxaAquisicao/2),'high');
    sinal = filter(b,a,sinal); % Filtrado passa alta
    [b,a] = butter(ordem,alta/(taxaAquisicao/2));
    sinal = filter(b,a,sinal); % filtrado passa baixa
    
    %sinal = abs(sinal);% - mean(sinal));
    
%     for j = 1:size(sinal,2)
%         sinal(j) = rms(sinal(j));
%     end
    
    sinal = sinal(inicio:fim) + offset * step;
    vetorTempo = (1:size(sinal,2))/taxaAquisicao;
    
    legenda = int2str(i);
    plot(vetorTempo,sinal,'DisplayName',legenda);%%
    
    hold on;
    offset = offset - 1;
end

title('16 monopolar channels - bandpass filtered (0.8Hz - 3Hz)');
xlabel('Time (s)');
ylabel('Signals (mV)');
axis([0 4000 0 1]);
lgd = legend('show');
lgd.FontSize = 16.5;
%title(lgd,'Channels');

%%

%%%% VISUALIZACAO DOS 12 CANAIS BIPOLARES FILTRADOS
% Sinais calculados pela subtracao de dois canais monopolares
figure('pos',[50 50 900 600]);
hold on;

offset = 16;
step = 0.047;

k=0;
for i = 1:4
    for j = 1:3
        k = k+1;
        sinal_diferencial(k,:) = val(i+4*j,1:end)/ganho - val(i+4*(j-1),1:end)/ganho;
        
        [b,a] = butter(ordem,baixa/(taxaAquisicao/2),'high');
        sinal_diferencial(k,:) = filter(b,a,sinal_diferencial(k,:)); %Filtrado passa alta
        [b,a] = butter(ordem,alta/(taxaAquisicao/2));
        sinal_diferencial(k,:) = filter(b,a,sinal_diferencial(k,:)); %filtrado passa baixa

        %sinal_diferencial(k,:) = abs(sinal_diferencial(k,:));% Comentar ou descomentar para plotar retificado %
        
        %sinal_diferencial(k,:) = MediaMovel(sinal_diferencial(k,:),0.0002);
        
        vetorTempo = (1:size(sinal_diferencial(k,inicio:fim),2))/taxaAquisicao;

        legenda = int2str(k);
        plot(vetorTempo,sinal_diferencial(k,inicio:fim) + offset * step,'DisplayName',legenda);%%
        
        offset = offset - 1;
    end
end

title('12 bipolar channels - bandpass filtered (0.8Hz - 3Hz)');
xlabel('Time (s)');
ylabel('Signals (mV)');
axis([0 4000 0.2 0.8]);
lgd = legend('show');
lgd.FontSize = 16.5;

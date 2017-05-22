% Código para manipular dados da base TPEHG

clc
clear all;
close all;

path = 'C:\Users\raiss\Desktop\MestradoGIT\trabalho1-fuzzy\BasesDeDados\Base1\Dados\';
prefix = 'tpehg';
file = '1751';
extension = '.dat';


start = 210;
stop = 310;


fid = fopen(strcat(path,prefix,file,extension),'r');

sinais = fread(fid,[12,inf],'*int16');

sinais = double(sinais);
%plot(number(1,:));

% PARAMETROS
taxaAquisicao = 20;
% baixa = 0.8;
% alta = 3;
% ordem = 5;
ganho = 13107;
offset = 2;
step = 0.5;

% Ajuste dos sinais (retirando 180s iniciais e finais como recomendado pela base)
inicio = 3600;
fim = size(sinais,2) - 3600;

%%%% VISUALIZACAO DOS 3 CANAIS FILTRADOS (0.08 - 4Hz)
figure('pos',[50 50 900 600]);
hold on;
cont = 0;
for i = 2:4:10
    cont = cont + 1;
    sinal = sinais(i,inicio:fim)/ganho;
    %vetorTempo = (1:size(sinal,2))/taxaAquisicao;
   
    sinal = sinal + offset * step;
    legenda = int2str(i);
    plot(sinal,'DisplayName',legenda);
    
    hold on;
    offset = offset - 1;
end

title('3 bipolar channels (Filtered 0.08 Hz to 4 Hz)');
xlabel('Time (s)');
ylabel('Signals (mV)');
lgd = legend('show');
lgd.FontSize = 16;
%%
%
% %FFT
% figure('pos',[50 50 900 600]);
% 
% L=length(sinal);
% NFFT=size(sinal,2); %NFFT-point DFT	 	 
% X=fft(sinal,NFFT); %compute DFT using FFT	
% X(1) = 0; %Retira Freq 0
% Px=X.*conj(X)/(NFFT*L); %Power of each freq components	 
% fVals=taxaAquisicao*(0:NFFT/2-1)/NFFT;	
% plot(fVals,Px(1:NFFT/2),'b','LineSmoothing','on','LineWidth',1);	 	 
% title('Power Spectral Density');	 	 
% xlabel('Frequency (Hz)')	 	 
% ylabel('PSD');
% axis([0 1 0 3e-5]);



%%%% VISUALIZACAO DO RMS
figure('pos',[50 50 900 600]);
hold on;

offset = 2;
for i = 2:4:2
    sinal = sinais(i,inicio:fim)/ganho;
    
    step = 0.3;
    sinal = rms(sinal, 6, 2, 1);
    %vetorTempo = (1:size(sinal,2))*2/taxaAquisicao; %só para plot
    
%     novoSinal(cont,:) = sinal(4800:6000);
%     plot(novoSinal(cont,:));

    sinal = sinal + offset * step;
    legenda = int2str(i);
    plot(sinal,'DisplayName',legenda);
    
    hold on;
    offset = offset - 1;
end

title('RMS of the 3 filtered channels (300ms window and 100ms overlap)');
xlabel('Time (s)');
ylabel('Signals (mV)');
%axis([0 4000 -0.2 1.2]);
lgd = legend('show');
lgd.FontSize = 16;



%%%% VISUALIZACAO DA VAR
figure('pos',[50 50 900 600]);
hold on;

offset = 2;
for i = 2:4:10
    sinal = sinais(i,inicio:fim)/ganho;
    
    step = 0.001;
    sinal = variance(sinal, 6, 2, 1);
    vetorTempo = (1:size(sinal,2))*2/taxaAquisicao; %só para plot
    
    sinal = sinal + offset * step;
    legenda = int2str(i);
    plot(vetorTempo,sinal,'DisplayName',legenda);
    
    hold on;
    offset = offset - 1;
end

title('VAR of the 3 filtered channels (300ms window and 100ms overlap)');
xlabel('Time (s)');
ylabel('Signals (mV)');
%axis([0 4000 -0.2 1.2]);
lgd = legend('show');
lgd.FontSize = 16;

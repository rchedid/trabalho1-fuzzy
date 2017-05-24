% C�digo para manipular dados da base TPEHG

clc
clearvars;
close all;

path = 'C:\tpehgdb\';
prefix = 'tpehg';
file = '618';
extension = '.dat';

fid = fopen(strcat(path,prefix,file,extension),'r'); % abre arquivo .dat
sinais = fread(fid,[12,inf],'*int16'); % l� os sinais do arquivo em int16
sinais = double(sinais);

% PARAMETROS
taxaAquisicao = 20;
% baixa = 0.8;
% alta = 3;
% ordem = 5;
ganho = 13107;
offset = 2;
% step = 0.5;

%discard_size = 10;   %prop�sito de teste
%M(1,:) = linspace(1,100);
%M(2,:) = linspace(1,100);
%M = M(:,1+discard_size:end)

% Ajuste dos sinais (retirando 180s iniciais e finais como recomendado pela base)
% "When using filtered channels, note that the first and last 180 seconds of the 
% signals should be ignored since these intervals contain transient effects
% of the filters."
discard_size = 180*taxaAquisicao; % 180 segundos multiplicado pela frequ�ncia de amostragem (20hz)
sinais = sinais(:,1+discard_size:end); % corta fora os primeiros 180 segundos do sinal filtrado
size_sinais = size(sinais,2); %pega o n�mer ode amostras do sinal

t = linspace(0,size_sinais-1,size_sinais)*0.05; %gera o vetor do tempo em segundos

sinais_mv = sinais.*5./(2^16); %gera os sinais em milivolts
%The individual records are 30 minutes in duration. Each signal has been 
%digitized at 20 samples per second per channel with 16-bit resolution over 
%a range of �2.5 millivolts

%%%% VISUALIZACAO DOS 3 CANAIS FILTRADOS (0.08 - 4Hz)

%sinais_mv([1,5,9],:) = []; % remove os sinais n�o filtrados (n�o
%interessam) e deixa os que tem filtro

filt = 1; %define filtro a ser usado (1: 0.08Hz to 4Hz. 2: 0.3Hz to 3Hz 3: 0.3Hz to 4Hz)

sinais_mv = sinais_mv([1+filt,5+filt,9+filt],:); %seleciona os sinais do filtro escolhido

%sinais_mv = abs(sinais_mv); % Retifica o sinal


subplot(4,1,1);   % plota os 3 canais
plot(t,sinais_mv(1,:));
title('Canal 1')
subplot(4,1,2);
plot(t,sinais_mv(2,:),'k');
title('Canal 2')
subplot(4,1,3);
plot(t,sinais_mv(3,:),'r'); 
title('Canal 3')


sinais_rect = abs(sinais_mv); % Retifica o sinal
%[sinais_upper,sinais_lower] = envelope(sinais_mv,1500,'rms');
sinal_rms = windowed_rms(sinais_rect(1,:), 100, 10, 1);

size_sinal_rms = size(sinal_rms,2); %pega o n�mer ode amostras do sinal rms
t_rms = linspace(0,size_sinal_rms-1,size_sinal_rms); %gera o vetor do tempo em samples 

Smooth_window = 30*taxaAquisicao;
DURATION = 0.05*taxaAquisicao;
threshold_style = 1;
gr = 0;

alarm = envelop_hilbert_v2(sinais_mv(2,:),Smooth_window,threshold_style,DURATION,gr);

alarm2 = round(resample(alarm,size_sinais,size(alarm,2)));


subplot(4,1,4);
plot(t,alarm2); 
title('Canal 3')
%{

plot(t_rms,sinal_rms);

figure

subplot(3,1,1);   % plota os 3 canais e o envelope
plot(t,sinais_rect(1,:));
title('Canal 1')
subplot(3,1,2);
plot(t,sinais_rect(2,:),'k');
title('Canal 2')
subplot(3,1,3);
plot(t,sinais_rect(3,:),'r');
title('Canal 3')




figure

subplot(2,1,1);   % plota os 2 canais
plot(t,sinais_mv(1,:));
title('Sinal')
subplot(2,1,2);
plot(t_rms, sinal_rms);;
title('RMS do Sinal')



hold off;
cont = 0;

start = 14000;
stop = 16500;



for i = 10:10
    cont = cont + 1;
    sinal = sinais(i,inicio:fim)/ganho;
%     sinal = sinais(i,start:stop)/ganho;
% 
%     RMS = rms(sinal)
%     VAR = var(sinal)

    %sinal = windowed_rms(sinal, 6, 2, 1);
    sinal = Retificar(sinal);
    sinal = MediaMovel(sinal,0.02);
    sinal = FiltroPB(sinal, 0.09,20,8);

%     legenda = int2str(i);
    
     plot(sinal);
%     
%     hold on;
    offset = offset - 1;
end


% title('3 bipolar channels (Filtered 0.08 Hz to 4 Hz)');
% xlabel('Time (s)');
% ylabel('Signals (mV)');
% lgd = legend('show');
% lgd.FontSize = 16;
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
    %vetorTempo = (1:size(sinal,2))*2/taxaAquisicao; %s� para plot
    
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
    vetorTempo = (1:size(sinal,2))*2/taxaAquisicao; %s� para plot
    
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

%}

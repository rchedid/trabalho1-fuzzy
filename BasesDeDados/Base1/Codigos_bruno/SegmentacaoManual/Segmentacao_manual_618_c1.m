% Código para fazer a segmentação manual das contrações em cada canal de
% cada aquisição

clc;
clearvars;
close all;

path = 'C:\tpehgdb\';
prefix = 'tpehg';
file = '618';
extension = '.dat';

fid = fopen(strcat(path,prefix,file,extension),'r'); % abre arquivo .dat
sinais = fread(fid,[12,inf],'*int16'); % lê os sinais do arquivo em int16
sinais = double(sinais);

%% PARAMETROS
    
    %Parâmetros básicos
    taxaAquisicao = 20; %Taxa de aquisição da base de dados
    numero_de_contracoes = 11;
    canal_analizado = 1;              %Seleciona o canal que se quer segmentar

    %Parâmetros do segmentador
    Smooth_window = 30*taxaAquisicao; %this is the window length used for smoothing your signal 
    DURATION = 0.05*taxaAquisicao;    %Number of the samples that the signal should stay
    threshold_style = 1;              %Set it 1 to have an adaptive threshold and set it 0
                                      % to manually select the threshold from a plot
    gr = 0;                           %Make it 1 if you want a plot and 0 when you dont want a plot
    
    %----------------------------------------------------------------------
    
    filt = 1; %define filtro a ser usado (1: 0.08Hz to 4Hz. 2: 0.3Hz to 3Hz 3: 0.3Hz to 4Hz)

    
%% Ajuste dos sinais (retirando 180s iniciais e finais como recomendado pela base)
% "When using filtered channels, note that the first and last 180 seconds of the 
% signals should be ignored since these intervals contain transient effects
% of the filters."
discard_size = 180*taxaAquisicao; % 180 segundos multiplicado pela frequência de amostragem (20hz)
sinais = sinais(:,1+discard_size:end); % corta fora os primeiros 180 segundos do sinal filtrado
size_sinais = size(sinais,2); %pega o númer ode amostras do sinal

t = linspace(0,size_sinais-1,size_sinais)*0.05; %gera o vetor do tempo em segundos
t = linspace(0,size_sinais-1,size_sinais); %gera o vetor do tempo em samples

sinais_mv = sinais.*5./(2^16); %gera os sinais em milivolts
%The individual records are 30 minutes in duration. Each signal has been 
%digitized at 20 samples per second per channel with 16-bit resolution over 
%a range of ±2.5 millivolts

%% VISUALIZACAO DOS 3 CANAIS FILTRADOS (0.08 - 4Hz)

sinais_mv = sinais_mv([1+filt,5+filt,9+filt],:); %seleciona os sinais do filtro escolhido

subplot(3,1,1);   % plota os 3 canais
plot(t,sinais_mv(1,:));
title('Canal 1')
subplot(3,1,2);
plot(t,sinais_mv(2,:),'k');
title('Canal 2')
subplot(3,1,3);
plot(t,sinais_mv(3,:),'r'); 
title('Canal 3')


 %% Segmentação manual

figure;
grid;

s1_i = 2084;  % Inicio da contração 1
s1_f = 2856;  % Fim da contração    1
timestamp1 = linspace(s1_i,s1_f,s1_f-s1_i+1);
seg1 = sinais_mv(1,1+s1_i:s1_f); % corta fora a contração selecionada
t1 = linspace(0,s1_f-s1_i-1,s1_f-s1_i)*0.05; % Faz vetor de tempo correspondente em segunds

subplot(4,3,1);   % plota
plot(t1,seg1);
grid;
title('Contração 1');

%___________________________________________________-
 
s2_i = 3218;  % Inicio da contração 1
s2_f = 5685;  % Fim da contração    1
timestamp2 = linspace(s2_i,s2_f,s2_f-s2_i+1);
seg2 = sinais_mv(1,1+s2_i:s2_f); % corta fora a contração selecionada
t2 = linspace(0,s2_f-s2_i-1,s2_f-s2_i)*0.05; % Faz vetor de tempo correspondente em segunds

subplot(4,3,2);   % plota
plot(t2,seg2);
grid;
title('Contração 2');

%_____________________________________________________
 
s3_i = 6745;  % Inicio da contração 1
s3_f = 8845;  % Fim da contração    1
timestamp3 = linspace(s3_i,s3_f,s3_f-s3_i+1);
seg3 = sinais_mv(1,1+s3_i:s3_f); % corta fora a contração selecionada
t3 = linspace(0,s3_f-s3_i-1,s3_f-s3_i)*0.05; % Faz vetor de tempo correspondente em segunds

subplot(4,3,3);   % plota
plot(t3,seg3);
grid;
title('Contração 3');

s4_i = 9860;  % Inicio da contração 1
s4_f = 11080;  % Fim da contração    1
timestamp4 = linspace(s4_i,s4_f,s4_f-s4_i+1);
seg4 = sinais_mv(1,1+s4_i:s4_f); % corta fora a contração selecionada
t4 = linspace(0,s4_f-s4_i-1,s4_f-s4_i)*0.05; % Faz vetor de tempo correspondente em segunds

subplot(4,3,4);   % plota
plot(t4,seg4);
grid;
title('Contração 4');

%_____________________________________________________
 
s5_i = 12280;  % Inicio da contração 1
s5_f = 13340;  % Fim da contração    1
timestamp5 = linspace(s5_i,s5_f,s5_f-s5_i+1);
seg5 = sinais_mv(1,1+s5_i:s5_f); % corta fora a contração selecionada
t5 = linspace(0,s5_f-s5_i-1,s5_f-s5_i)*0.05; % Faz vetor de tempo correspondente em segunds

subplot(4,3,5);   % plota
plot(t5,seg5);
grid;
title('Contração 5');

%_____________________________________________________
 
s6_i = 14440;  % Inicio da contração 1
s6_f = 15660;  % Fim da contração    1
timestamp6 = linspace(s6_i,s6_f,s6_f-s6_i+1);
seg6 = sinais_mv(1,1+s6_i:s6_f); % corta fora a contração selecionada
t6 = linspace(0,s6_f-s6_i-1,s6_f-s6_i)*0.05; % Faz vetor de tempo correspondente em segunds

subplot(4,3,6);   % plota
plot(t6,seg6);
grid;
title('Contração 6');

%_____________________________________________________
 
s7_i = 17410;  % Inicio da contração 1
s7_f = 18310;  % Fim da contração    1
timestamp7 = linspace(s7_i,s7_f,s7_f-s7_i+1);
seg7 = sinais_mv(1,1+s7_i:s7_f); % corta fora a contração selecionada
t7 = linspace(0,s7_f-s7_i-1,s7_f-s7_i)*0.05; % Faz vetor de tempo correspondente em segunds

subplot(4,3,7);   % plota
plot(t7,seg7);
grid;
title('Contração 7');

%_____________________________________________________
 
s8_i = 19940;  % Inicio da contração 1
s8_f = 20770;  % Fim da contração    1
timestamp8 = linspace(s8_i,s8_f,s8_f-s8_i+1);
seg8 = sinais_mv(1,1+s8_i:s8_f); % corta fora a contração selecionada
t8 = linspace(0,s8_f-s8_i-1,s8_f-s8_i)*0.05; % Faz vetor de tempo correspondente em segunds

subplot(4,3,8);   % plota
plot(t8,seg8);
grid;
title('Contração 8');

%_____________________________________________________
 
s9_i = 23540;  % Inicio da contração 1
s9_f = 24600;  % Fim da contração    1
timestamp9 = linspace(s9_i,s9_f,s9_f-s9_i+1);
seg9 = sinais_mv(1,1+s9_i:s9_f); % corta fora a contração selecionada
t9 = linspace(0,s9_f-s9_i-1,s9_f-s9_i)*0.05; % Faz vetor de tempo correspondente em segunds

subplot(4,3,9);   % plota
plot(t9,seg9);
grid;
title('Contração 9');

%_____________________________________________________
 
s10_i = 26420;  % Inicio da contração 1
s10_f = 27310;  % Fim da contração    1
timestamp10 = linspace(s10_i,s10_f,s10_f-s10_i+1);
seg10 = sinais_mv(1,1+s10_i:s10_f); % corta fora a contração selecionada
t10 = linspace(0,s10_f-s10_i-1,s10_f-s10_i)*0.05; % Faz vetor de tempo correspondente em segunds

subplot(4,3,10);   % plota
plot(t10,seg10);
grid;
title('Contração 10');

%_____________________________________________________
 
s11_i = 29650;  % Inicio da contração 1
s11_f = 30520;  % Fim da contração    1
timestamp11 = linspace(s11_i,s11_f,s11_f-s11_i+1);
seg11 = sinais_mv(1,1+s11_i:s11_f); % corta fora a contração selecionada
t11 = linspace(0,s11_f-s11_i-1,s11_f-s11_i)*0.05; % Faz vetor de tempo correspondente em segunds

subplot(4,3,11);   % plota
plot(t11,seg11);
grid;
title('Contração 11');

%_____________________________________________________
 


%{ 
s3_i = 
s3_f = 

s4_i = 
s4_f = 

s5_i = 
s5_f = 

s6_i = 
s6_f = 

s7_i = 
s7_f = 

s8_i = 
s8_f = 

s9_i = 
s9_f = 

s10_i = 
s10_f = 

s11_i = 
s11_f = 

s12_i = 
s12_f = 





%% Pré processamento do sinal
sinais_rect = abs(sinais_mv); % Retifica o sinal
%[sinais_upper,sinais_lower] = envelope(sinais_mv,1500,'rms');
sinal_rms = windowed_rms(sinais_rect(1,:), 100, 10, 1);

size_sinal_rms = size(sinal_rms,2); %pega o númer ode amostras do sinal rms
t_rms = linspace(0,size_sinal_rms-1,size_sinal_rms); %gera o vetor do tempo em samples 

timestamp = envelop_hilbert_v2(sinais_mv(2,:),Smooth_window,threshold_style,DURATION,gr);

timestamp2 = round(resample(timestamp,size_sinais,size(timestamp,2))); %Ajusta o tamanho do timestamp

subplot(4,1,4);
plot(t,timestamp2);

title(sprintf('Janelamento do Canal %d',canal_analizado))


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

%}

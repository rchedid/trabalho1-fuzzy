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

per_amostr = 1/taxaAquisicao; % período de amostragem
t = linspace(0,size_sinais-1,size_sinais)*per_amostr; %gera o vetor do tempo em segundos
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

% Inicio das contrações
% Fim das contrações

inicio_c = [2084 3218 6745 9860 12280 14440 17410 19940 23540 26420 29650];
fim_c = [2856 5685 8845 11080 13340 15660 18310 20770 24600 27310 30520];

%inicio_c = [10 30 50 70 90];   % para teste apenas
%fim_c = [20 40 60 80 100];

l_plot = size(fim_c,2);   % Gera a disposição dos subplots automaticamente
aux = round(sqrt(l_plot));
for i = 1:100
    if i*aux >= l_plot 
        h_plot = i;
        break;
    end    
end
l_plot = aux;
figure;

for i = 1:size(fim_c,2)
   
    segmento{i} = sinais_mv(1,1+inicio_c(i):fim_c(i)); % corta fora a contração selecionada
    tempo{i} = (1:size(segmento{i},2)).*per_amostr;  % Faz vetor de tempo correspondente em segunds

    subplot(h_plot,l_plot,i);
    plot(tempo{i},segmento{i});
    grid
    title(sprintf('Contração %d',i));
    
    
    temp_rms = windowed_rms(segmento{i},20,0,0);
    temp_var = variance(segmento{i},20,0,0); 
    rms_seg(i) = mean(temp_rms);
    var_seg(i) = mean(temp_var);
    
    clear temp_rms
    clear temp_var
end

% pega duração média das contrações em segundos
for i = 1:size(fim_c,2)
    dura(i) = fim_c(i)  - inicio_c(i);
end
duracao_med = sum(dura)/size(fim_c,2)*per_amostr;

% pega frequência entre as contrações em Hz
for i = 1:size(fim_c,2)-1
    inter_centr(i) = ((fim_c(i+1)  + inicio_c(i+1)) - (fim_c(i)  + inicio_c(i)))/2;
end    
freq_med = 1/((sum(inter_centr)/(size(fim_c,2)-1))*per_amostr);

% pega intervalo entre inicio e fim de cada contração em segundos
for i = 1:size(fim_c,2)-1
    inter(i) = inicio_c(i+1) - fim_c(i); %     ((fim_c(i+1)  + inicio_c(i+1)) - (fim_c(i)  + inicio_c(i)))/2;
end 
intervalo_med = (sum(inter)/(size(fim_c,2)-1))*per_amostr

%xlswrite('contracoes.xlsx',seg1,'seg1');

%{ 


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


%}

clearvars -except duracao_med intervalo_med freq_med rms_seg var_seg  %deixar aqui só o que nos interessa

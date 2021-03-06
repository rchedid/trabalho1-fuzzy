
% C�digo para fazer a segmenta��o manual das contra��es em cada canal de
% cada aquisi��o

clc;
clearvars;
close all;

coleta = 15;


% Vetores de inicio e fim das contra��es
inicio_c = [2211 12190 17970 22030 25900 29440];
fim_c =    [5067 13580 20620 23560 28080 30990];

canal_analizado = 1;              %Seleciona o canal que se quer segmentar

sem_parto = 38;

path = 'C:\tpehgdb\';
prefix = 'tpehg';
file = '1747';
extension = '.dat';

fid = fopen(strcat(path,prefix,file,extension),'r'); % abre arquivo .dat
sinais = fread(fid,[12,inf],'*int16'); % l� os sinais do arquivo em int16
sinais = double(sinais);

%%%% PARAMETROS

%Par�metros b�sicos
taxaAquisicao = 20; %Taxa de aquisi��o da base de dados

%Par�metros do segmentador
Smooth_window = 30*taxaAquisicao; %this is the window length used for smoothing your signal 
DURATION = 0.05*taxaAquisicao;    %Number of the samples that the signal should stay
threshold_style = 1;              %Set it 1 to have an adaptive threshold and set it 0
                                  % to manually select the threshold from a plot
gr = 0;                           %Make it 1 if you want a plot and 0 when you dont want a plot

%----------------------------------------------------------------------

%% FILTRO E DESCARTE DO INICIO DO SINAL

filt = 0; %define o sinal a ser usado da base (0: sem filtro 1: 0.08Hz to 4Hz. 2: 0.3Hz to 3Hz 3: 0.3Hz to 4Hz)

sinais_sep = sinais([1+filt,5+filt,9+filt],:); %seleciona os sinais do filtro escolhido

% FILTRO 0.35 a 1Hz
% citar artigo que fala desta frequencia

ORDEM = 8; % ordem do filtro

for i = 1:3
sinais_filt(i,:) = FiltroPA(sinais_sep(i,:),0.35,taxaAquisicao,ORDEM);
sinais_filt(i,:) = FiltroPB(sinais_filt(i,:),1,taxaAquisicao,ORDEM);
end
    
%%%% Ajuste dos sinais (retirando 180s iniciais e finais como recomendado pela base)
% "When using filtered channels, note that the first and last 180 seconds of the 
% signals should be ignored since these intervals contain transient effects
% of the filters."
discard_size = 180*taxaAquisicao; % 180 segundos multiplicado pela frequ�ncia de amostragem (20hz)
sinais_filt = sinais_filt(:,1+discard_size:end); % corta fora os primeiros 180 segundos do sinal filtrado
size_sinais = size(sinais_filt,2); %pega o n�mero de amostras do sinal

periodo_amostra = 1/taxaAquisicao; % per�odo de amostragem
t = linspace(0,size_sinais-1,size_sinais); %gera o vetor do tempo em samples

sinais_mv = sinais_filt.*5./(2^16); %gera os sinais em milivolts
%The individual records are 30 minutes in duration. Each signal has been 
%digitized at 20 samples per second per channel with 16-bit resolution over 
%a range of �2.5 millivolts

%%%% VISUALIZACAO DOS 3 CANAIS FILTRADOS (0.08 - 4Hz)

mixed_plot = 0; % escolhe se o sinal ser� plotado separado de sua DWT (0) ou junto (1)


%% "DENOISE" USANDO TRANSFORMADA DE WAVELET DISCRETA

% decompor o sinal usando a transformada de wavelet discreta:
f1 = sinais_mv(1,:);
f2 = sinais_mv(2,:);
f3 = sinais_mv(3,:);


TPTR = 'modwtsqtwolog'; % threshold selection rule"
SORH = 's'; % is for soft or hard thresholding
SCAL = 'mln'; % defines multiplicative threshold rescaling
N = 10; % Wavelet decomposition is performed at N level
wname = 'db4'; % is a character vector containing the name of the desired orthogonal wavelet

sinais_mv_dwt(1,:) = wden(f1,TPTR,SORH,SCAL,N,wname);
sinais_mv_dwt(2,:) = wden(f2,TPTR,SORH,SCAL,N,wname);
sinais_mv_dwt(3,:) = wden(f3,TPTR,SORH,SCAL,N,wname);


if mixed_plot
    subplot(3,1,1);   % plota os 3 canais sem e com dwt
    plot(t,sinais_mv(1,:),t,sinais_mv_dwt(1,:),'r');
    title('Canal 1')
    subplot(3,1,2);
    plot(t,sinais_mv(2,:),t,sinais_mv_dwt(2,:),'r');
    title('Canal 2')
    subplot(3,1,3);
    plot(t,sinais_mv(3,:),t,sinais_mv_dwt(3,:),'r'); 
    title('Canal 3')
else
    subplot(3,1,1);   % plota os 3 canais
    plot(t,sinais_mv(1,:),'r');
    title('Canal 1')
    subplot(3,1,2);
    plot(t,sinais_mv(2,:),'r');
    title('Canal 2')
    subplot(3,1,3);
    plot(t,sinais_mv(3,:),'r'); 
    title('Canal 3')

    figure;
    subplot(3,1,1);   % plota os 3 com dwt
    plot(t,sinais_mv_dwt(1,:));
    title('Canal 1 dwt')
    subplot(3,1,2);
    plot(t,sinais_mv_dwt(2,:));
    title('Canal 2 dwt')
    subplot(3,1,3);
    plot(t,sinais_mv_dwt(3,:)); 
    title('Canal 3 dwt')
end



%% Segmenta��o manual

%%%% C�lculo das caracter�sticas 

l_plot = size(fim_c,2);   % Gera a disposi��o dos subplots automaticamente
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
    
    % Separa a contra��o i
    segmento{i} = sinais_mv(canal_analizado,1+inicio_c(i):fim_c(i)); 
    tempo{i} = (1:size(segmento{i},2)).*periodo_amostra; % Tempo em segundos

    % Plota contra��o i em subplots
    subplot(h_plot,l_plot,i);
    plot(tempo{i},segmento{i});
    grid
    title(sprintf('Contra��o %d',i));
    
    % Extraindo as features escolhidas por janelamento (1s)
    temp_rms = windowed_rms(segmento{i},20,0,0);
    temp_var = variance(segmento{i},20,0,0); 
    rms_seg(i) = mean(temp_rms);
    var_seg(i) = mean(temp_var);
    
    %Extraindo PEAK FREQUENCY
    N = length(segmento{i});
    xdft = fft(segmento{i});
    xdft = xdft(1:N/2+1);
    psdx = (1/(taxaAquisicao*N)) * abs(xdft).^2;
    psdx(2:end-1) = 2*psdx(2:end-1);
    freq = 0:taxaAquisicao/length(segmento{i}):taxaAquisicao/2;
    [maximo,index] = max(psdx);
    peak_frequency(i) = freq(index);
    
    %Extraindo Sample Entropy
    samp_en(i) = SampEn(segmento{i},2,0.2);
    
    
    % Limpa vari�veis tempor�rias
    clear temp_rms
    clear temp_var
end

% Pega valor m�ximo, m�nimo e m�dio do RMS
rms_min = min(rms_seg);
rms_max = max(rms_seg);
rms_med = mean(rms_seg);

% Pega valor m�ximo, m�nimo e m�dio da vari�ncia
var_min = min(var_seg);
var_max = max(var_seg);
var_med = mean(var_seg);

% Pega valor m�ximo, m�nimo e m�dio da frequencia de pico
peak_frequency_min = min(peak_frequency);
peak_frequency_max = max(peak_frequency);
peak_frequency_med = mean(peak_frequency);

%pega a sample entropy
samp_en_min = min(samp_en);
samp_en_max = max(samp_en);
samp_en_med = mean(samp_en);

% pega dura��o m�dia das contra��es em segundos
for i = 1:size(fim_c,2)
    duracao_seg(i) = fim_c(i)  - inicio_c(i);
end
duracao_med = mean(duracao_seg)*periodo_amostra;

% pega frequ�ncia entre as contra��es em Hz
for i = 1:size(fim_c,2)-1
    %inter_centr(i) = ( (((fim_c(i+1) + inicio_c(i+1))/2)+inicio_c(i+1)) - (((fim_c(i) + inicio_c(i))/2)+inicio_c(i)) );
    inter_centr(i) = ((fim_c(i+1)  + inicio_c(i+1)) - (fim_c(i)  + inicio_c(i)))/2;
end    
freq_med = 1/((sum(inter_centr)/(size(fim_c,2)-1))*periodo_amostra);

% pega intervalo entre inicio e fim de cada contra��o em segundos
for i = 1:size(fim_c,2)-1
    inter(i) = inicio_c(i+1) - fim_c(i); %     ((fim_c(i+1)  + inicio_c(i+1)) - (fim_c(i)  + inicio_c(i)))/2;
end 
intervalo_med = (sum(inter)/(size(fim_c,2)-1))*periodo_amostra;

caracteristicas(coleta,:) = [str2num(file) sem_parto rms_min rms_max rms_med var_min var_max var_med peak_frequency_min peak_frequency_max peak_frequency_med samp_en_min samp_en_max samp_en_med duracao_med freq_med intervalo_med];

posicao_excel = strcat('A',num2str(coleta+1));

% Escrevendo caracter�sticas no excel
cabecalho_excel = {'Arquivo','SemanaParto','RMS_min','RMS_max','RMS_med','VAR_min','VAR_max','VAR_med','PF_min','PF_max','PF_med','SE_min','SE_max','SE_med','Dur_med','Freq_med','Inter_med'};
xlswrite('FeaturesContracoesWaveletTerm.xlsx',cabecalho_excel,'Features','A1');
xlswrite('FeaturesContracoesWaveletTerm.xlsx',caracteristicas(coleta,:),'Features',posicao_excel);

%clearvars -except caracteristicas duracao_med intervalo_med freq_med rms_min rms_max rms_med var_min var_max var_med  %deixar aqui s� o que nos interessa
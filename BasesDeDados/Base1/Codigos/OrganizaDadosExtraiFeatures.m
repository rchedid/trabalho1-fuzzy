% Código para automatizar extracao de features

clc;
clearvars;
close all;

%% CARREGA ARQUIVOS COM OS INTERVALOS DAS CONTRAÇÕES
diretorio = 'C:\Users\raiss\Desktop\MestradoGIT\trabalho1-fuzzy\BasesDeDados\Base1\Codigos_bruno\SegmentacaoManual\';
pre_files = dir(strcat(diretorio,'pre\'));
term_files = dir(strcat(diretorio,'term\'));

for i = 3:size(pre_files,1)
    pre{i-2} = dlmread(strcat(diretorio,'pre\',pre_files(i).name));
end

for i = 3:size(term_files,1)
    term{i-2} = dlmread(strcat(diretorio,'term\',term_files(i).name));
end


%% CARREGA SINAIS A PARTIR DOS ARQUIVOS DAS CONTRAÇÕES
path = 'C:\tpehgdb\';

for i = 1:size(pre,2)
    
    file = num2str(pre{i}(1));

    fid = fopen(strcat(path,'tpehg',file,'.dat'),'r'); % abre arquivo .dat
    sinais_pre{i} = double(fread(fid,[12,inf],'*int16')); % lê os sinais do arquivo em int16
    fclose(fid);

end

for i = 1:size(term,2)
    
    file = num2str(term{i}(1));

    fid = fopen(strcat(path,'tpehg',file,'.dat'),'r'); % abre arquivo .dat
    sinais_term{i} = double(fread(fid,[12,inf],'*int16')); % lê os sinais do arquivo em int16
    fclose(fid);

end

%%

%%%% PARAMETROS

%Parâmetros básicos
taxaAquisicao = 20; %Taxa de aquisição da base de dados

%Parâmetros do segmentador
Smooth_window = 30*taxaAquisicao; %this is the window length used for smoothing your signal 
DURATION = 0.05*taxaAquisicao;    %Number of the samples that the signal should stay
threshold_style = 1;              %Set it 1 to have an adaptive threshold and set it 0
                                  % to manually select the threshold from a plot
gr = 0;                           %Make it 1 if you want a plot and 0 when you dont want a plot

%----------------------------------------------------------------------

filt = 1; %define filtro a ser usado (1: 0.08Hz to 4Hz. 2: 0.3Hz to 3Hz 3: 0.3Hz to 4Hz)

    
%%%% Ajuste dos sinais (retirando 180s iniciais e finais como recomendado pela base)
% "When using filtered channels, note that the first and last 180 seconds of the 
% signals should be ignored since these intervals contain transient effects
% of the filters."
discard_size = 180*taxaAquisicao; % 180 segundos multiplicado pela frequência de amostragem (20hz)
sinais = sinais(:,1+discard_size:end); % corta fora os primeiros 180 segundos do sinal filtrado
size_sinais = size(sinais,2); %pega o númer ode amostras do sinal

periodo_amostra = 1/taxaAquisicao; % período de amostragem
%t = linspace(0,size_sinais-1,size_sinais)*per_amostr; %gera o vetor do tempo em segundos
t = linspace(0,size_sinais-1,size_sinais); %gera o vetor do tempo em samples

sinais_mv = sinais.*5./(2^16); %gera os sinais em milivolts
%The individual records are 30 minutes in duration. Each signal has been 
%digitized at 20 samples per second per channel with 16-bit resolution over 
%a range of ±2.5 millivolts

%%%% VISUALIZACAO DOS 3 CANAIS FILTRADOS (0.08 - 4Hz)

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

coleta = 1;

% Vetores de inicio e fim das contrações
inicio_c = [4308 15770];
fim_c =    [5023 16130];

canal_analizado = 3;              %Seleciona o canal que se quer segmentar

sem_parto = 40.43;

%%%% Cálculo das características 

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
    
    % Separa a contração i
    segmento{i} = sinais_mv(canal_analizado,1+inicio_c(i):fim_c(i)); 
    tempo{i} = (1:size(segmento{i},2)).*periodo_amostra; % Tempo em segundos

    % Plota contração i em subplots
    subplot(h_plot,l_plot,i);
    plot(tempo{i},segmento{i});
    grid
    title(sprintf('Contração %d',i));
    
    % Extraindo as features escolhidas por janelamento (1s)
    temp_rms = windowed_rms(segmento{i},20,0,0);
    temp_var = variance(segmento{i},20,0,0); 
    rms_seg(i) = mean(temp_rms);
    var_seg(i) = mean(temp_var);
    
    % Limpa variáveis temporárias
    clear temp_rms
    clear temp_var
end

% Pega valor máximo, mínimo e médio do RMS
rms_min = min(rms_seg);
rms_max = max(rms_seg);
rms_med = mean(rms_seg);

% Pega valor máximo, mínimo e médio da variância
var_min = min(var_seg);
var_max = max(var_seg);
var_med = mean(var_seg);

% pega duração média das contrações em segundos
for i = 1:size(fim_c,2)
    duracao_seg(i) = fim_c(i)  - inicio_c(i);
end
duracao_med = mean(duracao_seg)*periodo_amostra;

% pega frequência entre as contrações em Hz
for i = 1:size(fim_c,2)-1
    %inter_centr(i) = ( (((fim_c(i+1) + inicio_c(i+1))/2)+inicio_c(i+1)) - (((fim_c(i) + inicio_c(i))/2)+inicio_c(i)) );
    inter_centr(i) = ((fim_c(i+1)  + inicio_c(i+1)) - (fim_c(i)  + inicio_c(i)))/2;
end    
freq_med = 1/((sum(inter_centr)/(size(fim_c,2)-1))*periodo_amostra);

% pega intervalo entre inicio e fim de cada contração em segundos
for i = 1:size(fim_c,2)-1
    inter(i) = inicio_c(i+1) - fim_c(i); %     ((fim_c(i+1)  + inicio_c(i+1)) - (fim_c(i)  + inicio_c(i)))/2;
end 
intervalo_med = (sum(inter)/(size(fim_c,2)-1))*periodo_amostra;

caracteristicas(coleta,:) = [str2num(file) sem_parto rms_min rms_max rms_med var_min var_max var_med duracao_med freq_med intervalo_med];

posicao_excel = strcat('A',num2str(coleta+1));

% Escrevendo características no excel
% cabecalho_excel = {'Arquivo','SemanaParto','RMS_min','RMS_max','RMS_med','VAR_min','VAR_max','VAR_med','Dur_med','Freq_med','Inter_med'};
% xlswrite('FeaturesContracoes.xlsx',cabecalho_excel,'Features','A1');
% xlswrite('FeaturesContracoes.xlsx',caracteristicas(coleta,:),'Features',posicao_excel);

clearvars -except caracteristicas duracao_med intervalo_med freq_med rms_min rms_max rms_med var_min var_max var_med  %deixar aqui só o que nos interessa

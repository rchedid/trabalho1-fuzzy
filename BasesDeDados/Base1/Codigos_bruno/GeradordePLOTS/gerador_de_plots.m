% Código para organizar dados da base

clc
clearvars;
close all;


path = 'C:\Users\bruno\Google Drive\AA_ Base_de _dados\4ch_database\';

extension = '.dat';


arquivos = importdata('C:\Users\bruno\Google Drive\AA_ Base_de _dados\4ch_database\RECORDS');

taxaAquisicao = 20;
inicio = 3600;

ganho = 13107;

cont = 0;

figPath = '..\GeradordePLOTS\Resultados\';

for j = 276:size(arquivos)
    fig = figure(j);
    
    fid = fopen(strcat(path,char(arquivos(j)),extension),'r');

    sinais = double(fread(fid,[12,inf],'*int16'));
    
    filt = 0; %define o sinal a ser usado da base (0: sem filtro 1: 0.08Hz to 4Hz. 2: 0.3Hz to 3Hz 3: 0.3Hz to 4Hz)

    sinais_sep = sinais([1+filt,5+filt,9+filt],:); %seleciona os sinais do filtro escolhido
    
    ORDEM = 8; % ordem do filtro

    for i = 1:3
    sinais_filt(i,:) = FiltroPA(sinais_sep(i,:),0.35,taxaAquisicao,ORDEM);
    sinais_filt(i,:) = FiltroPB(sinais_filt(i,:),1,taxaAquisicao,ORDEM);
    end
    
    discard_size = 180*20; % 180 segundos multiplicado pela frequência de amostragem (20hz)
    sinais_filt = sinais_filt(:,1+discard_size:end); % corta fora os primeiros 180 segundos do sinal filtrado
    size_sinais = size(sinais_filt,2); %pega o número de amostras do sinal

    periodo_amostra = 1/20; % período de amostragem
    t = linspace(0,size_sinais-1,size_sinais); %gera o vetor do tempo em samples

    sinais_mv = sinais_filt.*5./(2^16); %gera os sinais em milivolts
    
    
    % decompor o sinal usando a transformada de wavelet discreta:
    f1 = sinais_mv(1,:);
    f2 = sinais_mv(2,:);
    f3 = sinais_mv(3,:);


    TPTR = 'modwtsqtwolog'; % threshold selection rule"
    SORH = 's'; % is for soft or hard thresholding
    SCAL = 'mln'; % defines multiplicative threshold rescaling
    N = 10; % Wavelet decomposition is performed at N level
    wname = 'dmey'; % is a character vector containing the name of the desired orthogonal wavelet

    sinais_mv_dwt(1,:) = wden(f1,TPTR,SORH,SCAL,N,wname);
    sinais_mv_dwt(2,:) = wden(f2,TPTR,SORH,SCAL,N,wname);
    sinais_mv_dwt(3,:) = wden(f3,TPTR,SORH,SCAL,N,wname);

    for i = 1:3
            

        %%% SINAL RAW
        
        vetorSegundos = t/20; 

        subplot(3,1,i);
        plot(vetorSegundos,sinais_mv_dwt(i,:));
        xlabel('Time (s)');
        ylabel('Signals (mV)');
    end
    print(fig,strcat(figPath,char(arquivos(j))),'-dpng');
    clear sinaisDeInteresse sinais_filt sinais_mv_dwt
    fclose(fid);
    
end
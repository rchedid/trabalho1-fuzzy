% C�digo para automatizar extracao de features
clc;
clearvars;
close all;

%% CARREGA ARQUIVOS COM OS INTERVALOS DAS CONTRA��ES
diretorio = 'C:\Icelandic\timestamp\';
labour_files = dir(strcat(diretorio,'labour\'));
nonlabour_files = dir(strcat(diretorio,'nonlabour\'));

for n_canal = 3:size(labour_files,1)       
    labour_name{n_canal-2} = strrep(labour_files(n_canal).name,'.txt','m.mat');
    intervalos_labour{n_canal-2} = dlmread(strcat(diretorio,'labour\',labour_files(n_canal).name));
end

for n_canal = 3:size(nonlabour_files,1)
    nonlabour_name{n_canal-2} = strrep(nonlabour_files(n_canal).name,'.txt','m.mat');
    intervalos_nonlabour{n_canal-2} = dlmread(strcat(diretorio,'nonlabour\',nonlabour_files(n_canal).name));
end


%% CARREGA SINAIS A PARTIR DOS ARQUIVOS DAS CONTRA��ES
path = 'C:\Icelandic\mio\';

for n_canal = 1:size(intervalos_labour,2)
    
    file = labour_name{n_canal};

    fid = fopen(strcat(path,file),'r'); % abre arquivo .mat
    sinais_labour{n_canal} = double(fread(fid,[12,inf],'*int16')); % l� os sinais do arquivo em int16
    fclose(fid);

end

for n_canal = 1:size(intervalos_nonlabour,2)
    
    file = nonlabour_name{n_canal};

    fid = fopen(strcat(path,file),'r'); % abre arquivo .mat
    sinais_nonlabour{n_canal} = double(fread(fid,[12,inf],'*int16')); % l� os sinais do arquivo em int16
    fclose(fid);

end

%Par�metros b�sicos
taxaAquisicao = 200; %Taxa de aquisi��o da base de dados
periodo_amostral = 1/taxaAquisicao;

clearvars -except sinais_labour sinais_nonlabour intervalos_labour intervalos_nonlabour taxaAquisicao periodo_amostral

%% TRATAMENTO DO SINAL ADQUIRIDO

ORDEM = 4; % ordem do filtro

% "DENOISE" USANDO TRANSFORMADA DE WAVELET DISCRETA

    % decompor o sinal usando a transformada de wavelet discreta:
    
    TPTR = 'modwtsqtwolog'; % threshold selection rule"
    SORH = 's'; % is for soft or hard thresholding
    SCAL = 'mln'; % defines multiplicative threshold rescaling
    N = 10; % Wavelet decomposition is performed at N level
    wname = 'db4'; % is a character vector containing the name of the desired orthogonal wavelet
    
% LABOUR    

for n_arq_labour = 1:2%size(intervalos_labour,2)  % n_arq_labour � o �ndice para todos os arquivos labour <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    
    for n_canal = 1:12  % �ndice dos canais analizados (para a base icelandic ser� sempre 12)
        
        sinais_labour_filt{n_arq_labour}(n_canal,:) = FiltroPA(sinais_labour{n_arq_labour}(n_canal,:),0.35,taxaAquisicao,ORDEM); %siltra o sinal
        sinais_labour_filt{n_arq_labour}(n_canal,:) = FiltroPB(sinais_labour_filt{n_arq_labour}(n_canal,:),1,taxaAquisicao,ORDEM);
        sinais_labour_mv{n_arq_labour}(n_canal,:) = sinais_labour_filt{n_arq_labour}(n_canal,:).*5./(2^16); %gera os sinais em milivolts 
        %sinais_labour_mv_dwt{n_arq_labour}(n_canal,:) = wden(sinais_labour_mv{n_arq_labour}(n_canal,:),TPTR,SORH,SCAL,N,wname); % faz transformada de wavelet no sinal
    end    
end

% NONLABOUR 

%{

for n_arq_nonlabour = 1:size(intervalos_nonlabour,2)  % n_arq_labour � o �ndice para todos os arquivos labour
    
    for n_canal = 1:12  % �ndice dos canais analizados (para a base icelandic ser� sempre 12)
        
        sinais_nonlabour_filt{n_arq_nonlabour}(n_canal,:) = FiltroPA(sinais_nonlabour{n_arq_nonlabour}(n_canal,:),0.35,taxaAquisicao,ORDEM); %siltra o sinal
        sinais_nonlabour_filt{n_arq_nonlabour}(n_canal,:) = FiltroPB(sinais_nonlabour_filt{n_arq_nonlabour}(n_canal,:),1,taxaAquisicao,ORDEM);
        sinais_nonlabour_mv{n_arq_nonlabour}(n_canal,:) = sinais_nonlabour_filt{n_arq_nonlabour}(n_canal,:).*5./(2^16); %gera os sinais em milivolts 
        %sinais_nonlabour_mv_dwt{n_arq_nonlabour}(n_canal,:) = wden(sinais_nonlabour_mv{n_arq_nonlabour}(n_canal,:),TPTR,SORH,SCAL,N,wname); % faz transformada de wavelet no sinal
    end    
end

%}

%% SEGMENTA��O DOS SINAIS E ARMAZENAMENTO EM C�LULA

%LABOUR

for n_arq_labour = 1:2 % size(intervalos_labour,2)  % n_arq_labour � o �ndice para todos os arquivos labour <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    
    inicio_c = intervalos_labour{n_arq_labour}(2,:);  %inicio das contra��es para todos os canais do arquivo "n"
    fim_c = intervalos_labour{n_arq_labour}(3,:);     %fim das contra��es para todos os canais do arquivo "n"
    
    for n_canal = 1:12  % �ndice dos canais analizados (para a base icelandic ser� sempre 12)
        
        for n_segmento = 1:size(intervalos_labour{n_arq_labour},2) 
            
            segmento = sinais_labour_mv{n_arq_labour}(n_canal,1+inicio_c(n_segmento):fim_c(n_segmento)); 
            tempo = (1:size(segmento,2)).*periodo_amostral; % Tempo em segundos

            segmentos_totais_labour{n_arq_labour}{n_segmento}{n_canal}(1,:) = segmento;
            segmentos_totais_labour{n_arq_labour}{n_segmento}{n_canal}(2,:) = tempo;
        
        end        
    end    
end

%NONLABOUR

%{

for n_arq_nonlabour = 1:size(intervalos_nonlabour,2)  % n_arq_labour � o �ndice para todos os arquivos labour
    
    inicio_c = intervalos_nonlabour{n_arq_nonlabour}(2,:);  %inicio das contra��es para todos os canais do arquivo "n"
    fim_c = intervalos_nonlabour{n_arq_nonlabour}(3,:);     %fim das contra��es para todos os canais do arquivo "n"
    
    for n_canal = 1:12  % �ndice dos canais analizados (para a base icelandic ser� sempre 12)
        
        for n_segmento = 1:size(intervalos_nonlabour{n_arq_nonlabour},2) 
            
            segmento = sinais_nonlabour_mv{n_arq_nonlabour}(n_canal,1+inicio_c(n_segmento):fim_c(n_segmento)); 
            tempo = (1:size(segmento,2)).*periodo_amostral; % Tempo em segundos

            segmentos_totais_nonlabour{n_arq_nonlabour}{n_segmento}{n_canal}(1,:) = segmento;
            segmentos_totais_nonlabour{n_arq_nonlabour}{n_segmento}{n_canal}(2,:) = tempo;
        
        end        
    end    
end

%}

clearvars -except segmentos_totais_labour segmentos_totais_nonlabour taxaAquisicao

%% C�lculo das caracter�sticas 

%LABOUR

    for n_arq_labour = 1:size(segmentos_totais_labour,2)  % n_arq_labour � o �ndice para todos os arquivos labour
    
        l_plot = size(segmentos_totais_labour{n_arq_labour},2);   % Gera a disposi��o dos subplots automaticamente
        aux = round(sqrt(l_plot));
        for i = 1:100
            if i*aux >= l_plot 
                h_plot = i;
                break;
            end    
        end
        l_plot = aux;
    
    
        for n_canal = 1:2%12  % �ndice dos canais analizados (para a base icelandic ser� sempre 12)  <<<<<<<<<<<<<<<<<<<<<<<<

            figure;

            for n_segmento = 1:size(segmentos_totais_labour{n_arq_labour},2)

                % Plota contra��o i em subplots
                
                auxi = segmentos_totais_labour{n_arq_labour}{n_segmento}{:,n_canal};

                subplot(h_plot,l_plot,n_segmento);
                plot(auxi(2,:),auxi(1,:));
                grid
                title(sprintf('Contra��o %d do canal %d',n_segmento, n_canal));
                
            end         
        end    
    end
    
    %NONLABOUR
    
    %{
    
    for n_arq_nonlabour = 1:size(segmentos_totais_nonlabour,2)  % n_arq_labour � o �ndice para todos os arquivos labour
    
        l_plot = size(segmentos_totais_nonlabour{n_arq_nonlabour},2);   % Gera a disposi��o dos subplots automaticamente
        aux = round(sqrt(l_plot));
        for i = 1:100
            if i*aux >= l_plot 
                h_plot = i;
                break;
            end    
        end
        l_plot = aux;
    
    
        for n_canal = 1:2  % �ndice dos canais analizados (para a base icelandic ser� sempre 12) 

            figure;

            for n_segmento = 1:size(segmentos_totais_nonlabour{n_arq_nonlabour},2)

                % Plota contra��o i em subplots
                
                auxi = segmentos_totais_nonlabour{n_arq_nonlabour}{n_segmento}{:,n_canal};

                subplot(h_plot,l_plot,n_segmento);
                plot(auxi(2,:),auxi(1,:));
                grid
                title(sprintf('Contra��o %d do canal %d',n_segmento, n_canal));
                
            end         
        end    
    end
    
    %}
    
clearvars -except segmentos_totais_labour segmentos_totais_nonlabour taxaAquisicao    
    
%% EXTRAI FEATURES 

% LABOUR
for n_arq_labour = 1:2 % size(intervalos_labour,2)  % n_arq_labour � o �ndice para todos os arquivos labour <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    
    for n_canal = 1:12  % �ndice dos canais analizados (para a base icelandic ser� sempre 12)
        
        for n_segmento = 1:size(segmentos_totais_labour{n_arq_labour},2) 
            
            auxi = segmentos_totais_labour{n_arq_labour}{n_segmento}{1,n_canal}(1,:);
            
            % calcula o rms de cada segmento em cada canal e cada arquivo
            temp_rms = windowed_rms(auxi,20,0,0);
            segmentos_totais_labour{n_arq_labour}{n_segmento}{2,n_canal}(1,:) = mean(temp_rms);
            % calcula a vari�ncia de cada segmento em cada canal e cada arquivo
            temp_var = variance(auxi,20,0,0);
            segmentos_totais_labour{n_arq_labour}{n_segmento}{3,n_canal}(1,:) = mean(temp_var); 
            
            %Extraindo PEAK FREQUENCY
            N = length(auxi);
            xdft = fft(auxi);
            xdft = xdft(1:N/2+1);
            psdx = (1/(taxaAquisicao*N)) * abs(xdft).^2;
            psdx(2:end-1) = 2*psdx(2:end-1);
            freq = 0:taxaAquisicao/length(auxi):taxaAquisicao/2;
            [maximo,index] = max(psdx);
            
            segmentos_totais_labour{n_arq_labour}{n_segmento}{4,n_canal}(1,:) = freq(index);
            
            %Extraindo Sample Entropy
            %segmentos_totais_labour{n_arq_labour}{n_segmento}{5,n_canal}(1,:) = SampEn(auxi,2,0.2); % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
            segmentos_totais_labour{n_arq_labour}{n_segmento}{5,n_canal}(1,:) = 1; %<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<        
        end        
    end    
end

% NONLABOUR
%{
for n_arq_nonlabour = 1:2 % size(intervalos_nonlabour,2)  % n_arq_nonlabour � o �ndice para todos os arquivos labour <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    
    for n_canal = 1:12  % �ndice dos canais analizados (para a base icelandic ser� sempre 12)
        
        for n_segmento = 1:size(segmentos_totais_nonlabour{n_arq_nonlabour},2) 
            
            auxi = segmentos_totais_nonlabour{n_arq_nonlabour}{n_segmento}{1,n_canal}(1,:);
            
            % calcula o rms de cada segmento em cada canal e cada arquivo
            temp_rms = windowed_rms(auxi,20,0,0);
            segmentos_totais_nonlabour{n_arq_nonlabour}{n_segmento}{2,n_canal}(1,:) = mean(temp_rms);
            % calcula a vari�ncia de cada segmento em cada canal e cada arquivo
            temp_var = variance(auxi,20,0,0);
            segmentos_totais_nonlabour{n_arq_nonlabour}{n_segmento}{3,n_canal}(1,:) = mean(temp_var); 
            
            %Extraindo PEAK FREQUENCY
            N = length(auxi);
            xdft = fft(auxi);
            xdft = xdft(1:N/2+1);
            psdx = (1/(taxaAquisicao*N)) * abs(xdft).^2;
            psdx(2:end-1) = 2*psdx(2:end-1);
            freq = 0:taxaAquisicao/length(auxi):taxaAquisicao/2;
            [maximo,index] = max(psdx);
            
            segmentos_totais_nonlabour{n_arq_nonlabour}{n_segmento}{4,n_canal}(1,:) = freq(index);
            
            %Extraindo Sample Entropy
            %segmentos_totais_nonlabour{n_arq_nonlabour}{n_segmento}{5,n_canal}(1,:) = SampEn(auxi,2,0.2); % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
            segmentos_totais_nonlabour{n_arq_nonlabour}{n_segmento}{5,n_canal}(1,:) = 1; %<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<        
        end        
    end    
end

%}

for n_arq_labour = 1:size(intervalos_labour,2)  % n_arq_labour � o �ndice para todos os arquivos labour
    
end
    %{

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

%}

    % pega dura��o m�dia das contra��es em segundos
    for n_canal = 1:size(fim_c,2)
        duracao_seg(n_segmento) = fim_c(n_segmento)  - inicio_c(n_segmento);
    end
    duracao_med = mean(duracao_seg)*periodo_amostra;

    % pega frequ�ncia entre as contra��es em Hz
    for n_segmento = 1:size(fim_c,2)-1
        %inter_centr(i) = ( (((fim_c(i+1) + inicio_c(i+1))/2)+inicio_c(i+1)) - (((fim_c(i) + inicio_c(i))/2)+inicio_c(i)) );
        inter_centr(n_segmento) = ((fim_c(n_segmento+1)  + inicio_c(n_segmento+1)) - (fim_c(n_segmento)  + inicio_c(n_segmento)))/2;
    end    
    freq_med = 1/((sum(inter_centr)/(size(fim_c,2)-1))*periodo_amostra);

    % pega intervalo entre inicio e fim de cada contra��o em segundos
    for n_segmento = 1:size(fim_c,2)-1
        inter(n_segmento) = inicio_c(n_segmento+1) - fim_c(n_segmento); %     ((fim_c(i+1)  + inicio_c(i+1)) - (fim_c(i)  + inicio_c(i)))/2;
    end 
    
    intervalo_med = (sum(inter)/(size(fim_c,2)-1))*periodo_amostra;




    caracteristicas(coleta,:) = [str2num(file) sem_parto rms_min rms_max rms_med var_min var_max var_med duracao_med freq_med intervalo_med];

    posicao_excel = strcat('A',num2str(coleta+1));

    % Escrevendo caracter�sticas no excel
    cabecalho_excel = {'Arquivo','SemanaParto','RMS_min','RMS_max','RMS_med','VAR_min','VAR_max','VAR_med','Dur_med','Freq_med','Inter_med'};
    xlswrite('FeaturesContracoes.xlsx',cabecalho_excel,'Features','A1');
    xlswrite('FeaturesContracoes.xlsx',caracteristicas(coleta,:),'Features',posicao_excel);







clearvars -except caracteristicas duracao_med intervalo_med freq_med rms_min rms_max rms_med var_min var_max var_med  %deixar aqui s� o que nos interessa

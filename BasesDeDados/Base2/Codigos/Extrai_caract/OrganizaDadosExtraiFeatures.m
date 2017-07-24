% Código para automatizar extracao de features
clc;
clearvars;
close all;

%% CARREGA ARQUIVOS COM OS INTERVALOS DAS CONTRAÇÕES
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


%% CARREGA SINAIS A PARTIR DOS ARQUIVOS DAS CONTRAÇÕES
path = 'C:\Icelandic\mio\';

for n_canal = 1:size(intervalos_labour,2)
    
    file = labour_name{n_canal};

    fid = fopen(strcat(path,file),'r'); % abre arquivo .mat
    sinais_labour{n_canal} = double(fread(fid,[16,inf],'*int16')); % lê os sinais do arquivo em int16
    fclose(fid);

end

for n_canal = 1:size(intervalos_nonlabour,2)
    
    file = nonlabour_name{n_canal};

    fid = fopen(strcat(path,file),'r'); % abre arquivo .mat
    sinais_nonlabour{n_canal} = double(fread(fid,[16,inf],'*int16')); % lê os sinais do arquivo em int16
    fclose(fid);

end

%Parâmetros básicos
taxaAquisicao = 200; %Taxa de aquisição da base de dados
periodo_amostral = 1/taxaAquisicao;

clearvars -except sinais_labour sinais_nonlabour intervalos_labour intervalos_nonlabour taxaAquisicao periodo_amostral

%% PLOT DOS SINAIS

for arquivo = 1:4
    figure
    hold
    for i = 1:16
        plot(sinais_labour{1,arquivo}(i,10:end));
    end
    title(sprintf('Arquivo %d - labour',arquivo));
end

for arquivo = 1:4
    figure
    hold
    for i = 1:16
        plot(sinais_nonlabour{1,arquivo}(i,10:end));
    end
    title(sprintf('Arquivo %d - non labour',arquivo));
end

%% CRIACAO DOS 8 CANAIS BIPOLARES

% Sinais calculados pela subtracao de dois canais monopolares

for arquivo = 1:4
    for i = 1:8
        sinais_labour_bip{1,arquivo}(i,:) = sinais_labour{1,arquivo}(i*2,1:end) ...
            - sinais_labour{1,arquivo}((i*2)-1,1:end);
        
        sinais_nonlabour_bip{1,arquivo}(i,:) = sinais_nonlabour{1,arquivo}(i*2,1:end) ...
            - sinais_nonlabour{1,arquivo}((i*2)-1,1:end);
    end
end

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

for n_arq_labour = 1:size(intervalos_labour,2)  % n_arq_labour é o índice para todos os arquivos labour 
    
    for n_canal = 1:8  % índice dos canais analizados (8 bipolares)
        
        sinais_labour_filt{n_arq_labour}(n_canal,:) = FiltroPA(sinais_labour_bip{n_arq_labour}(n_canal,:),0.35,taxaAquisicao,ORDEM); %siltra o sinal
        sinais_labour_filt{n_arq_labour}(n_canal,:) = FiltroPB(sinais_labour_filt{n_arq_labour}(n_canal,:),1,taxaAquisicao,ORDEM);
        sinais_labour_mv{n_arq_labour}(n_canal,:) = sinais_labour_filt{n_arq_labour}(n_canal,:).*5./(2^16); %gera os sinais em milivolts 
        %sinais_labour_mv_dwt{n_arq_labour}(n_canal,:) = wden(sinais_labour_mv{n_arq_labour}(n_canal,:),TPTR,SORH,SCAL,N,wname); % faz transformada de wavelet no sinal
    end    
end

% NONLABOUR 



for n_arq_nonlabour = 1:size(intervalos_nonlabour,2)  % n_arq_nonlabour é o índice para todos os arquivos nonlabour
    
    for n_canal = 1:8 
        
        sinais_nonlabour_filt{n_arq_nonlabour}(n_canal,:) = FiltroPA(sinais_nonlabour_bip{n_arq_nonlabour}(n_canal,:),0.35,taxaAquisicao,ORDEM); %siltra o sinal
        sinais_nonlabour_filt{n_arq_nonlabour}(n_canal,:) = FiltroPB(sinais_nonlabour_filt{n_arq_nonlabour}(n_canal,:),1,taxaAquisicao,ORDEM);
        sinais_nonlabour_mv{n_arq_nonlabour}(n_canal,:) = sinais_nonlabour_filt{n_arq_nonlabour}(n_canal,:).*5./(2^16); %gera os sinais em milivolts 
        %sinais_nonlabour_mv_dwt{n_arq_nonlabour}(n_canal,:) = wden(sinais_nonlabour_mv{n_arq_nonlabour}(n_canal,:),TPTR,SORH,SCAL,N,wname); % faz transformada de wavelet no sinal
    end    
end


%% PLOT DOS SINAIS TRATADOS

for arquivo = 1:4
    figure
    hold
    for i = 1:8
        plot(sinais_labour_mv{1,arquivo}(i,8000:end-2000));
    end
    title(sprintf('Arquivo Tratado %d - labour',arquivo));
end

for arquivo = 1:4
    figure
    hold
    for i = 1:8
        plot(sinais_nonlabour_mv{1,arquivo}(i,8000:end-2000));
    end
    title(sprintf('Arquivo Tratado %d - non labour',arquivo));
end


%% SEGMENTAÇÃO DOS SINAIS E ARMAZENAMENTO EM CÉLULA

%LABOUR

for n_arq_labour = 1:size(intervalos_labour,2)  % n_arq_labour é o índice para todos os arquivos labour 
    
    inicio_c = intervalos_labour{n_arq_labour}(2,:);  %inicio das contrações para todos os canais do arquivo "n"
    fim_c = intervalos_labour{n_arq_labour}(3,:);     %fim das contrações para todos os canais do arquivo "n"
    
    for n_canal = 1:8
        
        for n_segmento = 1:size(intervalos_labour{n_arq_labour},2) 
            
            segmento = sinais_labour_mv{n_arq_labour}(n_canal,1+inicio_c(n_segmento):fim_c(n_segmento)); 
            tempo = (1:size(segmento,2)).*periodo_amostral; % Tempo em segundos

            segmentos_totais_labour{n_arq_labour}{n_segmento}{n_canal}(1,:) = segmento;
            segmentos_totais_labour{n_arq_labour}{n_segmento}{n_canal}(2,:) = tempo;
        
        end        
    end    
end

%NONLABOUR
for n_arq_nonlabour = 1:size(intervalos_nonlabour,2)  % n_arq_nonlabour é o índice para todos os arquivos nonlabour
    
    inicio_c = intervalos_nonlabour{n_arq_nonlabour}(2,:);  %inicio das contrações para todos os canais do arquivo "n"
    fim_c = intervalos_nonlabour{n_arq_nonlabour}(3,:);     %fim das contrações para todos os canais do arquivo "n"
    
    for n_canal = 1:8  
        
        for n_segmento = 1:size(intervalos_nonlabour{n_arq_nonlabour},2) 
            
            segmento = sinais_nonlabour_mv{n_arq_nonlabour}(n_canal,1+inicio_c(n_segmento):fim_c(n_segmento)); 
            tempo = (1:size(segmento,2)).*periodo_amostral; % Tempo em segundos

            segmentos_totais_nonlabour{n_arq_nonlabour}{n_segmento}{n_canal}(1,:) = segmento;
            segmentos_totais_nonlabour{n_arq_nonlabour}{n_segmento}{n_canal}(2,:) = tempo;
        
        end        
    end    
end



clearvars -except segmentos_totais_labour segmentos_totais_nonlabour taxaAquisicao intervalos_labour intervalos_nonlabour

%% PLOTA OS SEGMENTOS

plotar = 1;  % Se quer plotar os segmentos: 1, se não quer: 0

    %LABOUR
if plotar
    for n_arq_labour = 1:size(segmentos_totais_labour,2)  % n_arq_labour é o índice para todos os arquivos labour
    
        l_plot = size(segmentos_totais_labour{n_arq_labour},2);   % Gera a disposição dos subplots automaticamente
        aux = round(sqrt(l_plot));
        for i = 1:100
            if i*aux >= l_plot 
                h_plot = i;
                break;
            end    
        end
        l_plot = aux;
    
    
        for n_canal = 1:8   

            figure;

            for n_segmento = 1:size(segmentos_totais_labour{n_arq_labour},2)

                % Plota contração i em subplots
                
                auxi = segmentos_totais_labour{n_arq_labour}{n_segmento}{:,n_canal};

                subplot(h_plot,l_plot,n_segmento);
                plot(auxi(2,:),auxi(1,:));
                grid
                title(sprintf('Contração %d do canal %d',n_segmento, n_canal));
                
            end         
        end    
    end
    
    %NONLABOUR 
    
    for n_arq_nonlabour = 1:size(segmentos_totais_nonlabour,2)  % n_arq_nonlabour é o índice para todos os arquivos nonlabour
    
        l_plot = size(segmentos_totais_nonlabour{n_arq_nonlabour},2);   % Gera a disposição dos subplots automaticamente
        aux = round(sqrt(l_plot));
        for i = 1:100
            if i*aux >= l_plot 
                h_plot = i;
                break;
            end    
        end
        l_plot = aux;
    
    
        for n_canal = 1:8 

            figure;

            for n_segmento = 1:size(segmentos_totais_nonlabour{n_arq_nonlabour},2)

                % Plota contração i em subplots
                
                auxi = segmentos_totais_nonlabour{n_arq_nonlabour}{n_segmento}{:,n_canal};

                subplot(h_plot,l_plot,n_segmento);
                plot(auxi(2,:),auxi(1,:));
                grid
                title(sprintf('Contração %d do canal %d',n_segmento, n_canal));
                
            end         
        end    
    end 
end    
    
clearvars -except segmentos_totais_labour segmentos_totais_nonlabour taxaAquisicao intervalos_labour intervalos_nonlabour   
    
%% EXTRAI FEATURES 

% LABOUR
for n_arq_labour = 1:size(segmentos_totais_labour,2)  % n_arq_labour é o índice para todos os arquivos labour 
    
    for n_canal = 1:8    
        
        for n_segmento = 1:size(segmentos_totais_labour{n_arq_labour},2) 
            
            auxi = segmentos_totais_labour{n_arq_labour}{n_segmento}{1,n_canal}(1,:);
            
            % calcula o rms de cada segmento em cada canal e cada arquivo
            temp_rms = windowed_rms(auxi,20,0,0);
            segmentos_totais_labour{n_arq_labour}{n_segmento}{2,n_canal}(1,:) = mean(temp_rms);
            % calcula a variância de cada segmento em cada canal e cada arquivo
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
            segmentos_totais_labour{n_arq_labour}{n_segmento}{5,n_canal}(1,:) = SampEn(auxi,2,0.2); % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
            %segmentos_totais_labour{n_arq_labour}{n_segmento}{5,n_canal}(1,:) = 1; %<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<        
        end        
    end    
end

% NONLABOUR

for n_arq_nonlabour = 1:size(segmentos_totais_nonlabour,2)  % n_arq_nonlabour é o índice para todos os arquivos nonlabour 
    
    for n_canal = 1:8
        
        for n_segmento = 1:size(segmentos_totais_nonlabour{n_arq_nonlabour},2) 
            
            auxi = segmentos_totais_nonlabour{n_arq_nonlabour}{n_segmento}{1,n_canal}(1,:);
            
            % calcula o rms de cada segmento em cada canal e cada arquivo
            temp_rms = windowed_rms(auxi,20,0,0);
            segmentos_totais_nonlabour{n_arq_nonlabour}{n_segmento}{2,n_canal}(1,:) = mean(temp_rms);
            % calcula a variância de cada segmento em cada canal e cada arquivo
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
            segmentos_totais_nonlabour{n_arq_nonlabour}{n_segmento}{5,n_canal}(1,:) = SampEn(auxi,2,0.2); % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
            %segmentos_totais_nonlabour{n_arq_nonlabour}{n_segmento}{5,n_canal}(1,:) = 1; %<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<        
        end        
    end    
end



clearvars -except segmentos_totais_labour segmentos_totais_nonlabour taxaAquisicao intervalos_labour intervalos_nonlabour 

% LABOUR
% pega duração média das contrações em segundos
clearvars auxi interv
for n_arq_labour = 1:size(segmentos_totais_labour,2)  % n_arq_labour é o índice para todos os arquivos labour 
    for n_segmento = 1:size(segmentos_totais_labour{1,n_arq_labour},2)
        auxi(n_segmento) = segmentos_totais_labour{1,n_arq_labour}{1,n_segmento}{1}(2,end); %salva duração de cada contração
        segmentos_totais_labour{1,n_arq_labour}{2,n_segmento} = auxi(n_segmento);
    end
    segmentos_totais_labour{2,n_arq_labour} = mean(auxi); % salva duração média das contrações do arquivo
end

% pega frequência entre as contrações em Hz e o intervalo médio entre elas
clearvars auxi interv
for n_arq_labour = 1:size(segmentos_totais_labour,2)  % n_arq_labour é o índice para todos os arquivos labour 
    clearvars inicio_c fim_c
    inicio_c = intervalos_labour{1,n_arq_labour}(2,:);
    fim_c = intervalos_labour{1,n_arq_labour}(3,:);
    
    for n_segmento = 1:size(inicio_c,2)-1
        auxi(n_segmento) = ((fim_c(n_segmento+1)  + inicio_c(n_segmento+1)) - (fim_c(n_segmento)  + inicio_c(n_segmento)))/2;
        interv(n_segmento) = inicio_c(n_segmento+1) - fim_c(n_segmento); %%
    end
    segmentos_totais_labour{3,n_arq_labour} = 1/(((sum(auxi)/taxaAquisicao)/(size(fim_c,2)-1))); % salva frequência média das contrações do arquivo
    segmentos_totais_labour{4,n_arq_labour} = (sum(interv)/(size(fim_c,2)-1))/taxaAquisicao; %% salva intervalo média das contrações do arquivo
end

%NONLABOUR
% pega duração média das contrações em segundos

clearvars auxi interv
for n_arq_nonlabour = 1:size(segmentos_totais_nonlabour,2)  % n_arq_nonlabour é o índice para todos os arquivos nonlabour 
    for n_segmento = 1:size(segmentos_totais_nonlabour{1,n_arq_nonlabour},2)
        auxi(n_segmento) = segmentos_totais_nonlabour{1,n_arq_nonlabour}{1,n_segmento}{1}(2,end); %salva duração de cada contração
        segmentos_totais_nonlabour{1,n_arq_nonlabour}{2,n_segmento} = auxi(n_segmento);
    end
    segmentos_totais_nonlabour{2,n_arq_nonlabour} = mean(auxi); % salva duração média das contrações do arquivo
end

% pega frequência entre as contrações em Hz
clearvars auxi interv
for n_arq_nonlabour = 1:size(segmentos_totais_nonlabour,2)  % n_arq_nonlabour é o índice para todos os arquivos nonlabour 
    clearvars inicio_c fim_c
    inicio_c = intervalos_nonlabour{1,n_arq_nonlabour}(2,:);
    fim_c = intervalos_nonlabour{1,n_arq_nonlabour}(3,:);
    
    for n_segmento = 1:size(inicio_c,2)-1
        auxi(n_segmento) = ((fim_c(n_segmento+1)  + inicio_c(n_segmento+1)) - (fim_c(n_segmento)  + inicio_c(n_segmento)))/2;
        interv(n_segmento) = inicio_c(n_segmento+1) - fim_c(n_segmento); %%
    end
    segmentos_totais_nonlabour{3,n_arq_nonlabour} = 1/(((sum(auxi)/taxaAquisicao)/(size(fim_c,2)-1))); % salva frequencia média das contrações do arquivo
    segmentos_totais_nonlabour{4,n_arq_nonlabour} = (sum(interv)/(size(fim_c,2)-1))/taxaAquisicao; %% salva intervalo média das contrações do arquivo
end



clearvars -except segmentos_totais_labour segmentos_totais_nonlabour taxaAquisicao intervalos_labour intervalos_nonlabour 

    
aa = 1+1;



    %{

    % Pega valor máximo, mínimo e médio do RMS
    rms_min = min(rms_seg);
    rms_max = max(rms_seg);
    rms_med = mean(rms_seg);

    % Pega valor máximo, mínimo e médio da variância
    var_min = min(var_seg);
    var_max = max(var_seg);
    var_med = mean(var_seg);

    % Pega valor máximo, mínimo e médio da frequencia de pico
    peak_frequency_min = min(peak_frequency);
    peak_frequency_max = max(peak_frequency);
    peak_frequency_med = mean(peak_frequency);

    %pega a sample entropy
    samp_en_min = min(samp_en);
    samp_en_max = max(samp_en);
    samp_en_med = mean(samp_en);






    caracteristicas(coleta,:) = [str2num(file) sem_parto rms_min rms_max rms_med var_min var_max var_med duracao_med freq_med intervalo_med];

    posicao_excel = strcat('A',num2str(coleta+1));

    % Escrevendo características no excel
    cabecalho_excel = {'Arquivo','SemanaParto','RMS_min','RMS_max','RMS_med','VAR_min','VAR_max','VAR_med','Dur_med','Freq_med','Inter_med'};
    xlswrite('FeaturesContracoes.xlsx',cabecalho_excel,'Features','A1');
    xlswrite('FeaturesContracoes.xlsx',caracteristicas(coleta,:),'Features',posicao_excel);


%}






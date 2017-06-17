% C�digo para separar manualmente as contra��es do sinal

clc
clearvars;
close all;

h80 = 70; %% altura do 80mmhg em pixels

filename = 'ice009_p_1of2';
path = 'imagens\nao_trabalho\';
ext = '.jpg';
toco = '_toco';

salva = strcat(filename,toco);

arquivo = strcat(path,filename,ext);

I_orig = imread(arquivo); % L� a imagem e armazena em uma matriz de uint

I_orig_r = I_orig(:,:,1);

[BW,I] = createMask2(I_orig);

figure
imshow(BW);

BW = ~BW;

%subplot(2,2,4);   % plota imagem com filtro gaussiano
figure
imshow(~BW);

matrix = double(BW);

sum = 0; %soma das posi��es dos uns no eixo y
conta_uns = 0; %conta o numero de 'uns' encontrados para fazer a m�dia da posi��o em y
iniciou = 0; % flag que determina se j� inciou o tra�ado da fun��o
eixo_x_func = 0;
func = 0;
tem_um = 0;

for eixo_x = 1:size(matrix,2); %varre a imagem no eixo x    
    
    % Primeiro FOR conta a quantidade de "uns" e a posi��o de cada um para
    % fazer uma m�dia posteriormente
    for eixo_y = 1:size(matrix,1); %varre a imagem no eixo y        
        if matrix(eixo_y,eixo_x) %verifica se o ponto atual � 'um'
            conta_uns = conta_uns + 1; % conta o n�mero de uns nesta coluna
            sum = sum + eixo_y; % soma os valores da posi��o de cada um dos "uns"           
        end           
    end
    
    if sum  % se o valor da soma for diferente de 0 pela primeira vez, avisa que iniciou o gr�fico
        iniciou = 1; % flag de inicio da fun��o
        tem_um = 1; % flag que diz que h� pelo menos um "um" nesta coluna
    else
        if iniciou %caso ja tenha iniciado a fun��o por�m no ponto atual n�o hava nenhum "um"
        %cria um ponto 'virtual' caso seja inexistente neste 'eixo_x'
            %virt = func(1,eixo_x_func); % pega a posi��o 'y' do 'x' da itera��o anterior
            % e cria um 'y' virtual na itera��o atual
            
            %virt = 2*func(1, eixo_x_func - 1) - func(1, eixo_x_func); % Ponto 'y' virtual
            % � o incremento entre os dois 'y' anteriores
        end
    end
    
    if iniciou && tem_um
        
        eixo_x_func = eixo_x_func + 1; %indexa a fun��o ap�s encontrar o primeiro 'um'
        func(1,eixo_x_func) = sum/conta_uns; %faz a m�dia da posi��o dos 'uns' encontrados
        func(2,eixo_x_func) = 1;
        
    elseif iniciou && ~tem_um
         eixo_x_func = eixo_x_func + 1; %indexa a fun��o ap�s encontrar o primeiro 'um' 
         %func(1,eixo_x_func) = virt;
         func(2,eixo_x_func) = 0;
    end
    
    
    sum = 0; conta_uns = 0; tem_um = 0; %apaga para a proxima itera��o    
end

%virar de cabe�a para baixo a fun��o

escreve = eixo_y - func(1,:);

%func(func == 0) = NaN;

% interpolate

% gera o vetor x para interpolar
j = 1;
for i = 1:eixo_x_func
    if escreve(1,i) ~= eixo_y
        x(1,j) = i;
        j = j+1;
    end    
end

% gera o vetor y para interpolar
y = escreve(x);

% gera os valores diferentes de zero a partir de spline c�bico
xx = 1:1:eixo_x_func;
yy = spline(x,y,xx);

escreve = yy;

escala_de_pressao = eixo_y - h80;  %ajusta a escala de press�o
escala_de_pressao = escala_de_pressao/80;
escreve = escreve/escala_de_pressao;
 

dlmwrite(strcat('C:\Users\bruno\Desktop\Trabalho1-Fuzzy\BasesDeDados\Base2\Codigos\imagevectorize\data\',salva,'.dat'),escreve, ' ')

aa = load(strcat('C:\Users\bruno\Desktop\Trabalho1-Fuzzy\BasesDeDados\Base2\Codigos\imagevectorize\data\',salva,'.dat'));


BWI = imref2d(size(I_orig));
BWI.XWorldLimits = [0 eixo_x_func];
BWI.YWorldLimits = [2 eixo_y*3];


figure;
subplot(2,1,1), imshow(I_orig,BWI);


subplot(2,1,2);
plot(aa);
xlim([-(eixo_x - eixo_x_func) eixo_x_func])
ylim([(min(yy) - 50)/escala_de_pressao (max(yy) + 50)/escala_de_pressao])
grid

%{
figure

imshow(I_orig);
hold on
plot(eixo_y-aa);
plot(0,eixo_y);
xlim([-(eixo_x - eixo_x_func) eixo_x_func])

%ylim([min(yy) - 50 max(yy) + 50])
hold off
%}







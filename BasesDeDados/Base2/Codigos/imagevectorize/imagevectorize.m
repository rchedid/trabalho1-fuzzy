% Código para separar manualmente as contrações do sinal

clc
clearvars;
close all;


filename = 'ice002_p_1of3';

I_orig = imread('imagens\ice002_p_1of3.jpg'); % Lê a imagem e armazena em uma matriz de uint


%whos I
%subplot(2,2,1);   % plota imagem original
figure
imshow(I_orig);    

I_blur = imgaussfilt(I_orig, 0.5);

%subplot(2,2,2);   % plota imagem com filtro gaussiano
figure
imshow(I_blur);

[BW,I] = createMask(I_blur);
%subplot(2,2,3);   % plota imagem com filtro gaussiano
figure
imshow(BW);

I_grey = rgb2gray(I_blur);

th = 160;
I_grey(I_grey>th)=255;
I_grey(I_grey<th)=0;

BW = ~BW;

%subplot(2,2,4);   % plota imagem com filtro gaussiano
figure
imshow(BW);

matrix = double(BW);

sum = 0; %soma das posições dos uns no eixo y
conta_uns = 0; %conta o numero de 'uns' encontrados para fazer a média da posição em y
iniciou = 0; % flag que determina se já inciou o traçado da função
eixo_x_func = 0;
func = 0;
tem_um = 0;

for eixo_x = 1:size(matrix,2); %varre a imagem no eixo x    
    
    for eixo_y = 1:size(matrix,1); %varre a imagem no eixo y        
        if matrix(eixo_y,eixo_x) %verifica se o ponto atual é 'um'
            conta_uns = conta_uns + 1;
            sum = sum + eixo_y;            
        end           
    end
    
    if sum
        iniciou = 1;
        tem_um = 1;
    else
        if iniciou %caso ja tenha iniciado a função porém no ponto atual não hava 'uns'
        %cria um ponto 'virtual' caso seja inexistente neste 'eixo_x'
            virt = func(1,eixo_x_func);
        end
    end
    
    if iniciou && tem_um
        
        eixo_x_func = eixo_x_func + 1; %indexa a função após encontrar o primeiro 'um'
        func(1,eixo_x_func) = sum/conta_uns; %faz a média da posição dos 'uns' encontrados
        
    elseif iniciou && ~tem_um
         eixo_x_func = eixo_x_func + 1; %indexa a função após encontrar o primeiro 'um' 
         func(1,eixo_x_func) = virt;
         
    end
    
    
    sum = 0; conta_uns = 0; tem_um = 0; %apaga para a proxima iteração    
end

%virar de cabeça para baixo a função

func = size(matrix,1) - func;

%func_filt = FiltroPB(func,1,taxaAquisicao,ORDEM);

dlmwrite(strcat('C:\Users\bruno\Desktop\Trabalho1-Fuzzy\BasesDeDados\Base2\Codigos\imagevectorize\data\',filename,'.dat'),func, ' ')

aa = load(strcat('C:\Users\bruno\Desktop\Trabalho1-Fuzzy\BasesDeDados\Base2\Codigos\imagevectorize\data\',filename,'.dat'));

figure

plot(aa)






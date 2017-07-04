function y = FiltroPF(sinal, freqBaixa, freqAlta, taxaAquisicao, ordem)

    for i = 1:ordem
        [b,a] = butter(1,freqBaixa/(taxaAquisicao/2),'high');
        sinal = filter(b,a,sinal); % Filtrado passa alta
        [b,a] = butter(1,freqAlta/(taxaAquisicao/2));
        sinal = filter(b,a,sinal); % filtrado passa baixa
    end
    
    y = sinal;
end
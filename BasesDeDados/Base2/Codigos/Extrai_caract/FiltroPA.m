function y = FiltroPA(sinal, frequencia, taxaAquisicao, ordem)
    [b,a] = butter(ordem,frequencia/(taxaAquisicao/2),'high');
    y = filter(b,a,sinal); 
end
function y = FiltroPB(sinal, frequencia, taxaAquisicao, ordem)
    [b,a] = butter(ordem,frequencia/(taxaAquisicao/2),'low');
    y = filter(b,a,sinal);
end

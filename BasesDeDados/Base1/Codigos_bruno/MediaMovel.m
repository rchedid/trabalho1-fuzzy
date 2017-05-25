function y = MediaMovel(sinal, ratio)
    atual = 0;
    
    for f = 1:size(sinal,2)
        v = sinal(f);
        novoV = atual * (1 - ratio) + v * ratio;
        y(f) = novoV;
        atual = novoV;
    end
end
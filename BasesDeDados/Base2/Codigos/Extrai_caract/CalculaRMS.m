function y = CalculaRMS(sinal, janela)
    k=0;
    for i = 1:janela:size(sinal,2)
        k = k + 1;
        vetorRMS(k) = rms(sinal,i:i+janela-1);
    end
    
    y = vetorRMS;
end
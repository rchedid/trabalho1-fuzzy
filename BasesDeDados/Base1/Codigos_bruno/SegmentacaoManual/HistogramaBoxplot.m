% histograma e boxplot

durac_med_term = [50 60.85909091 89.74 109.3944444 34.63 135.6666667 75.82692308 53.77666667 75.175 101.3];
durac_med_pre = [19.16666667 13.33333333 14 14.83333333 9.833333333 25 25 15.83333333 16.25 20.83333333];

figure
subplot(2,1,1);
histogram(durac_med_term);
title('Histograma da duração média das contrações');
ylabel('n');
xlabel('Duração média das contrações não prematuras');
subplot(2,1,2);
histogram(durac_med_pre);
ylabel('n');
xlabel('Duração média das contrações prematuras');

figure
boxplot([durac_med_term',durac_med_pre'],'Labels',{'Term','Preterm'});
title('Boxplot da duração média das contrações');
ylabel('Duração média');

%%
rms_med_term = [0.012775808 0.019698259 0.00276594 0.007908003 0.007820171 0.005596315 0.006733839 0.008227187 0.01266359 0.004667051 0.004992112 0.005128994 0.005290003 0.005680691 0.005040245];
rms_med_pre = [0.008877101 0.005903007 0.008347372 0.011895352 0.010741403 0.005901456 0.006298806 0.002257067 0.006072065 0.005425588];

figure
subplot(2,1,1);
histogram(rms_med_term);
title('Histograma da duração média das contrações');
ylabel('n');
xlabel('Duração média das contrações não prematuras');
subplot(2,1,2);
histogram(rms_med_pre);
ylabel('n');
xlabel('Duração média das contrações prematuras');

figure
boxplot([rms_med_term',rms_med_pre'],'Labels',{'Term','Preterm'});
title('Boxplot da duração média das contrações');
ylabel('Duração média');
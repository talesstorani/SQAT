% Script run_validation_FS_FM_fmod
%  This routine plot the validation of fluctuation strength (Osses et al. model )
%  
%  SIGNALS: FM tones, fc=1500 Hz, freq deviation=700 Hz, 70dBSPL, and fmod=[1 2 4 8 16 32] 
%
%  Details taken from : 
%  Osses Vecchi, Alejandro, Rodrigo Garc�a Le�n, and Armin Kohlrausch. 
%  "Modelling the sensation of fluctuation strength." Proceedings of Meetings on Acoustics 
%  22ICA. Vol. 28. No. 1. Acoustical Society of America, 2016.
%
%  Author: Gil Felix Greco, Braunschweig, 02/03/2020 (updated in 13.03.2023)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc; clear all; close all;

save_figs = 0; %% save figs flag

dir_out = [fileparts(mfilename('fullpath')) filesep];

%% reference data from Osses et al 2019

ref=[1 2 4 8 16 32;
    0.85 1.17 2 .7 .27 .02];

%% compute FS from signals

j=1; % init counter

res=cell(1,size(ref,2));  % declaring for memory allocation

SQAT_version=1; % v1.0
dir_sounds = get_dir_validation_sounds('FluctuationStrength_Osses2016',SQAT_version);

dBFS_in  = 100; % dB full scale convention from the input sounds
dBFS_out =  94; % dB full scale convention in SQAT: amplitude of 1 = 1 Pa, or 94 dB SPL
dB_correction = dBFS_in - dBFS_out;


tic
for i=1:size(ref,2)
    
    fname = sprintf('%sFM-tone-fc-1500_fmod-%.0f_deltaf-700-SPL-70-dB.wav',dir_sounds,ref(1,j));
    [insig,fs]=audioread(fname);
    
    res{i} = FluctuationStrength_Osses2016(insig,fs,...  % input signal and sampling freq.
                                                       0,...  % method, stationary analysis =0 - window size=length(insig), time_varying analysis - window size=2s
                                                       0,...  % time_skip, in seconds for statistical calculations
                                                       0);    % show results, 'false' (disable, default value) or 'true' (enable)
                                                   
    results(i)=res{1,i}.FSmean; % store mean roughness value in vector results[nfmod,nFc] 
    
    j=j+1;
    
end
t=toc/60; % time to run FS calculation in minutes

%% plot results

h  =figure;
set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])

% plot reference curves
hAx=axes;                     % new axes; save handle
err= (0.1*ref(2,:));
errorbar(ref(1,:),ref(2,:),err,'k-*','MarkerSize',6,'Linewidth',.5);hold all % results from SQAT

% semilogx(ref(1,:),ref(2,:),'k*-','MarkerSize',8);hold all;

% plot computed results
semilogx(ref(1,:),results,'ko:','MarkerSize',8);hold all;

hAx.XScale='log';              % turn to semilogx form

legend('Reference $\pm\:10\:\%\:(\mathrm{JND})$','SQAT','Location','NW','Interpreter','Latex');
legend boxoff

axis([0 32 0 3]);

ax = gca;
set(ax,'XTick',[0 1 2 4 8 16 32]);
set(ax,'YTick',[0 0.5 1 1.5 2 2.5 3]);
ax.XAxis.MinorTick = 'off';
ax.XAxis.MinorTickValues =  0:10:160;
ax.YAxis.MinorTick = 'on';
ax.YAxis.MinorTickValues = 0:0.1:3;
     
ylabel('Fluctuation strength, FS (vacil)','Interpreter','Latex');
xlabel('Modulation frequency, $f_{\mathrm{mod}}$ (Hz)','Interpreter','Latex');

set(gcf,'color','w');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if save_figs==1
    if ~exist(dir_out,'dir')
        mkdir(dir_out);
    end
    figures_dir = [dir_out 'figs' filesep];
    if ~exist(figures_dir,'dir')
        mkdir(figures_dir);
    end
    
    figname_short = 'validation_FS_fmod_FM_tones';
    figname_out = [figures_dir figname_short];
    % figures_dir = 'figs\'; % backslash is the fileseparator on Windows only 
    
%     saveas(gcf,figname_out, 'fig');
%     saveas(gcf,figname_out, 'pdf');
    saveas(gcf,figname_out, 'png');
    
    fprintf('%s.m: figure %s was saved on disk\n\t(full name: %s)\n',mfilename,figname_short,figname_out);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
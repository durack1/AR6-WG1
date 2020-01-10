% Generate salinity change maps from CMIP5

% Paul J. Durack 9 January 2020

% PJD  9 Jan 2020   - Started, grabbed code snippets from /work/durack1/Shared/140111_PaperPlots_Halosteric/make_paperplots.m

%/work/durack1/Shared/130626_data_OHCSteric/140503/cmip5_historical_1950-2004_driftcorrect/
%/work/durack1/Shared/130626_data_OHCSteric/140503/cmip5_historical_1950-2004_nodriftcorrect/
%/work/durack1/Shared/130626_data_OHCSteric/140503/cmip5_historicalNat_1950-2004_driftcorrect/
%/work/durack1/Shared/130626_data_OHCSteric/140503/cmip5_historicalNat_1950-2004_nodriftcorrect/


%% Get models 
% Create list of input models from directory listing
[~,models] = unix(['\ls -1 ',data_dir,'*.nc']);
models = strtrim(models);
models = regexp(models,'\n','split');

%% Load variables from model files, regrid and save to variable 
clearvars -except Atlantic Global Indian Pacific basins3* *dir drift experiment figtxt hanom_* model_suite models obs_* suite tanom_* times; clc; close all

% Load basins data
infile = os_path([home_dir,'code/make_basins.mat']);
load(infile,'basins3_NaN_ones_2x1');
basins3_NaN_ones_2x1 = basins3_NaN_ones_2x1(:,1:180)';

% Create area mask
[area_ratio,~,~] = area_weight(0:2:358,-90:1:90);
area_ratio = area_ratio(:,21:161)'; % Trim to 70S/N

% Cleanup existing png files
delete([fig_dir,datestr(now,'yymmdd'),'_*.png'])

% Preallocate arrays
[hanom,tanom] = deal(NaN(length(models),3,size(hanom_obs,2),size(hanom_obs,3)));
model_names = cell(length(models),1);

for x = 1:length(models)
    % Load data from files
    infile = models{x};
    ind_tmp     = strfind(infile,'/');
    model       = regexprep(infile((ind_tmp(end)+1):end),['.',times,'.nc'],''); clear ind_tmp
    disp(['** Processing: ',model])
    test_hanom  = getnc(infile,'steric_height_halo_anom_depthInterp');
    test_tanom  = getnc(infile,'steric_height_thermo_anom_depthInterp');
    % Extract levels
    test_hanom_0300    = squeeze(test_hanom(12,:,:));
    test_hanom_0700    = squeeze(test_hanom(14,:,:));
    test_hanom_2000    = squeeze(test_hanom(18,:,:));
    test_tanom_0300    = squeeze(test_tanom(12,:,:));
    test_tanom_0700    = squeeze(test_tanom(14,:,:));
    test_tanom_2000    = squeeze(test_tanom(18,:,:));
    clear test_hanom test_tanom
    % Get x,y dimensions
    test_lat            = getnc(infile,'lat');
    test_lon            = getnc(infile,'lon'); clear infile
    
    % Interpolate data
    if isvector(test_lat) % Interpolate a "standard grid"
        disp('standard')
        testis_hc_hanom_0300    = interp2(test_lat,test_lon,test_hanom_0300',obs_lat,obs_lon');
        testis_hc_hanom_0700    = interp2(test_lat,test_lon,test_hanom_0700',obs_lat,obs_lon');
        testis_hc_hanom_2000    = interp2(test_lat,test_lon,test_hanom_2000',obs_lat,obs_lon');
        testis_hc_tanom_0300    = interp2(test_lat,test_lon,test_tanom_0300',obs_lat,obs_lon');
        testis_hc_tanom_0700    = interp2(test_lat,test_lon,test_tanom_0700',obs_lat,obs_lon');
        testis_hc_tanom_2000    = interp2(test_lat,test_lon,test_tanom_2000',obs_lat,obs_lon'); clear test_lon
    else % Interpolate a "meshed grid"
        disp('meshed')
        [lat,lon] = meshgrid(obs_lat,obs_lon);
        % TriscatteredInterp
        F                       = TriScatteredInterp(test_lat(:),test_lon(:),test_hanom_0300(:));
        testis_hc_hanom_0300    = F(lat,lon); clear F
        F                       = TriScatteredInterp(test_lat(:),test_lon(:),test_hanom_0700(:));
        testis_hc_hanom_0700    = F(lat,lon); clear F
        F                       = TriScatteredInterp(test_lat(:),test_lon(:),test_hanom_2000(:));
        testis_hc_hanom_2000    = F(lat,lon); clear F
        F                       = TriScatteredInterp(test_lat(:),test_lon(:),test_tanom_0300(:));
        testis_hc_tanom_0300    = F(lat,lon); clear F
        F                       = TriScatteredInterp(test_lat(:),test_lon(:),test_tanom_0700(:));
        testis_hc_tanom_0700    = F(lat,lon); clear F
        F                       = TriScatteredInterp(test_lat(:),test_lon(:),test_tanom_2000(:));
        testis_hc_tanom_2000    = F(lat,lon); clear F
        % Deal with GFDL/bcc-csm rotated grid
        if ( sum(strfind(model,'GFDL-')) || ( sum(strfind(model,'GFDL-ESM2')) ) || ( sum(strfind(model,'bcc-csm')) ) )
            disp('GFDL*/bcc-csm* rotated grid')
            lon_ = test_lon + abs(min(min(test_lon)));
            % TriscatteredInterp
            F                       = TriScatteredInterp(test_lat(:),lon_(:),test_hanom_0300(:));
            testis_hc_hanom_0300    = F(lat,lon); clear F
            F                       = TriScatteredInterp(test_lat(:),lon_(:),test_hanom_0700(:));
            testis_hc_hanom_0700    = F(lat,lon); clear F
            F                       = TriScatteredInterp(test_lat(:),lon_(:),test_hanom_2000(:));
            testis_hc_hanom_2000    = F(lat,lon); clear F
            F                       = TriScatteredInterp(test_lat(:),lon_(:),test_tanom_0300(:));
            testis_hc_tanom_0300    = F(lat,lon); clear F
            F                       = TriScatteredInterp(test_lat(:),lon_(:),test_tanom_0700(:));
            testis_hc_tanom_0700    = F(lat,lon); clear F
            F                       = TriScatteredInterp(test_lat(:),lon_(:),test_tanom_2000(:));
            testis_hc_tanom_2000    = F(lat,lon); clear F test_lon lon_ 
            % Shift lons
            testis_hc_hanom_0300    = [testis_hc_hanom_0300(142:180,:);testis_hc_hanom_0300(1:141,:)];
            testis_hc_hanom_0700    = [testis_hc_hanom_0700(142:180,:);testis_hc_hanom_0700(1:141,:)];
            testis_hc_hanom_2000    = [testis_hc_hanom_2000(142:180,:);testis_hc_hanom_2000(1:141,:)];
            testis_hc_tanom_0300    = [testis_hc_tanom_0300(142:180,:);testis_hc_tanom_0300(1:141,:)];
            testis_hc_tanom_0700    = [testis_hc_tanom_0700(142:180,:);testis_hc_tanom_0700(1:141,:)];
            testis_hc_tanom_2000    = [testis_hc_tanom_2000(142:180,:);testis_hc_tanom_2000(1:141,:)];
            % And infill 0,360 values
            testis_hc_hanom_0300(41,:)  = testis_hc_hanom_0300(42,:);   testis_hc_hanom_0300(40,:)  = testis_hc_hanom_0300(39,:);
            testis_hc_hanom_0700(41,:)  = testis_hc_hanom_0700(42,:);   testis_hc_hanom_0700(40,:)  = testis_hc_hanom_0700(39,:);
            testis_hc_hanom_2000(41,:)  = testis_hc_hanom_2000(42,:);   testis_hc_hanom_2000(40,:)  = testis_hc_hanom_2000(39,:);
            testis_hc_tanom_0300(41,:)  = testis_hc_tanom_0300(42,:);   testis_hc_tanom_0300(40,:)  = testis_hc_tanom_0300(39,:);
            testis_hc_tanom_0700(41,:)  = testis_hc_tanom_0700(42,:);   testis_hc_tanom_0700(40,:)  = testis_hc_tanom_0700(39,:);
            testis_hc_tanom_2000(41,:)  = testis_hc_tanom_2000(42,:);   testis_hc_tanom_2000(40,:)  = testis_hc_tanom_2000(39,:);
        end
        clear lat lon test_mean test_lon
    end
    %figure(1); clf; pcolor(testis_mean'); shading flat; caxis([33 37]); clmap(27); colorbar; title('2'); pause
    
    % Smooth and infill all fields
    tmp                     = inpaint_nans(testis_hc_hanom_0300,2);
    tmp                     = smooth3(repmat(tmp,[1 1 2]));
    testis_hc_hanom_0300    = tmp(:,:,1).*basins3_NaN_ones_2x1; clear tmp
    tmp                     = inpaint_nans(testis_hc_hanom_0700,2);
    tmp                     = smooth3(repmat(tmp,[1 1 2]));
    testis_hc_hanom_0700    = tmp(:,:,1).*basins3_NaN_ones_2x1; clear tmp
    tmp                     = inpaint_nans(testis_hc_hanom_2000,2);
    tmp                     = smooth3(repmat(tmp,[1 1 2]));
    testis_hc_hanom_2000    = tmp(:,:,1).*basins3_NaN_ones_2x1; clear tmp
    tmp                     = inpaint_nans(testis_hc_tanom_0300,2);
    tmp                     = smooth3(repmat(tmp,[1 1 2]));
    testis_hc_tanom_0300    = tmp(:,:,1).*basins3_NaN_ones_2x1; clear tmp
    tmp                     = inpaint_nans(testis_hc_tanom_0700,2);
    tmp                     = smooth3(repmat(tmp,[1 1 2]));
    testis_hc_tanom_0700    = tmp(:,:,1).*basins3_NaN_ones_2x1; clear tmp
    tmp                     = inpaint_nans(testis_hc_tanom_2000,2);
    tmp                     = smooth3(repmat(tmp,[1 1 2]));
    testis_hc_tanom_2000    = tmp(:,:,1).*basins3_NaN_ones_2x1; clear tmp
    %figure(1); clf; pcolor(testis_mean'); shading flat; caxis([33 37]); clmap(27); colorbar; title('3'); pause
    
    % transpose
    testis_hc_hanom_0300    = testis_hc_hanom_0300';
    testis_hc_hanom_0700    = testis_hc_hanom_0700';
    testis_hc_hanom_2000    = testis_hc_hanom_2000';
    testis_hc_tanom_0300    = testis_hc_tanom_0300';
    testis_hc_tanom_0700    = testis_hc_tanom_0700';
    testis_hc_tanom_2000    = testis_hc_tanom_2000';
    
    % Calculate interpolated PC
    tanom_0700_obs = squeeze(tanom_obs(2,:,:));
    ind = ~isnan(tanom_0700_obs.*testis_hc_tanom_0700);
    pc = weightedcorrs([tanom_0700_obs(ind),testis_hc_tanom_0700(ind)],area_ratio(ind));
    pc1 = pc(2,1); clear ind pc
    hanom_0700_obs = squeeze(hanom_obs(2,:,:));
    ind = ~isnan(hanom_0700_obs.*testis_hc_tanom_0700);
    pc = weightedcorrs([hanom_0700_obs(ind),testis_hc_hanom_0700(ind)],area_ratio(ind));
    pc2 = pc(2,1); clear ind pc
    
    % Quick check plots
    clim = 1; clim1 = .5;
    handle = figure('units','centimeters','visible','off','color','w'); set(0,'CurrentFigure',handle); clf
    set(handle,'posi',[1 1 20 10],'visi','off')
    % Interpolated
    ax2 = subplot(2,3,2); pcolor(obs_lon,obs_lat,testis_hc_tanom_0700); clmap(27); shading flat; caxis([-clim clim]); continents
    t2 = title(regexprep(regexprep(model,'_','\\_'),'cmip[0-9].',''));
    text(40,50,['PC: ',num2str(pc1,'%3.2f')]); clear pc1
    % Native
    ax1 = subplot(2,3,1); pcolor(test_tanom_0700); clmap(27); shading flat; caxis([-clim clim])
    t1 = title('native');
    clear test_tanom_0300 test_tanom_0700 test_tanom_2000
    % Obs
    ax3 = subplot(2,3,3); pcolor(obs_lon,obs_lat,tanom_0700_obs); clmap(27); shading flat; caxis([-clim clim]); continents
    t3 = title('thermo obs');
    clear tanom_0700_obs
    % Interpolated
    ax5 = subplot(2,3,5); pcolor(obs_lon,obs_lat,testis_hc_hanom_0700); clmap(27); shading flat; caxis([-clim clim]); continents; set(handle,'visi','off')
    t5 = title(regexprep(regexprep(model,'_','\\_'),'cmip[0-9].',''));
    text(40,50,['PC: ',num2str(pc2,'%3.2f')]); clear pc2
    % Native
    ax4 = subplot(2,3,4); pcolor(test_hanom_0700); clmap(27); shading flat; caxis([-clim clim])
    t4 = title('native');
    clear test_hanom_0300 test_hanom_0700 test_hanom_2000
    % Obs
    ax6 = subplot(2,3,6); pcolor(obs_lon,obs_lat,hanom_0700_obs); clmap(27); shading flat; caxis([-clim clim]); continents; set(handle,'visi','off')
    t6 = title('halo obs');
    clear hanom_0700_obs
    hh_2 = colorbarf_nw('horiz',-clim:clim1:clim,-clim:clim1*2:clim); 
    set(ax1,'posi',[0.05 0.59 0.28 0.37],'xticklabels',{})
    set(ax2,'posi',[0.37 0.59 0.28 0.37],'xticklabels',{})
    set(ax3,'posi',[0.69 0.59 0.28 0.37],'xticklabels',{})
    set(t1,'posi',[size(test_lat,2)/2 size(test_lat,1)+(size(test_lat,1)/50) 1],'horizontalalign','center')
    set(t2,'posi',[180 72 1],'horizontalalign','center')
    set(t3,'posi',[180 72 1],'horizontalalign','center')
    set(t4,'posi',[size(test_lat,2)/2 size(test_lat,1)+(size(test_lat,1)/50) 1],'horizontalalign','center')
    set(t5,'posi',[180 72 1],'horizontalalign','center')
    set(t6,'posi',[180 72 1],'horizontalalign','center')
    set(ax4,'posi',[0.05 0.13 0.28 0.38])
    set(ax5,'posi',[0.37 0.13 0.28 0.38])
    set(ax6,'posi',[0.69 0.13 0.28 0.38])
    set(hh_2,'posi',[0.049 0.05 0.92 0.015])

    % Test directory existence/purge existing files
    if ~exist(fig_dir,'dir')
        mkdir(fig_dir)
    elseif x == 1
        delete([fig_dir,'/*.png'])
    end
    delete([fig_dir,datestr(now,'yymmdd'),'_',model,'.png'])
    export_fig([fig_dir,datestr(now,'yymmdd'),'_',model],'-png')
    close all %set(gcf,'visi','on');
    clear ax2 t2 ax1 t1 ax3 t3 ax5 t5 ax4 t4 ax6 t6 clim* hh_2 handle test_lat
    
    % Place variables into preallocated matrices
    hanom(x,1,:,:)   = testis_hc_hanom_0300; clear testis_hc_hanom_0300
    hanom(x,2,:,:)   = testis_hc_hanom_0700; clear testis_hc_hanom_0700
    hanom(x,3,:,:)   = testis_hc_hanom_2000; clear testis_hc_hanom_2000
    tanom(x,1,:,:)   = testis_hc_tanom_0300; clear testis_hc_tanom_0300
    tanom(x,2,:,:)   = testis_hc_tanom_0700; clear testis_hc_tanom_0700
    tanom(x,3,:,:)   = testis_hc_tanom_2000; clear testis_hc_tanom_2000
    model_names{x}   = model; clear model
end
clear x

%% Save variables to file 
outfile = [out_dir,datestr(now,'yymmdd'),'_',suite,'.',experiment,'.',times,'.an.ocn.steric_anom.',drift,'.mat'];
delete(outfile)
save(outfile,'data_dir','model_names','obs_lat','obs_lon', ...
             'hanom','tanom','hanom_obs','tanom_obs','hanom_ish','tanom_ish');
%clear all; close all

%% Load model suites and create suite-ensemble mean 
clearvars -except Atlantic Global Indian Pacific area_ratio basins3* *_dir drift figtxt hanom_* model_suite obs_* suite tanom_* times
clc; close all
% Set current file timestamps
fileTime = '140505';

% Use model names to generate model-ensemble means
% Build matrix of model results
for suite = [1,3]
    switch suite
        % CMIP5
        case 1 % cmip5 hist driftcorrect
            infile = [fileTime,'_cmip5.historical.1950-2004.an.ocn.steric_anom.driftcorrect.mat'];
            load(infile,'model_names','obs_lat','obs_lon', ...
                        'hanom','tanom'); clear infile
            model_names_cm5d = model_names;
            hanom_cm5d = hanom;
            tanom_cm5d = tanom;
            scaleFactor = (1/(2004-1949)); % Scale to per yr
        case 2 % cmip5 hist nodriftcorrect
            infile = [fileTime,'_cmip5.historical.1950-2004.an.ocn.steric_anom.nodriftcorrect.mat'];
            load(infile,'model_names','obs_lat','obs_lon', ...
                        'hanom','tanom'); clear infile
            model_names_cm5 = model_names;
            hanom_cm5 = hanom;
            tanom_cm5 = tanom;
            scaleFactor = (1/(2004-1949)); % Scale to per yr
        case 3 % cmip5 histNat driftcorrect
            infile = [fileTime,'_cmip5.historicalNat.1950-2004.an.ocn.steric_anom.driftcorrect.mat'];
            load(infile,'model_names','obs_lat','obs_lon', ...
                        'hanom','tanom'); clear infile
            model_names_cm5hnd = model_names;
            hanom_cm5hnd = hanom;
            tanom_cm5hnd = tanom;
            scaleFactor = (1/(2004-1949)); % Scale to per yr
        % CMIP3
        case 4 % cmip3
            infile = '14xxxx_cmip3.20c3m.1970-1999.an.ocn.steric_anom.driftcorrect.mat';
            load(infile,'model_names','obs_lat','obs_lon', ...
                        'hanom','tanom'); clear infile
            model_names_cm3 = model_names;
            hanom_cm3 = hanom;
            tanom_cm3 = tanom;
            scaleFactor = (1/(1999-1949)); % Scale to per yr
    end
    
    % Convert to generic names
    models = model_names; clear model_names
    models_h_0300 = squeeze(hanom(:,1,:,:))*scaleFactor;
    models_h_0700 = squeeze(hanom(:,2,:,:))*scaleFactor;
    models_h_2000 = squeeze(hanom(:,3,:,:))*scaleFactor; clear hanom
    models_t_0300 = squeeze(tanom(:,1,:,:))*scaleFactor;
    models_t_0700 = squeeze(tanom(:,2,:,:))*scaleFactor;
    models_t_2000 = squeeze(tanom(:,3,:,:))*scaleFactor; clear tanom scaleFactor
    
    disp(['Case: ',num2str(suite)])
    [hanom_0300_ens,hanom_0700_ens,hanom_2000_ens, ...
     hanom_0300_mean,hanom_0700_mean,hanom_2000_mean, ...
     tanom_0300_ens,tanom_0700_ens,tanom_2000_ens, ...
     tanom_0300_mean,tanom_0700_mean,tanom_2000_mean] = deal(NaN(size(models_h_0300)));
    model_names_mean = cell(length(models),1);
    count = 1; ens_count = 1;
    for x = 1:(length(models)-1)
        % Test for multiple realisations and generate ensemble mean
        model_ind = strfind(models{x},'.'); temp = models{x};
        model1 = temp((model_ind(1)+1):(model_ind(2)-1)); clear temp
        model_ind = strfind(models{x+1},'.'); temp = models{x+1};
        model2 = temp((model_ind(1)+1):(model_ind(2)-1)); clear temp
        if x == (length(models)-1) && ~strcmp(model1,model2)
            % Process final fields - if different
            hanom_0300_mean(count,:,:) = models_h_0300(x,:,:);
            hanom_0700_mean(count,:,:) = models_h_0700(x,:,:);
            hanom_2000_mean(count,:,:) = models_h_2000(x,:,:);
            tanom_0300_mean(count,:,:) = models_t_0300(x,:,:);
            tanom_0700_mean(count,:,:) = models_t_0700(x,:,:);
            tanom_2000_mean(count,:,:) = models_t_2000(x,:,:);
            model_names_mean{count} = model1;
            count = count + 1;
            hanom_0300_mean(count,:,:) = models_h_0300(x+1,:,:);
            hanom_0700_mean(count,:,:) = models_h_0700(x+1,:,:);
            hanom_2000_mean(count,:,:) = models_h_2000(x+1,:,:);
            tanom_0300_mean(count,:,:) = models_t_0300(x+1,:,:);
            tanom_0700_mean(count,:,:) = models_t_0700(x+1,:,:);
            tanom_2000_mean(count,:,:) = models_t_2000(x+1,:,:);
            model_names_mean{count} = model2;
        elseif x == (length(models)-1) && strcmp(model1,model2)
            % Process final fields - if same
            hanom_0300_ens(ens_count,:,:) = models_h_0300(x,:,:);
            hanom_0700_ens(ens_count,:,:) = models_h_0700(x,:,:);
            hanom_2000_ens(ens_count,:,:) = models_h_2000(x,:,:);
            tanom_0300_ens(ens_count,:,:) = models_t_0300(x,:,:);
            tanom_0700_ens(ens_count,:,:) = models_t_0700(x,:,:);
            tanom_2000_ens(ens_count,:,:) = models_t_2000(x,:,:);
            ens_count = ens_count + 1;
            hanom_0300_ens(ens_count,:,:) = models_h_0300(x+1,:,:);
            hanom_0700_ens(ens_count,:,:) = models_h_0700(x+1,:,:);
            hanom_2000_ens(ens_count,:,:) = models_h_2000(x+1,:,:);
            tanom_0300_ens(ens_count,:,:) = models_t_0300(x+1,:,:);
            tanom_0700_ens(ens_count,:,:) = models_t_0700(x+1,:,:);
            tanom_2000_ens(ens_count,:,:) = models_t_2000(x+1,:,:);
            % Write to matrix
            disp('write to matrix')
            hanom_0300_mean(count,:,:) = squeeze(nanmean(hanom_0300_ens));
            hanom_0700_mean(count,:,:) = squeeze(nanmean(hanom_0700_ens));
            hanom_2000_mean(count,:,:) = squeeze(nanmean(hanom_2000_ens));
            tanom_0300_mean(count,:,:) = squeeze(nanmean(tanom_0300_ens));
            tanom_0700_mean(count,:,:) = squeeze(nanmean(tanom_0700_ens));
            tanom_2000_mean(count,:,:) = squeeze(nanmean(tanom_2000_ens));
            model_names_mean{count} = model1;
        elseif ~strcmp(model1,model2)
            disp([num2str(x,'%03d'),' different count: ',num2str(count),' ',model1,' ',model2])
            % If models are different
            if ens_count > 1
                % Drop in final values - 140219 edit
                hanom_0300_ens(ens_count,:,:) = hanom_0300_ens(x,:,:);
                hanom_0700_ens(ens_count,:,:) = hanom_0700_ens(x,:,:);
                hanom_2000_ens(ens_count,:,:) = hanom_2000_ens(x,:,:);
                tanom_0300_ens(ens_count,:,:) = tanom_0300_ens(x,:,:);
                tanom_0700_ens(ens_count,:,:) = tanom_0700_ens(x,:,:);
                tanom_2000_ens(ens_count,:,:) = tanom_2000_ens(x,:,:);                
                % Average across ensemble
                disp('write mean - ensemble')
                hanom_0300_mean(count,:,:) = squeeze(nanmean(hanom_0300_ens));
                hanom_0700_mean(count,:,:) = squeeze(nanmean(hanom_0700_ens));
                hanom_2000_mean(count,:,:) = squeeze(nanmean(hanom_2000_ens));
                tanom_0300_mean(count,:,:) = squeeze(nanmean(tanom_0300_ens));
                tanom_0700_mean(count,:,:) = squeeze(nanmean(tanom_0700_ens));
                tanom_2000_mean(count,:,:) = squeeze(nanmean(tanom_2000_ens));
                model_names_mean{count} = model1;
                count = count + 1;
                % Reset ensemble stuff
                ens_count = 1;
                [hanom_0300_ens,hanom_0700_ens,hanom_2000_ens, ...
                 tanom_0300_ens,tanom_0700_ens,tanom_2000_ens] = deal(NaN(size(hanom_0300_mean)));
            else
                disp('write mean - single')
                hanom_0300_mean(count,:,:) = models_h_0300(x,:,:);
                hanom_0700_mean(count,:,:) = models_h_0700(x,:,:);
                hanom_2000_mean(count,:,:) = models_h_2000(x,:,:);
                tanom_0300_mean(count,:,:) = models_t_0300(x,:,:);
                tanom_0700_mean(count,:,:) = models_t_0700(x,:,:);
                tanom_2000_mean(count,:,:) = models_t_2000(x,:,:);
                model_names_mean{count} = model1;
                count = count + 1;
            end
        else
            disp([num2str(x,'%03d'),' same      count: ',num2str(count),' ',model1,' ',model2])
            % If models are the same
            hanom_0300_ens(ens_count,:,:) = models_h_0300(x,:,:);
            hanom_0700_ens(ens_count,:,:) = models_h_0700(x,:,:);
            hanom_2000_ens(ens_count,:,:) = models_h_2000(x,:,:);
            tanom_0300_ens(ens_count,:,:) = models_t_0300(x,:,:);
            tanom_0700_ens(ens_count,:,:) = models_t_0700(x,:,:);
            tanom_2000_ens(ens_count,:,:) = models_t_2000(x,:,:);
            ens_count = ens_count + 1;
        end
    end
    
    switch suite
        % CMIP5
        case 1 % cmip5 hist driftcorrect
            % Trim off excess
            cm5d_model_names_mean   = model_names_mean(1:count); clear model_names_mean
            cm5d_hanom_0300_mean    = hanom_0300_mean(1:count,:,:); clear hanom_0300_mean
            cm5d_hanom_0700_mean    = hanom_0700_mean(1:count,:,:); clear hanom_0700_mean
            cm5d_hanom_2000_mean    = hanom_2000_mean(1:count,:,:); clear hanom_2000_mean
            cm5d_tanom_0300_mean    = tanom_0300_mean(1:count,:,:); clear tanom_0300_mean
            cm5d_tanom_0700_mean    = tanom_0700_mean(1:count,:,:); clear tanom_0700_mean
            cm5d_tanom_2000_mean    = tanom_2000_mean(1:count,:,:); clear tanom_2000_mean
            clear *ens
            model_names_mean_cm5d = cm5d_model_names_mean; clear cm5d_model_names_mean
            [hanom_mean_cm5d,tanom_mean_cm5d] = deal(NaN([3,size(cm5d_hanom_0300_mean)]));
            hanom_mean_cm5d(1,:,:,:) = cm5d_hanom_0300_mean; clear cm5d_hanom_0300_mean
            hanom_mean_cm5d(2,:,:,:) = cm5d_hanom_0700_mean; clear cm5d_hanom_0700_mean
            hanom_mean_cm5d(3,:,:,:) = cm5d_hanom_2000_mean; clear cm5d_hanom_2000_mean
            tanom_mean_cm5d(1,:,:,:) = cm5d_tanom_0300_mean; clear cm5d_tanom_0300_mean
            tanom_mean_cm5d(2,:,:,:) = cm5d_tanom_0700_mean; clear cm5d_tanom_0700_mean
            tanom_mean_cm5d(3,:,:,:) = cm5d_tanom_2000_mean; clear cm5d_tanom_2000_mean
        case 2 % cmip5 hist nodriftcorrect
            % Trim off excess
            cm5_model_names_mean   = model_names_mean(1:count); clear model_names_mean
            cm5_hanom_0300_mean    = hanom_0300_mean(1:count,:,:); clear hanom_0300_mean
            cm5_hanom_0700_mean    = hanom_0700_mean(1:count,:,:); clear hanom_0700_mean
            cm5_hanom_2000_mean    = hanom_2000_mean(1:count,:,:); clear hanom_2000_mean
            cm5_tanom_0300_mean    = tanom_0300_mean(1:count,:,:); clear tanom_0300_mean
            cm5_tanom_0700_mean    = tanom_0700_mean(1:count,:,:); clear tanom_0700_mean
            cm5_tanom_2000_mean    = tanom_2000_mean(1:count,:,:); clear tanom_2000_mean
            clear *ens
            model_names_mean_cm5 = cm5_model_names_mean; clear cm5_model_names_mean
            [hanom_mean_cm5,tanom_mean_cm5] = deal(NaN([3,size(cm5_hanom_0300_mean)]));
            hanom_mean_cm5(1,:,:,:) = cm5_hanom_0300_mean; clear cm5_hanom_0300_mean
            hanom_mean_cm5(2,:,:,:) = cm5_hanom_0700_mean; clear cm5_hanom_0700_mean
            hanom_mean_cm5(3,:,:,:) = cm5_hanom_2000_mean; clear cm5_hanom_2000_mean
            tanom_mean_cm5(1,:,:,:) = cm5_tanom_0300_mean; clear cm5_tanom_0300_mean
            tanom_mean_cm5(2,:,:,:) = cm5_tanom_0700_mean; clear cm5_tanom_0700_mean
            tanom_mean_cm5(3,:,:,:) = cm5_tanom_2000_mean; clear cm5_tanom_2000_mean            
        case 3 % cmip5 histNat nodriftcorrect
            % Trim off excess
            cm5_model_names_mean   = model_names_mean(1:count); clear model_names_mean
            cm5_hanom_0300_mean    = hanom_0300_mean(1:count,:,:); clear hanom_0300_mean
            cm5_hanom_0700_mean    = hanom_0700_mean(1:count,:,:); clear hanom_0700_mean
            cm5_hanom_2000_mean    = hanom_2000_mean(1:count,:,:); clear hanom_2000_mean
            cm5_tanom_0300_mean    = tanom_0300_mean(1:count,:,:); clear tanom_0300_mean
            cm5_tanom_0700_mean    = tanom_0700_mean(1:count,:,:); clear tanom_0700_mean
            cm5_tanom_2000_mean    = tanom_2000_mean(1:count,:,:); clear tanom_2000_mean
            clear *ens
            model_names_mean_cm5hnd = cm5_model_names_mean; clear cm5_model_names_mean
            [hanom_mean_cm5hnd,tanom_mean_cm5hnd] = deal(NaN([3,size(cm5_hanom_0300_mean)]));
            hanom_mean_cm5hnd(1,:,:,:) = cm5_hanom_0300_mean; clear cm5_hanom_0300_mean
            hanom_mean_cm5hnd(2,:,:,:) = cm5_hanom_0700_mean; clear cm5_hanom_0700_mean
            hanom_mean_cm5hnd(3,:,:,:) = cm5_hanom_2000_mean; clear cm5_hanom_2000_mean
            tanom_mean_cm5hnd(1,:,:,:) = cm5_tanom_0300_mean; clear cm5_tanom_0300_mean
            tanom_mean_cm5hnd(2,:,:,:) = cm5_tanom_0700_mean; clear cm5_tanom_0700_mean
            tanom_mean_cm5hnd(3,:,:,:) = cm5_tanom_2000_mean; clear cm5_tanom_2000_mean 
        % CMIP3
        case 4 % cmip3 nodriftcorrect
            % Trim off excess
            cm3_model_names_mean   = model_names_mean(1:count); clear model_names_mean
            cm3_hanom_0300_mean    = hanom_0300_mean(1:count,:,:); clear hanom_0300_mean
            cm3_hanom_0700_mean    = hanom_0700_mean(1:count,:,:); clear hanom_0700_mean
            cm3_hanom_2000_mean    = hanom_2000_mean(1:count,:,:); clear hanom_2000_mean
            cm3_tanom_0300_mean    = tanom_0300_mean(1:count,:,:); clear tanom_0300_mean
            cm3_tanom_0700_mean    = tanom_0700_mean(1:count,:,:); clear tanom_0700_mean
            cm3_tanom_2000_mean    = tanom_2000_mean(1:count,:,:); clear tanom_2000_mean
            clear *ens
    end
end ; clear x count ens_count model1 model2 models* model_ind suite

%% Tables - Write out models to screen
clc
%models = model_names_mean_cm5d;
%models = model_names_cm5d;
%models = model_names_mean_cm5hnd;
models = model_names_cm5hnd;
for x = 1:length(models)
    disp([num2str(x,'%03d'),' ',models{x}])
end

%% Figure 1 - 0-2000m Steric/Halo/Thermo maps: DW10, Ishii, CM5
clc; close all
clearvars -except Atlantic Global Indian Pacific basins3* *_dir drift figtxt model_suite times obs_* *_en4 *_ish *_obs *cm5d *cm5hnd
fignum = '1'; fonts_ax = 6; fonts_lab = 8;

handle = figure('units','centimeters','visible','off','color','w'); set(0,'CurrentFigure',handle)

% Plot 3 x 3 maps: steric, thermo and halo
steric_ish = squeeze(tanom_ish(3,:,:)) + squeeze(hanom_ish(3,:,:));
steric_obs = squeeze(tanom_obs(3,:,:)) + squeeze(hanom_obs(3,:,:));
steric_cm5d = squeeze(nanmean(squeeze(tanom_mean_cm5d(3,:,:,:)),1)+nanmean(squeeze(hanom_mean_cm5d(3,:,:,:)),1));

% Create stipple masks
steric_sign = sign(steric_ish) + sign(steric_obs);
tanom_sign = sign(squeeze(tanom_ish(3,:,:))) + sign(squeeze(tanom_obs(3,:,:)));
hanom_sign = sign(squeeze(hanom_ish(3,:,:))) + sign(squeeze(hanom_obs(3,:,:)));
stip_lon = obs_lon(1):4:obs_lon(end); ind_lon = 1:2:length(obs_lon);
stip_lat = obs_lat(1):2:obs_lat(end); ind_lat = 1:2:length(obs_lat);
steric_sign = abs(steric_sign(1:2:end,1:2:end));
tanom_sign = abs(tanom_sign(1:2:end,1:2:end));
hanom_sign = abs(hanom_sign(1:2:end,1:2:end));

for var = 1:3
    switch var
        case 1
            mat = sign(squeeze(tanom_mean_cm5d(3,:,:,:))+squeeze(hanom_mean_cm5d(3,:,:,:)));
        case 2
            mat = sign(squeeze(tanom_mean_cm5d(3,:,:,:)));
        case 3
            mat = sign(squeeze(hanom_mean_cm5d(3,:,:,:)));
    end
    % Compare signs to MMM (hc_cm5, hc_cm3)
    hc_cm5_mmm = sign(steric_cm5d);
    for x = 1:size(mat,1)
        mat(x,:,:) = squeeze(mat(x,:,:)) == hc_cm5_mmm;
    end; clear hc_cm5_mmm
    mat = squeeze(nansum(mat,1))/size(mat,1);
    mat(isnan(steric_cm5d)) = NaN;
    mat = mat(ind_lat,ind_lon);
    switch var
        case 1
            steric_cm5_sign = mat;
        case 2
            tanom_cm5_sign = mat;
        case 3
            hanom_cm5_sign = mat;
    end
end
% Model agreement with MMM map
sn_scale = 1/2; % At 3/4 all area is stippled

clmap(27); scale = 100; scale1 = [4, .5, 1]; % Decimeters to mm
% ish
ax1 = subplot(3,3,1);
pcolor(obs_lon,obs_lat,steric_ish*scale); shading flat; caxis([-1 1]*scale1(1)); continents
error_stipple(1,stip_lon,stip_lat,steric_sign,1.5,0.05,[.5 .5 .5]); set(gcf,'visi','off')
lab1a = text(90,38,'A1','horiz','center','fontsize',fonts_lab);
lab1 = text(75,55,'Ish09','horiz','center','fontsize',fonts_lab);
ylab1 = ylabel('Latitude');
ax2 = subplot(3,3,2);
pcolor(obs_lon,obs_lat,squeeze(tanom_ish(3,:,:))*scale); shading flat; caxis([-1 1]*scale1(1)); continents
error_stipple(1,stip_lon,stip_lat,tanom_sign,1.5,0.05,[.5 .5 .5]); set(gcf,'visi','off')
lab2 = text(75,55,'Thermo.','horiz','center','fontsize',fonts_lab);
lab2a = text(90,38,'A2','horiz','center','fontsize',fonts_lab);
ax3 = subplot(3,3,3);
pcolor(obs_lon,obs_lat,squeeze(hanom_ish(3,:,:))*scale); shading flat; caxis([-1 1]*scale1(1)); continents
error_stipple(1,stip_lon,stip_lat,hanom_sign,1.5,0.05,[.5 .5 .5]); set(gcf,'visi','off')
lab3 = text(75,55,'Halo.','horiz','center','fontsize',fonts_lab);
lab3a = text(90,38,'A3','horiz','center','fontsize',fonts_lab);
% obs
ax4 = subplot(3,3,4);
pcolor(obs_lon,obs_lat,steric_obs*scale); shading flat; caxis([-1 1]*scale1(1)); continents
error_stipple(1,stip_lon,stip_lat,steric_sign,1.5,0.05,[.5 .5 .5]); set(gcf,'visi','off')
lab4a = text(90,38,'B1','horiz','center','fontsize',fonts_lab);
lab4 = text(75,55,'DW10','horiz','center','fontsize',fonts_lab);
ylab4 = ylabel('Latitude');
ax5 = subplot(3,3,5);
pcolor(obs_lon,obs_lat,squeeze(tanom_obs(3,:,:))*scale); shading flat; caxis([-1 1]*scale1(1)); continents
error_stipple(1,stip_lon,stip_lat,tanom_sign,1.5,0.05,[.5 .5 .5]); set(gcf,'visi','off')
lab5 = text(75,55,'Thermo.','horiz','center','fontsize',fonts_lab);
lab5a = text(90,38,'B2','horiz','center','fontsize',fonts_lab);
ax6 = subplot(3,3,6);
pcolor(obs_lon,obs_lat,squeeze(hanom_obs(3,:,:))*scale); shading flat; caxis([-1 1]*scale1(1)); continents
error_stipple(1,stip_lon,stip_lat,hanom_sign,1.5,0.05,[.5 .5 .5]); set(gcf,'visi','off')
lab6 = text(75,55,'Halo.','horiz','center','fontsize',fonts_lab);
lab6a = text(90,38,'B3','horiz','center','fontsize',fonts_lab);
% cm5
ax7 = subplot(3,3,7);
pcolor(obs_lon,obs_lat,steric_cm5d*scale); shading flat; caxis([-1 1]*scale1(1)); continents
error_stipple(1,stip_lon,stip_lat,steric_cm5_sign,sn_scale,0.05,[.5 .5 .5]); set(gcf,'visi','off')
lab7a = text(90,38,'C1','horiz','center','fontsize',fonts_lab);
lab7 = text(75,55,'CM5','horiz','center','fontsize',fonts_lab);
ylab7 = ylabel('Latitude');
xlab7 = xlabel('Longitude');
ax8 = subplot(3,3,8);
pcolor(obs_lon,obs_lat,squeeze(nanmean(squeeze(tanom_mean_cm5d(3,:,:,:)),1))*scale); shading flat; caxis([-1 1]*scale1(1)); continents
error_stipple(1,stip_lon,stip_lat,tanom_cm5_sign,sn_scale,0.05,[.5 .5 .5]); set(gcf,'visi','off')
lab8 = text(75,55,'Thermo.','horiz','center','fontsize',fonts_lab);
lab8a = text(90,38,'C2','horiz','center','fontsize',fonts_lab);
xlab8 = xlabel('Longitude');
ax9 = subplot(3,3,9);
pcolor(obs_lon,obs_lat,squeeze(nanmean(squeeze(hanom_mean_cm5d(3,:,:,:)),1))*scale); shading flat; caxis([-1 1]*scale1(1)); continents
error_stipple(1,stip_lon,stip_lat,hanom_cm5_sign,sn_scale,0.05,[.5 .5 .5]); set(gcf,'visi','off')
lab9 = text(75,55,'Halo.','horiz','center','fontsize',fonts_lab);
lab9a = text(90,38,'C3','horiz','center','fontsize',fonts_lab);
xlab9 = xlabel('Longitude');
hh1 = colorbarf_nw('horiz',-scale1(1):scale1(2):scale1(1),-scale1(1):scale1(3):scale1(1));

% Resize into canvas
width = 0.29; height = 0.26;
row1 = .15; row2 = .44; row3 = .73;
col1 = .1; col2 = .40; col3 = .70;
set(handle,'Position',[0 2 18 8]) % Full page width (175mm (17) width x 83mm (8) height) - Back to 16.5 x 6 for proportion
set(ax1,'Position',[col1 row3 width height]);
set(ax1,'Tickdir','out','fontsize',fonts_ax,'layer','top','box','on', ...
    'ylim',[-70 70],'ytick',-70:10:70,'yticklabel',{'70S','','50S','','30S','','10S','','10N','','30N','','50N','','70N'},'yminort','on', ...
    'xlim',[0 360],'xtick',0:60:360,'xticklabel',{''},'xminort','off')
set(ax2,'Position',[col2 row3 width height]);
set(ax2,'Tickdir','out','fontsize',fonts_ax,'layer','top','box','on', ...
    'ylim',[-70 70],'ytick',-70:10:70,'yticklabel',{''},'yminort','on', ...
    'xlim',[0 360],'xtick',0:60:360,'xticklabel',{''},'xminort','off')
set(ax3,'Position',[col3 row3 width height]);
set(ax3,'Tickdir','out','fontsize',fonts_ax,'layer','top','box','on', ...
    'ylim',[-70 70],'ytick',-70:10:70,'yticklabel',{''},'yminort','on', ...
    'xlim',[0 360],'xtick',0:60:360,'xticklabel',{''},'xminort','off')
set(ax4,'Position',[col1 row2 width height]);
set(ax4,'Tickdir','out','fontsize',fonts_ax,'layer','top','box','on', ...
    'ylim',[-70 70],'ytick',-70:10:70,'yticklabel',{'70S','','50S','','30S','','10S','','10N','','30N','','50N','','70N'},'yminort','on', ...
    'xlim',[0 360],'xtick',0:60:360,'xticklabel',{''},'xminort','off')
set(ax5,'Position',[col2 row2 width height]);
set(ax5,'Tickdir','out','fontsize',fonts_ax,'layer','top','box','on', ...
    'ylim',[-70 70],'ytick',-70:10:70,'yticklabel',{''},'yminort','on', ...
    'xlim',[0 360],'xtick',0:60:360,'xticklabel',{''},'xminort','off')
set(ax6,'Position',[col3 row2 width height]);
set(ax6,'Tickdir','out','fontsize',fonts_ax,'layer','top','box','on', ...
    'ylim',[-70 70],'ytick',-70:10:70,'yticklabel',{''},'yminort','on', ...
    'xlim',[0 360],'xtick',0:60:360,'xticklabel',{''},'xminort','off')
set(ax7,'Position',[col1 row1 width height]);
set(ax7,'Tickdir','out','fontsize',fonts_ax,'layer','top','box','on', ...
    'ylim',[-70 70],'ytick',-70:10:70,'yticklabel',{'70S','','50S','','30S','','10S','','10N','','30N','','50N','','70N'},'yminort','on', ...
    'xlim',[0 360],'xtick',0:60:360,'xticklabel',{'0','60E','120E','180','120W','60W','0'},'xminort','off')
set(ax8,'Position',[col2 row1 width height]);
set(ax8,'Tickdir','out','fontsize',fonts_ax,'layer','top','box','on', ...
    'ylim',[-70 70],'ytick',-70:10:70,'yticklabel',{''},'yminort','on', ...
    'xlim',[0 360],'xtick',0:60:360,'xticklabel',{'0','60E','120E','180','120W','60W','0'},'xminort','off')
set(ax9,'Position',[col3 row1 width height]);
set(ax9,'Tickdir','out','fontsize',fonts_ax,'layer','top','box','on', ...
    'ylim',[-70 70],'ytick',-70:10:70,'yticklabel',{''},'yminort','on', ...
    'xlim',[0 360],'xtick',0:60:360,'xticklabel',{'0','60E','120E','180','120W','60W','0'},'xminort','off')
set(lab1,'fontwei','bold');
set(lab4,'fontwei','bold');
set(lab7,'fontwei','bold');
set(ylab1,'Position',[-40 0 1],'fontsize',fonts_lab);
set(ylab4,'Position',[-40 0 1],'fontsize',fonts_lab);
set(ylab7,'Position',[-40 0 1],'fontsize',fonts_lab);
set(xlab7,'Position',[180 -95 1],'fontsize',fonts_lab);
set(xlab8,'Position',[180 -95 1],'fontsize',fonts_lab);
set(xlab9,'Position',[180 -95 1],'fontsize',fonts_lab);
set(hh1,'Position',[.17 .045 .75 .02],'fontsize',fonts_lab);

export_fig([out_dir,datestr(now,'yymmdd'),'_Fig',fignum],'-eps')

close all%set(gcf,'visi','on'); %
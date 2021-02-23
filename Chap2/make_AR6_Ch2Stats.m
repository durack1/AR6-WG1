function make_AR6_Ch2Stats(infile,writeFiles)
% This file generates statistics to be used in AR6 Ch2 salinity descriptions
%
% Paul J. Durack 22nd February 2021
%
% PJD 22 Feb 2021   - Copied from ~git/oceanObs/evaluate/make_nc.m (210218) and updated input
% PJD 22 Feb 2021   - Generated outputs from two files
%                       ~work/Shared/090605_FLR2_sptg/
%                       DurackandWijffels_GlobalOceanChanges_1950-2000.nc
%                       ~work/Shared/200428_data_OceanObsAnalysis/
%                       DurackandWijffels_GlobalOceanChanges_19500101-20191231__210122-205355_beta.nc
% PJD 23 Feb 2021   - Further updates including pattern amplification (PA) calculation

% make_AR6_Ch2Stats.m

% Output for CMIP5/AR5 and CMIP6/AR6 data
%{
CDF
Obs corrcoef: 0.8 p-val: 2.0403e-62
infile: DurackandWijffels_GlobalOceanChanges_1950-2000.nc
analysis time period: 1950-1-1 to 2009-04-04
mean salinity (weighted):                     +34.853
mean salinity (unweighted):                   +34.702
check salinity (35.0 PSS-78, wt'd):           +35.000 (vs +35.000 unwt'd)
low salinity chg (wt'd):                      -0.0600 +/- 0.027
high salinity chg (wt'd):                     +0.0563 +/- 0.024
salinity contrast chg (wt'd):                 +0.1163 +/- 0.036
salinity contrast chg (wt'd @ 90% C.I):       +0.1163 +/- 0.059 (0.06 to 0.18)
salinity contrast chg (wt'd @ 90% C.I +4.2f): +0.12 +/- 0.06 (0.06 to 0.18)
salinity contrast chg (wt'd) 58yrs:           +0.1349
salinity contrast chg (wt'd) 59yrs:           +0.1372
salinity PA/R^2:                               8.19% / 0.76

CDF
Obs corrcoef: 0.7 p-val: 1.7798e-50
infile: DurackandWijffels_GlobalOceanChanges_19500101-20191231__210122-205355_beta.nc
analysis time period: 1949-12-31 to 2019-12-30
mean salinity (weighted):                     +34.857
mean salinity (unweighted):                   +34.699
check salinity (35.0 PSS-78, wt'd):           +35.000 (vs +35.000 unwt'd)
low salinity chg (wt'd):                      -0.0611 +/- 0.030
high salinity chg (wt'd):                     +0.0743 +/- 0.022
salinity contrast chg (wt'd):                 +0.1355 +/- 0.037
salinity contrast chg (wt'd @ 90% C.I):       +0.1355 +/- 0.061 (0.07 to 0.20)
salinity contrast chg (wt'd @ 90% C.I +4.2f): +0.14 +/- 0.06 (0.07 to 0.20)
salinity contrast chg (wt'd) decade-1:        +0.0194
salinity PA/R^2:                               10.44% / 0.70
%}

%% Cleanup workspace and command window
% Initialise environment variables - only homeDir needed for file cleanups
%[homeDir,work_dir,dataDir,obsDir,username,a_host_longname,a_maxThreads,a_opengl,a_matver] = myMatEnv(maxThreads);
[homeDir,~,~,~,username,aHostLongname,~,~,~] = myMatEnv(2);
if ~sum(strcmp(username,{'dur041','duro','durack1'})); disp('**myMatEnv - username error**'); keyboard; end
outDir = ['/export/',username,'/git/AR6-WG1/Chap2/'];

%infile = '/work/durack1/Shared/090605_FLR2_sptg/DurackandWijffels_GlobalOceanChanges_1950-2000.nc'
%writeFiles = '0'

%% Error/C.I inflation factors
% Error estimate inflation factors
CI_99 = 2.57583; % Raise error estimates to 99% C.I assuming normal distn http://en.wikipedia.org/wiki/Normal_distribution
CI_90 = 1.64485;
booterror_pres = 1.09; % Add 9% to the formal error to account for bootstrap result (pressure, was 30%)

%% Change the infile and pathnames
% Create inputs if they are not passed as arguments - check usage below..
if nargin < 1, disp('No valid input file, exiting'); return; end
if ~validatestring(writeFiles,{'0','1','True','true','False','false'})
    disp('Invalid writeFile argument, exiting'); return
end
if sum(strcmp(writeFiles,{'0','False','false'}))
    writeFiles = false;
elseif sum(strcmp(writeFiles,{'1','True','true'}))
    writeFiles = true;
end
if nargin > 2, disp('Too many arguments, exiting'); return; end
if nargin == 2
   % Validate input is matfile
   if isfile(infile)
       fclose('all');
       [fid,~] = fopen(infile);
       ncVer = convertCharsToStrings(fread(fid,3,'uint8=>char')); % read 80 elements, captures all version and date info
       fclose(fid); clear fid
       disp(ncVer)
       if contains(ncVer,'CDF')
           [inPath,name,ext] = fileparts(infile);
           %fileNameBits = split(name,'_'); % cell array
           %outPath = char(fullfile(filePath,join(fileNameBits([1,2,5,7:end]),'_')));
           %disp(['outPath: ',outPath])
       else
           disp('Not valid netcdf-file, exiting')
           quit
       end % contains(ncVer
   end % isfile(infile)
end % nargin == 1

%% Extract netcdf variables
sChg = getnc(infile,'salinity_change');
sChgErr = getnc(infile,'salinity_change_error');
sMean = getnc(infile,'salinity_mean');
sMeanComment = attnc(infile,'salinity_mean','comment');
tmp = strsplit(sMeanComment);
timeStart = tmp{8}; timeStop = tmp{10}; clear tmp
%tChg = getnc(infile,'thetao_change');
%tChgErr = getnc(infile,'thetao_change_error');
%tMean = getnc(infile,'thetao_mean');
lon = getnc(infile,'longitude');
lat = getnc(infile,'latitude');
%depth = getnc(infile,'depth');

% Re-index longitude
sChg = squeeze(sChg(1,:,:));
sChgErr = squeeze(sChgErr(1,:,:));
sMean = squeeze(sMean(1,:,:));
%tChg = squeeze(tChg(1,:,:1));
%tChgErr = squeeze(tChgErr(1,:,:));
%tMean = squeeze(tMean(1,:,:));

%% Calculate pattern amplification
latLim = 60; % Set limit of latitude
load([homeDir,'code/make_basins.mat'],'basins3_NaN_2x1','basins3_NaN_ones_2x1','grid_lons','grid_lats');
basins3_NaN_2x1 = basins3_NaN_2x1(:,1:180);
basins3_NaN_ones_2x1 = basins3_NaN_ones_2x1(:,1:180);
gridLons = grid_lons(1:180); clear grid_lons
latGrid = meshgrid(grid_lats,gridLons)'; clear grid_lats
[Global,Pacific,Atlantic,Indian] = deal(basins3_NaN_ones_2x1);
index = basins3_NaN_2x1 ~= 1 | abs(latGrid) > latLim; Pacific(index) = NaN;
index = basins3_NaN_2x1 ~= 2 | abs(latGrid) > latLim | ( repmat(gridLons,141,1) > 150 & repmat(gridLons,141,1) < 210 ) ; Atlantic(index) = NaN;
index = basins3_NaN_2x1 ~= 3 | abs(latGrid) > latLim; Indian(index) = NaN;
clear basins3_NaN_2x1 gridLons index latGrid latLim

% Allocate data to preallocated variable
[obs_sos_chg_basins,obs_sos_mean_basins] = deal(NaN([size(sMean),4]));
for basin = 1:4
    switch basin
        case 1 % Global - no masking
            obs_sos_chg_basins(:,:,basin) = sChg.*Global;
            obs_sos_mean_basins(:,:,basin) = sMean.*Global;
        case 2 % Pacific
            obs_sos_chg_basins(:,:,basin) = sChg.*Pacific;
            obs_sos_mean_basins(:,:,basin) = sMean.*Pacific;
        case 3 % Atlantic
            obs_sos_chg_basins(:,:,basin) = sChg.*Atlantic;
            obs_sos_mean_basins(:,:,basin) = sMean.*Atlantic;
        case 4 % Indian
            obs_sos_chg_basins(:,:,basin) = sChg.*Indian;
            obs_sos_mean_basins(:,:,basin) = sMean.*Indian;
    end % switch basin
end % for basin
clear Global basin

% Generate basin zonal mean for all variables - converted to mean along lons (2), create output array for all lats (3)
[obs_sos_chg_zonal,obs_sos_mean_zonal] = deal(NaN([size(sChg,1),4]));
for basin = 1:4
    obs_sos_chg_zonal(:,basin) = squeeze(nanmean(obs_sos_chg_basins(:,:,basin),2));
    obs_sos_mean_zonal(:,basin) = squeeze(nanmean(obs_sos_mean_basins(:,:,basin),2));
end % for basin
clear basin

% Create vector for zonal averages
index_pac = ~isnan(obs_sos_mean_zonal(:,2)); index_atl = ~isnan(obs_sos_mean_zonal(:,3)); index_ind = ~isnan(obs_sos_mean_zonal(:,4));
pac = obs_sos_chg_zonal(:,2);
atl = obs_sos_chg_zonal(:,3);
ind = obs_sos_chg_zonal(:,4);
obs_sos_zonal_chg = [pac(index_pac);atl(index_atl);ind(index_ind)];
pac = obs_sos_mean_zonal(:,2);
atl = obs_sos_mean_zonal(:,3);
ind = obs_sos_mean_zonal(:,4);
obs_sos_zonal_mean = [pac(index_pac);atl(index_atl);ind(index_ind)];
clear index_pac index_atl index_ind pac atl ind

% Get file name
fileOnly = strsplit(infile,'/'); fileOnly = fileOnly{end};

% Plot up/calculate PA
fonts = 8;
close all, handle = figure('units','centimeters','visible','off','color','w'); set(0,'CurrentFigure',handle);
ax = subplot(1,1,1);
offset = nanmean(obs_sos_zonal_mean(:));
plot(obs_sos_zonal_mean-offset,obs_sos_zonal_chg,'.','color',[.6 .6 .6],'markersize',5); grid on; hold on % Global
[corr,p] = corrcoef(obs_sos_zonal_mean-offset,obs_sos_zonal_chg);
rob = robustfit(obs_sos_zonal_mean-offset,obs_sos_zonal_chg,'fair',1.4,'on');
PA = rob(2); R = abs(corr(2,1)); clear corr
hold on; plot(obs_sos_zonal_mean-offset,rob(1)+rob(2)*(obs_sos_zonal_mean-offset),'k','LineWidth',2)
ylab = ylabel('Salinity Change','fontsize',fonts);
xlab = xlabel('Salinity Mean Anomaly','fontsize',fonts);
text(3.2,-0.45,[num2str(PA*100,'%2.1f'),'%'],'fontsize',fonts*1.5,'color','k','fontweight','b','HorizontalAlignment','Right')
text(3.3,0.53,['R = ',num2str(R,'%2.1f')],'fontsize',fonts*1.5,'color','k','fontweight','b','HorizontalAlignment','Right')
text(-2.97,-0.51,['Date range: ',timeStart,' to ',timeStop],'fontsize',fonts*.6,'color','k','fontweight','b','HorizontalAlignment','Left')
text(-2.97,-0.57,['Infile: ',strrep(fileOnly,'_','\_')],'fontsize',fonts*.5,'color','k','fontweight','b','HorizontalAlignment','Left')
disp(['Obs corrcoef: ',num2str(R,'%2.1f'),' p-val: ',num2str(p(2,1))])
set(handle,'posi',[3 3 8 5]);
line([-3 3],[0 0],'linewid',1,'color','k'); line([0 0],[-0.6 0.6],'linewid',1,'color','k'); hold on % Drop black lines on top
set(ax,'Position', [0.15 0.2 0.8 0.75],'fontsize',fonts,'layer','bottom','box','on','Tickdir','out', ...
    'xlim',[-3 3],'xtick',-3:1:3,'xticklabel',{'-3','-2','-1','0','1','2','3'},'xminort','on', ...
    'ylim',[-0.6 0.6],'ytick',-0.6:0.2:0.6,'yticklabel',{'-0.6','-0.4','-0.2','0','0.2','0.4','0.6'},'yminort','on')
if writeFiles
    set(handle,'visi','on'); % Reset visuals for export_fig
    export_fig([outDir,datestr(now,'yymmdd'),'_',name,'_PA'],'-eps')
    close all
end

%% Create near-surface salinity contrast diagnostic
% Generate masks and near-surface fields
[~,~,areaKm2] = area_weight(lon,lat); areaKm2 = areaKm2';
areaKm2Masked = areaKm2.*basins3_NaN_ones_2x1;
areaKm2MaskedSum = nansum(nansum(areaKm2Masked));
nearSurfMeanSalinity = squeeze(sMean(:,:,1));
nearSurfChgSalinity = squeeze(sChg(:,:,1));
nearSurfChgErrSalinity = squeeze(sChgErr(:,:,1));
saltCheck = repmat(35.0,[141 180]).*basins3_NaN_ones_2x1;
% Generate weighted and unweighted mean numbers
nearSurfMeanSalinityUnwt = nanmean(nanmean(nearSurfMeanSalinity));
nearSurfMeanSalinityWt = nansum(nansum(nearSurfMeanSalinity.*areaKm2Masked))/areaKm2MaskedSum;
saltCheckUnwt = nanmean(nanmean(saltCheck));
saltCheckWt = nansum(nansum(saltCheck.*areaKm2Masked))/areaKm2MaskedSum;
% Generate masks using weighted mean
nearSurfLowSalinityMask = nearSurfMeanSalinity < nearSurfMeanSalinityWt;
nearSurfLowSalinityMask = double(nearSurfLowSalinityMask); nearSurfLowSalinityMask(nearSurfLowSalinityMask == 0) = NaN;
nearSurfHighSalinityMask = nearSurfMeanSalinity > nearSurfMeanSalinityWt;
nearSurfHighSalinityMask = double(nearSurfHighSalinityMask); nearSurfHighSalinityMask(nearSurfHighSalinityMask == 0) = NaN;
% Weight masked low/high areas
areaKm2HighMasked = areaKm2.*nearSurfHighSalinityMask;
areaKm2LowMasked = areaKm2.*nearSurfLowSalinityMask;
% Using weights calculate low/high from near-surface change fields
areaKm2LowMaskedSum = nansum(nansum(areaKm2LowMasked));
nearSurfLowChgSalinity = nearSurfChgSalinity.*areaKm2LowMasked;
nearSurfLowChgSalinityWt = nansum(nansum(nearSurfLowChgSalinity))/areaKm2LowMaskedSum;
nearSurfLowChgErrSalinity = nearSurfChgErrSalinity.*areaKm2LowMasked;
nearSurfLowChgErrSalinityWt = nansum(nansum(nearSurfLowChgErrSalinity))/areaKm2LowMaskedSum;
areaKm2HighMaskedSum = nansum(nansum(areaKm2HighMasked));
nearSurfHighChgSalinity = nearSurfChgSalinity.*areaKm2HighMasked;
nearSurfHighChgSalinityWt = nansum(nansum(nearSurfHighChgSalinity))/areaKm2HighMaskedSum;
nearSurfHighChgErrSalinity = nearSurfChgErrSalinity.*areaKm2HighMasked;
nearSurfHighChgErrSalinityWt = nansum(nansum(nearSurfHighChgErrSalinity))/areaKm2HighMaskedSum;
% Report
%fileOnly = strsplit(infile,'/');
disp(['infile: ',fileOnly])
disp(['analysis time period: ',timeStart,' to ',timeStop])
disp(['mean salinity (weighted):                     ',num2str(nearSurfMeanSalinityWt,'%+7.3f')])
disp(['mean salinity (unweighted):                   ',num2str(nearSurfMeanSalinityUnwt,'%+7.3f')])
disp(['check salinity (35.0 PSS-78, wt''d):           ',num2str(saltCheckWt,'%+7.3f'),' (vs ', ...
    num2str(saltCheckUnwt,'%+7.3f'),' unwt''d)'])
disp(['low salinity chg (wt''d):                      ',num2str(nearSurfLowChgSalinityWt,'%+8.4f'), ...
    ' +/- ',num2str(nearSurfLowChgErrSalinityWt,'%7.3f')])
disp(['high salinity chg (wt''d):                     ',num2str(nearSurfHighChgSalinityWt,'%+8.4f'), ...
    ' +/- ',num2str(nearSurfHighChgErrSalinityWt,'%7.3f')])
nearSurfChgErrSalinityQuad = (nearSurfLowChgErrSalinityWt + nearSurfHighChgErrSalinityWt)/sqrt(2); % Sum in quadrature
disp(['salinity contrast chg (wt''d):                 ', ...
    num2str((nearSurfHighChgSalinityWt-nearSurfLowChgSalinityWt),'%+8.4f'), ...
    ' +/- ',num2str(nearSurfChgErrSalinityQuad,'%7.3f')])
nearSurfHighToLowContrast = nearSurfHighChgSalinityWt-nearSurfLowChgSalinityWt;
nearSurfChgErrSalinity90CI = nearSurfChgErrSalinityQuad*CI_90;
disp(['salinity contrast chg (wt''d @ 90% C.I):       ', ...
    num2str((nearSurfHighToLowContrast),'%+8.4f'), ...
    ' +/- ',num2str(nearSurfChgErrSalinity90CI,'%7.3f'), ...
    ' (',num2str(nearSurfHighToLowContrast-nearSurfChgErrSalinity90CI,'%4.2f'), ...
    ' to ',num2str(nearSurfHighToLowContrast+nearSurfChgErrSalinity90CI,'%4.2f'),')'])
disp(['salinity contrast chg (wt''d @ 90% C.I +4.2f): ', ...
    num2str((nearSurfHighToLowContrast),'%+5.2f'), ...
    ' +/- ',num2str(nearSurfChgErrSalinity90CI,'%4.2f'), ...
    ' (',num2str(nearSurfHighToLowContrast-nearSurfChgErrSalinity90CI,'%4.2f'), ...
    ' to ',num2str(nearSurfHighToLowContrast+nearSurfChgErrSalinity90CI,'%4.2f'),')'])
if contains(infile,'_1950-2000')
    disp(['salinity contrast chg (wt''d) 58yrs:           ', ...
        num2str((nearSurfHighChgSalinityWt-nearSurfLowChgSalinityWt)*(58/50),'%+8.4f')])
    disp(['salinity contrast chg (wt''d) 59yrs:           ', ...
        num2str((nearSurfHighChgSalinityWt-nearSurfLowChgSalinityWt)*(59/50),'%+8.4f')])
else
    disp(['salinity contrast chg (wt''d) decade-1:        ', ...
        num2str((nearSurfHighChgSalinityWt-nearSurfLowChgSalinityWt)/((2020-1950)/10),'%+8.4f')])
end
disp(['salinity PA/R^2:                               ', ...
    num2str(PA*100,'%4.2f'), ...
    '% / ',num2str(R,'%4.2f')])

% Plots for region validation
if writeFiles
    %{
    nearSurfHighSalinityMaskSum = nansum(nansum(areaKm2.*nearSurfHighSalinityMask));
    nearSurfHighSalinityMaskSumArr = areaKm2.*nearSurfHighSalinityMask;
    figure(1); clf, pcolor(lon,lat,(nearSurfHighSalinityMaskSumArr/nearSurfHighSalinityMaskSum)'); shading flat, continents, colorbar
    nearSurfLowSalinityMaskSum = nansum(nansum(areaKm2.*nearSurfLowSalinityMask));
    nearSurfLowSalinityMaskSumArr = areaKm2.*nearSurfLowSalinityMask;
    figure(2); clf ,pcolor(lon,lat,(nearSurfLowSalinityMaskSumArr/nearSurfLowSalinityMaskSum)'); shading flat, continents, colorbar
    %}
end
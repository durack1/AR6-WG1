% This file generates two-panel figures displaying density changes for
% global basins as sourced from DW10
%
% Paul J. Durack 7th January 2011
%
% make_AR5_Chap9ModelEval.m

% PJD 29 Dec 2019   - Renamed from ../120711_AR5/Chap09/make_AR5_Fig9p13_CMIP5minusWOA09_thetaoAndso.m and updated input
% PJD 29 Dec 2019   - Updated from WOA09 to WOD/A18 obs data
% PJD 29 Dec 2019   - Added getGitInfo for export_fig hash
% PJD  2 Jan 2020   - Updated to qc and process first files
% PJD  3 Jan 2020   - Added thetao exclusion list
% PJD  3 Jan 2020   - Added fix for lon offset in input files (both plots and reads)
% PJD  4 Jan 2020   - Turned off eps writing for WOA18 validation figures
% PJD  4 Jan 2020   - Fixed bug in subsurface temperature plots
% PJD  4 Jan 2020   - Deal with 'so' match in EC-Earth-Consortium
% PJD  4 Jan 2020   - Updated colorbar call with clim update - has changed since R2011b
% PJD  4 Jan 2020   - Finalised global mean, next stop CMIP5 and basins
%                   - TODO: First plot greyed for each box, then overplot colours and contours (greyed bathymetry underlaid)
%                   - TODO: Add more models (total count 120720 is 45 for CMIP5), deal with sigma-level models


% Cleanup workspace and command window
clear, clc, close all
% Initialise environment variables
[homeDir,~,dataDir,obsDir,~,aHostLongname] = myMatEnv(2);
outDir = os_path([homeDir,'190311_AR6/Chap3/']);
outData = os_path([outDir,'ncs/CMIP6/historical/woaGrid/']);

% Setup plotting scales
ptcont1 = -2.5:2.5:30;
ptcont2 = -2.5:2.5:30;
ptcont3 = -2.5:1.25:30;
scont1 = 30.25:0.5:39.75;
scont2 = 30:0.5:40;
scont3 = 30:0.25:40;
sscale = [1 1]; gscale = [0.3 0.5]; ptscale = [3 3];
fonts = 7; fonts_c = 6; fonts_ax = 6; fonts_lab = 10;

%% If running through entire script cleanup old figure files
[command] = matlab_mode;
disp(command)
if ~contains(command,'-r ') % Test for interactive mode
    purge_all = input('* Are you sure you want to purge ALL current figure files? Y/N [Y]: ','s');
    if strcmpi(purge_all,'y')
        purge = 1;
    else
        purge = 0;
    end
else % If batch job purge files
    purge = 1;
end
if purge
    delete([outDir,datestr(now,'yymmdd'),'*_CMIP6*.eps']);
    delete([outDir,datestr(now,'yymmdd'),'_WOA09*.png']);
    delete([outDir,datestr(now,'yymmdd'),'_CMIP6*.png']);
    delete([outDir,datestr(now,'yymmdd'),'_CMIP6*.mat']);
    delete([outData,'so/figs/',datestr(now,'yymmdd'),'*.png']);
    delete([outData,'thetao/figs/',datestr(now,'yymmdd'),'*.png']);
end

%% Print time to console, for logging
disp(['TIME: ',datestr(now)])
setenv('USERCREDENTIALS','Paul J. Durack; pauldurack@llnl.gov (durack1); +1 925 422 5208')
disp(['CONTACT: ',getenv('USERCREDENTIALS')])
disp(['HOSTNAME: ',aHostLongname])
a = getGitInfo('/export/durack1/git/export_fig/') ;
disp([upper('export_fig hash: '),a.hash])
a = getGitInfo('/export/durack1/git/AR6-WG1/') ;
disp([upper('AR6-WG1 hash: '),a.hash])
disp('')

%% Load WOA18 data
woaDir = os_path([obsDir,'WOD18/190312/']);
infile = os_path([woaDir,'woa18_decav_t00_01.nc']);
t_mean          = getnc(infile,'t_an');
t_lat           = getnc(infile,'lat');
t_lon           = getnc(infile,'lon');
t_depth         = getnc(infile,'depth'); clear infile
infile = os_path([woaDir,'woa18_decav_s00_01.nc']);
s_mean          = getnc(infile,'s_an'); clear infile

% Convert lat to 0 to 360 and flip grids
t_lon = t_lon+179.5;
t_mean = t_mean(:,:,[181:360,1:180]);
s_mean = s_mean(:,:,[181:360,1:180]);

% Mask marginal seas
infile = os_path([homeDir,'code/make_basins.mat']);
load(infile,'basins3_NaN_ones'); % lat/lon same as WOA09
%clf; pcolor(basins3_NaN_ones); shading flat
for x = 1:length(t_depth)
    t_mean(x,:,:) = squeeze(t_mean(x,:,:)).*basins3_NaN_ones;
    s_mean(x,:,:) = squeeze(s_mean(x,:,:)).*basins3_NaN_ones;
end; clear x infile

%{
close all
figure(1)
contourf(t_lon,t_lat,squeeze(t_mean(1,:,:)))
figure(2)
pcolor(t_lon,t_lat,basins3_NaN_ones); shading flat
%figure(3)
%contourf(t_lon,t_lat,squeeze(t_mean2(1,:,:)))
%}

% Convert in-situ temperature to potential temperature
t_depth_mat = repmat(t_depth,[1 length(t_lat)]);
pres = sw_pres(t_depth_mat,t_lat');
pres_mat = repmat(pres,[1 1 size(t_mean,3)]);
pt_mean = NaN(size(t_mean));
for x = 1:size(t_mean,3)
    pt_mean(:,:,x) = sw_ptmp(s_mean(:,:,x),t_mean(:,:,x),pres_mat(:,:,x),0);
end
clear t_mean pres pres_mat x

% Generate zonal means
pt_mean_zonal    = nanmean(pt_mean,3);
s_mean_zonal    = nanmean(s_mean,3);

% WOA18 potential temperature
close all, handle = figure('units','centimeters','visible','off','color','w'); set(0,'CurrentFigure',handle)
ax1 = subplot(1,2,1);
pcolor(t_lon,t_lat,squeeze(pt_mean(1,:,:))); shading flat; caxis([ptcont1(1) ptcont1(end)]); clmap(27); hold all
contour(t_lon,t_lat,squeeze(pt_mean(1,:,:)),ptcont1,'color','k');
ax2 = subplot(1,2,2);
pcolor(t_lat,t_depth,nanmean(pt_mean,3)); shading flat; caxis([ptcont1(1) ptcont1(end)]); clmap(27); axis ij; hold all
contour(t_lat,t_depth,nanmean(pt_mean,3),ptcont1,'color','k');
hh1 = colorbarf_nw('horiz',ptcont3,ptcont2);
set(handle,'Position',[3 3 16 7]) % Full page width (175mm (17) width x 83mm (8) height) - Back to 16.5 x 6 for proportion
set(ax1,'Position',[0.03 0.19 0.45 0.8]);
set(ax2,'Position',[0.54 0.19 0.45 0.8]);
set(hh1,'Position',[0.06 0.075 0.9 0.03],'fontsize',fonts_c);
set(ax1,'Tickdir','out','fontsize',fonts_ax,'layer','top','box','on', ...
    'xlim',[0 360],'xtick',0:30:360,'xticklabel',{'0','30','60','90','120','150','180','210','240','270','300','330','360'},'xminort','on', ...
    'ylim',[-90 90],'ytick',-90:20:90,'yticklabel',{'-90','-70','-50','-30','-10','10','30','50','70','90'},'yminort','on');
set(ax2,'Tickdir','out','fontsize',fonts_ax,'layer','top','box','on', ...
    'ylim',[0 5500],'ytick',0:500:5500,'yticklabel',{'0','500','1000','1500','2000','2500','3000','3500','4000','4500','5000','5500'},'yminort','on', ...
    'xlim',[-90 90],'xtick',-90:20:90,'xticklabel',{'-90','-70','-50','-30','-10','10','30','50','70','90'},'xminort','on');
export_fig([outDir,datestr(now,'yymmdd'),'_WOA18_thetao_mean'],'-png')
%export_fig([outDir,datestr(now,'yymmdd'),'_WOA18_thetao_mean'],'-eps')
clear ax1 ax2 hh1

% WOA18 salinity
close all, handle = figure('units','centimeters','visible','off','color','w'); set(0,'CurrentFigure',handle)
ax1 = subplot(1,2,1);
pcolor(t_lon,t_lat,squeeze(s_mean(1,:,:))); shading flat; caxis([scont1(1) scont1(end)]); clmap(27); hold all
contour(t_lon,t_lat,squeeze(s_mean(1,:,:)),scont1,'color','k');
ax2 = subplot(1,2,2);
pcolor(t_lat,t_depth,nanmean(s_mean,3)); shading flat; caxis([scont3(1) scont3(end)]); clmap(27); axis ij; hold all
contour(t_lat,t_depth,nanmean(s_mean,3),scont3,'color','k');
hh1 = colorbarf_nw('horiz',scont3,scont2);
set(handle,'Position',[3 3 16 7]) % Full page width (175mm (17) width x 83mm (8) height) - Back to 16.5 x 6 for proportion
set(ax1,'Position',[0.03 0.19 0.45 0.8]);
set(ax2,'Position',[0.54 0.19 0.45 0.8]);
set(hh1,'Position',[0.06 0.075 0.9 0.03],'fontsize',fonts_c);
set(ax1,'Tickdir','out','fontsize',fonts_ax,'layer','top','box','on', ...
    'xlim',[0 360],'xtick',0:30:360,'xticklabel',{'0','30','60','90','120','150','180','210','240','270','300','330','360'},'xminort','on', ...
    'ylim',[-90 90],'ytick',-90:20:90,'yticklabel',{'-90','-70','-50','-30','-10','10','30','50','70','90'},'yminort','on');
set(ax2,'Tickdir','out','fontsize',fonts_ax,'layer','top','box','on', ...
    'ylim',[0 5500],'ytick',0:500:5500,'yticklabel',{'0','500','1000','1500','2000','2500','3000','3500','4000','4500','5000','5500'},'yminort','on', ...
    'xlim',[-90 90],'xtick',-90:20:90,'xticklabel',{'-90','-70','-50','-30','-10','10','30','50','70','90'},'xminort','on');
export_fig([outDir,datestr(now,'yymmdd'),'_WOA18_so_mean'],'-png')
%export_fig([outDir,datestr(now,'yymmdd'),'_WOA18_so_mean'],'-eps')
clear ax1 ax2 hh1

disp('** WOA18 processing complete.. **')

%% Do model temperature
inVar = '*thetao';
[~, models] = unix(['\ls -1 ',outData,inVar,'*woaClim.nc']);
models = strtrim(models);
temp = regexp(models,'\n','split'); clear models status
models = unique(temp); clear temp

% Trim model list for duplicates - Use plots to guide trimming
bad_list = {
    'CAS.FGOALS-f3-L.r1i1p1f1.mon.thetao.ocean.glb-l-gn.v20190822' ; % rotated pole
    'CNRM-CERFACS.CNRM-CM6-1-HR.r1i1p1f2.mon.thetao.ocean.glb-l-gn.v20191021' ; % mask
    'E3SM-Project.E3SM-1-0.r1i1p1f1.mon.thetao.ocean.glb-l-gr.v20190826' ; % mask/missing_value?
    'E3SM-Project.E3SM-1-0.r2i1p1f1.mon.thetao.ocean.glb-l-gr.v20190830' ; % zeros
    'E3SM-Project.E3SM-1-0.r3i1p1f1.mon.thetao.ocean.glb-l-gr.v20190827'
    'E3SM-Project.E3SM-1-0.r4i1p1f1.mon.thetao.ocean.glb-l-gr.v20190909'
    'E3SM-Project.E3SM-1-0.r5i1p1f1.mon.thetao.ocean.glb-l-gr.v20191009'
    'IPSL.IPSL-CM6A-LR.r10i1p1f1.mon.thetao.ocean.glb-l-gn.v20180803' ; % zeros
    'IPSL.IPSL-CM6A-LR.r11i1p1f1.mon.thetao.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r12i1p1f1.mon.thetao.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r13i1p1f1.mon.thetao.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r14i1p1f1.mon.thetao.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r15i1p1f1.mon.thetao.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r16i1p1f1.mon.thetao.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r17i1p1f1.mon.thetao.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r18i1p1f1.mon.thetao.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r19i1p1f1.mon.thetao.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r1i1p1f1.mon.thetao.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r20i1p1f1.mon.thetao.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r21i1p1f1.mon.thetao.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r22i1p1f1.mon.thetao.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r23i1p1f1.mon.thetao.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r24i1p1f1.mon.thetao.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r25i1p1f1.mon.thetao.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r26i1p1f1.mon.thetao.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r27i1p1f1.mon.thetao.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r28i1p1f1.mon.thetao.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r29i1p1f1.mon.thetao.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r2i1p1f1.mon.thetao.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r30i1p1f1.mon.thetao.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r31i1p1f1.mon.thetao.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r32i1p1f1.mon.thetao.ocean.glb-l-gn.v20190802'
    'IPSL.IPSL-CM6A-LR.r3i1p1f1.mon.thetao.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r4i1p1f1.mon.thetao.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r5i1p1f1.mon.thetao.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r6i1p1f1.mon.thetao.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r7i1p1f1.mon.thetao.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r8i1p1f1.mon.thetao.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r9i1p1f1.mon.thetao.ocean.glb-l-gn.v20180803'
    'MIROC.MIROC-ES2L.r1i1p1f2.mon.thetao.ocean.glb-l-gn.v20190823' ; % zeros
    'MIROC.MIROC-ES2L.r2i1p1f2.mon.thetao.ocean.glb-l-gn.v20190823'
    'MIROC.MIROC-ES2L.r3i1p1f2.mon.thetao.ocean.glb-l-gn.v20190823'
    'MRI.MRI-ESM2-0.r1i2p1f1.mon.thetao.ocean.glb-l-gn.v20191108' ; % zeros
    'NCAR.CESM2.r10i1p1f1.mon.thetao.ocean.glb-l-gn.v20190313' ; % zeros
    'NCAR.CESM2.r11i1p1f1.mon.thetao.ocean.glb-l-gn.v20190514'
    'NCAR.CESM2.r1i1p1f1.mon.thetao.ocean.glb-l-gn.v20190308'
    'NCAR.CESM2.r2i1p1f1.mon.thetao.ocean.glb-l-gn.v20190308'
    'NCAR.CESM2.r3i1p1f1.mon.thetao.ocean.glb-l-gn.v20190308'
    'NCAR.CESM2.r4i1p1f1.mon.thetao.ocean.glb-l-gn.v20190308'
    'NCAR.CESM2.r5i1p1f1.mon.thetao.ocean.glb-l-gn.v20190308'
    'NCAR.CESM2.r6i1p1f1.mon.thetao.ocean.glb-l-gn.v20190308'
    'NCAR.CESM2.r7i1p1f1.mon.thetao.ocean.glb-l-gn.v20190311' ; % depth coord?
    'NCAR.CESM2.r8i1p1f1.mon.thetao.ocean.glb-l-gn.v20190311'
    'NCAR.CESM2.r9i1p1f1.mon.thetao.ocean.glb-l-gn.v20190311'
    'NCAR.CESM2-WACCM.r1i1p1f1.mon.thetao.ocean.glb-l-gn.v20190808' ; % zeros
    'NCAR.CESM2-WACCM.r2i1p1f1.mon.thetao.ocean.glb-l-gn.v20190808'
    'NCAR.CESM2-WACCM.r3i1p1f1.mon.thetao.ocean.glb-l-gn.v20190808'
    'NOAA-GFDL.GFDL-CM4.r1i1p1f1.mon.thetao.ocean.glb-l-gn.v20180701' ; % land mask/low values
    'NOAA-GFDL.GFDL-ESM4.r1i1p1f1.mon.thetao.ocean.glb-l-gn.v20190726' ; % land mask/low values
};

%CMIP5
%{
bad_list = {
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/thetao/cmip5.EC-EARTH.historical.r10i1p1.an.ocn.thetao.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/thetao/cmip5.EC-EARTH.historical.r12i1p1.an.ocn.thetao.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/thetao/cmip5.EC-EARTH.historical.r14i1p1.an.ocn.thetao.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/thetao/cmip5.EC-EARTH.historical.r2i1p1.an.ocn.thetao.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/thetao/cmip5.EC-EARTH.historical.r3i1p1.an.ocn.thetao.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/thetao/cmip5.EC-EARTH.historical.r5i1p1.an.ocn.thetao.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/thetao/cmip5.EC-EARTH.historical.r6i1p1.an.ocn.thetao.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/thetao/cmip5.EC-EARTH.historical.r7i1p1.an.ocn.thetao.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/thetao/cmip5.EC-EARTH.historical.r9i1p1.an.ocn.thetao.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/thetao/cmip5.GISS-E2-H.historical.r1i1p3.an.ocn.thetao.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/thetao/cmip5.GISS-E2-H.historical.r1i1p3.an.ocn.thetao.ver-v20120313.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/thetao/cmip5.GISS-E2-H.historical.r2i1p3.an.ocn.thetao.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/thetao/cmip5.GISS-E2-H.historical.r2i1p3.an.ocn.thetao.ver-v20120313.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/thetao/cmip5.GISS-E2-H.historical.r3i1p3.an.ocn.thetao.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/thetao/cmip5.GISS-E2-H.historical.r3i1p3.an.ocn.thetao.ver-v20120313.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/thetao/cmip5.GISS-E2-H.historical.r4i1p3.an.ocn.thetao.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/thetao/cmip5.GISS-E2-H.historical.r4i1p3.an.ocn.thetao.ver-v20120314.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/thetao/cmip5.GISS-E2-H.historical.r5i1p3.an.ocn.thetao.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/thetao/cmip5.GISS-E2-H.historical.r5i1p3.an.ocn.thetao.ver-v20120314.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/thetao/cmip5.MIROC4h.historical.r1i1p1.an.ocn.thetao.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/thetao/cmip5.MIROC4h.historical.r2i1p1.an.ocn.thetao.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/thetao/cmip5.MIROC4h.historical.r3i1p1.an.ocn.thetao.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/thetao/cmip5.MIROC5.historical.r1i1p1.an.ocn.thetao.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/thetao/cmip5.MIROC5.historical.r2i1p1.an.ocn.thetao.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/thetao/cmip5.MIROC5.historical.r3i1p1.an.ocn.thetao.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/thetao/cmip5.MIROC5.historical.r4i1p1.an.ocn.thetao.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/thetao/cmip5.MIROC5.historical.r4i1p1.an.ocn.thetao.ver-v20120112.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/thetao/cmip5.MIROC5.historical.r5i1p1.an.ocn.thetao.ver-1.1975-2005_anClim_WOAGrid.nc'
};

bad_list_130322 = {
'/work/durack1/Shared/120711_AR5/Chap09/ncs/thetao/cmip5.EC-EARTH.historical.r10i1p1.an.ocn.thetao.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/thetao/cmip5.EC-EARTH.historical.r12i1p1.an.ocn.thetao.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/thetao/cmip5.EC-EARTH.historical.r12i1p1.an.ocn.thetao.ver-v20120516.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/thetao/cmip5.EC-EARTH.historical.r14i1p1.an.ocn.thetao.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/thetao/cmip5.EC-EARTH.historical.r14i1p1.an.ocn.thetao.ver-v20120516.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/thetao/cmip5.EC-EARTH.historical.r2i1p1.an.ocn.thetao.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/thetao/cmip5.EC-EARTH.historical.r3i1p1.an.ocn.thetao.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/thetao/cmip5.EC-EARTH.historical.r5i1p1.an.ocn.thetao.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/thetao/cmip5.EC-EARTH.historical.r6i1p1.an.ocn.thetao.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/thetao/cmip5.EC-EARTH.historical.r7i1p1.an.ocn.thetao.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/thetao/cmip5.EC-EARTH.historical.r7i1p1.an.ocn.thetao.ver-v20120515.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/thetao/cmip5.EC-EARTH.historical.r9i1p1.an.ocn.thetao.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/thetao/cmip5.GISS-E2-H.historical.r1i1p3.an.ocn.thetao.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/thetao/cmip5.GISS-E2-H.historical.r1i1p3.an.ocn.thetao.ver-v20120313.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/thetao/cmip5.GISS-E2-H.historical.r2i1p3.an.ocn.thetao.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/thetao/cmip5.GISS-E2-H.historical.r2i1p3.an.ocn.thetao.ver-v20120313.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/thetao/cmip5.GISS-E2-H.historical.r3i1p3.an.ocn.thetao.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/thetao/cmip5.GISS-E2-H.historical.r3i1p3.an.ocn.thetao.ver-v20120313.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/thetao/cmip5.GISS-E2-H.historical.r4i1p3.an.ocn.thetao.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/thetao/cmip5.GISS-E2-H.historical.r4i1p3.an.ocn.thetao.ver-v20120314.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/thetao/cmip5.GISS-E2-H.historical.r5i1p3.an.ocn.thetao.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/thetao/cmip5.GISS-E2-H.historical.r5i1p3.an.ocn.thetao.ver-v20120314.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/thetao/cmip5.MIROC4h.historical.r1i1p1.an.ocn.thetao.ver-v20110907.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/thetao/cmip5.MIROC4h.historical.r2i1p1.an.ocn.thetao.ver-v20110907.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/thetao/cmip5.MIROC4h.historical.r3i1p1.an.ocn.thetao.ver-v20110907.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/thetao/cmip5.MIROC5.historical.r1i1p1.an.ocn.thetao.ver-v20120112.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/thetao/cmip5.MIROC5.historical.r2i1p1.an.ocn.thetao.ver-v20111202.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/thetao/cmip5.MIROC5.historical.r3i1p1.an.ocn.thetao.ver-v20111202.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/thetao/cmip5.MIROC5.historical.r4i1p1.an.ocn.thetao.ver-v20120112.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/thetao/cmip5.MIROC5.historical.r4i1p1.an.ocn.thetao.ver-v20121221.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/thetao/cmip5.MIROC5.historical.r5i1p1.an.ocn.thetao.ver-v20120608.1975-2005_anClim_WOAGrid.nc'
};

bad_list2 = {
'/work/durack1/Shared/120711_AR5/Chap09/ncs/thetao/cmip5.GISS-E2-R.historical.r1i1p3.an.ocn.thetao.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/thetao/cmip5.GISS-E2-R.historical.r1i1p3.an.ocn.thetao.ver-v20120206.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/thetao/cmip5.GISS-E2-R.historical.r1i1p3.an.ocn.thetao.ver-v20121015.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/thetao/cmip5.GISS-E2-R.historical.r2i1p3.an.ocn.thetao.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/thetao/cmip5.GISS-E2-R.historical.r2i1p3.an.ocn.thetao.ver-v20120207.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/thetao/cmip5.GISS-E2-R.historical.r2i1p3.an.ocn.thetao.ver-v20121015.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/thetao/cmip5.GISS-E2-R.historical.r3i1p3.an.ocn.thetao.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/thetao/cmip5.GISS-E2-R.historical.r3i1p3.an.ocn.thetao.ver-v20120207.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/thetao/cmip5.GISS-E2-R.historical.r3i1p3.an.ocn.thetao.ver-v20121015.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/thetao/cmip5.GISS-E2-R.historical.r4i1p3.an.ocn.thetao.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/thetao/cmip5.GISS-E2-R.historical.r4i1p3.an.ocn.thetao.ver-v20120207.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/thetao/cmip5.GISS-E2-R.historical.r4i1p3.an.ocn.thetao.ver-v20121015.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/thetao/cmip5.GISS-E2-R.historical.r5i1p3.an.ocn.thetao.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/thetao/cmip5.GISS-E2-R.historical.r5i1p3.an.ocn.thetao.ver-v20120207.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/thetao/cmip5.GISS-E2-R.historical.r5i1p3.an.ocn.thetao.ver-v20121015.1975-2005_anClim_WOAGrid.nc'
};
%}

% Truncate using dupe list
ind = NaN(40,1); y = 1;
for x = 1:length(models)
    splits = strfind(models{x},'/');
    mod = models{x}(splits(end)+1:end);
    separators = strfind(mod,'.');
    mod = mod(separators(3)+1:separators(11)-1);
    %disp(['mod:',mod])
    match = strfind(bad_list,mod);
    match = find(~cellfun(@isempty,match), 1);
    if ~isempty(match)
        ind(y) = x;
        y = y + 1;
        disp(['drop: ',mod])
    end
end
% Truncate using ind list
ind = ind(~isnan(ind));
ind = ismember(1:length(models),ind); % Logic is create index of files in bad_list
models(ind) = [];
clear bad_list ind match splits x y

% Build matrix of model results
thetao = NaN(length(models),length(t_depth),length(t_lat),length(t_lon));
thetao_model_names = cell(length(models),1);
count = 1; ens_count = 1;
ensemble = NaN(50,length(t_depth),length(t_lat),length(t_lon));
for x = 1:(length(models)-1)
    % Test for multiple realisations and generate ensemble mean
    model_ind = strfind(models{x},'.'); temp = models{x};
    %model1 = temp((model_ind(1)+1):(model_ind(2)-1)); clear temp
    model1 = temp((model_ind(4)+1):(model_ind(5)-1)); clear temp
    model_ind = strfind(models{x+1},'.'); temp = models{x+1};
    model2 = temp((model_ind(4)+1):(model_ind(5)-1)); clear temp

    % Plot model fields for bug-tracking - 2D and global zonal mean
    tmp1 = getnc(models{x},'thetao_mean_WOAGrid'); temp = models{x};
    tmp1 = tmp1(:,:,[181:360,1:180]); % Correct lon offset issue
    ind = strfind(temp,'/'); tmp1name = regexprep(temp((ind(end)+1):end),'.nc','');
    tmp2 = getnc(models{x+1},'thetao_mean_WOAGrid'); temp = models{x+1};
    tmp2 = tmp2(:,:,[181:360,1:180]); % Correct lon offset issue
    ind = strfind(temp,'/'); tmp2name = regexprep(temp((ind(end)+1):end),'.nc','');
    % Plot model 1
    close all, handle = figure('units','centimeters','visible','off','color','w'); set(0,'CurrentFigure',handle)
    ax1 = subplot(1,2,1);
    pcolor(t_lon,t_lat,squeeze(tmp1(1,:,:))); shading flat; caxis([ptcont1(1) ptcont1(end)]); clmap(27); hold all
    contour(t_lon,t_lat,squeeze(tmp1(1,:,:)),ptcont1,'color','k');
    ax2 = subplot(1,2,2);
    pcolor(t_lat,t_depth,nanmean(tmp1,3)); shading flat; caxis([ptcont1(1) ptcont1(end)]); clmap(27); axis ij; hold all
    contour(t_lat,t_depth,nanmean(tmp1,3),ptcont1,'color','k');
    hh1 = colorbarf_nw('horiz',ptcont3,ptcont2);
    set(handle,'Position',[3 3 16 7]) % Full page width (175mm (17) width x 83mm (8) height) - Back to 16.5 x 6 for proportion
    set(ax1,'Position',[0.03 0.19 0.45 0.8]);
    set(ax2,'Position',[0.54 0.19 0.45 0.8]);
    set(hh1,'Position',[0.06 0.075 0.9 0.03],'fontsize',fonts_c);
    set(ax1,'Tickdir','out','fontsize',fonts_ax,'layer','top','box','on', ...
    'xlim',[0 360],'xtick',0:30:360,'xticklabel',{'0','30','60','90','120','150','180','210','240','270','300','330','360'},'xminort','on', ...
    'ylim',[-90 90],'ytick',-90:20:90,'yticklabel',{'-90','-70','-50','-30','-10','10','30','50','70','90'},'yminort','on');
    set(ax2,'Tickdir','out','fontsize',fonts_ax,'layer','top','box','on', ...
    'ylim',[0 5500],'ytick',0:500:5500,'yticklabel',{'0','500','1000','1500','2000','2500','3000','3500','4000','4500','5000','5500'},'yminort','on', ...
    'xlim',[-90 90],'xtick',-90:20:90,'xticklabel',{'-90','-70','-50','-30','-10','10','30','50','70','90'},'xminort','on');    
    export_fig([outData,'thetao/',datestr(now,'yymmdd'),'_',tmp1name],'-png')
    close all
    clear handle ax1 ax2 hh1 tmp1 ind tmp1name
    
    % Plot model 2
    close all, handle = figure('units','centimeters','visible','off','color','w'); set(0,'CurrentFigure',handle)
    ax1 = subplot(1,2,1);
    pcolor(t_lon,t_lat,squeeze(tmp2(1,:,:))); shading flat; caxis([ptcont1(1) ptcont1(end)]); clmap(27); hold all
    contour(t_lon,t_lat,squeeze(tmp2(1,:,:)),ptcont1,'color','k');
    ax2 = subplot(1,2,2);
    pcolor(t_lat,t_depth,nanmean(tmp2,3)); shading flat; caxis([ptcont1(1) ptcont1(end)]); clmap(27); axis ij; hold all
    contour(t_lat,t_depth,nanmean(tmp2,3),ptcont1,'color','k');
    hh1 = colorbarf_nw('horiz',ptcont3,ptcont2);
    set(handle,'Position',[3 3 16 7]) % Full page width (175mm (17) width x 83mm (8) height) - Back to 16.5 x 6 for proportion
    set(ax1,'Position',[0.03 0.19 0.45 0.8]);
    set(ax2,'Position',[0.54 0.19 0.45 0.8]);
    set(hh1,'Position',[0.06 0.075 0.9 0.03],'fontsize',fonts_c);
    set(ax1,'Tickdir','out','fontsize',fonts_ax,'layer','top','box','on', ...
    'xlim',[0 360],'xtick',0:30:360,'xticklabel',{'0','30','60','90','120','150','180','210','240','270','300','330','360'},'xminort','on', ...
    'ylim',[-90 90],'ytick',-90:20:90,'yticklabel',{'-90','-70','-50','-30','-10','10','30','50','70','90'},'yminort','on');
    set(ax2,'Tickdir','out','fontsize',fonts_ax,'layer','top','box','on', ...
    'ylim',[0 5500],'ytick',0:500:5500,'yticklabel',{'0','500','1000','1500','2000','2500','3000','3500','4000','4500','5000','5500'},'yminort','on', ...
    'xlim',[-90 90],'xtick',-90:20:90,'xticklabel',{'-90','-70','-50','-30','-10','10','30','50','70','90'},'xminort','on');    
    export_fig([outData,'thetao/',datestr(now,'yymmdd'),'_',tmp2name],'-png');
    close all
    clear handle ax1 ax2 hh1 tmp2 tmp2name
    
    if x == (length(models)-1) && ~strcmp(model1,model2)
        % Process final fields - if different
        infile = models{x};
        unit_test = getnc(infile,'thetao_mean_WOAGrid');
        unit_test = unit_test(:,:,[181:360,1:180]); % Correct lon offset issue
        if min(min(unit_test(1,:,:))) > 250; unit_test = unit_test-273.15; end
        thetao(count,:,:,:) = unit_test;
        thetao_model_names{count} = model1;
        count = count + 1;
        infile = models{x+1};
        unit_test = getnc(infile,'thetao_mean_WOAGrid');
        unit_test = unit_test(:,:,[181:360,1:180]); % Correct lon offset issue
        if min(min(unit_test(1,:,:))) > 250; unit_test = unit_test-273.15; end
        thetao(count,:,:,:) = unit_test;
        thetao_model_names{count} = model2;
    elseif x == (length(models)-1) && strcmp(model1,model2)
        % Process final fields - if same
        infile = models{x};
        unit_test = getnc(infile,'thetao_mean_WOAGrid');
        unit_test = unit_test(:,:,[181:360,1:180]); % Correct lon offset issue
        if min(min(unit_test(1,:,:))) > 250; unit_test = unit_test-273.15; end
        ensemble(ens_count,:,:,:) = unit_test;
        ens_count = ens_count + 1;
        infile = models{x+1};
        unit_test = getnc(infile,'thetao_mean_WOAGrid');
        unit_test = unit_test(:,:,[181:360,1:180]); % Correct lon offset issue
        if min(min(unit_test(1,:,:))) > 250; unit_test = unit_test-273.15; end
        ensemble(ens_count,:,:,:) = unit_test;
        % Write to matrix
        thetao(count,:,:,:) = squeeze(nanmean(ensemble));
        thetao_model_names{count} = model1;
    elseif ~strcmp(model1,model2)
        disp([num2str(x,'%03d'),' thetao different count: ',num2str(count),' ',model1,' ',model2])
        % If models are different
        if ens_count > 1
            thetao(count,:,:,:) = squeeze(nanmean(ensemble));
            thetao_model_names{count} = model1;
            count = count + 1;
            % Reset ensemble stuff
            ens_count = 1;
            ensemble = NaN(20,length(t_depth),length(t_lat),length(t_lon));
        else
            infile = models{x};
            unit_test = getnc(infile,'thetao_mean_WOAGrid');
            unit_test = unit_test(:,:,[181:360,1:180]); % Correct lon offset issue
            if min(min(unit_test(1,:,:))) > 250; unit_test = unit_test-273.15; end
            thetao(count,:,:,:) = unit_test;
            thetao_model_names{count} = model1;
            count = count + 1;
        end
    else
        disp([num2str(x,'%03d'),' thetao same      count: ',num2str(count),' ',model1,' ',model2])
        % If models are the same
        infile = models{x};
        unit_test = getnc(infile,'thetao_mean_WOAGrid');
        unit_test = unit_test(:,:,[181:360,1:180]); % Correct lon offset issue
        if min(unit_test(:)) > 250; unit_test = unit_test-273.15; end
        ensemble(ens_count,:,:,:) = unit_test;
        ens_count = ens_count + 1;
    end
end
% Trim excess values
thetao((count+1):end,:,:,:) = [];
thetao_model_names((count+1):end) = [];
clear count ens_count ensemble in_path infile model* unit_test x

% Cludgey fix for bad data
%{
thetao(thetao < -3) = NaN;
thetao(thetao > 35) = NaN;
for x = 18:31
    % Truncate big stuff
    level = squeeze(thetao(:,x,:,:));
    index = level > 10;
    level(index) = NaN;
    thetao(:,x,:,:) = level;
    if x >= 23
        level = squeeze(thetao(:,x,:,:));
        index = level > 5;
        level(index) = NaN;
        thetao(:,x,:,:) = level;
    end
    if x >= 26
        level = squeeze(thetao(:,x,:,:));
        index = level > 2.5;
        level(index) = NaN;
        thetao(:,x,:,:) = level;
    end
    % truncate small stuff
    level = squeeze(thetao(:,x,:,:));
    index = level < -3;
    level(index) = NaN;
    thetao(:,x,:,:) = level;
end
%}

% Mask marginal seas
for mod = 1:size(thetao,1)
    for x = 1:length(t_depth)
        thetao(mod,x,:,:) = squeeze(thetao(mod,x,:,:)).*basins3_NaN_ones;
    end
end; clear mod x

% Calculate ensemble mean
thetao_mean = squeeze(nanmean(thetao,1)); % Generate mean amongst models

% CMIP potential temperature
close all, handle = figure('units','centimeters','visible','off','color','w'); set(0,'CurrentFigure',handle)
ax1 = subplot(1,2,1);
pcolor(t_lon,t_lat,squeeze(thetao_mean(1,:,:))); shading flat; caxis([ptcont1(1) ptcont1(end)]); clmap(27); hold all
contour(t_lon,t_lat,squeeze(thetao_mean(1,:,:)),ptcont1,'color','k');
ax2 = subplot(1,2,2);
pcolor(t_lat,t_depth,nanmean(thetao_mean,3)); shading flat; caxis([ptcont1(1) ptcont1(end)]); clmap(27); axis ij; hold all
contour(t_lat,t_depth,nanmean(thetao_mean,3),ptcont1,'color','k');
hh1 = colorbarf_nw('horiz',ptcont3,ptcont2);
set(handle,'Position',[3 3 16 7]) % Full page width (175mm (17) width x 83mm (8) height) - Back to 16.5 x 6 for proportion
set(ax1,'Position',[0.03 0.19 0.45 0.8]);
set(ax2,'Position',[0.54 0.19 0.45 0.8]);
set(hh1,'Position',[0.06 0.075 0.9 0.03],'fontsize',fonts_c);
set(ax1,'Tickdir','out','fontsize',fonts_ax,'layer','top','box','on', ...
    'xlim',[0 360],'xtick',0:30:360,'xticklabel',{'0','30','60','90','120','150','180','210','240','270','300','330','360'},'xminort','on', ...
    'ylim',[-90 90],'ytick',-90:20:90,'yticklabel',{'-90','-70','-50','-30','-10','10','30','50','70','90'},'yminort','on');
set(ax2,'Tickdir','out','fontsize',fonts_ax,'layer','top','box','on', ...
    'ylim',[0 5500],'ytick',0:500:5500,'yticklabel',{'0','500','1000','1500','2000','2500','3000','3500','4000','4500','5000','5500'},'yminort','on', ...
    'xlim',[-90 90],'xtick',-90:20:90,'xticklabel',{'-90','-70','-50','-30','-10','10','30','50','70','90'},'xminort','on');
export_fig([outDir,datestr(now,'yymmdd'),'_CMIP6_thetao_mean'],'-png')

% Calculate zonal means
thetao_mean_zonal = squeeze(nanmean(thetao_mean,3)); % Generate zonal mean
disp('thetao done..')

%% Do model salinity
inVar = '*.so.';
[~, models] = unix(['\ls -1 ',outData,inVar,'*woaClim.nc']);
models = strtrim(models);
temp = regexp(models,'\n','split'); clear models status
models = unique(temp); clear temp

% Trim model list for duplicates - Use plots to guide trimming
bad_list = {
    'CAS.FGOALS-f3-L.r1i1p1f1.mon.so.ocean.glb-l-gn.v20190822' ; % rotated pole
    'CNRM-CERFACS.CNRM-CM6-1-HR.r1i1p1f2.mon.so.ocean.glb-l-gn.v20191021' ; % zeros
    'E3SM-Project.E3SM-1-0.r1i1p1f1.mon.so.ocean.glb-l-gr.v20190826' ; % mask/missing values
    'E3SM-Project.E3SM-1-0.r2i1p1f1.mon.so.ocean.glb-l-gr.v20190830'
    'E3SM-Project.E3SM-1-0.r3i1p1f1.mon.so.ocean.glb-l-gr.v20190827'
    'E3SM-Project.E3SM-1-0.r4i1p1f1.mon.so.ocean.glb-l-gr.v20190909'
    'E3SM-Project.E3SM-1-0.r5i1p1f1.mon.so.ocean.glb-l-gr.v20191009'
    'IPSL.IPSL-CM6A-LR.r10i1p1f1.mon.so.ocean.glb-l-gn.v20180803' ; % zeros
    'IPSL.IPSL-CM6A-LR.r11i1p1f1.mon.so.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r12i1p1f1.mon.so.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r13i1p1f1.mon.so.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r14i1p1f1.mon.so.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r15i1p1f1.mon.so.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r16i1p1f1.mon.so.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r17i1p1f1.mon.so.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r18i1p1f1.mon.so.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r19i1p1f1.mon.so.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r1i1p1f1.mon.so.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r20i1p1f1.mon.so.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r21i1p1f1.mon.so.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r22i1p1f1.mon.so.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r23i1p1f1.mon.so.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r24i1p1f1.mon.so.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r25i1p1f1.mon.so.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r26i1p1f1.mon.so.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r27i1p1f1.mon.so.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r28i1p1f1.mon.so.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r29i1p1f1.mon.so.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r2i1p1f1.mon.so.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r30i1p1f1.mon.so.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r31i1p1f1.mon.so.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r32i1p1f1.mon.so.ocean.glb-l-gn.v20190802'
    'IPSL.IPSL-CM6A-LR.r3i1p1f1.mon.so.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r4i1p1f1.mon.so.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r5i1p1f1.mon.so.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r6i1p1f1.mon.so.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r7i1p1f1.mon.so.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r8i1p1f1.mon.so.ocean.glb-l-gn.v20180803'
    'IPSL.IPSL-CM6A-LR.r9i1p1f1.mon.so.ocean.glb-l-gn.v20180803'
    'MIROC.MIROC-ES2L.r1i1p1f2.mon.so.ocean.glb-l-gn.v20190823' ; % ?
    'MIROC.MIROC-ES2L.r2i1p1f2.mon.so.ocean.glb-l-gn.v20190823'
    'MIROC.MIROC-ES2L.r3i1p1f2.mon.so.ocean.glb-l-gn.v20190823'
    'NCAR.CESM2.r10i1p1f1.mon.so.ocean.glb-l-gn.v20190313' ; % zeros
    'NCAR.CESM2.r11i1p1f1.mon.so.ocean.glb-l-gn.v20190514'
    'NCAR.CESM2.r1i1p1f1.mon.so.ocean.glb-l-gn.v20190308'
    'NCAR.CESM2.r2i1p1f1.mon.so.ocean.glb-l-gn.v20190308'
    'NCAR.CESM2.r3i1p1f1.mon.so.ocean.glb-l-gn.v20190308'
    'NCAR.CESM2.r4i1p1f1.mon.so.ocean.glb-l-gn.v20190308'
    'NCAR.CESM2.r5i1p1f1.mon.so.ocean.glb-l-gn.v20190308'
    'NCAR.CESM2.r6i1p1f1.mon.so.ocean.glb-l-gn.v20190308'
    'NCAR.CESM2.r7i1p1f1.mon.so.ocean.glb-l-gn.v20190311' ; % depth coord
    'NCAR.CESM2.r8i1p1f1.mon.so.ocean.glb-l-gn.v20190311'
    'NCAR.CESM2.r9i1p1f1.mon.so.ocean.glb-l-gn.v20190311'
    'NCAR.CESM2-WACCM.r1i1p1f1.mon.so.ocean.glb-l-gn.v20190808' ; % zeros
    'NCAR.CESM2-WACCM.r2i1p1f1.mon.so.ocean.glb-l-gn.v20190808'
    'NCAR.CESM2-WACCM.r3i1p1f1.mon.so.ocean.glb-l-gn.v20190808'
    'NCC.NorESM2-LM.r2i1p1f1.mon.so.ocean.glb-l-gn.v20190920' ; % depth issue >1000m
    'NOAA-GFDL.GFDL-CM4.r1i1p1f1.mon.so.ocean.glb-l-gn.v20180701' ; % zeros
    'NOAA-GFDL.GFDL-ESM4.r1i1p1f1.mon.so.ocean.glb-l-gn.v20190726' ; % zeros
};

% CMIP5
%{
bad_list = {
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/so/cmip5.EC-EARTH.historical.r10i1p1.an.ocn.so.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/so/cmip5.EC-EARTH.historical.r12i1p1.an.ocn.so.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/so/cmip5.EC-EARTH.historical.r14i1p1.an.ocn.so.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/so/cmip5.EC-EARTH.historical.r2i1p1.an.ocn.so.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/so/cmip5.EC-EARTH.historical.r3i1p1.an.ocn.so.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/so/cmip5.EC-EARTH.historical.r5i1p1.an.ocn.so.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/so/cmip5.EC-EARTH.historical.r6i1p1.an.ocn.so.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/so/cmip5.EC-EARTH.historical.r7i1p1.an.ocn.so.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/so/cmip5.EC-EARTH.historical.r9i1p1.an.ocn.so.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/so/cmip5.GISS-E2-H.historical.r1i1p3.an.ocn.so.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/so/cmip5.GISS-E2-H.historical.r1i1p3.an.ocn.so.ver-v20120313.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/so/cmip5.GISS-E2-H.historical.r2i1p3.an.ocn.so.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/so/cmip5.GISS-E2-H.historical.r2i1p3.an.ocn.so.ver-v20120313.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/so/cmip5.GISS-E2-H.historical.r3i1p3.an.ocn.so.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/so/cmip5.GISS-E2-H.historical.r3i1p3.an.ocn.so.ver-v20120313.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/so/cmip5.GISS-E2-H.historical.r4i1p3.an.ocn.so.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/so/cmip5.GISS-E2-H.historical.r4i1p3.an.ocn.so.ver-v20120314.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/so/cmip5.GISS-E2-H.historical.r5i1p3.an.ocn.so.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/so/cmip5.GISS-E2-H.historical.r5i1p3.an.ocn.so.ver-v20120314.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/so/cmip5.GISS-E2-H.historical.r6i1p1.an.ocn.so.ver-v20130404.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/so/cmip5.GISS-E2-H.historical.r6i1p3.an.ocn.so.ver-v20130404.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/so/cmip5.MIROC4h.historical.r1i1p1.an.ocn.so.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/so/cmip5.MIROC4h.historical.r2i1p1.an.ocn.so.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/so/cmip5.MIROC4h.historical.r3i1p1.an.ocn.so.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/so/cmip5.MIROC5.historical.r1i1p1.an.ocn.so.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/so/cmip5.MIROC5.historical.r2i1p1.an.ocn.so.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/so/cmip5.MIROC5.historical.r3i1p1.an.ocn.so.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/so/cmip5.MIROC5.historical.r4i1p1.an.ocn.so.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/so/cmip5.MIROC5.historical.r4i1p1.an.ocn.so.ver-v20120112.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/130522/so/cmip5.MIROC5.historical.r5i1p1.an.ocn.so.ver-1.1975-2005_anClim_WOAGrid.nc'
};

bad_list_130222 = {
'/work/durack1/Shared/120711_AR5/Chap09/ncs/so/cmip5.EC-EARTH.historical.r10i1p1.an.ocn.so.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/so/cmip5.EC-EARTH.historical.r12i1p1.an.ocn.so.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/so/cmip5.EC-EARTH.historical.r12i1p1.an.ocn.so.ver-v20120516.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/so/cmip5.EC-EARTH.historical.r14i1p1.an.ocn.so.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/so/cmip5.EC-EARTH.historical.r14i1p1.an.ocn.so.ver-v20120516.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/so/cmip5.EC-EARTH.historical.r2i1p1.an.ocn.so.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/so/cmip5.EC-EARTH.historical.r3i1p1.an.ocn.so.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/so/cmip5.EC-EARTH.historical.r5i1p1.an.ocn.so.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/so/cmip5.EC-EARTH.historical.r6i1p1.an.ocn.so.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/so/cmip5.EC-EARTH.historical.r7i1p1.an.ocn.so.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/so/cmip5.EC-EARTH.historical.r7i1p1.an.ocn.so.ver-v20120515.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/so/cmip5.EC-EARTH.historical.r9i1p1.an.ocn.so.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/so/cmip5.GISS-E2-H.historical.r1i1p3.an.ocn.so.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/so/cmip5.GISS-E2-H.historical.r1i1p3.an.ocn.so.ver-v20120313.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/so/cmip5.GISS-E2-H.historical.r2i1p3.an.ocn.so.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/so/cmip5.GISS-E2-H.historical.r2i1p3.an.ocn.so.ver-v20120313.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/so/cmip5.GISS-E2-H.historical.r3i1p3.an.ocn.so.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/so/cmip5.GISS-E2-H.historical.r3i1p3.an.ocn.so.ver-v20120313.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/so/cmip5.GISS-E2-H.historical.r4i1p3.an.ocn.so.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/so/cmip5.GISS-E2-H.historical.r4i1p3.an.ocn.so.ver-v20120314.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/so/cmip5.GISS-E2-H.historical.r5i1p3.an.ocn.so.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/so/cmip5.GISS-E2-H.historical.r5i1p3.an.ocn.so.ver-v20120314.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/so/cmip5.MIROC4h.historical.r1i1p1.an.ocn.so.ver-v20110907.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/so/cmip5.MIROC4h.historical.r2i1p1.an.ocn.so.ver-v20110907.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/so/cmip5.MIROC4h.historical.r3i1p1.an.ocn.so.ver-v20110907.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/so/cmip5.MIROC5.historical.r1i1p1.an.ocn.so.ver-v20120112.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/so/cmip5.MIROC5.historical.r2i1p1.an.ocn.so.ver-v20111202.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/so/cmip5.MIROC5.historical.r3i1p1.an.ocn.so.ver-v20111202.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/so/cmip5.MIROC5.historical.r4i1p1.an.ocn.so.ver-v20120112.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/so/cmip5.MIROC5.historical.r4i1p1.an.ocn.so.ver-v20121221.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/so/cmip5.MIROC5.historical.r5i1p1.an.ocn.so.ver-v20120608.1975-2005_anClim_WOAGrid.nc'
};

bad_list2 = {
'/work/durack1/Shared/120711_AR5/Chap09/ncs/so/cmip5.GISS-E2-R.historical.r1i1p3.an.ocn.so.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/so/cmip5.GISS-E2-R.historical.r1i1p3.an.ocn.so.ver-v20120206.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/so/cmip5.GISS-E2-R.historical.r1i1p3.an.ocn.so.ver-v20121015.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/so/cmip5.GISS-E2-R.historical.r2i1p3.an.ocn.so.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/so/cmip5.GISS-E2-R.historical.r2i1p3.an.ocn.so.ver-v20120207.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/so/cmip5.GISS-E2-R.historical.r2i1p3.an.ocn.so.ver-v20121015.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/so/cmip5.GISS-E2-R.historical.r3i1p3.an.ocn.so.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/so/cmip5.GISS-E2-R.historical.r3i1p3.an.ocn.so.ver-v20120207.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/so/cmip5.GISS-E2-R.historical.r3i1p3.an.ocn.so.ver-v20121015.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/so/cmip5.GISS-E2-R.historical.r4i1p3.an.ocn.so.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/so/cmip5.GISS-E2-R.historical.r4i1p3.an.ocn.so.ver-v20120207.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/so/cmip5.GISS-E2-R.historical.r4i1p3.an.ocn.so.ver-v20121015.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/so/cmip5.GISS-E2-R.historical.r5i1p3.an.ocn.so.ver-1.1975-2005_anClim_WOAGrid.nc'
'/work/durack1/Shared/120711_AR5/Chap09/ncs/so/cmip5.GISS-E2-R.historical.r5i1p3.an.ocn.so.ver-v20120207.1975-2005_anClim_WOAGrid.nc'
};
%}


% Truncate using dupe list
ind = NaN(40,1); y = 1;
for x = 1:length(models)
    splits = strfind(models{x},'/');
    mod = models{x}(splits(end)+1:end);
    separators = strfind(mod,'.');
    mod = mod(separators(3)+1:separators(11)-1);
    %disp(['mod:',mod])
    match = strfind(bad_list,mod);
    match = find(~cellfun(@isempty,match), 1);
    if ~isempty(match)
        ind(y) = x;
        y = y + 1;
        disp(['drop: ',mod])
    end
end
% Truncate using ind list
ind = ind(~isnan(ind));
ind = ismember(1:length(models),ind); % Logic is create index of files in bad_list
models(ind) = [];
clear bad_list ind match splits x y

% Build matrix of model results
so = NaN(length(models),length(t_depth),length(t_lat),length(t_lon));
so_model_names = cell(length(models),1);
count = 1; ens_count = 1;
ensemble = NaN(50,length(t_depth),length(t_lat),length(t_lon));
for x = 1:(length(models)-1)
    % Test for multiple realisations and generate ensemble mean
    model_ind = strfind(models{x},'.'); temp = models{x};
    model1 = temp((model_ind(4)+1):(model_ind(5)-1)); clear temp
    model_ind = strfind(models{x+1},'.'); temp = models{x+1};
    model2 = temp((model_ind(4)+1):(model_ind(5)-1)); clear temp

    % Plot model fields for bug-tracking - 2D and global zonal mean
    tmp1 = getnc(models{x},'so_mean_WOAGrid'); temp = models{x};
    tmp1 = tmp1(:,:,[181:360,1:180]); % Correct lon offset issue
    ind = strfind(temp,'/'); tmp1name = regexprep(temp((ind(end)+1):end),'.nc','');
    tmp2 = getnc(models{x+1},'so_mean_WOAGrid'); temp = models{x+1};
    tmp2 = tmp2(:,:,[181:360,1:180]); % Correct lon offset issue
    ind = strfind(temp,'/'); tmp2name = regexprep(temp((ind(end)+1):end),'.nc','');
    % Plot model 1
    close all, handle = figure('units','centimeters','visible','off','color','w'); set(0,'CurrentFigure',handle)
    ax1 = subplot(1,2,1);
    pcolor(t_lon,t_lat,squeeze(tmp1(1,:,:))); shading flat; caxis([scont1(1) scont1(end)]); clmap(27); hold all
    contour(t_lon,t_lat,squeeze(tmp1(1,:,:)),scont1,'color','k');
    ax2 = subplot(1,2,2);
    pcolor(t_lat,t_depth,nanmean(tmp1,3)); shading flat; caxis([scont3(1) scont3(end)]); clmap(27); axis ij; hold all
    contour(t_lat,t_depth,nanmean(tmp1,3),scont3,'color','k');
    hh1 = colorbarf_nw('horiz',scont3,scont2);
    set(handle,'Position',[3 3 16 7]) % Full page width (175mm (17) width x 83mm (8) height) - Back to 16.5 x 6 for proportion
    set(ax1,'Position',[0.03 0.19 0.45 0.8]);
    set(ax2,'Position',[0.54 0.19 0.45 0.8]);
    set(hh1,'Position',[0.06 0.075 0.9 0.03],'fontsize',fonts_c);
    set(ax1,'Tickdir','out','fontsize',fonts_ax,'layer','top','box','on', ...
    'xlim',[0 360],'xtick',0:30:360,'xticklabel',{'0','30','60','90','120','150','180','210','240','270','300','330','360'},'xminort','on', ...
    'ylim',[-90 90],'ytick',-90:20:90,'yticklabel',{'-90','-70','-50','-30','-10','10','30','50','70','90'},'yminort','on');
    set(ax2,'Tickdir','out','fontsize',fonts_ax,'layer','top','box','on', ...
    'ylim',[0 5500],'ytick',0:500:5500,'yticklabel',{'0','500','1000','1500','2000','2500','3000','3500','4000','4500','5000','5500'},'yminort','on', ...
    'xlim',[-90 90],'xtick',-90:20:90,'xticklabel',{'-90','-70','-50','-30','-10','10','30','50','70','90'},'xminort','on');    
    export_fig([outData,'so/',datestr(now,'yymmdd'),'_',tmp1name],'-png')
    close all
    clear handle ax1 ax2 hh1 tmp1 ind tmp1name
    % Plot model 2
    close all, handle = figure('units','centimeters','visible','off','color','w'); set(0,'CurrentFigure',handle)
    ax1 = subplot(1,2,1);
    pcolor(t_lon,t_lat,squeeze(tmp2(1,:,:))); shading flat; caxis([scont1(1) scont1(end)]); clmap(27); hold all
    contour(t_lon,t_lat,squeeze(tmp2(1,:,:)),scont1,'color','k');
    ax2 = subplot(1,2,2);
    pcolor(t_lat,t_depth,nanmean(tmp2,3)); shading flat; caxis([scont3(1) scont3(end)]); clmap(27); axis ij; hold all
    contour(t_lat,t_depth,nanmean(tmp2,3),scont3,'color','k');
    hh1 = colorbarf_nw('horiz',scont3,scont2);
    set(handle,'Position',[3 3 16 7]) % Full page width (175mm (17) width x 83mm (8) height) - Back to 16.5 x 6 for proportion
    set(ax1,'Position',[0.03 0.19 0.45 0.8]);
    set(ax2,'Position',[0.54 0.19 0.45 0.8]);
    set(hh1,'Position',[0.06 0.075 0.9 0.03],'fontsize',fonts_c);
    set(ax1,'Tickdir','out','fontsize',fonts_ax,'layer','top','box','on', ...
    'xlim',[0 360],'xtick',0:30:360,'xticklabel',{'0','30','60','90','120','150','180','210','240','270','300','330','360'},'xminort','on', ...
    'ylim',[-90 90],'ytick',-90:20:90,'yticklabel',{'-90','-70','-50','-30','-10','10','30','50','70','90'},'yminort','on');
    set(ax2,'Tickdir','out','fontsize',fonts_ax,'layer','top','box','on', ...
    'ylim',[0 5500],'ytick',0:500:5500,'yticklabel',{'0','500','1000','1500','2000','2500','3000','3500','4000','4500','5000','5500'},'yminort','on', ...
    'xlim',[-90 90],'xtick',-90:20:90,'xticklabel',{'-90','-70','-50','-30','-10','10','30','50','70','90'},'xminort','on');    
    export_fig([outData,'so/',datestr(now,'yymmdd'),'_',tmp2name],'-png');
    close all
    clear handle ax1 ax2 hh1 tmp2 tmp2name
    
    if x == (length(models)-1) && ~strcmp(model1,model2)
        % Process final fields - if different
        infile = models{x};
        unit_test = getnc(infile,'so_mean_WOAGrid');
        unit_test = unit_test(:,:,[181:360,1:180]); % Correct lon offset issue
        so(count,:,:,:) = unit_test;
        so_model_names{count} = model1;
        count = count + 1;
        infile = models{x+1};
        unit_test = getnc(infile,'so_mean_WOAGrid');
        unit_test = unit_test(:,:,[181:360,1:180]); % Correct lon offset issue
        so(count,:,:,:) = unit_test;
        so_model_names{count} = model2;
    elseif x == (length(models)-1) && strcmp(model1,model2)
        % Process final fields - if same
        infile = models{x};
        unit_test = getnc(infile,'so_mean_WOAGrid');
        unit_test = unit_test(:,:,[181:360,1:180]); % Correct lon offset issue
        ensemble(ens_count,:,:,:) = unit_test;
        ens_count = ens_count + 1;
        infile = models{x+1};
        unit_test = getnc(infile,'so_mean_WOAGrid');
        unit_test = unit_test(:,:,[181:360,1:180]); % Correct lon offset issue
        ensemble(ens_count,:,:,:) = unit_test;
        % Write to matrix
        so(count,:,:,:) = squeeze(nanmean(ensemble));
        so_model_names{count} = model1;
    elseif ~strcmp(model1,model2)
        disp([num2str(x,'%03d'),' so     different count: ',num2str(count),' ',model1,' ',model2])
        % If models are different
        if ens_count > 1
            so(count,:,:,:) = squeeze(nanmean(ensemble));
            so_model_names{count} = model1;
            count = count + 1;
            % Reset ensemble stuff
            ens_count = 1;
            ensemble = NaN(20,length(t_depth),length(t_lat),length(t_lon));
        else
            infile = models{x};
            unit_test = getnc(infile,'so_mean_WOAGrid');
            unit_test = unit_test(:,:,[181:360,1:180]); % Correct lon offset issue
            so(count,:,:,:) = unit_test;
            so_model_names{count} = model1;
            count = count + 1;
        end
    else
        disp([num2str(x,'%03d'),' so     same      count: ',num2str(count),' ',model1,' ',model2])
        % If models are the same
        infile = models{x};
        unit_test = getnc(infile,'so_mean_WOAGrid');
        unit_test = unit_test(:,:,[181:360,1:180]); % Correct lon offset issue
        ensemble(ens_count,:,:,:) = unit_test;
        ens_count = ens_count + 1;
    end
end
% Trim excess values
so((count+1):end,:,:,:) = [];
so_model_names((count+1):end) = [];
clear count ens_count ensemble in_path infile model* unit_test x

% Cludgey fix for bad data
%{
so(so < 0) = NaN;
so(so > 50) = NaN;
for x = 18:31
    % Truncate big stuff
    level = squeeze(so(:,x,:,:));
    index = level > 50;
    level(index) = NaN;
    so(:,x,:,:) = level;
    if x >= 23
        level = squeeze(so(:,x,:,:));
        index = level > 37;
        level(index) = NaN;
        so(:,x,:,:) = level;
    end
    % truncate small stuff
    level = squeeze(so(:,x,:,:));
    index = level < 0;
    level(index) = NaN;
    so(:,x,:,:) = level;
end
%}

% Mask marginal seas
for mod = 1:size(so,1)
    for x = 1:length(t_depth)
        so(mod,x,:,:) = squeeze(so(mod,x,:,:)).*basins3_NaN_ones;
    end
end; clear mod x

% Calculate ensemble mean
so_mean = squeeze(nanmean(so,1)); % Generate mean amongst models

% WOA18 salinity
close all, handle = figure('units','centimeters','visible','off','color','w'); set(0,'CurrentFigure',handle)
ax1 = subplot(1,2,1);
pcolor(t_lon,t_lat,squeeze(so_mean(1,:,:))); shading flat; caxis([scont1(1) scont1(end)]); clmap(27); hold all
contour(t_lon,t_lat,squeeze(so_mean(1,:,:)),scont1,'color','k');
ax2 = subplot(1,2,2);
pcolor(t_lat,t_depth,nanmean(so_mean,3)); shading flat; caxis([scont3(1) scont3(end)]); clmap(27); axis ij; hold all
contour(t_lat,t_depth,nanmean(so_mean,3),scont3,'color','k');
hh1 = colorbarf_nw('horiz',scont3,scont2);
set(handle,'Position',[3 3 16 7]) % Full page width (175mm (17) width x 83mm (8) height) - Back to 16.5 x 6 for proportion
set(ax1,'Position',[0.03 0.19 0.45 0.8]);
set(ax2,'Position',[0.54 0.19 0.45 0.8]);
set(hh1,'Position',[0.06 0.075 0.9 0.03],'fontsize',fonts_c);
set(ax1,'Tickdir','out','fontsize',fonts_ax,'layer','top','box','on', ...
    'xlim',[0 360],'xtick',0:30:360,'xticklabel',{'0','30','60','90','120','150','180','210','240','270','300','330','360'},'xminort','on', ...
    'ylim',[-90 90],'ytick',-90:20:90,'yticklabel',{'-90','-70','-50','-30','-10','10','30','50','70','90'},'yminort','on');
set(ax2,'Tickdir','out','fontsize',fonts_ax,'layer','top','box','on', ...
    'ylim',[0 5500],'ytick',0:500:5500,'yticklabel',{'0','500','1000','1500','2000','2500','3000','3500','4000','4500','5000','5500'},'yminort','on', ...
    'xlim',[-90 90],'xtick',-90:20:90,'xticklabel',{'-90','-70','-50','-30','-10','10','30','50','70','90'},'xminort','on');
export_fig([outDir,datestr(now,'yymmdd'),'_CMIP6_so_mean'],'-png')

% Calculate zonal means
so_mean_zonal = squeeze(nanmean(so_mean,3)); % Generate zonal mean
disp('so done..')

disp('** Model processing complete.. **')

%% Save WOA18 and CMIP6 ensemble matrices to file
% Obs
so_woa18_mean = s_mean; clear s_mean
so_woa18_mean_zonal = s_mean_zonal; clear s_mean_zonal
thetao_woa18_mean = pt_mean; clear pt_mean
thetao_woa18_mean_zonal = pt_mean_zonal; clear pt_mean_zonal
% Models
so_cmip6 = so; clear so
so_cmip6_mean = so_mean; clear so_mean
so_cmip6_mean_zonal = so_mean_zonal; clear so_mean_zonal
thetao_cmip6 = thetao; clear thetao
thetao_cmip6_mean = thetao_mean; clear thetao_mean
thetao_cmip6_mean_zonal = thetao_mean_zonal; clear thetao_mean_zonal
save([outDir,datestr(now,'yymmdd'),'_CMIP6andWOA09_thetaoAndso.mat'],'so_woa18_mean','thetao_woa18_mean','so_woa18_mean_zonal','thetao_woa18_mean_zonal', ...
                                                                     'so_cmip6_mean','thetao_cmip6_mean','so_cmip6_mean_zonal','thetao_cmip6_mean_zonal', ...
                                                                     'so_cmip6','thetao_cmip6');
%                                                                     'so_cmip5_mean','thetao_cmip5_mean','so_cmip5_mean_zonal','thetao_cmip5_mean_zonal', ...
%                                                                     'so_cmip5','thetao_cmip5', ...
disp('** All data written to *.mat.. **')

%% Figure 3.21 - thetao and so clim vs WOA18
close all
% Determine depth split
depth1 = find(t_depth == 1000);

% Create anomaly
thetao_mean_anom_zonal = thetao_cmip6_mean_zonal - thetao_woa18_mean_zonal;
pt_mean_zonal = thetao_woa18_mean_zonal;
so_mean_anom_zonal = so_cmip6_mean_zonal - so_woa18_mean_zonal;
s_mean_zonal = so_woa18_mean_zonal;

% Do thetao global
close all, handle = figure('units','centimeters','visible','off','color','w'); set(0,'CurrentFigure',handle); clmap(27)

% Potential Temperature
% 0-1000db
ax1 = subplot(2,2,1);
[~,h] = contourf(t_lat,t_depth(1:depth1),thetao_mean_anom_zonal(1:depth1,:),50); hold all
set(h,'linestyle','none'); hold all; clear h
axis ij, caxis([-1 1]*ptscale(1)), clmap(27), hold all
contour(t_lat,t_depth(1:depth1),pt_mean_zonal(1:depth1,:),[2.5 7.5 12.5 17.5 22.5 27.5],'k')
[c,h] = contour(t_lat,t_depth(1:depth1),pt_mean_zonal(1:depth1,:),0:5:30,'k','linewidth',2);
clabel(c,h,'LabelSpacing',200,'fontsize',fonts_c,'fontweight','bold','color','k')
contour(t_lat,t_depth(1:depth1),thetao_mean_anom_zonal(1:depth1,:),-ptscale(2):1:ptscale(2),'color',[1 1 1]);
ylab1 = ylabel('Depth (m)','fontsize',fonts);
set(ax1,'Tickdir','out','fontsize',fonts,'layer','top','box','on', ...
    'ylim',[0 1000],'ytick',0:200:1000,'yticklabel',{'0','200','400','600','800',''},'yminort','on', ...
    'xlim',[-90 90],'xtick',-90:10:90,'xticklabel','','xminort','on');

% 1000-5000db
ax3 = subplot(2,2,3);
[~,h] = contourf(t_lat,t_depth(depth1:end),thetao_mean_anom_zonal(depth1:end,:),50); hold all
set(h,'linestyle','none'); hold all; clear h
axis ij, caxis([-1 1]*ptscale(1)), clmap(27), hold all
contour(t_lat,t_depth(depth1:end),pt_mean_zonal(depth1:end,:),[2.5 7.5 12.5 17.5 22.5 27.5],'k')
[c,h] = contour(t_lat,t_depth(depth1:end),pt_mean_zonal(depth1:end,:),0:5:30,'k','linewidth',2);
clabel(c,h,'LabelSpacing',200,'fontsize',fonts_c,'fontweight','bold','color','k')
contour(t_lat,t_depth(depth1:end),thetao_mean_anom_zonal(depth1:end,:),-ptscale(2):1:ptscale(2),'color',[1 1 1]);
xlab3 = xlabel('Latitude','fontsize',fonts);
text(-88,4650,'Temperature','fontsize',fonts_lab,'horizontalAlignment','left','color','k','fontweight','b');
text(88,4650,'A','fontsize',fonts_lab*1.5,'horizontalAlignment','right','color','k','fontweight','b');
hh3 = colorbarf_nw('horiz',-ptscale(1):0.25:ptscale(1),-ptscale(1):1:ptscale(1));
set(hh3,'clim',[-ptscale(1) ptscale(1)]); % See https://www.mathworks.com/help/matlab/ref/matlab.graphics.illustration.colorbar-properties.html
set(ax3,'Tickdir','out','fontsize',fonts,'layer','top','box','on', ...
    'ylim',[1000 5000],'ytick',1000:500:5000,'yticklabel',{'1000','','2000','','3000','','4000','','5000'},'yminort','on', ...
    'xlim',[-90 90],'xtick',-90:10:90,'xticklabel',{'90S','','','60S','','','30S','','','EQU','','','30N','','','60N','','','90N'},'xminort','on');

% Salinity
% 0-1000db
ax2 = subplot(2,2,2);
[~,h] = contourf(t_lat,t_depth(1:depth1),so_mean_anom_zonal(1:depth1,:),50); hold all
set(h,'linestyle','none'); hold all; clear h
axis ij, caxis([-1 1]*sscale(1)), clmap(27), hold all
contour(t_lat,t_depth(1:depth1),s_mean_zonal(1:depth1,:),scont1,'k')
[c,h] = contour(t_lat,t_depth(1:depth1),s_mean_zonal(1:depth1,:),scont2,'k','linewidth',2);
clabel(c,h,'LabelSpacing',200,'fontsize',fonts_c,'fontweight','bold','color','k')
contour(t_lat,t_depth(1:depth1),so_mean_anom_zonal(1:depth1,:),-sscale(2):0.25:sscale(2),'color',[1 1 1]);
set(ax2,'Tickdir','out','fontsize',fonts,'layer','top','box','on', ...
    'ylim',[0 1000],'ytick',0:200:1000,'yticklabel',{''},'yminort','on', ...
    'xlim',[-90 90],'xtick',-90:10:90,'xticklabel','','xminort','on');

% 1000-5000db
ax4 = subplot(2,2,4);
[~,h] = contourf(t_lat,t_depth(depth1:end),so_mean_anom_zonal(depth1:end,:),50); hold all
set(h,'linestyle','none'); hold all; clear h
axis ij, caxis([-1 1]*sscale(1)), clmap(27), hold all
contour(t_lat,t_depth(depth1:end),s_mean_zonal(depth1:end,:),scont1,'k')
[c,h] = contour(t_lat,t_depth(depth1:end),s_mean_zonal(depth1:end,:),scont2,'k','linewidth',2);
clabel(c,h,'LabelSpacing',200,'fontsize',fonts_c,'fontweight','bold','color','k')
contour(t_lat,t_depth(depth1:end),so_mean_anom_zonal(depth1:end,:),-sscale(2):0.25:sscale(2),'color',[1 1 1]);
xlab4 = xlabel('Latitude','fontsize',fonts);
text(-88,4650,'Salinity','fontsize',fonts_lab,'horizontalAlignment','left','color','k','fontweight','b');
text(88,4650,'B','fontsize',fonts_lab*1.5,'horizontalAlignment','right','color','k','fontweight','b');
hh4 = colorbarf_nw('horiz',-sscale(1):0.125:sscale(1),-sscale(1):0.25:sscale(1));
set(hh4,'clim',[-sscale(1) sscale(1)])
set(ax4,'Tickdir','out','fontsize',fonts,'layer','top','box','on', ...
    'ylim',[1000 5000],'ytick',1000:500:5000,'yticklabel',{''},'yminort','on', ...
    'xlim',[-90 90],'xtick',-90:10:90,'xticklabel',{'90S','','','60S','','','30S','','','EQU','','','30N','','','60N','','','90N'},'xminort','on');

% Resize into canvas
set(handle,'Position',[3 3 18 7]) % Full page width (175mm (17) width x 83mm (8) height) - Back to 16.5 x 6 for proportion
set(ax1,'Position',[0.0550 0.58 0.45 0.40]);
set(ax3,'Position',[0.0550 0.17 0.45 0.40]);
set(hh3,'Position',[0.0750 0.042 0.41 0.015],'fontsize',fonts);
set(ax2,'Position',[0.535 0.58 0.45 0.40]);
set(ax4,'Position',[0.535 0.17 0.45 0.40]);
set(hh4,'Position',[0.555 0.042 0.410 0.015],'fontsize',fonts);

% Drop blanking mask between upper and lower panels
%axr1 = axes('Position',[0.0475 0.5715 0.95 0.007],'xtick',[],'ytick',[],'box','off','visible','on','xcolor',[1 1 1],'ycolor',[1 1 1]);
axr1 = axes('Position',[0.0475 0.57065 0.95 0.0076],'xtick',[],'ytick',[],'box','off','visible','on','xcolor',[1 1 1],'ycolor',[1 1 1]);

% Axis labels
set(ylab1,'Position',[-106 1000 1.0001]);
set(xlab3,'Position',[0 5600 1.0001]);
set(xlab4,'Position',[0 5600 1.0001]);

% Print to file
export_fig([outDir,datestr(now,'yymmdd'),'_AR6WG1_Ch3_Fig3p21_CMIP6minusWOA18_thetaoAndso'],'-png')
export_fig([outDir,datestr(now,'yymmdd'),'_AR6WG1_Ch3_Fig3p21_CMIP6minusWOA18_thetaoAndso'],'-eps')

close all %set(gcf,'visi','on');
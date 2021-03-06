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
% PJD  5 Jan 2020   - Updated all badLists for 5/6
% PJD  5 Jan 2020   - Updated for dynamic generation of CMIP5/6
% PJD  5 Jan 2020   - Finalized CMIP6/5 global plots
% PJD  7 Jan 2020   - Updated with CMIP6/5 basin plots
%                   - TODO: CMIP5 reported 41 so 43 thetao models, now have 33/34 figure out what is missing
%                   - TODO: First plot greyed for each box, then overplot colours and contours (greyed bathymetry underlaid)
%                   - TODO: Add more models (total count 120720 is 45 for CMIP5), deal with sigma-level models


% Cleanup workspace and command window
clear, clc, close all
% Initialise environment variables
[homeDir,~,dataDir,obsDir,~,aHostLongname] = myMatEnv(2);
outDir = os_path([homeDir,'190311_AR6/Chap3/']);

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
    delete([outDir,datestr(now,'yymmdd'),'*_cmip*.eps']);
    delete([outDir,datestr(now,'yymmdd'),'*_cmip*.png']);
    delete([outDir,datestr(now,'yymmdd'),'_WOA18*.png']);
    delete([outDir,datestr(now,'yymmdd'),'_cmip*.png']);
    delete([outDir,datestr(now,'yymmdd'),'_CMIP5*.mat']);
    delete([outDir,'ncs/CMIP*/historical/woaGrid/so/',datestr(now,'yymmdd'),'*.png']);
    delete([outDir,'ncs/CMIP*/historical/woaGrid/thetao/',datestr(now,'yymmdd'),'*.png']);
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
clear a

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
load(infile,'basins3_NaN_ones'); % lat/lon same as WOA18
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

%% Declare bad lists
badListCM6Thetao = {
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
badListCM6So = {
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
badListCM5Thetao = {
    'ICHEC.EC-EARTH.r10i1p1.mon.thetao.ocean.glb-l-gu.1' ; % mask
    'ICHEC.EC-EARTH.r11i1p1.mon.thetao.ocean.glb-l-gu.v20120403'
    'ICHEC.EC-EARTH.r12i1p1.mon.thetao.ocean.glb-l-gu.1'
    'ICHEC.EC-EARTH.r14i1p1.mon.thetao.ocean.glb-l-gu.1'
    'ICHEC.EC-EARTH.r2i1p1.mon.thetao.ocean.glb-l-gu.1'
    'ICHEC.EC-EARTH.r3i1p1.mon.thetao.ocean.glb-l-gu.1'
    'ICHEC.EC-EARTH.r5i1p1.mon.thetao.ocean.glb-l-gu.1'
    'ICHEC.EC-EARTH.r6i1p1.mon.thetao.ocean.glb-l-gu.1'
    'ICHEC.EC-EARTH.r7i1p1.mon.thetao.ocean.glb-l-gu.1'
    'ICHEC.EC-EARTH.r9i1p1.mon.thetao.ocean.glb-l-gu.1'
    'INM.inmcm4.r1i1p1.mon.thetao.ocean.glb-l-gu.1' ; % weird values through depth
    'MIROC.MIROC4h.r1i1p1.mon.thetao.ocean.glb-l-gu.1' ; % weird values through depth
    'MIROC.MIROC4h.r2i1p1.mon.thetao.ocean.glb-l-gu.1'
    'MIROC.MIROC4h.r3i1p1.mon.thetao.ocean.glb-l-gu.1'
    'MIROC.MIROC5.r1i1p1.mon.thetao.ocean.glb-l-gu.1' ; % weird values through depth
    'MIROC.MIROC5.r2i1p1.mon.thetao.ocean.glb-l-gu.1'
    'MIROC.MIROC5.r3i1p1.mon.thetao.ocean.glb-l-gu.1'
    'MIROC.MIROC5.r4i1p1.mon.thetao.ocean.glb-l-gu.v20120112'
    'MIROC.MIROC5.r5i1p1.mon.thetao.ocean.glb-l-gu.1'
    'MRI.MRI-CGCM3.r1i1p1.mon.thetao.ocean.glb-l-gu.v20120510' ; % mask an values through depth
    'MRI.MRI-CGCM3.r2i1p1.mon.thetao.ocean.glb-l-gu.v20120510'
    'MRI.MRI-CGCM3.r3i1p1.mon.thetao.ocean.glb-l-gu.v20120510'
    'MRI.MRI-CGCM3.r4i1p2.mon.thetao.ocean.glb-l-gu.v20120510'
    'MRI.MRI-CGCM3.r5i1p2.mon.thetao.ocean.glb-l-gu.v20120510'
    };
badListCM5So = {
    'ICHEC.EC-EARTH.r10i1p1.mon.so.ocean.glb-z1-gu.1' ; % mask
    'ICHEC.EC-EARTH.r11i1p1.mon.so.ocean.glb-z1-gu.v20120403'
    'ICHEC.EC-EARTH.r12i1p1.mon.so.ocean.glb-z1-gu.1'
    'ICHEC.EC-EARTH.r14i1p1.mon.so.ocean.glb-z1-gu.1'
    'ICHEC.EC-EARTH.r2i1p1.mon.so.ocean.glb-z1-gu.1'
    'ICHEC.EC-EARTH.r3i1p1.mon.so.ocean.glb-z1-gu.1'
    'ICHEC.EC-EARTH.r5i1p1.mon.so.ocean.glb-z1-gu.1'
    'ICHEC.EC-EARTH.r6i1p1.mon.so.ocean.glb-z1-gu.1'
    'ICHEC.EC-EARTH.r7i1p1.mon.so.ocean.glb-z1-gu.1'
    'ICHEC.EC-EARTH.r9i1p1.mon.so.ocean.glb-z1-gu.1'
    'INM.inmcm4.r1i1p1.mon.so.ocean.glb-z1-gu.1' ; % weird values through depth
    'MIROC.MIROC4h.r1i1p1.mon.so.ocean.glb-z1-gu.1' ; % weird values through depth
    'MIROC.MIROC4h.r2i1p1.mon.so.ocean.glb-z1-gu.1'
    'MIROC.MIROC4h.r3i1p1.mon.so.ocean.glb-z1-gu.1'
    'MIROC.MIROC5.r1i1p1.mon.so.ocean.glb-z1-gu.1' ; % mask an values through depth
    'MIROC.MIROC5.r2i1p1.mon.so.ocean.glb-z1-gu.1'
    'MIROC.MIROC5.r3i1p1.mon.so.ocean.glb-z1-gu.1'
    'MIROC.MIROC5.r4i1p1.mon.so.ocean.glb-z1-gu.v20120112'
    'MIROC.MIROC5.r5i1p1.mon.so.ocean.glb-z1-gu.1'
    'MRI.MRI-CGCM3.r1i1p1.mon.so.ocean.glb-z1-gu.v20120510' ; % mask an values through depth
    'MRI.MRI-CGCM3.r2i1p1.mon.so.ocean.glb-z1-gu.v20120510'
    'MRI.MRI-CGCM3.r3i1p1.mon.so.ocean.glb-z1-gu.v20120510'
    'MRI.MRI-CGCM3.r4i1p2.mon.so.ocean.glb-z1-gu.v20120510'
    'MRI.MRI-CGCM3.r5i1p2.mon.so.ocean.glb-z1-gu.v20120510'
    };

%% Process models
for mipVar = 1:4 % Cycle through all mip_eras and variables
    switch mipVar
        case 1 % CMIP5 thetao
            inVar = '*thetao';
            inVarName = 'thetao';
            ncVar = 'thetao_mean_WOAGrid';
            badList = badListCM5Thetao;
            outData = os_path([outDir,'ncs/CMIP5/historical/woaGrid/']);
            mipEra = 'cmip5';
            cont1 = ptcont1;
            cont2 = ptcont2;
            cont3 = ptcont3;
        case 2 % CMIP5 so
            inVar = '*.so.';
            inVarName = 'so';
            ncVar = 'so_mean_WOAGrid';
            badList = badListCM5So;
            outData = os_path([outDir,'ncs/CMIP5/historical/woaGrid/']);
            mipEra = 'cmip5';
            cont1 = scont1;
            cont2 = scont2;
            cont3 = scont3;
        case 3 % CMIP6 thetao
            inVar = '*thetao';
            inVarName = 'thetao';
            ncVar = 'thetao_mean_WOAGrid';
            badList = badListCM6Thetao;
            outData = os_path([outDir,'ncs/CMIP6/historical/woaGrid/']);
            mipEra = 'cmip6';
            cont1 = ptcont1;
            cont2 = ptcont2;
            cont3 = ptcont3;
        case 4 % CMIP6 so
            inVar = '*.so.';
            inVarName = 'so';
            ncVar = 'so_mean_WOAGrid';
            badList = badListCM6So;
            outData = os_path([outDir,'ncs/CMIP6/historical/woaGrid/']);
            mipEra = 'cmip6';
            cont1 = scont1;
            cont2 = scont2;
            cont3 = scont3;
    end

    % Now process
    [~, models] = unix(['\ls -1 ',outData,inVar,'*woaClim.nc']);
    models = strtrim(models);
    temp = regexp(models,'\n','split'); clear models status
    models = unique(temp); clear temp

    % Truncate using dupe list
    ind = NaN(50,1); y = 1;
    for x = 1:length(models)
        splits = strfind(models{x},'/');
        mod = models{x}(splits(end)+1:end);
        separators = strfind(mod,'.');
        mod = mod(separators(3)+1:separators(11)-1);
        %disp(['mod:',mod])
        match = strfind(badList,mod);
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
    varTmp = NaN(length(models),length(t_depth),length(t_lat),length(t_lon));
    varTmp_model_names = cell(length(models),1);
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
        tmp1 = getnc(models{x},ncVar); temp = models{x};
        tmp1 = tmp1(:,:,[181:360,1:180]); % Correct lon offset issue
        ind = strfind(temp,'/'); tmp1name = regexprep(temp((ind(end)+1):end),'.nc','');
        tmp2 = getnc(models{x+1},ncVar); temp = models{x+1};
        tmp2 = tmp2(:,:,[181:360,1:180]); % Correct lon offset issue
        ind = strfind(temp,'/'); tmp2name = regexprep(temp((ind(end)+1):end),'.nc','');
        clear temp
        % Plot model 1
        close all, handle = figure('units','centimeters','visible','off','color','w'); set(0,'CurrentFigure',handle)
        ax1 = subplot(1,2,1);
        pcolor(t_lon,t_lat,squeeze(tmp1(1,:,:))); shading flat; caxis([cont1(1) cont1(end)]); clmap(27); hold all
        contour(t_lon,t_lat,squeeze(tmp1(1,:,:)),cont1,'color','k');
        ax2 = subplot(1,2,2);
        pcolor(t_lat,t_depth,nanmean(tmp1,3)); shading flat; caxis([cont1(1) cont1(end)]); clmap(27); axis ij; hold all
        contour(t_lat,t_depth,nanmean(tmp1,3),cont1,'color','k');
        hh1 = colorbarf_nw('horiz',cont3,cont2);
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
        export_fig([outData,'/',inVarName,'/',datestr(now,'yymmdd'),'_',tmp1name],'-png')
        close all
        clear handle ax1 ax2 hh1 tmp1 ind tmp1name

        % Plot model 2
        close all, handle = figure('units','centimeters','visible','off','color','w'); set(0,'CurrentFigure',handle)
        ax1 = subplot(1,2,1);
        pcolor(t_lon,t_lat,squeeze(tmp2(1,:,:))); shading flat; caxis([cont1(1) cont1(end)]); clmap(27); hold all
        contour(t_lon,t_lat,squeeze(tmp2(1,:,:)),cont1,'color','k');
        ax2 = subplot(1,2,2);
        pcolor(t_lat,t_depth,nanmean(tmp2,3)); shading flat; caxis([cont1(1) cont1(end)]); clmap(27); axis ij; hold all
        contour(t_lat,t_depth,nanmean(tmp2,3),cont1,'color','k');
        hh1 = colorbarf_nw('horiz',cont3,cont2);
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
        export_fig([outData,'/',inVarName,'/',datestr(now,'yymmdd'),'_',tmp2name],'-png');
        close all
        clear handle ax1 ax2 hh1 tmp2 tmp2name

        if x == (length(models)-1) && ~strcmp(model1,model2)
            % Process final fields - if different
            infile = models{x};
            unit_test = getnc(infile,ncVar);
            unit_test = unit_test(:,:,[181:360,1:180]); % Correct lon offset issue
            if min(min(unit_test(1,:,:))) > 250; unit_test = unit_test-273.15; end
            varTmp(count,:,:,:) = unit_test;
            varTmp_model_names{count} = model1;
            count = count + 1;
            infile = models{x+1};
            unit_test = getnc(infile,ncVar);
            unit_test = unit_test(:,:,[181:360,1:180]); % Correct lon offset issue
            if min(min(unit_test(1,:,:))) > 250; unit_test = unit_test-273.15; end
            varTmp(count,:,:,:) = unit_test;
            varTmp_model_names{count} = model2;
        elseif x == (length(models)-1) && strcmp(model1,model2)
            % Process final fields - if same
            infile = models{x};
            unit_test = getnc(infile,ncVar);
            unit_test = unit_test(:,:,[181:360,1:180]); % Correct lon offset issue
            if min(min(unit_test(1,:,:))) > 250; unit_test = unit_test-273.15; end
            ensemble(ens_count,:,:,:) = unit_test;
            ens_count = ens_count + 1;
            infile = models{x+1};
            unit_test = getnc(infile,ncVar);
            unit_test = unit_test(:,:,[181:360,1:180]); % Correct lon offset issue
            if min(min(unit_test(1,:,:))) > 250; unit_test = unit_test-273.15; end
            ensemble(ens_count,:,:,:) = unit_test;
            % Write to matrix
            varTmp(count,:,:,:) = squeeze(nanmean(ensemble));
            varTmp_model_names{count} = model1;
        elseif ~strcmp(model1,model2)
            disp([num2str(x,'%03d'),' ',inVarName,' different count: ',num2str(count),' ',model1,' ',model2])
            % If models are different
            if ens_count > 1
                varTmp(count,:,:,:) = squeeze(nanmean(ensemble));
                varTmp_model_names{count} = model1;
                count = count + 1;
                % Reset ensemble stuff
                ens_count = 1;
                ensemble = NaN(20,length(t_depth),length(t_lat),length(t_lon));
            else
                infile = models{x};
                unit_test = getnc(infile,ncVar);
                unit_test = unit_test(:,:,[181:360,1:180]); % Correct lon offset issue
                if min(min(unit_test(1,:,:))) > 250; unit_test = unit_test-273.15; end
                varTmp(count,:,:,:) = unit_test;
                varTmp_model_names{count} = model1;
                count = count + 1;
            end
        else
            disp([num2str(x,'%03d'),' ',inVarName,' same      count: ',num2str(count),' ',model1,' ',model2])
            % If models are the same
            infile = models{x};
            unit_test = getnc(infile,ncVar);
            unit_test = unit_test(:,:,[181:360,1:180]); % Correct lon offset issue
            if min(unit_test(:)) > 250; unit_test = unit_test-273.15; end
            ensemble(ens_count,:,:,:) = unit_test;
            ens_count = ens_count + 1;
        end
    end
    % Trim excess values
    varTmp((count+1):end,:,:,:) = [];
    varTmp_model_names((count+1):end) = [];
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
    for mod = 1:size(varTmp,1)
        for x = 1:length(t_depth)
            varTmp(mod,x,:,:) = squeeze(varTmp(mod,x,:,:)).*basins3_NaN_ones;
        end
    end; clear mod x

    % Calculate ensemble mean
    varTmp_mean = squeeze(nanmean(varTmp,1)); % Generate mean amongst models

    % CMIP potential temperature
    close all, handle = figure('units','centimeters','visible','off','color','w'); set(0,'CurrentFigure',handle)
    ax1 = subplot(1,2,1);
    pcolor(t_lon,t_lat,squeeze(varTmp_mean(1,:,:))); shading flat; caxis([cont1(1) cont1(end)]); clmap(27); hold all
    contour(t_lon,t_lat,squeeze(varTmp_mean(1,:,:)),cont1,'color','k');
    ax2 = subplot(1,2,2);
    pcolor(t_lat,t_depth,nanmean(varTmp_mean,3)); shading flat; caxis([cont1(1) cont1(end)]); clmap(27); axis ij; hold all
    contour(t_lat,t_depth,nanmean(varTmp_mean,3),cont1,'color','k');
    hh1 = colorbarf_nw('horiz',cont3,cont2);
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
    export_fig([outDir,datestr(now,'yymmdd'),'_',mipEra,'_',inVarName,'_mean'],'-png')
    clear handle ax1 ax2 hh1 cont1 cont2 cont3 inVar ncVar badList
    % Calculate zonal means
    eval([inVarName,'_',mipEra,' = varTmp;']);
    eval([inVarName,'_',mipEra,'_mean = varTmp_mean;']);
    eval([inVarName,'_',mipEra,'_mean_zonal = squeeze(nanmean(varTmp_mean,3));']); % Generate zonal mean
    eval([inVarName,'_',mipEra,'_modelNames = varTmp_model_names;']); % Generate model name lookup
    clear varTmp varTmp_mean varTmp_model_names
    %varTmp_mean_zonal = squeeze(nanmean(varTmp_mean,3)); % Generate zonal mean
    disp([mipEra,' ',inVarName,' done..'])
    clear mipEra mipVar inVarName
end
disp('** Model processing complete.. **')

%% Save WOA18 and CMIP6 ensemble matrices to file
% Rename obs
so_woa18_mean = s_mean; clear s_mean
so_woa18_mean_zonal = s_mean_zonal; clear s_mean_zonal
thetao_woa18_mean = pt_mean; clear pt_mean
thetao_woa18_mean_zonal = pt_mean_zonal; clear pt_mean_zonal
save([outDir,datestr(now,'yymmdd'),'_CMIP5And6andWOA18_thetaoAndso.mat'],'so_woa18_mean','thetao_woa18_mean', ...
                                                                     'so_woa18_mean_zonal','thetao_woa18_mean_zonal', ...
                                                                     'so_cmip6_modelNames','thetao_cmip6_modelNames', ...
                                                                     'so_cmip6','thetao_cmip6', ...
                                                                     'so_cmip6_mean','thetao_cmip6_mean', ...
                                                                     'so_cmip6_mean_zonal','thetao_cmip6_mean_zonal', ...
                                                                     'so_cmip5_modelNames','thetao_cmip5_modelNames', ...
                                                                     'so_cmip5','thetao_cmip5', ...
                                                                     'so_cmip5_mean','thetao_cmip5_mean', ...
                                                                     'so_cmip5_mean_zonal','thetao_cmip5_mean_zonal', ...
                                                                     't_depth','t_lat','t_lon');
disp('** All data written to *.mat.. **')

%% Figure 3.21 global - thetao and so clim vs WOA18
close all
% Determine depth split
depth1 = find(t_depth == 1000);
for mipEra = 1:2
    switch mipEra
        case 1
            % Create anomaly fields
            thetao_mean_anom_zonal = thetao_cmip5_mean_zonal - thetao_woa18_mean_zonal;
            pt_mean_zonal = thetao_woa18_mean_zonal;
            so_mean_anom_zonal = so_cmip5_mean_zonal - so_woa18_mean_zonal;
            s_mean_zonal = so_woa18_mean_zonal;
            mipEraId = 'cmip5';
        case 2
            % Create anomaly fields
            thetao_mean_anom_zonal = thetao_cmip6_mean_zonal - thetao_woa18_mean_zonal;
            pt_mean_zonal = thetao_woa18_mean_zonal;
            so_mean_anom_zonal = so_cmip6_mean_zonal - so_woa18_mean_zonal;
            s_mean_zonal = so_woa18_mean_zonal;
            mipEraId = 'cmip6';
    end
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
    text(98,4650,'Temperature','fontsize',fonts_lab,'horizontalAlignment','right','color','k','fontweight','b');
    text(-88,4650,'A','fontsize',fonts_lab*1.5,'horizontalAlignment','left','color','k','fontweight','b');
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
    text(94,4650,'Salinity','fontsize',fonts_lab,'horizontalAlignment','right','color','k','fontweight','b');
    text(-88,4650,'B','fontsize',fonts_lab*1.5,'horizontalAlignment','left','color','k','fontweight','b');
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
    axr1 = axes('Position',[0.0475 0.57061 0.95 0.01],'xtick',[],'ytick',[],'box','off','visible','on','xcolor',[1 1 1],'ycolor',[1 1 1]);

    % Axis labels
    set(ylab1,'Position',[-106 1000 1.0001]);
    set(xlab3,'Position',[0 5600 1.0001]);
    set(xlab4,'Position',[0 5600 1.0001]);

    % Print to file
    export_fig([outDir,datestr(now,'yymmdd'),'_AR6WG1_Ch3_Fig3p21_',mipEraId,'minusWOA18_thetaoAndso_global'],'-png')
    export_fig([outDir,datestr(now,'yymmdd'),'_AR6WG1_Ch3_Fig3p21_',mipEraId,'minusWOA18_thetaoAndso_global'],'-eps')

    close all %set(gcf,'visi','on');
    clear ax* c h handle hh* xlab* ylab* mipEra
end

%% Figure 3.21 basins - thetao and so clim vs WOA18
close all
% Load basin mask
infile = os_path([homeDir,'code/make_basins.mat']);
load(infile,'basins3_NaN','lat','lon'); % lat/lon same as WOA18
%pcolor(lon,lat,basins3_NaN); shading flat

% Determine depth split
depth1 = find(t_depth == 1000);
for mipEra = 1:2
    switch mipEra
        case 0
            % Create anomaly fields
            thetao_mean_anom_zonal = thetao_cmip5_mean_zonal - thetao_woa18_mean_zonal;
            pt_mean_zonal = thetao_woa18_mean_zonal;
            so_mean_anom_zonal = so_cmip5_mean_zonal - so_woa18_mean_zonal;
            so_mean_zonal = so_woa18_mean_zonal;
            mipEraId = 'cmip5';
        case 1
            % Create anomaly fields
            thetao_mean_anom = thetao_cmip5_mean - thetao_woa18_mean;
            pt_mean = thetao_woa18_mean;
            so_mean_anom = so_cmip5_mean - so_woa18_mean;
            so_mean = so_woa18_mean;
            mipEraId = 'cmip5';
        case 2
            % Create anomaly fields
            thetao_mean_anom = thetao_cmip6_mean - thetao_woa18_mean;
            pt_mean = thetao_woa18_mean;
            so_mean_anom = so_cmip6_mean - so_woa18_mean;
            so_mean = so_woa18_mean;
            mipEraId = 'cmip6';
    end
    
    % Do basin zonals
    close all, handle = figure('units','centimeters','visible','off','color','w'); set(0,'CurrentFigure',handle); clmap(27)
    
    for basin = 1:4
        switch basin
            case 1
                % Global
                axInfo = 1;
                mask = ones([102,size(basins3_NaN)]);
                basinLabels = ['A','B'];
                basinId = 'GLO';
            case 2
                % Atlantic
                axInfo = 5;
                tmp = basins3_NaN;
                index = tmp ~= 2; tmp(index) = NaN;
                index = tmp == 2; tmp(index) = 1; clear index
                tmp = repmat(tmp,[1 1 102]);
                mask = shiftdim(tmp,2); clear tmp
                %pcolor(lon,lat,squeeze(mask(1,:,:))); shading flat
                basinLabels = ['C','D'];
                basinId = 'ATL';
            case 3
                % Pacific
                axInfo = 9;
                tmp = basins3_NaN;
                index = tmp ~= 1; tmp(index) = NaN;
                index = tmp == 1; tmp(index) = 1; clear index
                tmp = repmat(tmp,[1 1 102]);
                mask = shiftdim(tmp,2); clear tmp
                %pcolor(lon,lat,squeeze(mask(1,:,:))); shading flat
                basinLabels = ['E','F'];
                basinId = 'PAC';
            case 4
                % Indian
                axInfo = 13;
                tmp = basins3_NaN;
                index = tmp ~= 3; tmp(index) = NaN;
                index = tmp == 3; tmp(index) = 1; clear index
                tmp = repmat(tmp,[1 1 102]);
                mask = shiftdim(tmp,2); clear tmp
                %pcolor(lon,lat,squeeze(mask(1,:,:))); shading flat
                basinLabels = ['G','H'];
                basinId = 'IND';
        end
        
        % Generate anomaly zonal means
        thetao_mean_anom_zonal = nanmean((thetao_mean_anom.*mask),3);
        pt_mean_zonal = nanmean((pt_mean.*mask),3);
        so_mean_anom_zonal = nanmean((so_mean_anom.*mask),3);
        so_mean_zonal = nanmean((so_mean.*mask),3);
        % Check values
        %{
        close all
        figure(2); pcolor(t_lat,t_depth,thetao_mean_anom_zonal); shading flat; axis ij; caxis([-4 4]); title('thetao\_anom'); colorbar; clmap(27)
        figure(3); pcolor(t_lat,t_depth,pt_mean_zonal); shading flat; axis ij; caxis([-3 35]); title('pt\_mean'); colorbar; clmap(27)
        figure(4); pcolor(t_lat,t_depth,so_mean_anom_zonal); shading flat; axis ij; caxis([-.5 .5]); title('so\_anom'); colorbar; clmap(27)
        figure(5); pcolor(t_lat,t_depth,so_mean_zonal); shading flat; axis ij; caxis([33 37]); title('so\_mean'); colorbar; clmap(27)
        set(figure(2),'posi',[20 800 600 400]);
        set(figure(3),'posi',[20 1200 600 400]);
        set(figure(4),'posi',[592 800 600 400]);
        set(figure(5),'posi',[592 1200 600 400]);
        keyboard
        close figure 2
        close figure 3
        close figure 4
        close figure 5
        %}
        
        % Set label xy pairs
        idLab = [-88,4650];
        sVarLab = [94 4650];
        tVarLab = [99 4650];
        basinIdLab = [0,4600];
        
        % Potential Temperature
        % 0-1000db
        eval(['ax',num2str(axInfo),' = subplot(8,2,',num2str(axInfo),');']);
        [~,h] = contourf(t_lat,t_depth(1:depth1),thetao_mean_anom_zonal(1:depth1,:),50); hold all
        set(h,'linestyle','none'); hold all; clear h
        axis ij, caxis([-1 1]*ptscale(1)), clmap(27), hold all
        contour(t_lat,t_depth(1:depth1),pt_mean_zonal(1:depth1,:),[2.5 7.5 12.5 17.5 22.5 27.5],'k')
        [c,h] = contour(t_lat,t_depth(1:depth1),pt_mean_zonal(1:depth1,:),0:5:30,'k','linewidth',2);
        clabel(c,h,'LabelSpacing',200,'fontsize',fonts_c,'fontweight','bold','color','k')
        contour(t_lat,t_depth(1:depth1),thetao_mean_anom_zonal(1:depth1,:),-ptscale(2):1:ptscale(2),'color',[1 1 1]);
        if ismember(axInfo,[1 5 9 13])
            eval(['ylab',num2str(axInfo),' = ylabel(''Depth (m)'',''fontsize'',fonts);'])
        end
        eval(['axHandle = ax',num2str(axInfo),';'])
        set(axHandle,'Tickdir','out','fontsize',fonts,'layer','top','box','on', ...
            'ylim',[0 1000],'ytick',0:200:1000,'yticklabel',{'0','200','400','600','800',''},'yminort','on', ...
            'xlim',[-90 90],'xtick',-90:10:90,'xticklabel','','xminort','on');

        % 1000-5000db
        eval(['ax',num2str(axInfo+2),' = subplot(8,2,',num2str(axInfo+2),');']);
        [~,h] = contourf(t_lat,t_depth(depth1:end),thetao_mean_anom_zonal(depth1:end,:),50); hold all
        set(h,'linestyle','none'); hold all; clear h
        axis ij, caxis([-1 1]*ptscale(1)), clmap(27), hold all
        contour(t_lat,t_depth(depth1:end),pt_mean_zonal(depth1:end,:),[2.5 7.5 12.5 17.5 22.5 27.5],'k')
        [c,h] = contour(t_lat,t_depth(depth1:end),pt_mean_zonal(depth1:end,:),0:5:30,'k','linewidth',2);
        clabel(c,h,'LabelSpacing',200,'fontsize',fonts_c,'fontweight','bold','color','k')
        contour(t_lat,t_depth(depth1:end),thetao_mean_anom_zonal(depth1:end,:),-ptscale(2):1:ptscale(2),'color',[1 1 1]);
        text(tVarLab(1),tVarLab(2),'Temperature','fontsize',fonts_lab,'horizontalAlignment','right','color','k','fontweight','b');
        text(idLab(1),idLab(2),basinLabels(1),'fontsize',fonts_lab*1.5,'horizontalAlignment','left','color','k','fontweight','b');
        text(basinIdLab(1),basinIdLab(2),basinId,'fontsize',fonts_lab*1.75,'horizontalAlignment','center','color','k','fontweight','b');
        if basin == 4
            xlab15 = xlabel('Latitude','fontsize',fonts);
            hh1 = colorbarf_nw('horiz',-ptscale(1):0.25:ptscale(1),-ptscale(1):1:ptscale(1));
            set(hh1,'clim',[-ptscale(1) ptscale(1)]); % See https://www.mathworks.com/help/matlab/ref/matlab.graphics.illustration.colorbar-properties.html
        end
        eval(['axHandle = ax',num2str(axInfo+2),';'])
        if basin == 4
            set(axHandle,'Tickdir','out','fontsize',fonts,'layer','top','box','on', ...
                'ylim',[1000 5000],'ytick',1000:500:5000,'yticklabel',{'1000','','2000','','3000','','4000','','5000'},'yminort','on', ...
                'xlim',[-90 90],'xtick',-90:10:90,'xticklabel',{'90S','','','60S','','','30S','','','EQU','','','30N','','','60N','','','90N'},'xminort','on');
        else
            set(axHandle,'Tickdir','out','fontsize',fonts,'layer','top','box','on', ...
                'ylim',[1000 5000],'ytick',1000:500:5000,'yticklabel',{'1000','','2000','','3000','','4000','','5000'},'yminort','on', ...
                'xlim',[-90 90],'xtick',-90:10:90,'xticklabel',{''},'xminort','on');            
        end

        % Salinity
        % 0-1000db
        eval(['ax',num2str(axInfo+1),' = subplot(8,2,',num2str(axInfo+1),');']);
        [~,h] = contourf(t_lat,t_depth(1:depth1),so_mean_anom_zonal(1:depth1,:),50); hold all
        set(h,'linestyle','none'); hold all; clear h
        axis ij, caxis([-1 1]*sscale(1)), clmap(27), hold all
        contour(t_lat,t_depth(1:depth1),so_mean_zonal(1:depth1,:),scont1,'k')
        [c,h] = contour(t_lat,t_depth(1:depth1),so_mean_zonal(1:depth1,:),scont2,'k','linewidth',2);
        clabel(c,h,'LabelSpacing',200,'fontsize',fonts_c,'fontweight','bold','color','k')
        contour(t_lat,t_depth(1:depth1),so_mean_anom_zonal(1:depth1,:),-sscale(2):0.25:sscale(2),'color',[1 1 1]);
        eval(['axHandle = ax',num2str(axInfo+1),';'])        
        set(axHandle,'Tickdir','out','fontsize',fonts,'layer','top','box','on', ...
            'ylim',[0 1000],'ytick',0:200:1000,'yticklabel',{''},'yminort','on', ...
            'xlim',[-90 90],'xtick',-90:10:90,'xticklabel','','xminort','on');

        % 1000-5000db
        eval(['ax',num2str(axInfo+3),' = subplot(8,2,',num2str(axInfo+3),');']);
        [~,h] = contourf(t_lat,t_depth(depth1:end),so_mean_anom_zonal(depth1:end,:),50); hold all
        set(h,'linestyle','none'); hold all; clear h
        axis ij, caxis([-1 1]*sscale(1)), clmap(27), hold all
        contour(t_lat,t_depth(depth1:end),so_mean_zonal(depth1:end,:),scont1,'k')
        [c,h] = contour(t_lat,t_depth(depth1:end),so_mean_zonal(depth1:end,:),scont2,'k','linewidth',2);
        clabel(c,h,'LabelSpacing',200,'fontsize',fonts_c,'fontweight','bold','color','k')
        contour(t_lat,t_depth(depth1:end),so_mean_anom_zonal(depth1:end,:),-sscale(2):0.25:sscale(2),'color',[1 1 1]);
        text(sVarLab(1),sVarLab(2),'Salinity','fontsize',fonts_lab,'horizontalAlignment','right','color','k','fontweight','b');
        text(idLab(1),idLab(2),basinLabels(2),'fontsize',fonts_lab*1.5,'horizontalAlignment','left','color','k','fontweight','b');
        text(basinIdLab(1),basinIdLab(2),basinId,'fontsize',fonts_lab*1.75,'horizontalAlignment','center','color','k','fontweight','b');
        if basin == 4
            xlab16 = xlabel('Latitude','fontsize',fonts);
            hh2 = colorbarf_nw('horiz',-sscale(1):0.125:sscale(1),-sscale(1):0.25:sscale(1));
            set(hh2,'clim',[-sscale(1) sscale(1)])
        end
        eval(['axHandle = ax',num2str(axInfo+3),';'])
        if basin == 4
            set(axHandle,'Tickdir','out','fontsize',fonts,'layer','top','box','on', ...
                'ylim',[1000 5000],'ytick',1000:500:5000,'yticklabel',{''},'yminort','on', ...
                'xlim',[-90 90],'xtick',-90:10:90,'xticklabel',{'90S','','','60S','','','30S','','','EQU','','','30N','','','60N','','','90N'},'xminort','on');
        else
            set(axHandle,'Tickdir','out','fontsize',fonts,'layer','top','box','on', ...
                'ylim',[1000 5000],'ytick',1000:500:5000,'yticklabel',{''},'yminort','on', ...
                'xlim',[-90 90],'xtick',-90:10:90,'xticklabel',{''},'xminort','on');            
        end
    end

    % Resize into canvas - A4 page 8.26 x 11.69" or 20.98 x 29.69
    set(handle,'Position',[3 3 16.8 23.8]) % Full page width (175mm (17) width x 83mm (8) height) - Back to 16.5 x 6 for proportion  
    axHeight = 0.11; axWidth = 0.435;
    %                   x    y     wid  hei
    %set(hh1,'Position',[0.09 0.017 0.41 0.008],'fontsize',fonts);
    set(hh1,'Position',[0.092 0.017 0.41 0.008],'fontsize',fonts);
    set(hh2,'Position',[0.56 0.017 0.41 0.008],'fontsize',fonts);
    rowHeight = 0.06;
    set(ax15,'Position',[0.08 rowHeight axWidth axHeight]);
    set(ax16,'Position',[0.547 rowHeight axWidth axHeight]);
    rowHeight = rowHeight+axHeight+.005; %.175
    set(ax13,'Position',[0.08 rowHeight axWidth axHeight]);
    set(ax14,'Position',[0.547 rowHeight axWidth axHeight]);
    rowHeight = rowHeight+axHeight+.01;%.295
    set(ax11,'Position',[0.08 rowHeight axWidth axHeight]);
    set(ax12,'Position',[0.547 rowHeight axWidth axHeight]);
    rowHeight = rowHeight+axHeight+.005; %.41
    set(ax9,'Position',[0.08 rowHeight axWidth axHeight]);
    set(ax10,'Position',[0.547 rowHeight axWidth axHeight]);
    rowHeight = rowHeight+axHeight+.01; %.530
    set(ax7,'Position',[0.08 rowHeight axWidth axHeight]);
    set(ax8,'Position',[0.547 rowHeight axWidth axHeight]);
    rowHeight = rowHeight+axHeight+.005; %.645
    set(ax5,'Position',[0.08 rowHeight axWidth axHeight]);
    set(ax6,'Position',[0.547 rowHeight axWidth axHeight]);    
    rowHeight = rowHeight+axHeight+.01; %.765
    set(ax3,'Position',[0.08 rowHeight axWidth axHeight]);
    set(ax4,'Position',[0.547 rowHeight axWidth axHeight]);
    rowHeight = rowHeight+axHeight+.005; % 0.88
    set(ax1,'Position',[0.08 rowHeight axWidth axHeight]);
    set(ax2,'Position',[0.547 rowHeight axWidth axHeight]);      
    
    % Drop blanking mask between upper and lower panels
    rowHeight = rowHeight-.004; %.876
    axr1 = axes('Position',[0.07 rowHeight 0.95 0.003],'xtick',[],'ytick',[],'box','off','visible','on','xcolor',[1 1 1],'ycolor',[1 1 1]);
    rowHeight = rowHeight-axHeight*2-.015; %.645
    axr2 = axes('Position',[0.07 rowHeight 0.95 0.003],'xtick',[],'ytick',[],'box','off','visible','on','xcolor',[1 1 1],'ycolor',[1 1 1]);
    rowHeight = rowHeight-axHeight*2-.015; %.41
    axr3 = axes('Position',[0.07 rowHeight 0.95 0.003],'xtick',[],'ytick',[],'box','off','visible','on','xcolor',[1 1 1],'ycolor',[1 1 1]);
    rowHeight = rowHeight-axHeight*2-.015; %.175
    axr4 = axes('Position',[0.07 rowHeight 0.95 0.003],'xtick',[],'ytick',[],'box','off','visible','on','xcolor',[1 1 1],'ycolor',[1 1 1]);
                                 %0.875      0.004
    % Axis labels
    xPos = -110; yPos = 1000;
    set(ylab1,'Position',[xPos yPos 1.0001]);
    set(ylab5,'Position',[xPos yPos 1.0001]);
    set(ylab9,'Position',[xPos yPos 1.0001]);
    set(ylab13,'Position',[xPos yPos 1.0001]);
    set(xlab15,'Position',[0 5686 1.0001]);
    set(xlab16,'Position',[0 5686 1.0001]); 
    
    % Print to file
    export_fig([outDir,datestr(now,'yymmdd'),'_AR6WG1_Ch3_Fig3p21_',mipEraId,'minusWOA18_thetaoAndso_basin'],'-png')
    export_fig([outDir,datestr(now,'yymmdd'),'_AR6WG1_Ch3_Fig3p21_',mipEraId,'minusWOA18_thetaoAndso_basin'],'-eps')

    close all %set(gcf,'visi','on');
    clear ax* c h handle hh* xlab* ylab* mipEra
end
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

% make_AR6_Ch2Stats.m

% Output for AR5 and AR6 data
%{
CDF
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

CDF
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
%}

%% Cleanup workspace and command window
% Initialise environment variables - only homeDir needed for file cleanups
%[homeDir,work_dir,dataDir,obsDir,username,a_host_longname,a_maxThreads,a_opengl,a_matver] = myMatEnv(maxThreads);
[homeDir,~,~,~,username,aHostLongname,~,~,~] = myMatEnv(2);
if ~sum(strcmp(username,{'dur041','duro','durack1'})); disp('**myMatEnv - username error**'); keyboard; end

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

% Load mask
load([homeDir,'code/make_basins.mat'], 'basins3_NaN_ones_2x1')
basins3_NaN_ones_2x1 = basins3_NaN_ones_2x1(:,1:180);

% Re-index longitude
sChg = squeeze(sChg(1,:,:));
sChgErr = squeeze(sChgErr(1,:,:));
sMean = squeeze(sMean(1,:,:));
%tChg = squeeze(tChg(1,:,:1));
%tChgErr = squeeze(tChgErr(1,:,:));
%tMean = squeeze(tMean(1,:,:));

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
fileOnly = strsplit(infile,'/');
disp(['infile: ',fileOnly{end}])
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
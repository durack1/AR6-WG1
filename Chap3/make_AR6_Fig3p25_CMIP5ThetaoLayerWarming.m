% Generate CMIP5 layered warming plot for the industrial period

% Paul J. Durack 9 January 2020
%{
% PJD  6 Jun 2018   - Copied from 161109_ChapterPlots_OceanWarming and updated input
% PJD 27 Jul 2018   - Update volcanoes for 4.7.0 release
% PJD  6 Aug 2018   - Update input obs
% PJD 13 Aug 2018   - Updated input obs
% PJD 13 Aug 2018   - Updated pjgDir to use local
% PJD 15 Aug 2018   - Updated all local data to 180815 (fixed issue with cdat_info logging; JAMSTEC grid)
% PJD 15 Aug 2018   - Finalized Fig1 CDF updated to 2017
% PJD  6 Sep 2018   - Added hemispheric splits (Figure 2)
% PJD  6 Sep 2018   - Regenerate trend maps see /work/durack1/Shared/130626_data_OHCSteric/drive_obs.py
% PJD 11 Sep 2018   - Added Fig3 with reviewed data
% PJD 11 Sep 2018   - More compact and cleaner text files are generated with the '-painters' renderer specified (fig1&2)
% PJD 12 Sep 2018   - Models upper. mid and lower read and regridded
% PJD 13 Sep 2018   - Ensemble mean generated, and levels model data rerun to generate level bound information
% PJD  2 Oct 2018   - Copied obs coverage Fig 1 from 111126_ChapterPlots_SaltyWaterCycle/make_chapterplots.m
% PJD 18 Oct 2018   - Generated Fig 5 Models vs Purkey using C/yr units
% PJD  1 Nov 2018   - Corrected Fig 5, labels, and colour bar is now not split across white
% PJD  1 Nov 2018   - Corrected Fig 3, added Lyman and corrected y-ax units
% PJD  1 Nov 2018   - Corrected Fig 2, added Lyman
% PJD  2 Nov 2018   - Generated Fig 2 with volcs >4 for all time periods (missing forcings for input4MIPs poster)
% PJD  8 Nov 2018   - Updated diag plots for regridded lower/upper fields
% PJD 23 Nov 2018   - Figure updates for final submission
% PJD 24 Nov 2018   - Fig 1 has issue with XBT/MBT data duplication - one is incorrect
% PJD 24 Nov 2018   - Figs 2, 3 Johnson et al 2018 ref updated; Fig 5 obs/model order flipped
% PJD 24 Nov 2018   - Fig 2 fixed volcanic coverage, and broken line legend for Ridley et al 2014
% PJD 24 Nov 2018   - Fig 5 fixed A => B, fixed units, fixed lons basin bounds, add unit and descriptive labels
% PJD 24 Nov 2018   - Fig 1 Tim B provided updated latbin file
% PJD 24 Nov 2018   - Fig 5, corrected units to mC, was off by 10
% PJD 24 Nov 2018   - Fig 3, updated units to depth-averaged temp per 12 yrs
% PJD 25 Nov 2018   - Extract information from mat files - drift tables
%                   strX = 'NorESM1-M'; for x = 1:length(model_names), if strfind(model_names{x},strX),disp(model_names{x}), end, end
% PJD 25 Nov 2018   - Fig 1 Updated to use corrected latbin_count_tempall and latbin_count_deep files (decimal values replaced)
% PJD 25 Nov 2018   - Fig 1 removed temporal extent from legend as this provides confusing guidance due to inconsistencies
%                     in the database entries associated with the labels
% PJD 25 Nov 2018   - General cleanup, deleted obsolete/commented code blocks
% PJD 25 Nov 2018   - Fig 2 added trend calc and reporting in code
% PJD 28 Nov 2018   - Fig 4 update units to degC decade-1
% PJD 28 Nov 2018   - Update all figs to use -painters renderer to ensure vector outputs are preserved
% durack1@oceanonly:[export_fig]:[master]:[9512]> git fetch --all -p
% Fetching origin
% remote: Enumerating objects: 18, done.
% remote: Counting objects: 100% (18/18), done.
% remote: Compressing objects: 100% (2/2), done.
% remote: Total 50 (delta 16), reused 17 (delta 16), pack-reused 32
% Unpacking objects: 100% (50/50), done.
% From https://github.com/altmany/export_fig
%    c062ae2..26eb699  master     -> origin/master
% PJD 30 Nov 2018   - Added some tests for export_fig bug https://github.com/altmany/export_fig/issues/262
% PJD 24 Dec 2018   - Updated to export fig1 and fig5 to matlab fig format for export_fig bug reporting
%}
% PJD  9 Jan 2020   - Renamed from ../180606_PaperPlots_UpperDeepWarming/make_paperplots.m and updated input
% PJD  9 Jan 2020   - Purged redundant code
% PJD  9 Jan 2020   - Got up to 10e16 vs 10e22 conversion
% PJD  9 Jan 2020   - First pass finalized file
% PJD  9 Jan 2020   - Updated figure naming with identifier (durack1)

%                   - TODO:
%                     Expand to 2018/19
%                     Update volcano histories
%                     Add non-depth cm5 models: MIROC-ESM-CHEM,MIROC-ESM, MIROC4h, MIROC5, INMCM4

% uisetcolor - colour picker

% Figure sizes      - NCC indicates 88mm single, 170mm double column width - 300dpi TIFF CMYK
% in-situ vs thetao - http://www.nature.com/scitable/knowledge/library/key-physical-variables-in-the-ocean-temperature-102805293

% make_AR6_Fig3p25_CMIP5ThetaoLayerWarming.m

%% Cleanup workspace and command window
clear, clc, close all
% Initialise environment variables
[homeDir,~,~,obsDir,~,aHostLongname] = myMatEnv(2);
outDir = os_path([homeDir,'190311_AR6/Chap3/']);
dataDir = [homeDir,'180606_PaperPlots_UpperDeepWarming/'];
pjgDir = [dataDir,'ohc_deep/'] ; %'/export/gleckler1/processing/ohc_deep/';
mipEraId = 'CMIP5';
cd(outDir);

% Error estimate inflation factors
CI_99 = 2.57583; % Raise error estimates to 99% C.I assuming normal distn http://en.wikipedia.org/wiki/Normal_distribution booterror_pres = 1.09; % Add 9% to the formal error to account for bootstrap result (pressure, was 30%)
CI_95 = 1.95996;
CI_90 = 1.64485;
booterror_pres = 1.09; % Add 9% to formal error to (bootstrap result)

% Specify data source
%addpath('/work/durack1/matlab/calendar') % Add days365 to path
%addpath('/work/durack1/matlab/curvefit/curvefit') % Add smooth to path

% Set colours
dk_blue     = [000/255 146/255 200/255];
mid_blue    = [032/255 196/255 244/255];
lt_blue     = [171/255 255/255 250/255];
orange      = [253/255 179/255 2/255];
lt_green    = [173/255 253/255 2/255];
gray        = [191/255 191/255 191/255];
mauve       = [225/255 171/255 250/255]; % Or 0.7176 0.2745 1.0000
br_green    = [120/255 171/255 48/255]; %[171/255 250/255 245/255];
dk_gray     = [.7 .7 .7];
lt_gray     = [.2 .2 .2];
%lt_gray     = dk_gray; % No utility Fig2

greg_colours = [0.0000    0.4470    0.7410; 0.8500    0.3250    0.0980; 0.9290    0.6940    0.1250; ...
                0.4940    0.1840    0.5560; 0.4660    0.6740    0.1880; 0.3010    0.7450    0.9330; ...
                0.6350    0.0780    0.1840];

%% Specify Forster et al., (2013) adjusted forcings
%{
hist_rcp85_forcing_wm2 = {
    'model','hist','rcp26','rcp45','rcp60','rcp85';
    'ACCESS1-0',1.1,NaN,3.3,NaN,6.2;
    'bcc-csm1-1',2.2,2.5,3.3,4.5,7.0;
    'bcc-csm1-1-m',2.2,1.9,3.3,4.3,7.0;
    'CanESM2',2.0,2.9,4.3,NaN,8.4;
    'CCSM4',2.5,2.8,4.3,5.4,8.3;
    'CNRM-CM5',1.5,2.3,3.7,NaN,6.9;
    'CSIRO-Mk3-6-0',0.9,1.9,2.8,3.4,5.7;
    'FGOALS-s2',2.3,2.5,4.3,6.5,10.0;
    'GFDL-CM3',1.1,3.1,4.2,4.9,7.2;
    'GFDL-ESM2G',2.0,1.2,2.8,3.9,6.4;
    'GFDL-ESM2M',2.0,2.5,3.5,4.9,7.3;
    'GISS-E2-H',2.3,NaN,NaN,NaN,NaN;
    'GISS-E2-R',2.5,2.6,4.7,5.9,8.6;
    'HadGEM2-ES',0.8,1.7,2.9,4.0,5.9;
    'inmcm4',1.7,NaN,3.8,NaN,7.3;
    'IPSL-CM5A-LR',1.9,2.2,3.5,4.3,7.1;
    'IPSL-CM5B-LR',1.0,NaN,NaN,NaN,NaN;
    'MIROC5',1.6,3.0,4.5,5.3,8.7;
    'MIROC-ESM',1.1,2.8,4.0,5.1,8.2;
    'MPI-ESM-LR',2.1,2.2,3.9,NaN,7.7;
    'MPI-ESM-P',2.3,NaN,NaN,NaN,NaN;
    'MRI-CGCM3',1.2,2.1,3.6,4.3,7.0;
    'NorESM1-M',1.4,2.0,3.6,4.2,7.0;
    };
%}

%% Set model forcings
% 10.1002/2014JD021783
%{
modelForcing = {
  'bcc-csm1-1','indirect','Salzmannetal14JGR-A';
  'CanESM2','indirect','Salzmannetal14JGR-A';
  'CCSM4','indirect','Salzmannetal14JGR-A';
  'GFDL-CM3','indirect','Salzmannetal14JGR-A';
  'GFDL-ESM2','indirect','Salzmannetal14JGR-A';
  'CNRM-CM5','indirect','Salzmannetal14JGR-A';
  'CSIRO-Mk3-6-0','indirect','Salzmannetal14JGR-A';
  'GISS-E2-H','indirect','Salzmannetal14JGR-A';
  'GISS-E2-R','indirect','Salzmannetal14JGR-A';
  'HadGEM','indirect','Salzmannetal14JGR-A';
  'IPSL-CM5','indirect','Salzmannetal14JGR-A';
  'MIROC-ESM','indirect','Salzmannetal14JGR-A';
  'MIROC-ESM-C','indirect','Salzmannetal14JGR-A';
  'MRI-CGCM3','indirect','Salzmannetal14JGR-A';
  'NorESM','indirect','Salzmannetal14JGR-A';
};
%}

%% 1 Set Volcano dates
% http://en.wikipedia.org/wiki/List_of_large_volcanic_eruptions_of_the_19th_century
% http://en.wikipedia.org/wiki/List_of_large_volcanic_eruptions_of_the_20th_century
% http://en.wikipedia.org/wiki/List_of_large_volcanic_eruptions_in_the_21st_century
% http://www.volcano.si.edu/search_eruption.cfm
volcsOld = {
    'Name','year','month','day','VEI';
    'Krakatoa',1883,8,26,6;
    'Mount Tarawera',1886,6,10,5;
    'Mount Bandai',1888,7,15,4;
    'Santa Maria',1902,10,24,6;
    'Mount Agung',1963,3,17,5;
    'Mount St. Helens',1980,5,18,5;
    'El Chichon',1982,3,29,5; % char(243)
    'Mount Pinatubo',1991,6,15,6;
    'Ulawun',2000,9,29,4;
    'Shiveluch',2001,5,22,4;
    'Ruang',2002,9,25,4;
    'Reventador',2002,11,3,4;
    'Anatahan',2004,4,12,3;
    'Manam',2005,1,27,4;
    'Sierra Negra',2005,10,22,3;
    'Soufriere Hills',2006,5,20,4; % char(232)
    'Tarvurvur',2006,10,7,4;
    'Jebel at Tair',2007,9,30,3;
    'Chaiten',2008,5,2,4; % char(232)
    'Mount Okmok',2008,7,12,4;
    'Kasatochi',2008,8,7,4;
    'Sarychev Peak',2009,6,12,4;
    'Eyjafjallajokull',2010,4,14,4; % char(246)
    'Mount Merapi',2010,10,26,4;
    'Grimsvotn',2011,5,21,4; % char(237),char(246)
    'Puyehue-Cordon Caulle',2011,6,4,5; % char(243)
    'Nabro',2011,6,13,4;
    'Kelud',2014,2,13,4;
    'Mount Ontake',2014,9,27,3;
    'Calbuco', 2015,4,22,4;
};
volcs = {
    'Volcano Number','Volcano Name','VEI','Start Year','Start Month','Start Day','Latitude','Longitude','CMIPx included?','CMIP#';
    '285030','Toya',4,1853,4,22,42.544,140.839,0,0;
    '300270','Sheveluch',5,1854,2,18,56.653,161.36,0,0;
    '285020','Hokkaido-Komagatake',4,1856,9,25,42.063,140.677,0,0;
    '342090','Fuego',4,1857,1,15,14.473,-90.88,0,0;
    '372030','Katla',4,1860,5,8,63.633,-19.083,0,0;
    '268070','Makian',4,1861,12,28,0.32,127.4,0,0;
    '290290','Sinarka',4,1872,0,0,48.873,154.182,0,0;
    '263250','Merapi',4,1872,4,15,-7.54,110.446,0,0;
    '373010','Grimsvotn',4,1873,1,8,64.416,-17.316,0,0;
    '211020','Vesuvius',4,1875,12,18,40.821,14.426,0,0;
    '373060','Askja',5,1875,1,1,65.033,-16.783,0,0;
    '282030','Suwanosejima',4,1877,0,0,29.638,129.714,0,0;
    '352050','Cotopaxi',4,1877,1,0,-0.677,-78.436,0,0;
    '342090','Fuego',4,1880,6,28,14.473,-90.88,0,0;
    '313010','Augustine',4,1883,10,6,59.363,-153.43,0,0;
    '262000','Krakatau',6,1883,5,20,-6.102,105.423,1,1; %'Krakatoa',1883,8,26,6;
    '352080','Tungurahua',4,1886,1,11,-1.467,-78.442,0,0;
    '243110','Niuafo''''ou',4,1886,8,31,-15.6,-175.63,0,0;
    '241050','Okataina',5,1886,6,10,-38.12,176.5,1,2; %'Mount Tarawera',1886,6,10,5;
    '283160','Bandaisan',4,1888,7,15,37.601,140.072,1,3; %'Mount Bandai',1888,7,15,4;
    '341040','Colima',4,1889,8,9,19.514,-103.62,0,0;
    '282030','Suwanosejima',4,1889,10,2,29.638,129.714,0,0;
    '358020','Calbuco',4,1893,1,7,-41.33,-72.618,0,0;
    '273030','Mayon',4,1897,5,23,13.257,123.685,0,0;
    '351070','Dona Juana',4,1897,11,1,1.5,-76.936,0,0;
    '360120','Pelee',4,1902,4,23,14.809,-61.165,0,0;
    '360150','Soufriere St. Vincent',4,1902,5,6,13.33,-61.18,0,0;
    '373010','Grimsvotn',4,1902,12,0,64.416,-17.316,0,0;
    '342030','Santa Maria',6,1902,10,24,14.757,-91.552,1,4; %'Santa Maria',1902,10,24,6;
    '252130','Lolobau',4,1904,8,9,-4.92,151.158,0,0;
    '300050','Ksudach',5,1907,3,28,51.844,157.572,0,0;
    '252130','Lolobau',4,1911,0,0,-4.92,151.158,0,0;
    '312180','Novarupta',6,1912,6,6,58.27,-155.157,0,0;
    '341040','Colima',5,1913,1,17,19.514,-103.62,0,0;
    '282080','Aira',4,1914,1,12,31.593,130.657,0,0;
    '352080','Tungurahua',4,1916,3,3,-1.467,-78.442,0,0;
    '357060','Azul, Cerro',5,1916,0,0,-35.653,-70.761,0,0;
    '284160','Agrigan',4,1917,4,9,18.77,145.67,0,0;
    '372030','Katla',4,1918,10,12,63.633,-19.083,0,0;
    '263280','Kelut',4,1919,5,19,-7.93,112.308,0,0;
    '251020','Manam',4,1919,8,11,-4.08,145.037,0,0;
    '290250','Raikoke',4,1924,2,15,48.292,153.25,0,0;
    '282010','Submarine Volcano NNE of Iriomotejima',4,1924,10,31,24.57,123.93,0,0;
    '300100','Avachinsky',4,1926,3,27,53.256,158.836,0,0;
    '285020','Hokkaido-Komagatake',4,1929,6,17,42.063,140.677,0,0;
    '300260','Klyuchevskoy',4,1931,3,25,56.056,160.642,0,0;
    '312090','Aniakchak',4,1931,5,1,56.88,-158.17,0,0;
    '342090','Fuego',4,1932,1,21,14.473,-90.88,0,0;
    '261270','Suoh',4,1933,7,10,-5.25,104.27,0,0;
    '282050','Kuchinoerabujima',4,1933,12,23,30.443,130.217,0,0;
    '290300','Kharimkotan',5,1933,1,8,49.12,154.508,0,0;
    '252140','Rabaul',4,1937,5,29,-4.271,152.203,0,0;
    '341060','Michoacan-Guanajuato',4,1943,2,20,19.85,-101.75,0,0;
    '300100','Avachinsky',4,1945,2,25,53.256,158.836,0,0;
    '290240','Sarychev Peak',4,1946,11,9,48.092,153.2,0,0;
    '372070','Hekla',4,1947,3,29,63.983,-19.666,0,0;
    '257040','Ambrym',4,1950,12,6,-16.25,168.12,0,0;
    '253010','Lamington',4,1951,1,17,-8.95,148.15,0,0;
    '263280','Kelut',4,1951,8,31,-7.93,112.308,0,0;
    '255020','Bagana',4,1952,2,29,-6.137,155.196,0,0;
    '313040','Spurr',4,1953,7,9,61.299,-152.251,0,0;
    '357140','Carran-Los Venados',4,1955,7,27,-40.35,-72.07,0,0; % char(225) á
    '300250','Bezymianny',5,1955,10,22,55.972,160.595,0,0;
    '264020','Agung',5,1963,2,18,-8.343,115.508,1,5; %'Mount Agung',1963,3,17,5;
    '300270','Sheveluch',4,1964,11,12,56.653,161.36,0,0;
    '273070','Taal',4,1965,9,28,14.002,120.993,0,0;
    '263280','Kelut',4,1966,4,26,-7.93,112.308,0,0;
    '267040','Awu',4,1966,8,12,3.689,125.447,0,0;
    '353010','Fernandina',4,1968,6,11,-0.37,-91.55,0,0;
    '290030','Chachadake [Tiatia]',4,1973,7,14,44.353,146.252,0,0;
    '342090','Fuego',4,1974,10,10,14.473,-90.88,0,0;
    '300240','Tolbachik',4,1975,6,28,55.832,160.326,0,0;
    '313010','Augustine',4,1976,1,22,59.363,-153.43,0,0;
    '321050','St. Helens',5,1980,3,27,46.2,-122.18,1,6; %'Mount St. Helens',1980,5,18,5;
    '290390','Alaid',4,1981,4,27,50.861,155.565,0,0;
    '284170','Pagan',4,1981,5,15,18.13,145.8,0,0;
    '263140','Galunggung',4,1982,4,5,-7.25,108.058,0,0;
    '341120','Chichon, El',5,1982,3,28,17.36,-93.228,1,7; %'El Chichon',1982,3,29,5; % char(243)
    '266010','Colo',4,1983,7,18,-0.162,121.601,0,0;
    '313010','Augustine',4,1986,3,27,59.363,-153.43,0,0;
    '290360','Chikurachki',4,1986,11,18,50.324,155.461,0,0;
    '300260','Klyuchevskoy',4,1986,11,27,56.056,160.642,0,0;
    '263280','Kelut',4,1990,2,10,-7.93,112.308,0,0;
    '358057','Hudson, Cerro',5,1991,8,8,-45.9,-72.97,0,0;
    '273083','Pinatubo',6,1991,4,2,15.13,120.35,1,8; %'Mount Pinatubo',1991,6,15,6;
    '313040','Spurr',4,1992,6,27,61.299,-152.251,0,0;
    '355100','Lascar',4,1993,1,30,-23.37,-67.73,0,0;
    '252140','Rabaul',4,1994,9,19,-4.271,152.203,0,0;
    '300270','Sheveluch',4,1999,8,15,56.653,161.36,0,0;
    '372070','Hekla',3,2000,2,26,63.983,-19.666,0,0;
    '241040','White Island',3,2000,3,7,-37.52,177.18,0,0;
    '284040','Miyakejima',3,2000,6,27,34.094,139.526,0,0;
    '282030','Suwanosejima',3,2000,12,19,29.638,129.714,0,0;
    '252120','Ulawun',4,2000,9,28,-5.05,151.33,0,0;
    '273030','Mayon',3,2001,1,8,13.257,123.685,0,0;
    '252120','Ulawun',3,2001,1,16,-5.05,151.33,0,0;
    '311240','Cleveland',3,2001,2,2,52.825,-169.944,0,0;
    '257050','Lopevi',3,2001,6,8,-16.507,168.346,0,0;
    '300250','Bezymianny',3,2001,7,23,55.972,160.595,0,0;
    '300130','Karymsky',3,2001,11,15,54.049,159.443,0,0;
    '251020','Manam',3,2002,1,13,-4.08,145.037,0,0;
    '252080','Witori',3,2002,8,3,-5.576,150.516,0,0;
    '211060','Etna',3,2002,10,26,37.748,14.999,0,0;
    '267010','Ruang',4,2002,9,25,2.3,125.37,0,0;
    '352010','Reventador',4,2002,11,3,-0.077,-77.656,0,0;
    '284200','Anatahan',3,2003,5,10,16.35,145.67,0,0;
    '257050','Lopevi',3,2003,6,8,-16.507,168.346,0,0;
    '264200','Leroboleng',3,2003,6,26,-8.365,122.833,0,0;
    '300250','Bezymianny',3,2003,7,26,55.972,160.595,0,0;
    '266100','Lokon-Empung',3,2003,9,12,1.358,124.792,0,0;
    '300250','Bezymianny',3,2004,1,14,55.972,160.595,0,0;
    '360050','Soufriere Hills',3,2004,3,3,16.72,-62.18,0,0;
    '284200','Anatahan',3,2004,4,12,16.35,145.67,0,0;
    '351080','Galeras',3,2004,7,16,1.22,-77.37,0,0;
    '342110','Pacaya',3,2004,7,19,14.382,-90.601,0,0;
    '266030','Soputan',3,2004,10,18,1.112,124.737,0,0;
    '373010','Grimsvotn',3,2004,11,1,64.416,-17.316,0,0;
    '251020','Manam',4,2004,10,24,-4.08,145.037,0,0;
    '360050','Soufriere Hills',3,2005,4,15,16.72,-62.18,0,0;
    '355100','Lascar',3,2005,5,4,-23.37,-67.73,0,0;
    '343020','Santa Ana',3,2005,6,16,13.853,-89.63,0,0;
    '221113','Dabbahu',3,2005,9,26,12.595,40.48,0,0;
    '353050','Negra, Sierra',3,2005,10,22,-0.83,-91.17,0,0;
    '233010','Karthala',3,2005,11,24,-11.75,43.38,0,0;
    '313010','Augustine',3,2005,12,9,59.363,-153.43,0,0;
    '311240','Cleveland',3,2006,2,6,52.825,-169.944,0,0;
    '342110','Pacaya',3,2006,3,9,14.382,-90.601,0,0;
    '300250','Bezymianny',3,2006,4,16,55.972,160.595,0,0;
    '355100','Lascar',3,2006,4,18,-23.37,-67.73,0,0;
    '252140','Rabaul',4,2006,8,11,-4.271,152.203,0,0;
	'351050','Huila, Nevado del',3,2007,2,19,2.93,-76.03,0,0;
    '300250','Bezymianny',3,2007,5,10,55.972,160.595,0,0;
    '266030','Soputan',3,2007,6,16,1.112,124.737,0,0;
    '222120','Lengai, Ol Doinyo',3,2007,6,16,-2.764,35.914,0,0;
    '221010','Tair, Jebel at',3,2007,9,30,15.55,41.83,0,0;
    '351080','Galeras',3,2007,10,4,1.22,-77.37,0,0;
    '357110','Llaima',3,2008,1,1,-38.692,-71.729,0,0;
    '266030','Soputan',3,2008,6,6,1.112,124.737,0,0;
    '300250','Bezymianny',3,2008,7,11,55.972,160.595,0,0;
    '351080','Galeras',3,2008,10,21,1.22,-77.37,0,0;
    '351050','Huila, Nevado del',3,2008,10,26,2.93,-76.03,0,0;
    '221060','Alu-Dalafilla',3,2008,11,3,13.793,40.553,0,0;
    '358041','Chaiten',4,2008,5,2,-42.833,-72.646,0,0;
    '311290','Okmok',4,2008,7,12,53.43,-168.13,0,0;
    '311130','Kasatochi',4,2008,8,7,52.177,-175.508,0,0;
    '313030','Redoubt',3,2009,3,15,60.485,-152.742,0,0;
    '300250','Bezymianny',3,2009,12,17,55.972,160.595,0,0;
    '290240','Sarychev Peak',4,2009,6,11,48.092,153.2,0,0;
    '352080','Tungurahua',3,2010,1,1,-1.467,-78.442,0,0;
    '300250','Bezymianny',3,2010,5,21,55.972,160.595,0,0;
    '284193','South Sarigan Seamount',3,2010,5,27,16.58,145.78,0,0;
    '267020','Karangetang',3,2010,8,6,2.781,125.407,0,0;
    '300230','Kizimen',3,2010,11,11,55.131,160.32,0,0;
    '352080','Tungurahua',3,2010,11,22,-1.467,-78.442,0,0;
    '263310','Tengger Caldera',3,2010,11,26,-7.942,112.95,0,0;
    '372020','Eyjafjallajokull',4,2010,3,20,63.633,-19.633,0,0;
    '263250','Merapi',4,2010,10,26,-7.54,110.446,0,0;
    '357040','Planchon-Peteroa',3,2011,2,17,-35.223,-70.568,0,0;
    '266030','Soputan',3,2011,7,3,1.112,124.737,0,0;
    '352080','Tungurahua',3,2011,11,27,-1.467,-78.442,0,0;
    '373010','Grimsvotn',4,2011,5,21,64.416,-17.316,0,0;
    '221101','Nabro',4,2011,6,13,13.37,41.7,0,0;
    '357150','Puyehue-Cordon Caulle',5,2011,6,4,-40.59,-72.117,0,0;
    '251030','Karkar',3,2012,2,1,-4.649,145.964,0,0;
    '351020','Ruiz, Nevado del',3,2012,2,22,4.892,-75.324,0,0;
    '266030','Soputan',3,2012,8,26,1.112,124.737,0,0;
    '300240','Tolbachik',4,2012,11,27,55.832,160.326,0,0;
    '251030','Karkar',3,2013,1,29,-4.649,145.964,0,0;
    '312030','Pavlof',3,2013,5,13,55.417,-161.894,0,0;
    '312070','Veniaminof',3,2013,6,13,56.17,-159.38,0,0;
    '300120','Zhupanovsky',3,2013,10,23,53.589,159.15,0,0;
    '263250','Merapi',3,2014,3,9,-7.54,110.446,0,0;
    '263300','Semeru',3,2014,4,1,-8.108,112.922,0,0;
    '264050','Sangeang Api',3,2014,5,30,-8.2,119.07,0,0;
    '312030','Pavlof',3,2014,5,31,55.417,-161.894,0,0;
    '300120','Zhupanovsky',3,2014,6,6,53.589,159.15,0,0;
    '252140','Rabaul',3,2014,7,7,-4.271,152.203,0,0;
    '283040','Ontakesan',3,2014,9,27,35.893,137.48,0,0;
    '384010','Fogo',3,2014,11,23,14.95,-24.35,0,0;
    '263280','Kelut',4,2014,2,13,-7.93,112.308,0,0;
    '266030','Soputan',3,2015,1,6,1.112,124.737,0,0;
    '263340','Raung',3,2015,2,1,-8.119,114.056,0,0;
    '290360','Chikurachki',3,2015,2,16,50.324,155.461,0,0;
    '282050','Kuchinoerabujima',3,2015,5,29,30.443,130.217,0,0;
    '300260','Klyuchevskoy',3,2015,8,28,56.056,160.642,0,0;
    '358020','Calbuco',4,2015,4,22,-41.33,-72.618,0,0;
    '353020','Wolf',4,2015,5,25,0.02,-91.35,0,0;
    '266030','Soputan',3,2016,1,2,1.112,124.737,0,0;
    '282110','Asosan',3,2016,10,7,32.884,131.104,0,0;
    '354006','Sabancaya',3,2016,11,6,-15.787,-71.857,0,0;
    '290260','Chirinkotan',3,2016,11,29,48.98,153.48,0,0;
    '311300','Bogoslof',3,2016,12,20,53.93,-168.03,0,0;
    '300010','Kambalny',3,2017,3,24,51.306,156.875,0,0;
    '300130','Karymsky',3,2017,6,4,54.049,159.443,0,0;
    '257030','Ambae',3,2017,9,6,-15.389,167.835,0,0;
    '256010','Tinakula',3,2017,10,21,-10.386,165.804,0,0;
    '264020','Agung',3,2017,11,21,-8.343,115.508,0,0;
    '282090','Kirishimayama',3,2018,3,1,31.934,130.862,0,0;
    '263250','Merapi',3,2018,5,11,-7.54,110.446,0,0;
};
%volcs(1).name = 'Krakatoa'; volcs(1).date = 1883.0;

%% 2 Input files Obs 10^17, volume integral - PJD
%dataVer = '150605'; dataTag = '0to700And700to2000m.nc';
%dataVer = '180815'; dataTag = '0to700And700to2000m.nc';
dataVer = '180905'; dataTag = '0to700And700to2000m.nc';
upTag = 'toInteg_0to700'; intTag = 'toInteg_700to2000';
infile          = [dataDir,dataVer,'_IPRC_',dataTag];
data_iprc_up    = getnc(infile,upTag);
data_iprc_int   = getnc(infile,intTag);
time_iprc       = timenc(infile);
infile          = [dataDir,dataVer,'_JAMSTEC_',dataTag];
data_jam_up     = getnc(infile,upTag);
data_jam_int    = getnc(infile,intTag);
time_jam        = timenc(infile);
infile          = [dataDir,dataVer,'_UCSD_',dataTag];
data_ucsd_up    = getnc(infile,upTag);
data_ucsd_int   = getnc(infile,intTag);
time_ucsd       = timenc(infile);
infile          = [dataDir,dataVer,'_EN4.2.1.g10_',dataTag];
data_en4_up     = getnc(infile,upTag);
data_en4_int    = getnc(infile,intTag);
time_en4        = timenc(infile);
infile          = [dataDir,dataVer,'_NODC_',dataTag];
data_nodc_up    = getnc(infile,upTag);
data_nodc_int   = getnc(infile,intTag);
time_nodc       = timenc(infile);
%infile          = [dataDir,dataVer,'_Ishii_v6.13_',dataTag];
%data_ish6_up    = getnc(infile,upTag);
%data_ish6_int   = getnc(infile,intTag);
%time_ish6       = timenc(infile);
clear upTag intTag
% Load hemispheric totals
dataVer = '180905'; dataTag = '0to700And700to2000m.nc';
upTag = 'toInteg_0to700_SN'; intTag = 'toInteg_700to2000_SN';
infile          = [dataDir,dataVer,'_IPRC_',dataTag];
data_iprc_upSN    = getnc(infile,upTag);
data_iprc_intSN   = getnc(infile,intTag);
infile          = [dataDir,dataVer,'_JAMSTEC_',dataTag];
data_jam_upSN     = getnc(infile,upTag);
data_jam_intSN    = getnc(infile,intTag);
infile          = [dataDir,dataVer,'_UCSD_',dataTag];
data_ucsd_upSN    = getnc(infile,upTag);
data_ucsd_intSN   = getnc(infile,intTag);
infile          = [dataDir,dataVer,'_EN4.2.1.g10_',dataTag];
data_en4_upSN     = getnc(infile,upTag);
data_en4_intSN    = getnc(infile,intTag);
infile          = [dataDir,dataVer,'_NODC_',dataTag];
data_nodc_upSN    = getnc(infile,upTag);
data_nodc_intSN   = getnc(infile,intTag);
% Gleckler - Levitus 0-2000
%infile          = [pjgDir,'obs_levitus/lev_mid.nc'];
%data_nodcg_int  = getnc(infile,'thetao');
%time_nodcg      = timenc(infile);
%time_nodcg      = 1957:2010;

%% 3 Input files Models 10^16 - PJG
infile      = [pjgDir,'data_mmm/','mmm_hist+rcp_areacello_top.nc'];
data_upper  = getnc(infile,'thetao');
infile      = [pjgDir,'data_mmm/','mmm_hist+rcp_areacello_mid.nc'];
data_inter  = getnc(infile,'thetao');
infile      = [pjgDir,'data_mmm/','mmm_hist+rcp_areacello_bottom.nc'];
data_lower  = getnc(infile,'thetao');
time        = linspace(1865,2025,161); % Time periods provided by PJG
timelen     = 1:length(time);

% PJG - Model data
% Constants
rho                 = 1020;
cp                  = 3992;
conv                = (rho*cp)/1e22;
ocean_total_area_m2 = 361132000000000;
radearth_m2         = 6371000;
vol                 = 4/3*pi*(power(radearth_m2,3)-power(radearth_m2-700,3));
obsconv             = vol*conv*.7;
% Get input file list and purge existing output files
[models,models1971] = deal(NaN(3,16,161)); % 1865 -> 2025
timeIndex = 107; % 1971 (1865:2025) [(1:161)',(1865:2025)']
modelInfo = cell(16,1);
layers = {'0-700','mid','bottom'};
for layer = 1:length(layers)
    data_path = [pjgDir,'compute_ts/data_am/',layers{layer},'/historical+rcp85_drift_removed/areacello_NHSHEQ70_NOMED/'];
    [~,modelList] = unix(['\ls -1 ',data_path,'*.nc']);
    modelList = strtrim(modelList);
    temp = regexp(modelList,'\n','split'); clear modelList
    [~,index] = sort(temp);
    temp = temp(1,index); clear index
    disp([layers{layer},': ',num2str(length(temp))])
    % Read each
    for x = 1:length(temp)
       infile = temp{x};
       tmp = getnc(infile,'thetao',1,161,1); % Get subset: lower, upper, stride (required as time badly formed)
       %ind = strfind(infile,'/');
       %disp([num2str(size(tmp,1),'%03d'),': ',infile(ind(end)+1:end)])
       ind = strfind(infile,'.');
       modInfo = [infile((ind(1)+1):ind(2)),infile((ind(3)+1):ind(4)-1)];
       %disp(modInfo)
       if contains(modInfo,'MIROC5')
           modelInfo{x} = 'NaN';
           continue
       else
           models1971(layer,x,:)    = (tmp-tmp(timeIndex))*conv; % Rescale to 1970==0; Rescale to convertor = Je22
           models(layer,x,:)        = (tmp-tmp(1))*conv; % Rescale to 1865==0; Rescale to convertor = Je22
           modelInfo{x} = modInfo;
           %disp(modInfo);
       end
    end
end
% Generate CDF for models
timeIndex1 = 134; % 1998 (1865:2025)
timeIndex2 = 153; % 2017 ; 151; % 2015 (1865:2025)
test1 = squeeze(nansum(models,1));
test2 = test1(:,timeIndex1);
ranges = range(test2);
%figure(1); clf
%plot(1865:2025,test1');
%line([1998 1998],[-40 100])
%line([1865 2025],[ranges(1) ranges(1)])
%line([1865 2025],[ranges(2) ranges(2)])
test2 = squeeze(nansum(models,1));
test2 = test2(:,1:timeIndex2); % Truncate to 2015
test2 = test2./repmat(squeeze(test2(:,end)),[1 size(test2,2)]);
test2 = test2(:,timeIndex1); % Extract 1998
disp(['Full suite: ',num2str(nanstd(test2),'%3.2f')])
disp(['ex ',modelInfo{10},' ',num2str(nanstd(test2([1:9,11:size(test2,1)])),'%3.2f')])
disp(['ex ',modelInfo{7},' ',num2str(nanstd(test2([1:6,8:size(test2,1)])),'%3.2f')])
test3 = squeeze(nansum(models,1));
test3 = test3(:,1:timeIndex2); % Truncate to 2015
test3 = test3./repmat(squeeze(test3(:,end)),[1 size(test3,2)]);
%figure(2); clf
% 2 models have strong negative value, removing from spread
%plot(1865:2015,test3([1:6,8:9,11:size(test3,1)],:)');
models1998CDFSpread = test3([1:6,8:9,11:size(test3,1)],timeIndex1); % Extract 1998
%range(models1998CDFSpread)
disp(['Truncated suite: ',num2str(nanstd(models1998CDFSpread),'%3.2f')])

% PJG - Obs data
%{
obs = NaN(4,72); % 1945 -> 2016
ind = 27; % 1971 1945:2016 [(1:72)',(1945:2016)']
infile = [pjgDir,'obs_gregory/dom_ohca.nc']; % 1950.5 start
obs(1,6:end-5) = getnc(infile,'ohc');
obs(1,:) = obs(1,:)-obs(1,ind);
infile = [pjgDir,'obs_gregory/ish_ohca.nc']; % 1945.5 start
obs(2,1:end-5) = getnc(infile,'ohc');
obs(2,:) = obs(2,:)-obs(2,ind);
infile = [pjgDir,'obs_gregory/lev_ohca.nc']; % 1955 start
obs(3,11:end-5) = getnc(infile,'ohc');
obs(3,:) = obs(3,:)-obs(3,ind);
infile = [pjgDir,'obs_levitus/lev_mid.nc']; % 1955 start - pentads
obs(4,13:end-6) = getnc(infile,'thetao');
obs(4,:) = obs(4,:)-obs(4,ind);
%}

%% 4 Construct time histories from models - no scaling
data_total      = data_upper+data_inter+data_lower;
data_mid        = data_inter+data_lower;
data_up_total   = data_upper+data_inter;

%% 5 Construct time histories from Argo and obs - no scaling
% Argo start in 2005
ind_iprc        = find(time_iprc(:,1)==2017);  % Starts in 200501, ends in 201806
data_iprc       = data_iprc_up(1:ind_iprc(end))+data_iprc_int(1:ind_iprc(end));
data_iprc_SN    = data_iprc_upSN(1:ind_iprc(end),:)+data_iprc_intSN(1:ind_iprc(end),:); % Hemis
ind_jam         = find(time_jam(:,1)==2005); % Starts in 200101
ind_jam2        = find(time_jam(:,1)==2017); % Ends in 201805
data_jam        = data_jam_up(ind_jam(1):ind_jam2(end))+data_jam_int(ind_jam(1):ind_jam2(end));
data_jam_SN     = data_jam_upSN(ind_jam(1):ind_jam2(end),:)+data_jam_intSN(ind_jam(1):ind_jam2(end),:); % Hemis
data_jam_up     = data_jam_up(ind_jam(1):ind_jam2(end));
data_jam_int    = data_jam_int(ind_jam(1):ind_jam2(end));
ind_ucsd        = find(time_ucsd(:,1)==2005); % Starts in 200401
ind_ucsd2       = find(time_ucsd(:,1)==2017); % Ends in 201806
data_ucsd       = data_ucsd_up(ind_ucsd(1):ind_ucsd2(end))+data_ucsd_int(ind_ucsd(1):ind_ucsd2(end));
data_ucsd_SN    = data_ucsd_upSN(ind_ucsd(1):ind_ucsd2(end),:)+data_ucsd_intSN(ind_ucsd(1):ind_ucsd2(end),:); % Hemis
data_ucsd_up    = data_ucsd_up(ind_ucsd(1):ind_ucsd2(end));
data_ucsd_int   = data_ucsd_int(ind_ucsd(1):ind_ucsd2(end));
ind_nodc        = find(time_nodc(:,1)==2005); % Starts in 1955, ends in 2017
data_nodc_an    = data_nodc_up(ind_nodc(1):end)+data_nodc_int(ind_nodc(1):end);
data_nodc_an_SN = data_nodc_upSN(ind_nodc(1):end,:)+data_nodc_intSN(ind_nodc(1):end,:); % Hemis
ind_en4         = find(time_en4(:,1)==2005); % Starts in 190001
ind_en42        = find(time_en4(:,1)==2017); % Ends in 201806
%stepKludge = 7; % Problem with 201408-on data - too low
%data_en4        = data_en4_up(ind_en4(1):ind_en42(stepKludge))+data_en4_int(ind_en4(1):ind_en42(stepKludge)); % Starts in 1900, ends in 201501
%data_en4        = [data_en4;NaN(12-stepKludge,1)];
data_en4        = data_en4_up(ind_en4(1):ind_en42(end))+data_en4_int(ind_en4(1):ind_en42(end));
data_en4_SN     = data_en4_upSN(ind_en4(1):ind_en42(end),:)+data_en4_intSN(ind_en4(1):ind_en42(end),:);
%ind_ish6        = find(time_ish6(:,1)==2005);  % Starts in 1955
%data_ish6       = data_ish6_up(ind_ish6(1):end)+data_ish6_int(ind_ish6(1):end);
% Start in 1960
%{
%(data_ish6_an_up_60-data_ish6_an_up_60(1))*conv
%ind_ish6            = find(time_ish6(:,1)==1960);
%data_ish6_up_60     = data_ish6_up(ind_ish6(1):end); % Starts in 1945
%data_ish6_int_60    = data_ish6_int(ind_ish6(1):end); % Starts in 1945
ind_nodc            = find(time_nodc(:,1)==1960);
data_nodc_an_up_60  = data_nodc_up(ind_nodc(1):end); % Starts in 1955
data_nodc_an_int_60 = data_nodc_int(ind_nodc(1):end); % Starts in 1955
ind_en4             = find(time_en4(:,1)==1960);
ind_en42            = find(time_en4(:,1)==2014); stepKludge = 7; % Problem with 201408-on data - too low
data_en4_up_60      = data_en4_up(ind_en4(1):ind_en42(end)); % Starts in 1900, ends in 201501
%data_en4_up_60      = [data_en4_up_60;NaN(12-stepKludge,1)];
data_en4_int_60     = data_en4_int(ind_en4(1):ind_en42(end)); % Starts in 1900, ends in 201501
%data_en4_int_60     = [data_en4_int_60;NaN(12-stepKludge,1)];
%}

% Convert monthly to annual
[data_iprc_an,data_jam_an,data_ucsd_an, ...
 data_iprc_an_up,data_jam_an_up,data_ucsd_an_up, ...
 data_iprc_an_int,data_jam_an_int,data_ucsd_an_int, ...
 data_ish6_an,data_en4_an, ...
 data_ish6_an_up_60,data_en4_an_up_60,data_ish6_an_int_60,data_en4_an_int_60] = deal(NaN(13,1));

[data_iprc_an_SN,data_jam_an_SN,data_ucsd_an_SN, ...
data_en4_an_SN] = deal(NaN(13,2)); % data_nodc_an_SN,
count = 1;
for x = 1:12:(size(data_iprc,1))
    data_iprc_an(count) = mean(data_iprc(x:x+11));
    data_iprc_an_up(count) = mean(data_iprc_up(x:x+11));
    data_iprc_an_int(count) = mean(data_iprc_int(x:x+11));
    data_iprc_an_SN(count,:) = mean(data_iprc_SN(x:x+11,:));
    count = count + 1;
end; clear x count
count = 1;
for x = 1:12:(size(data_jam,1))
    data_jam_an(count) = mean(data_jam(x:x+11));
    data_jam_an_up(count) = mean(data_jam_up(x:x+11));
    data_jam_an_int(count) = mean(data_jam_int(x:x+11));
    data_jam_an_SN(count,:) = mean(data_jam_SN(x:x+11,:));
    count = count + 1;
end; clear x count
count = 1;
for x = 1:12:(size(data_ucsd,1))
    data_ucsd_an(count) = mean(data_ucsd(x:x+11));
    data_ucsd_an_up(count) = mean(data_ucsd_up(x:x+11));
    data_ucsd_an_int(count) = mean(data_ucsd_int(x:x+11));
    data_ucsd_an_SN(count,:) = mean(data_ucsd_SN(x:x+11,:));
    count = count + 1;
end; clear x count
%count = 1;
%for x = 1:12:(size(data_ish6,1))
%    data_ish6_an(count) = mean(data_ish6(x:x+11));
%    count = count + 1;
%end; clear x count
% No need for NODC already annual data
count = 1;
for x = 1:12:(size(data_en4,1))
    data_en4_an(count) = nanmean(data_en4(x:x+11));
    data_en4_an_SN(count,:) = mean(data_en4_SN(x:x+11,:));
    count = count + 1;
end; clear x count
disp('Up/int process complete')

%% 6 Convert time histories to %
start_up = 134; end_up = 153; % Extend to 2017 %end_up = 151; % Reset from 1860-2025 -> 1860-2015 -> 1998-2015 (134:151)
data_total_pc       = data_total(1:end_up)/data_total(end_up);
data_mid_pc         = data_mid(1:end_up)/data_total(end_up);
data_lower_pc       = data_lower(1:end_up)/data_total(end_up);

% User 100% range - Inset numbers
data_up_total_pc    = (data_up_total(start_up:end_up)-data_up_total(start_up))/(data_up_total(end_up)-data_up_total(start_up));
data_up_mid_pc      = (data_inter(start_up:end_up)-data_inter(start_up))/(data_up_total(end_up)-data_up_total(start_up));
% Time truncation
time2               = time(1:end_up);
timelen             = timelen(1:end_up);
% Set Argo origins at 2005 MMM
% Calculate Solomonetal11 fudge factor to apply to data_up_total
time_scale = (2016-1998)*365.25*24*60*60;
factor1 = (ocean_total_area_m2*time_scale);
cm5MMM1998 = data_up_total(start_up)*rho*cp; % Convert to J
cm5MMM2015 = data_up_total(end_up)*rho*cp; % Convert to J
cm5Wm2 = ((cm5MMM2015-cm5MMM1998))/factor1;
%cm5MMMScale = ((cm5Wm2-.1)/cm5Wm2); % Solomon et al 2010 -0.1 Wm^2
cm5MMMScale = ((cm5Wm2-.19)/cm5Wm2); % Ridley et al 2014 -0.19+-0.09 Wm^2
ind2005 = 8; % 2005
% No truncation       IPRC data normalized by iprc(1) /
data_iprc_total_pc  = ((data_iprc_an-data_iprc_an(1))/(data_up_total(end_up)-data_up_total(start_up)))+(data_up_total_pc(ind2005)*cm5MMMScale);
data_jam_total_pc   = ((data_jam_an-data_jam_an(1))/(data_up_total(end_up)-data_up_total(start_up)))+(data_up_total_pc(ind2005)*cm5MMMScale);
data_ucsd_total_pc  = ((data_ucsd_an-data_ucsd_an(1))/(data_up_total(end_up)-data_up_total(start_up)))+(data_up_total_pc(ind2005)*cm5MMMScale);
data_ish6_total_pc  = ((data_ish6_an-data_ish6_an(1))/(data_up_total(end_up)-data_up_total(start_up)))+(data_up_total_pc(ind2005)*cm5MMMScale);
data_nodc_total_pc  = ((data_nodc_an-data_nodc_an(1))/(data_up_total(end_up)-data_up_total(start_up)))+(data_up_total_pc(ind2005)*cm5MMMScale);
data_en4_total_pc   = ((data_en4_an-data_en4_an(1))/(data_up_total(end_up)-data_up_total(start_up)))+(data_up_total_pc(ind2005)*cm5MMMScale);
% Load Lyman data
load([dataDir,'181030_JohnLyman_PMEL/PMEL_OHCA_0_1950.mat'],'hc_pmel'); fixUnits = .1;
% Generate scale factor
% ave temp -> J; ave temp x specific heat x density x depth
%                X        x 3850          x 1025    x 4000
scaler1 = 3850*1025; %*4000;
scaler2 = 1e22; % Keep units to Lyman 10^22 J
data_lyman_an = hc_pmel*fixUnits; clear hc_pmel % Scale 10^21 -> 10^22
data_lyman_an = data_lyman_an/scaler1*scaler2; % Convert 10^22 to actual units and correct for specific heat and density -> 10^16 is the result
data_lym_total_pc   = ((data_lyman_an-data_lyman_an(1))'/(data_up_total(end_up)-data_up_total(start_up)))+(data_up_total_pc(ind2005)*cm5MMMScale);

% Scale to model results - Inset numbers
ind1998 = find(time == 1998);
cm5MMM_lower_1998 = data_lower_pc(ind1998);
ind2015 = find(time == 2015);
cm5MMM_lower_2015 = data_lower_pc(ind2015);
% Construct file total
cm5MMM_upper_2015 = 1-cm5MMM_lower_2015;
cm5MMM_upper_1998 = 1-data_total_pc(ind1998);
cm5MMM_upper_range = cm5MMM_upper_2015-cm5MMM_upper_1998;
disp('Time history -> %, complete')
% Truncated
%{
data_iprc_total_pc  = ((data_iprc_an-data_iprc_an(1))/(data_up_total(end_up)-data_up_total(start_up)))+((data_up_total_pc(ind2005)*cm5MMM_upper_range)+cm5MMM_upper_1998);
data_jam_total_pc   = ((data_jam_an-data_jam_an(1))/(data_up_total(end_up)-data_up_total(start_up)))+((data_up_total_pc(ind2005)*cm5MMM_upper_range)+cm5MMM_upper_1998);
data_ucsd_total_pc  = ((data_ucsd_an-data_ucsd_an(1))/(data_up_total(end_up)-data_up_total(start_up)))+((data_up_total_pc(ind2005)*cm5MMM_upper_range)+cm5MMM_upper_1998);
% Create scales data (and add back in 0 offset)
data_up_total_pcTrunc   = (data_up_total_pc*cm5MMM_upper_range)+cm5MMM_upper_1998;
data_up_mid_pcTrunc     = (data_up_mid_pc*cm5MMM_upper_range)+cm5MMM_upper_1998;
% Generate scaled series
offset = (data_up_total_pcTrunc*scale)+(cm5MMM_upper_1998-(data_up_total_pcTrunc(1)*scale));
%offset = .6075;
%data_iprc_total_pcTrunc = (data_iprc_total_pc*cm5MMM_upper_range)+cm5MMM_upper_1998;
data_iprc_total_pcTrunc = (data_iprc_total_pc*cm5MMM_upper_range)+offset(1);
data_jam_total_pcTrunc  = (data_jam_total_pc*cm5MMM_upper_range)+offset(1);
data_ucsd_total_pcTrunc = (data_ucsd_total_pc*cm5MMM_upper_range)+offset(1);
%}

%% Figure 3.25 - Model-based CDF including all data sources updated to 2017
clc; close all
errorBar = 1;
close all, handle = figure('units','centimeters','visible','off','color','w','posi',[.5 1 30 10]); set(0,'CurrentFigure',handle); clmap(27)
font_labs = 11; font_ax_labs = 10; font_ax_labs2 = 7; font_panel_lab = 20; fonts_leg = 9; fonts_leg2 = 5;
fontW = 'normal';
linewid = 3; linewid2 = 1.25; linewid3 = 3;
markInset = 4;
one = subplot(1,4,1); hold all

plot(time(1:end_up),data_total_pc,'color',lt_blue); hold all
h1 = fill(time(timelen([1 1:end_up end_up])),[0 fliplr(data_total_pc)' 0],lt_blue); hold all
set(h1,'FaceColor',lt_blue,'EdgeColor','None')
plot(time(1:end_up),data_mid_pc,'color',mid_blue); hold all
h2 = fill(time(timelen([1 1:end_up end_up])),[0 fliplr(data_mid_pc)' 0],mid_blue); hold all
set(h2,'FaceColor',mid_blue,'EdgeColor','None')
plot(time(1:end_up),data_lower_pc,'color',dk_blue); hold all
h3 = fill(time(timelen([1 1:end_up end_up])),[0 fliplr(data_lower_pc)' 0],dk_blue); hold all
set(h3,'FaceColor',dk_blue,'EdgeColor','None')
zero    = line([1860 2040],[0 0],'color','k');
% Overplot all timeseries
plot(time(1:end_up),data_lower_pc,'color',dk_blue); hold all
plot(time(1:end_up),data_mid_pc,'color',mid_blue); hold all
plot(time(1:end_up),data_total_pc,'color',lt_blue); hold all
% Add error bar
if errorBar
    % Add 1std error estimate from model suite CDF - note this removes 2 of the 16 models
    %spread  = line([1998 1998],[.52-nanstd(models1998CDFSpread) .52+nanstd(models1998CDFSpread)],'color',dk_gray,'linewidth',linewid3);
    % PJG provided estimates
    xspread  = line([1999 1999],[.52-.2 .52+.2],'color',dk_gray,'linewidth',linewid3);
    yspread  = line([1999-8 1999+8],[.52 .52],'color',dk_gray,'linewidth',linewid3);
end
% Plot cross-hairs
fifty   = line([1860 2040],[.52 .52],'color','k'); % 51%
hiatus  = line([1999 1999],[-.1 1.05],'color','k'); % Should be 1999 - 2000 to provide link with inset
textH   = text(1986,.55,'51% @ 1999','fontsize',font_ax_labs2,'fontweight','bold','verticalalign','middle','horizontalalign','center');
ylab1   = ylabel('% of Global Ocean Heat Content Change');
xlab1   = xlabel('Year');
lab1    = text(2008,.98,'A','fontsize',font_panel_lab,'fontweight','bold','verticalalign','middle','horizontalalign','center');

% Create legend
hold all
xax1 = 1862:0.1:1870; xax2 = 1872; yax = [1.0225,-.075];
yax1 = yax(1);
plot(xax1,repmat(yax1,1,length(xax1)),'color',lt_blue,'linewidth',linewid)
text(xax2,yax1,'0-700 m','fontsize',fonts_leg,'color','k','fontweight',fontW,'horizontalalign','left','backgroundcolor','none');
yax1 = yax1+yax(2);
plot(xax1,repmat(yax1,1,length(xax1)),'color',mid_blue,'linewidth',linewid)
text(xax2,yax1,'700-2000 m','fontsize',fonts_leg,'color','k','fontweight',fontW,'horizontalalign','left','backgroundcolor','none');
yax1 = yax1+yax(2);
plot(xax1,repmat(yax1,1,length(xax1)),'color',dk_blue,'linewidth',linewid)
text(xax2,yax1,'2000 m-bottom','fontsize',fonts_leg,'color','k','fontweight',fontW,'horizontalalign','left','backgroundcolor','none');
yax1 = yax1+yax(2);
xax3 = 1864;
plot(xax3,yax1,'^','color','k','markeredgecol','k','markerfacecolor','k');
plot(xax3+5,yax1,'^','color',gray,'markeredgecol',gray,'markerfacecolor',gray);
text(xax2,yax1,'Simulated/unsimulated volcanic aerosols (VEI > 3)','fontsize',fonts_leg,'color','k','fontweight',fontW,'horizontalalign','left','backgroundcolor','none');
if errorBar
    yax1 = yax1+yax(2);
    plot(xax1,repmat(yax1,1,length(xax1)),'color',dk_gray,'linewidth',linewid3)
    text(xax2,yax1,'CMIP5 1 SD uncertainty (1999 origin)','fontsize',fonts_leg,'color','k','fontweight',fontW,'horizontalalign','left','backgroundcolor','none');
end

% Drop volcanoes - main canvas
for x = 2:length(volcs)
    % Determine decimal time
    %'Volcano Number','Volcano Name','VEI','Start Year','Start Month','Start Day','Latitude','Longitude','CMIPx included?'
    %'273083','Pinatubo',6,1991,4,2,15.13,120.35,1; %'Mount Pinatubo',1991,6,15,6;
    %offset = days365(datenum(volcs{x,2},1,1),datenum(volcs{x,2},volcs{x,3},volcs{x,4}))/365;
    offset = newDays365(datenum(volcs{x,4},1,1),datenum(volcs{x,4},volcs{x,5},volcs{x,6}))/365;
    if volcs{x,9} > 0
        markCol = 'k';
    else
        markCol = gray;
    end
    % Set VEI
    VEILim = 3;
    if volcs{x,3} > VEILim %5
        marker = 12; yoff = -.07;
    elseif volcs{x,3} > 4
        marker = 9; yoff = -.076;
    elseif volcs{x,3} > 3
        marker = 6; yoff = -.082;
    else
        marker = 5; yoff = -.08;
    end
    VEILim = 4; %4 and uncomment below
    if volcs{x,3} < VEILim
        continue % Don't plot VEI values less than 4
    elseif ( volcs{x,9} == 0 && volcs{x,4} < 2000 )
        continue % Miss out observed period, CMIP5 datasets
    else % Plot VEI=4+ after 2000
        plot(volcs{x,4}+offset,yoff,'^','color',markCol,'markeredgecol',markCol,'markerfacecolor',markCol,'markersize',marker)
    end
end
% And numeric identifier
for x = 2:length(volcs)
    % Determine decimal time
    offset = newDays365(datenum(volcs{x,4},1,1),datenum(volcs{x,4},volcs{x,5},volcs{x,6}))/365;
    if volcs{x,9} > 0
        text(volcs{x,4}+offset,-.0775,num2str(volcs{x,10}),'fontsi',5,'horizontalAlign','center','color','w','fontwei','bold');
    end
end

% Do subplot insert
% Generate scale factor
% ave temp -> J; ave temp x specific heat x density x depth
%                X        x 3850          x 1025    x 4000
scaler1 = 3850*1025; %*4000;

% start_up and end_up
start_up = 134; end_up = 153; % Extend to 2017 %end_up = 151; % Reset from 1860-2025 -> 1860-2015 -> 1998-2015 (134:151)
data_up_total_sub = data_up_total(start_up:end_up)*scaler1;
data_up_mid_sub = data_inter(start_up:end_up)*scaler1;

two = subplot(1,4,2); % White background for three axes
three = subplot(1,4,3); % White background for three axes
% Plot inset canvas
four = subplot(1,4,4); %grid on; hold all;

% Plot model 0-700 and 700-2000 - as J data
test = data_up_total_sub-data_up_total_sub(1);
plot(time(start_up:end_up),test,'color',lt_blue); hold all
h4 = fill(time(timelen([start_up start_up:end_up end_up])),[0 fliplr(test)' 0],lt_blue); hold all
set(h4,'FaceColor',lt_blue,'EdgeColor','None'); hold all
test = data_up_mid_sub-data_up_mid_sub(1);
plot(time(start_up:end_up),test,'color',mid_blue); hold all
h5 = fill(time(timelen([start_up start_up:end_up end_up])),[0 fliplr(test)' 0],mid_blue); hold all
set(h5,'FaceColor',mid_blue,'EdgeColor','None'); hold all

% Plot Solomonetal11 fudge factor
time_scale = (2017-1998)*365.25*24*60*60;
factor1 = (ocean_total_area_m2*time_scale);
cm5MMM1998 = data_up_total(start_up)*rho*cp; % Convert to J
cm5MMM2015 = data_up_total(end_up)*rho*cp; % Convert to J
cm5Wm2 = ((cm5MMM2015-cm5MMM1998))/factor1;
%scale = ((cm5Wm2-.1)/cm5Wm2); % Solomon et al 2010 -0.1 Wm^2
scale = ((cm5Wm2-.19)/cm5Wm2); % Ridley et al 2014 -0.19+-0.09 Wm^2

% Corrected J - units 10e16
test = (data_up_total_sub-data_up_total_sub(1))*scale; % offset for CMIP5 corrected timeseries
plot(time(start_up:end_up),test,'color','k','linesty','--','linewidth',linewid2); hold all
%plot(time(start_up:end_up),data_up_total_sub,'color','k','linesty','--','linewidth',linewid2); hold all % Sanity check, this should be the top value - it is!

% Plot Argo - J
test = data_up_total_sub-data_up_total_sub(1);
cm5AdjustedOffset = (test(8)*scale);
unitFudge = 1e5; unitFudge = scaler1;
test = ((data_iprc_an-data_iprc_an(1))*unitFudge)+cm5AdjustedOffset; % offset for CMIP5 corrected timeseries
plot(time(141:end_up),test,'color','r','linewidth',linewid2); hold all
test = ((data_jam_an-data_jam_an(1))*unitFudge)+cm5AdjustedOffset; % offset for CMIP5 corrected timeseries
plot(time(141:end_up),test,'color',orange,'linewidth',linewid2); hold all
test = ((data_ucsd_an-data_ucsd_an(1))*unitFudge)+cm5AdjustedOffset; % offset for CMIP5 corrected timeseries
plot(time(141:end_up),test,'color',dk_gray,'linewidth',linewid2); hold all
test = ((data_nodc_an-data_nodc_an(1))*unitFudge)+cm5AdjustedOffset; % offset for CMIP5 corrected timeseries
plot(time(141:end_up),test,'color',lt_gray,'linewidth',linewid2); hold all
test = ((data_en4_an-data_en4_an(1))*unitFudge)+cm5AdjustedOffset; % offset for CMIP5 corrected timeseries
plot(time(141:end_up),test,'color',br_green,'linewidth',linewid2); hold all
test = ((data_lyman_an-data_lyman_an(1))*scaler1)+cm5AdjustedOffset; % offset for CMIP5 corrected timeseries
plot(time(141:end_up),test,'color',mauve,'linewidth',linewid2); hold all

% Plot Argo truncated
%{
plot(time(141:end_up),data_iprc_total_pcTrunc(1:end-1)-.1015,'color','r','linewidth',linewid2); hold all
plot(time(141:end_up),data_jam_total_pcTrunc(1:end-1)-.1015,'color',orange,'linewidth',linewid2); hold all
plot(time(141:end_up),data_ucsd_total_pcTrunc(1:end-1)-.1015,'color',dk_gray,'linewidth',linewid2); hold all
%}
lab2 = text(2017.75,.1,'B','fontsize',font_panel_lab*.7,'fontweight','bold','verticalalign','middle','horizontalalign','center');

% Calculate trends for each
%{
linewid3 = 1; plotTrends = 0;
% CMIP5 trends
ind = ((1:length(time(start_up:end_up)))-1)';
xax = time(start_up:end_up);
p = polyfit(ind,data_up_total_pc*scale,1);
if plotTrends, plot(xax,p(2)+(1:length(xax)).*p(1),'color','k','linewidth',linewid3); hold all, end
disp(['CM5 MM:',num2str(p(1)*100,'%3.2f'),' %'])
% Obs trends
ind = ((1:length(data_iprc_total_pc))-1)';
xax = time(141:end_up);
p = polyfit(ind,data_iprc_total_pc,1);
if plotTrends, plot(xax,p(2)+(1:length(xax)).*p(1),'color','r','linewidth',linewid3); hold all, end
disp(['IPRC:  ',num2str(p(1)*100,'%3.2f'),' %'])
p = polyfit(ind,data_jam_total_pc,1);
if plotTrends, plot(xax,p(2)+(1:length(xax)).*p(1),'color',orange,'linewidth',linewid3); hold all, end
disp(['JAM :  ',num2str(p(1)*100,'%3.2f'),' %'])
p = polyfit(ind,data_ucsd_total_pc,1);
if plotTrends, plot(xax,p(2)+(1:length(xax)).*p(1),'color',dk_gray,'linewidth',linewid3); hold all, end
disp(['UCSD:  ',num2str(p(1)*100,'%3.2f'),' %'])
p = polyfit(ind,data_nodc_total_pc,1);
if plotTrends, plot(xax,p(2)+(1:length(xax)).*p(1),'color',lt_gray,'linewidth',linewid3); hold all, end
disp(['NODC:  ',num2str(p(1)*100,'%3.2f'),' %'])
p = polyfit(ind,data_en4_total_pc,1);
if plotTrends, plot(xax,p(2)+(1:length(xax)).*p(1),'color',br_green,'linewidth',linewid3); hold all, end
disp(['EN4 :  ',num2str(p(1)*100,'%3.2f'),' %'])
p = polyfit(ind,data_lym_total_pc,1);
if plotTrends, plot(xax,p(2)+(1:length(xax)).*p(1),'color',mauve,'linewidth',linewid3); hold all, end
disp(['LYM :  ',num2str(p(1)*100,'%3.2f'),' %'])
%}

% Drop volcanoes
yint = [-.06 -.03 -.005];
yint = -8e21;
%yint = [.44 .45 .46]; % Truncated
for x = 2:length(volcs)
    % Determine decimal time
    offset = newDays365(datenum(volcs{x,4},1,1),datenum(volcs{x,4},volcs{x,5},volcs{x,6}))/365;
    if volcs{x,9} > 0
        markCol = 'k';
    else
        markCol = gray;
    end
    if volcs{x,3} < 4
        continue
    else
        plot(volcs{x,4}+offset,yint(1),'^','color',markCol,'markeredgecol',markCol,'markerfacecolor',markCol,'markersize',markInset)
    end
end
% And numeric identifier
%{
for x = 2:length(volcs)
    % Determine decimal time
    offset = newDays365(datenum(volcs{x,4},1,1),datenum(volcs{x,4},volcs{x,5},volcs{x,6}))/365;
    if sum(ismember([13,21,27],x)) > 0
        text(volcs{x,4}+offset,yint(3),num2str(x-1),'fontsi',3,'horizontalAlign','center','color','k','backgroundcolor','w','margin',0.01,'fontwei','bold');
    elseif sum(ismember([22,28,32],x)) > 0
        text(volcs{x,4}+offset+.3,yint(2),num2str(x-1),'fontsi',3,'horizontalAlign','center','color','k','backgroundcolor','w','margin',0.01,'fontwei','bold');
    else
        text(volcs{x,4}+offset,yint(1),num2str(x-1),'fontsi',3,'horizontalAlign','center','color','k','fontwei','bold');
    end
end
%}

% Try second y-axis
ax4 = get(four);
ax4_pos = ax4.Position; % position of first axes
ax5 = axes('Position',ax4_pos,...
    'XAxisLocation','top',...
    'YAxisLocation','right',...
    'Color','none');

% Create legend
hold all
fontW = 'bold';
xax1 = 1998.25:0.05:1999; xax2 = 1999.2; yax = [1,-.1];
yax1 = yax(1);
plot(xax1(1):.25:xax1(end-7),repmat(yax1,1,length(xax1(1):.25:xax1(end-7))),'color','k','linewidth',linewid2) % Converted to two lines ,'linesty','-'
plot(xax1(12):.25:xax1(end)+.25,repmat(yax1,1,length(xax1(12):.25:xax1(end)+.25)),'color','k','linewidth',linewid2)
%text(xax2,yax1,'CMIP5 MMM Adjusted (-0.19 W m^-^2; Ridley et al., 2014)','fontsize',fonts_leg2,'color','k','fontweight',fontW,'horizontalalign','left','backgroundcolor','none');
text(xax2,yax1,'CMIP5 MMM Adjusted (-0.19 W m','fontsize',fonts_leg2,'color','k','fontweight',fontW,'horizontalalign','left','backgroundcolor','none');
text(xax2+8.5,yax1,'^-^2; Ridley et al., 2014)','fontsize',fonts_leg2,'color','k','fontweight',fontW,'horizontalalign','left','backgroundcolor','none');
yax1 = yax1+yax(2);
plot(xax1,repmat(yax1,1,length(xax1)),'color',orange,'linewidth',linewid2)
text(xax2,yax1,'JAMSTEC Argo (Hosoda et al., 2008)','fontsize',fonts_leg2,'color','k','fontweight',fontW,'horizontalalign','left','backgroundcolor','none');
yax1 = yax1+yax(2);
plot(xax1,repmat(yax1,1,length(xax1)),'color',dk_gray,'linewidth',linewid2)
text(xax2,yax1,'UCSD Argo (Roemmich & Gilson, 2009)','fontsize',fonts_leg2,'color','k','fontweight',fontW,'horizontalalign','left','backgroundcolor','none');
yax1 = yax1+yax(2);
plot(xax1,repmat(yax1,1,length(xax1)),'color',br_green,'linewidth',linewid2)
text(xax2,yax1,'EN4.2.1.g10 (Good et al., 2013)','fontsize',fonts_leg2,'color','k','fontweight',fontW,'horizontalalign','left','backgroundcolor','none');
yax1 = yax1+yax(2);
plot(xax1,repmat(yax1,1,length(xax1)),'color',mauve,'linewidth',linewid2)
text(xax2,yax1,'PMEL (Johnson et al., 2018)','fontsize',fonts_leg2,'color','k','fontweight',fontW,'horizontalalign','left','backgroundcolor','none');
yax1 = yax1+yax(2);
plot(xax1,repmat(yax1,1,length(xax1)),'color',lt_gray,'linewidth',linewid2)
text(xax2,yax1,'NODC (Levitus et al., 2012)','fontsize',fonts_leg2,'color','k','fontweight',fontW,'horizontalalign','left','backgroundcolor','none');
yax1 = yax1+yax(2);
plot(xax1,repmat(yax1,1,length(xax1)),'color','r','linewidth',linewid2)
text(xax2,yax1,'IPRC Argo','fontsize',fonts_leg2,'color','k','fontweight',fontW,'horizontalalign','left','backgroundcolor','none');
textZJ1  = text(1995,-.1,'10   J','fontsize',font_ax_labs2,'fontweight','bold','verticalalign','middle','horizontalalign','center');
textZJ2  = text(1995,-.1,'22','fontsize',font_ax_labs2,'fontweight','bold','verticalalign','middle','horizontalalign','center');

% Resize
set(handle,'Position',[.5 1 12 8]) % Full page width (175mm (17) width x 83mm (8) height) - Back to 16.5 x 6 for proportion
set(one,'Position',[.11 .13 .88 .845]);
set(one,'Tickdir','out','fontsize',font_ax_labs,'layer','bottom','box','on', ...
    'ylim',[-.1 1.05],'ytick',-.1:.1:1.05,'yticklabel',{'','0','','20','','40','','60','','80','','100',''},'yminort','on', ...
    'xlim',[1860 2020],'xtick',1860:10:2020,'xticklabel',{'1860','','1880','','1900','','1920','','1940','','1960','','1980','','2000','',''},'xminort','on')
set(two,  'Position',[.115 .31 .47 .38]); % Set box on and x/ycolor to black [0 0 0] to position
set(two,  'layer','top','box','off','visible','on','xcolor',[1 1 1],'ycolor',[1 1 1],'xtick',[],'xticklabel',{},'ytick',[],'yticklabel',{})
set(two,'visi','on'); % Make inset y-axis viewable
set(three,'Position',[.5 .38 .17 .31]); % Set box on and x/ycolor to black [0 0 0] to position
set(three,'layer','top','box','off','visible','on','xcolor',[1 1 1],'ycolor',[1 1 1],'xtick',[],'xticklabel',{},'ytick',[],'yticklabel',{})
set(three,'visi','off')
set(four,'Position',[.16 .36 .48 .34]);
axFourLab = {'','0','','5','','10','','15','','20','','25'};
set(four,'Tickdir','out','fontsize',font_ax_labs2,'layer','bottom','box','on', ...
   'ylim',[-15e21 25e22],'ytick',-25e21:25e21:25e22,'yticklabel',axFourLab,'yminort','on', ...
   'xlim',[1998 2018.5],'xtick',1998:1:2019,'xticklabel',{'','','2000','','','','','2005','','','','','2010','','','','','2015','','',''},'xminort','on')
set(ax5,'Position',four.Position);
% Fudge second y-axis
axFiveLab = {};
set(ax5,'fontsize',font_ax_labs2, ...
    'ylim',[-.1 1.05],'ytick',-.1:.025:1.05,'yticklabel',axFiveLab,'yminort','off','ticklength',[0 0], ...
    'xlim',[1998 2015.5],'xtick',[],'xticklabel',{''},'xminort','off');
set(ax5,'visi','off')

set(xlab1,'posi',[1940 -.2 1],'fontsize',font_labs,'HorizontalAlignment','center')
set(ylab1,'posi',[1846.5 .43 1],'fontsize',font_labs,'HorizontalAlignment','center')
set(ylab1,'posi',[1846.5 .5 1],'fontsize',font_labs,'HorizontalAlignment','center')
set(textZJ1,'posi',[1997.2,-.14],'layer','front','fontsi',6)
set(textZJ2,'posi',[1997.3,-.12],'layer','front','fontsi',4)
set(lab2,'posi',[2017.7 1e22 0]); % Set B location

export_fig([outDir,datestr(now,'yymmdd'),'_durack1_AR6WG1_Ch3_Fig3p25_',mipEraId,'ThetaoLayerWarming'],'-png')
export_fig([outDir,datestr(now,'yymmdd'),'_durack1_AR6WG1_Ch3_Fig3p25_',mipEraId,'ThetaoLayerWarming'],'-eps','-painters')

%% Figure 3 - Hemisphere warming from Argo - Durack et al 2018 - Check values
%{
clc; close all
fignum = '3';
close all, handle = figure('units','centimeters','visible','off','color','w','posi',[.5 1 20 10]); set(0,'CurrentFigure',handle); clmap(27)
font_labs = 11; font_ax_labs = 10; font_ax_labs2 = 7; font_panel_lab = 20; fonts_leg = 9; fonts_leg2 = 7;
linewid = 3; linewid2 = 1.25; linewid3 = 3;
mark = 7; markInset = 4;
one = subplot(1,1,1); hold all

% Generate scale factor
% ave temp -> J; ave temp x specific heat x density x depth
%                X        x 3850          x 1025    x 4000
scaler1 = 3850*1025; %*4000;
scaler2 = 1e22; % Keep units to Lyman 10^22 J

% Prepare data - anomalies
%data_en4SN(:,1) = (data_en4_an_SN(:,1)-data_en4_an_SN(1,1))/power(10,16);
data_en4SN(:,1) = (data_en4_an_SN(:,1)-data_en4_an_SN(1,1))*scaler1/scaler2;
data_en4SN(:,2) = (data_en4_an_SN(:,2)-data_en4_an_SN(1,2))*scaler1/scaler2;
data_iprcSN(:,1) = (data_iprc_an_SN(:,1)-data_iprc_an_SN(1,1))*scaler1/scaler2;
data_iprcSN(:,2) = (data_iprc_an_SN(:,2)-data_iprc_an_SN(1,2))*scaler1/scaler2;
data_jamSN(:,1) = (data_jam_an_SN(:,1)-data_jam_an_SN(1,1))*scaler1/scaler2;
data_jamSN(:,2) = (data_jam_an_SN(:,2)-data_jam_an_SN(1,2))*scaler1/scaler2;
data_nodcSN(:,1) = (data_nodc_an_SN(:,1)-data_nodc_an_SN(1,1))*scaler1/scaler2;
data_nodcSN(:,2) = (data_nodc_an_SN(:,2)-data_nodc_an_SN(1,2))*scaler1/scaler2;
data_ucsdSN(:,1) = (data_ucsd_an_SN(:,1)-data_ucsd_an_SN(1,1))*scaler1/scaler2;
data_ucsdSN(:,2) = (data_ucsd_an_SN(:,2)-data_ucsd_an_SN(1,2))*scaler1/scaler2;
% Load Lyman data
load('181030_JohnLyman_PMEL/PMEL_OHCA_0_1950.mat','hc_pmel_NH','hc_pmel_SH');
fixUnits = .1;
data_lymanSN_N = hc_pmel_NH*fixUnits; clear hc_pmel_NH % Scale 10^21 -> 10^22
data_lymanSN(:,2) = (data_lymanSN_N(:)-data_lymanSN_N(1)); clear data_lymanSN_N
data_lymanSN_S = hc_pmel_SH*fixUnits; clear hc_pmel_NH
data_lymanSN(:,1) = (data_lymanSN_S(:)-data_lymanSN_S(1)); clear data_lymanSN_S
% Now plot
xax = 2005.5:2017.5;
%plot(2005.5:2017,data_en4SN(:,1),'color',br_green,'linesty','-','linewidth',linewid2); hold all
plot(xax,data_en4SN(:,1),'color',br_green,'linesty','-','linewidth',linewid2); hold all
plot(xax,data_en4SN(:,2),'color',br_green,'linesty','--','linewidth',linewid2);
plot(xax,data_iprcSN(:,1),'color','r','linesty','-','linewidth',linewid2);
plot(xax,data_iprcSN(:,2),'color','r','linesty','--','linewidth',linewid2);
plot(xax,data_jamSN(:,1),'color',orange,'linesty','-','linewidth',linewid2);
plot(xax,data_jamSN(:,2),'color',orange,'linesty','--','linewidth',linewid2);
plot(xax,data_nodcSN(:,1),'color',lt_gray,'linesty','-','linewidth',linewid2);
plot(xax,data_nodcSN(:,2),'color',lt_gray,'linesty','--','linewidth',linewid2);
plot(xax,data_ucsdSN(:,1),'color',dk_gray,'linesty','-','linewidth',linewid2);
plot(xax,data_ucsdSN(:,2),'color',dk_gray,'linesty','--','linewidth',linewid2);
plot(xax,data_lymanSN(:,1),'color',mauve,'linesty','-','linewidth',linewid2);
plot(xax,data_lymanSN(:,2),'color',mauve,'linesty','--','linewidth',linewid2);

% Calculate trends for each
ind = ((1:length(xax))-1)';
linewid3 = 1; plotTrends = 0;
% SouthernHemiTrends
p = polyfit(ind,data_en4SN(:,1),1);
if plotTrends, plot(xax,p(2)+(1:length(xax)).*p(1),'color',br_green,'linewidth',linewid3); hold all, end
disp(['en4SH:   ',num2str(p(1)),' J^22 yr-1'])
p = polyfit(ind,data_iprcSN(:,1),1);
if plotTrends, plot(xax,p(2)+(1:length(xax)).*p(1),'color','r','linewidth',linewid3); hold all, end
disp(['iprcSH:  ',num2str(p(1)),' J^22 yr-1'])
p = polyfit(ind,data_jamSN(:,1),1);
if plotTrends, plot(xax,p(2)+(1:length(xax)).*p(1),'color',orange,'linewidth',linewid3); hold all, end
disp(['jamSH:   ',num2str(p(1)),' J^22 yr-1'])
p = polyfit(ind,data_nodcSN(:,1),1);
if plotTrends, plot(xax,p(2)+(1:length(xax)).*p(1),'color',lt_gray,'linewidth',linewid3); hold all, end
disp(['nodcSH:  ',num2str(p(1)),' J^22 yr-1'])
p = polyfit(ind,data_ucsdSN(:,1),1);
if plotTrends, plot(xax,p(2)+(1:length(xax)).*p(1),'color',dk_gray,'linewidth',linewid3); hold all, end
disp(['ucsdSH:  ',num2str(p(1)),' J^22 yr-1'])
p = polyfit(ind,data_lymanSN(:,1),1);
if plotTrends, plot(xax,p(2)+(1:length(xax)).*p(1),'color',mauve,'linewidth',linewid3); hold all, end
disp(['lymanSH: ',num2str(p(1)),' J^22 yr-1'])
% NorthernHemiTrends
p = polyfit(ind,data_en4SN(:,2),1);
if plotTrends, plot(xax,p(2)+(1:length(xax)).*p(1),'color',br_green,'linewidth',linewid3); hold all, end
disp('-----'); disp(['en4NH:   ',num2str(p(1)),' J^22 yr-1'])
p = polyfit(ind,data_iprcSN(:,2),1);
if plotTrends, plot(xax,p(2)+(1:length(xax)).*p(1),'color','r','linewidth',linewid3); hold all, end
disp(['iprcNH:  ',num2str(p(1)),' J^22 yr-1'])
p = polyfit(ind,data_jamSN(:,2),1);
if plotTrends, plot(xax,p(2)+(1:length(xax)).*p(1),'color',orange,'linewidth',linewid3); hold all, end
disp(['jamNH:   ',num2str(p(1)),' J^22 yr-1'])
p = polyfit(ind,data_nodcSN(:,2),1);
if plotTrends, plot(xax,p(2)+(1:length(xax)).*p(1),'color',lt_gray,'linewidth',linewid3); hold all, end
disp(['nodcNH:  ',num2str(p(1)),' J^22 yr-1'])
p = polyfit(ind,data_ucsdSN(:,2),1);
if plotTrends, plot(xax,p(2)+(1:length(xax)).*p(1),'color',dk_gray,'linewidth',linewid3); hold all, end
disp(['ucsdNH:  ',num2str(p(1)),' J^22 yr-1'])
p = polyfit(ind,data_lymanSN(:,2),1);
if plotTrends, plot(xax,p(2)+(1:length(xax)).*p(1),'color',mauve,'linewidth',linewid3); hold all, end
disp(['lymanNH: ',num2str(p(1)),' J^22 yr-1'])

line([2004,2018],[0 0],'color','k')
xlab1 = xlabel('Year');
ylab1 = ylabel({'Annual Heat Content Anomaly (10^{22} J)'}); % Was 10^16; Space is added if -painters is selected, use -opengl

% Create legend
hold all
fontW = 'bold';
xax1 = 2004.25:0.05:2004.75; xax2 = 2004.9; yax = [9.5,-.5];
yax1 = yax(1);
plot(xax1,repmat(yax1,1,length(xax1)),'color','r','linewidth',linewid2)
text(xax2,yax1,'IPRC Argo','fontsize',fonts_leg2,'color','k','fontweight',fontW,'horizontalalign','left','backgroundcolor','none');
yax1 = yax1+yax(2);
plot(xax1,repmat(yax1,1,length(xax1)),'color',orange,'linewidth',linewid2)
text(xax2,yax1,'JAMSTEC Argo (Hosoda et al., 2008)','fontsize',fonts_leg2,'color','k','fontweight',fontW,'horizontalalign','left','backgroundcolor','none');
yax1 = yax1+yax(2);
plot(xax1,repmat(yax1,1,length(xax1)),'color',dk_gray,'linewidth',linewid2)
text(xax2,yax1,'UCSD Argo (Roemmich & Gilson, 2009)','fontsize',fonts_leg2,'color','k','fontweight',fontW,'horizontalalign','left','backgroundcolor','none');
yax1 = yax1+yax(2);
plot(xax1,repmat(yax1,1,length(xax1)),'color',lt_gray,'linewidth',linewid2)
text(xax2,yax1,'NODC (Levitus et al., 2012)','fontsize',fonts_leg2,'color','k','fontweight',fontW,'horizontalalign','left','backgroundcolor','none');
yax1 = yax1+yax(2);
plot(xax1,repmat(yax1,1,length(xax1)),'color',br_green,'linewidth',linewid2)
text(xax2,yax1,'EN4.2.1.g10 (Good et al., 2013)','fontsize',fonts_leg2,'color','k','fontweight',fontW,'horizontalalign','left','backgroundcolor','none');
yax1 = yax1+yax(2);
plot(xax1,repmat(yax1,1,length(xax1)),'color',mauve,'linewidth',linewid2)
text(xax2,yax1,'PMEL (Johnson et al., 2018)','fontsize',fonts_leg2,'color','k','fontweight',fontW,'horizontalalign','left','backgroundcolor','none');
%yax1 = yax1+yax(2);
%plot(xax1,yax1,'color',mauve,'linewidth',linewid2)
%text(xax2,yax1,'Ishii v6.13 (Ishii & Kimoto, 2009)','fontsize',fonts_leg2,'color','k','fontweight',fontW,'horizontalalign','left','backgroundcolor','none');
% Identifiers
text(2016.775,9.2,{'Southern','Hemisphere','(Complete lines)'},'fontsize',fonts_leg2,'color','k','fontweight',fontW,'horizontalalign','center','backgroundcolor','none');
text(2016.9,.9,{'Northern','Hemisphere','(Dashed lines)'},'fontsize',fonts_leg2,'color','k','fontweight',fontW,'horizontalalign','center','backgroundcolor','none');

% Resize
set(handle,'Position',[.5 1 14 9]) % Full page width (175mm (17) width x 83mm (8) height) - Back to 16.5 x 6 for proportion
set(one,'Position',[.12 .1 .85 .83]);
set(one,'Tickdir','out','fontsize',font_ax_labs,'layer','bottom','box','on', ...
    'ylim',[-2.5 10],'ytick',-2.5:2.5:10,'yticklabel',{'-2.5','0','2.5','5.0','7.5','10.0'},'yminort','on', ...
    'xlim',[2004 2018],'xtick',2004:1:2018,'xticklabel',{'2004','','2006','','2008','','2010','','2012','','2014','','2016','','2018'},'xminort','on')

set(xlab1,'posi',[2011 -3.4 1],'fontsize',font_labs,'HorizontalAlignment','center')
set(ylab1,'posi',[2002.75 3.75 1],'fontsize',font_labs,'HorizontalAlignment','center')

export_fig([out_dir,datestr(now,'yymmdd'),'_Fig',fignum],'-eps','-painters') ; % -opengl used to get around ylab1 superscript bug, inflates file size 56Kb -> 753Kb (mac)
%}
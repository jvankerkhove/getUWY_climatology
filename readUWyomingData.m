function [Data,SondeIndices] = readUWyomingData(filename,getSondeIndices)

%filename = '/Users/Jef/Documents/MATLAB/Data/Store/NWSsondes/Stuttgart/1976061200NWS10739.txt';
%filename = '/Users/Jef/Documents/MATLAB/Data/Store/NWSsondes/Stuttgart/1976061800NWS10739.txt';

%Header Stuff
buffer = fileread( filename) ;
dashline='-------------------------------------------------------------------------------------------';
dashlinel = length(dashline);
headerend = strfind(buffer,dashline);
headerend = headerend(end)+dashlinel;

%Remove header
buffer = buffer(headerend:end);

%find end of data
dataend = strfind(buffer,'</PRE><H3>');
dataend = dataend(1);

%Get soundings indices
if getSondeIndices
%Sounding indices strings    
SHOWs = 'Showalter index: ';
LIFTs = 'Lifted index: ';
LFTVs = 'LIFT computed using virtual temperature: ';
SWETs = 'SWEAT index: ';
KINXs = 'K index: ';
CTOTs = 'Cross totals index: ';
VTOTs = 'Vertical totals index: ';
TTOTs = 'Totals totals index: ';
CAPEs = 'Convective Available Potential Energy: ';
CAPVs = 'CAPE using virtual temperature: ';
CINSs = 'Convective Inhibition: ';
CINVs = 'CINS using virtual temperature: ';
EQLVs = 'Equilibrum Level: ';
EQTVs = 'Equilibrum Level using virtual temperature: ';
LFCTs = 'Level of Free Convection: ';
LFCVs = 'LFCT using virtual temperature: ';
BRCHs = 'Bulk Richardson Number: ';
BRCVs = 'Bulk Richardson Number using CAPV: ';
LCLTs = 'Temp [K] of the Lifted Condensation Level: ';
LCLPs = 'Pres [hPa] of the Lifted Condensation Level: ';
MLTHs = 'Mean mixed layer potential temperature: ';
MLMRs = 'Mean mixed layer mixing ratio: ';
THTKs = '1000 hPa to 500 hPa thickness: ';
PWATs = 'Precipitable water [mm] for entire sounding: ';
%length of strings
SHOWl = length(SHOWs);
LIFTl = length(LIFTs);
LFTVl = length(LFTVs);
SWETl = length(SWETs);
KINXl = length(KINXs);
CTOTl = length(CTOTs);
VTOTl = length(VTOTs);
TTOTl = length(TTOTs);
CAPEl = length(CAPEs);
CAPVl = length(CAPVs);
CINSl = length(CINSs);
CINVl = length(CINVs);
EQLVl = length(EQLVs);
EQTVl = length(EQTVs);
LFCTl = length(LFCTs);
LFCVl = length(LFCVs);
BRCHl = length(BRCHs);
BRCVl = length(BRCVs);
LCLTl = length(LCLTs);
LCLPl = length(LCLPs);
MLTHl = length(MLTHs);
MLMRl = length(MLMRs);
THTKl = length(THTKs);
PWATl = length(PWATs);
%Indices in buffer 
SHOWi = strfind(buffer,SHOWs);
LIFTi = strfind(buffer,LIFTs);
LFTVi = strfind(buffer,LFTVs);
SWETi = strfind(buffer,SWETs);
KINXi = strfind(buffer,KINXs);
CTOTi = strfind(buffer,CTOTs);
VTOTi = strfind(buffer,VTOTs);
TTOTi = strfind(buffer,TTOTs);
CAPEi = strfind(buffer,CAPEs);
CAPVi = strfind(buffer,CAPVs);
CINSi = strfind(buffer,CINSs);
CINVi = strfind(buffer,CINVs);
EQLVi = strfind(buffer,EQLVs);
EQTVi = strfind(buffer,EQTVs);
LFCTi = strfind(buffer,LFCTs);
LFCVi = strfind(buffer,LFCVs);
BRCHi = strfind(buffer,BRCHs);
BRCVi = strfind(buffer,BRCVs);
LCLTi = strfind(buffer,LCLTs);
LCLPi = strfind(buffer,LCLPs);
MLTHi = strfind(buffer,MLTHs);
MLMRi = strfind(buffer,MLMRs);
THTKi = strfind(buffer,THTKs);
PWATi = strfind(buffer,PWATs);
% Index where name ends (and values begin)
SHOWN = SHOWi+SHOWl;
LIFTN = LIFTi+LIFTl;
LFTVN = LFTVi+LFTVl;
SWETN = SWETi+SWETl;
KINXN = KINXi+KINXl;
CTOTN = CTOTi+CTOTl;
VTOTN = VTOTi+VTOTl;
TTOTN = TTOTi+TTOTl;
CAPEN = CAPEi+CAPEl;
CAPVN = CAPVi+CAPVl;
CINSN = CINSi+CINSl;
CINVN = CINVi+CINVl;
EQLVN = EQLVi + EQLVl;
EQTVN = EQTVi + EQTVl;
LFCTN = LFCTi + LFCTl;
LFCVN = LFCVi + LFCVl;
BRCHN = BRCHi+BRCHl;
BRCVN = BRCVi+BRCVl;
LCLTN = LCLTi+LCLTl;
LCLPN = LCLPi+LCLPl;
MLTHN = MLTHi+MLTHl;
MLMRN = MLMRi+MLMRl;
THTKN = THTKi+THTKl;
PWATN = PWATi+PWATl;
% Convert characters to numbers
SHOW = str2double(buffer(SHOWN: SHOWN+6));
LIFT = str2double(buffer(LIFTN: LIFTN+6));
LFTV = str2double(buffer(LFTVN: LFTVN+6));
SWET = str2double(buffer(SWETN: SWETN+6));
KINX = str2double(buffer(KINXN: KINXN+6));
CTOT = str2double(buffer(CTOTN: CTOTN+6));
VTOT = str2double(buffer(VTOTN: VTOTN+6));
TTOT = str2double(buffer(TTOTN: TTOTN+6));
CAPE = str2double(buffer(CAPEN: CAPEN+6));
CAPV = str2double(buffer(CAPVN: CAPVN+6));
CINS = str2double(buffer(CINSN: CINSN+6));
CINV = str2double(buffer(CINVN: CINVN+6));
EQLV = str2double(buffer(EQLVN: EQLVN+6));
EQTV = str2double(buffer(EQTVN: EQTVN+6));
LFCT = str2double(buffer(LFCTN: LFCTN+6));
LFCV = str2double(buffer(LFCVN: LFCVN+6));
BRCH = str2double(buffer(BRCHN: BRCHN+6));
BRCV = str2double(buffer(BRCVN: BRCVN+6));
LCLT = str2double(buffer(LCLTN: LCLTN+6));
LCLP = str2double(buffer(LCLPN: LCLPN+6));
MLTH = str2double(buffer(MLTHN: MLTHN+6));
MLMR = str2double(buffer(MLMRN: MLMRN+6));
THTK = str2double(buffer(THTKN: THTKN+6));
PWAT = str2double(buffer(PWATN: PWATN+5));%since last value
if isnan(PWAT)
    PWAT = str2double(buffer(PWATN: PWATN+4));
end

%Put sonde indices in a structure
si.SHOW = SHOW;
si.SHOW_name = SHOWs(1:end-2);
si.LIFT = LIFT;
si.LIFT_name = LIFTs(1:end-2);
si.LFTV = LFTV;
si.LFTV_name = LFTVs(1:end-2);
si.SWET = SWET;
si.SWET_name = SWETs(1:end-2);
si.KINX = KINX;
si.KINX_name = KINXs(1:end-2);
si.CTOT = CTOT;
si.CTOT_name = CTOTs(1:end-2);
si.VTOT = VTOT;
si.VTOT_name = VTOTs(1:end-2);
si.TTOT = TTOT;
si.TTOT_name = TTOTs(1:end-2);
si.CAPE = CAPE;
si.CAPE_name = strcat(CAPEs(1:end-2),' (J/kg)');
si.CAPV = CAPV;
si.CAPV_name = CAPVs(1:end-2);
si.CINS = CINS;
si.CINS_name = strcat(CINSs(1:end-2),' (J/kg)');
si.CINV = CINV;
si.CINV_name = CINVs(1:end-2);
si.EQLV = EQLV;
si.EQLV_name = strcat(EQLVs(1:end-2), ' (hPa)');
si.EQTV = EQTV;
si.EQTV_name = EQTVs(1:end-2);
si.LFCT = LFCT;
si.LFCT_name = strcat(LFCTs(1:end-2), ' (hPa)');
si.LFCV = LFCV;
si.LFCV_name = LFCVs(1:end-2);
si.BRCH = BRCH;
si.BRCH_name = BRCHs(1:end-2);
si.BRCV = BRCV;
si.BRCV_name = BRCVs(1:end-2);
si.LCLT = LCLT;
si.LCLT_name = LCLTs(1:end-2);
si.LCLP = LCLP;
si.LCLP_name = LCLPs(1:end-2);
si.MLTH = MLTH;
si.MLTH_name = strcat(MLTHs(1:end-2),' (K)');
si.MLMR = MLMR;
si.MLMR_name = strcat(MLMRs(1:end-2),' (g/kg)');
si.THTK = THTK;
si.THTK_name = strcat(THTKs(1:end-2),' (m)');
si.PWAT = PWAT;
si.PWAT_name = PWATs(1:end-2);
SondeIndices = si;

%clearvars -except buffer SondeIndices dataend 
else
SondeIndices = [];
end


%Remove non-data
buffer = buffer(1:dataend-1);

%With just data left
buffer = regexprep( buffer, ' {7}', '   NaN' ) ;
dataArray   = reshape( sscanf( buffer, '%f' ), 13, [] )' ;

%Arrange Data into structure
Data.PRES = dataArray(:,1);
Data.PRES_name = 'Atmospheric Pressure (hPa)';
Data.HGHT = dataArray(:,2);
Data.HGHT_name = 'Geopotential Height (m)';
Data.TEMP = dataArray(:,3);
Data.TEMP_name = 'Temperature (degC)';
Data.DWPT = dataArray(:,4);
Data.DWPT_name = 'Dewpoint Temperature (degC)';
Data.FRPT = dataArray(:,5);
Data.FRPT_name = 'Frost point Temperature (degC)';
Data.RELH = dataArray(:,6);
Data.RELH_name = 'Relative Humidity (%)';
Data.RELI = dataArray(:,7);
Data.RELI_name = 'Relative Humidity with respect to ice (%)';
Data.MIXR = dataArray(:,8);
Data.MIXR_name = 'Mixing Ratio (g/kg)';
Data.DRCT = dataArray(:,9);
Data.DRCT_name = 'Wind Direction (degrees true)';
Data.SKNT = dataArray(:,10);
Data.SKNT_name = 'Wind Speed (knot)';
Data.THTA = dataArray(:,11);
Data.THTA_name = 'Potential Temperature (K)';
Data.THTE = dataArray(:,12);
Data.THTE_name = 'Equivalent Potential Temperature (K)';
Data.THTV = dataArray(:,13);
Data.THTV_name = 'Virtual Potential Temperature (K)';









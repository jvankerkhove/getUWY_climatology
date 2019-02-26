%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% getUWY_climatology.m
%
% Get climatological radiosonde data from University of Wyoming web-based database
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [UWY] = getUWY_climatology()

%inputs
in = getUWY_inputs;
station_name = in.station_name;
dayTime = in.dayTime;
month = in.month;
startYr = in.startYr;
stopYr  = in.stopYr;
ClimOption = in.ClimOption;
RS_file_store_dir = in.RS_file_store_dir;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Empty structure
UWY = struct();
UWY.data = struct();
UWY.clim = struct();


%U Wyoming site info
UWYsite_dir = which('UWYsites.csv');
UWYsiteInfo = importdata(UWYsite_dir);
station_nameCell = UWYsiteInfo.textdata;
station_nameCell(1,:) = [];%remove header
station_nameCell(:,2:6) = [];
siteIDsfi = strfind(station_nameCell,station_name);%find station
siteIDi = find(not(cellfun('isempty', siteIDsfi)));   
siteID = UWYsiteInfo.data(siteIDi,1);%Grab site info
z0 = UWYsiteInfo.data(siteIDi,4);
lat = UWYsiteInfo.data(siteIDi,2);
lon = UWYsiteInfo.data(siteIDi,3);
regionID = UWYsiteInfo.data(siteIDi,5);

%Altitude and pressure grid arrays 
z = [z0:100:25000]'; 

%Choose region
switch regionID
    case 1
        region = 'naconf';
    case 2
        region = 'samer';
    case 3
        region = 'pac';
    case 4
        region = 'nz';
    case 5
        region = 'ant';
    case 6
        region = 'np';
    case 7
        region = 'europe';
    case 8
        region = 'africa';
    case 9
        region = 'seasia';       
    case 10
        region = 'midest';
end    

%Hour info
if strcmp(dayTime,'day')
    dayTime = '12';
elseif strcmp(dayTime,'night')
    dayTime = '00';
end

%Number of days for the given month
if month==2
    monthdays = 28;
elseif month==3 || month==4 || month==6 || month==9 || month==11
    monthdays = 30;
else
    monthdays = 31;
end    

%Month info
if month<10
    month = strcat('0',num2str(month));
else    
    month = num2str(month);
end    

%Array of years
yearAr = startYr:stopYr;

%Empty output arrays 
Parr = zeros(length(z),monthdays+2);
Tarr = zeros(length(z),monthdays+2);
RHarr = zeros(length(z),monthdays+2);
MRarr = zeros(length(z),monthdays+2);

%Save file name
if ~exist(RS_file_store_dir)
    mkdir(RS_file_store_dir);
    addpath(genpath(RS_file_store_dir));
end    
UWYsavefile_name = strcat('Clim_',station_name,'_',dayTime,'_',month,'_',num2str(startYr),'_',num2str(stopYr),'.mat'); 
UWYsaveroot_name = strcat(RS_file_store_dir,filesep,'UWYsondes',filesep,station_name,filesep);
UWYsavedir_name  = strcat(UWYsaveroot_name,UWYsavefile_name);

%Find if file already exists
UWYsavefile_search = strcat(UWYsaveroot_name,UWYsavefile_name(1:end-13),'*');        
UWYdir = dir(UWYsavefile_search);
if ~isempty(UWYdir) 
    name1 = str2num(UWYdir.name(end-12:end-9));
    name2 = str2num(UWYdir.name(end-7:end-4));
    UWYfileexist = (name1<=startYr && name2>=stopYr);

else 
    UWYfileexist = 0;
end   

%If file exists, load it up
if UWYfileexist
    UWYsavedir_open = strcat(UWYsaveroot_name,UWYdir.name);
    UWY = load(UWYsavedir_open);
    UWY = UWY.UWY;
else    
%If file doesn't exist, make directory
if ~exist(UWYsaveroot_name)
    mkdir(UWYsaveroot_name);
end    
%iterate for each year in range
for n=1:length(yearAr)%year
    year = num2str(yearAr(n));
    disp(year);
    UWY.data(n).year = str2num(year);

    %UWY{1,n}.year = year;
    %UWY.data(n).P = 
    %day in the month 
    UWY.data(n).P = Parr;
    UWY.data(n).T = Tarr;
    UWY.data(n).RH = RHarr;
    UWY.data(n).MR = MRarr;

    %Iterate for each day in the given month
    for m=1:monthdays
        days = 1:monthdays;
        dateval = days(m);
        %Day string must have 2 characters
        if dateval<10
            dateval = strcat('0',num2str(dateval));
        else
            dateval = num2str(dateval);
        end
        datehour = strcat(dateval,dayTime);

        %output file name
        store_filename = strcat(year,month,datehour,'UWY',num2str(siteID),'.txt');
        UWYstore_dir = strcat(RS_file_store_dir,filesep,'UWYsondes',filesep,station_name,filesep,store_filename);

        %URL string for weather.uwyo.edu
        sondestring = strcat('http://weather.uwyo.edu/cgi-bin/sounding?region=',...
        region,'&TYPE=TEXT%3ALIST&YEAR=',year,'&MONTH=',month,...
        '&FROM=',datehour,'&TO=',datehour,'&STNM=',num2str(siteID),'&ICE=1');

        %If file doesn't already exist, grab it from the U Wyoming sounding database
        if ~exist(UWYstore_dir,'file')
            try 
                websave(UWYstore_dir,sondestring);
            catch
                warning('Service Unavilable for weather.uwyo.edu - try 1 (Day %d)',m);
                try
                    websave(UWYstore_dir,sondestring);
                catch
                    warning('Service Unavilable for weather.uwyo.edu - try 2 (Day %d)',m);
                end    
            end    
        end


        %Check what's in the file
        try
            busy_file = importdata(UWYstore_dir);
            classval  = class(busy_file);
            busy_char = fileread(UWYstore_dir);
        catch
            busy_file = [];   
        end
        if isempty(busy_file)
            warning('No busy file found! (Day %d)',m);
            zs = z;
            P = NaN(length(zs),1);
            Tk = NaN(length(zs),1);
            RH = NaN(length(zs),1);
            MR = NaN(length(zs),1);
            allNaNs = 1;
        elseif strcmp(busy_file,'Sorry, the server is too busy to process your request.')
            warning('No data found in the busy file (Day %d)',m); 
            zs = z;
            P = NaN(length(zs),1);
            Tk = NaN(length(zs),1);
            RH = NaN(length(zs),1);
            MR = NaN(length(zs),1);
            allNaNs = 1;
        %elseif strfind(busy_char,'Can''t get')
        elseif contains(busy_char,'Can''t get')
            warning('Can''t get Data for (Day %d)!',m); 
            zs = z;
            P = NaN(length(zs),1);
            Tk = NaN(length(zs),1);
            RH = NaN(length(zs),1);
            MR = NaN(length(zs),1);               
            allNaNs = 1;
        elseif strcmp(classval,'cell')
            warning('No data in file for (Day %d)!',m); 
            zs = z;
            P = NaN(length(zs),1);
            Tk = NaN(length(zs),1);
            RH = NaN(length(zs),1);
            MR = NaN(length(zs),1);               
            allNaNs = 1;                
        else
            %Read data from text file
            [rfData,rfSondeIndices] = readUWyomingData(UWYstore_dir,0);
            zs = rfData.HGHT;
            P  = rfData.PRES;
            Tk = rfData.TEMP + 273.16;
            RH = rfData.RELH;
            MR = rfData.MIXR;
            allNaNs = 0;            
        end

        %Remove altitudes below station elevation
        zslow = find(zs<z0);
        zs(zslow) = [];
        P(zslow) = [];
        Tk(zslow) = [];
        RH(zslow) = [];
        MR(zslow) = [];

        %Remove NaNs from altitude array
        zNaNi = find(isnan(zs));
        zs(zNaNi) = [];
        P(zNaNi) = [];
        Tk(zNaNi) = [];
        RH(zNaNi) = [];
        MR(zNaNi) = [];

        %Remove repeated heights
        [zs,zsi] = unique(zs);
        P = P(zsi);
        Tk = Tk(zsi);
        RH = RH(zsi);
        MR = MR(zsi);


        %Don't use it too few entries in the array
        if (length(P(~isnan(P))) < 3) && ~allNaNs
            warning('Only %d entries for Pressure (Day %d)',length(P(~isnan(P))),m); 
            %zs = z;
            P = NaN(length(z),1);  
        elseif (length(P(~isnan(P))) >= 3)
            %Interpolate onto z grid 
            P = interp1(zs,P,z);           
        end
        if (length(Tk(~isnan(Tk))) < 3) && ~allNaNs
            warning('Only %d entries for Temperature (Day %d)',length(Tk(~isnan(Tk))),m); 
            %zs = z;
            Tk = NaN(length(z),1); 
        elseif (length(Tk(~isnan(Tk))) >= 3)
            %Interpolate onto z grid 
            Tk = interp1(zs,Tk,z);           
        end      
        if (length(RH(~isnan(RH))) < 3) && ~allNaNs
            warning('Only %d entries for Relative Humidity (Day %d)',length(RH(~isnan(RH))),m); 
            %zs = z;
            RH = NaN(length(z),1); 
        elseif (length(RH(~isnan(RH))) >= 3)
            %Interpolate onto z grid 
            RH = interp1(zs,RH,z);           
        end 
        if (length(MR(~isnan(MR))) < 3) && ~allNaNs
            warning('Only %d entries for Mixing Ratio (Day %d)',length(MR(~isnan(MR))),m); 
            %zs = z;
            MR = NaN(length(z),1); 
        elseif (length(MR(~isnan(MR))) >= 3)
            %Interpolate onto z grid 
            MR = interp1(zs,MR,z);           
        end 

        %Collecting data into UWY structure
        UWY.data(n).date = days;
        UWY.data(n).P(:,m) = P;
        UWY.data(n).T(:,m) = Tk;
        UWY.data(n).RH(:,m) = RH;
        UWY.data(n).MR(:,m) = MR;

        %Append monthly mean and std to last 2 columns of arrays
        if m==monthdays
        UWY.data(n).P(:,m+1) = nanmean( UWY.data(n).P(:,1:m),2);
        UWY.data(n).T(:,m+1) = nanmean( UWY.data(n).T(:,1:m),2);
        UWY.data(n).RH(:,m+1) = nanmean( UWY.data(n).RH(:,1:m),2);
        UWY.data(n).MR(:,m+1) = nanmean( UWY.data(n).MR(:,1:m),2);
        UWY.data(n).P(:,m+2) = nanstd( UWY.data(n).P(:,1:m),2);
        UWY.data(n).T(:,m+2) = nanstd( UWY.data(n).T(:,1:m),2);
        UWY.data(n).RH(:,m+2) = nanstd( UWY.data(n).RH(:,1:m),2);
        UWY.data(n).MR(:,m+2) = nanstd( UWY.data(n).MR(:,1:m),2);
        end          

    end    
end



%Put monthly means/std into clim structure
UWY.clim.Tm = zeros(length(z),length(yearAr));
UWY.clim.Ts = zeros(length(z),length(yearAr));
UWY.clim.RHm = zeros(length(z),length(yearAr));
UWY.clim.RHs = zeros(length(z),length(yearAr));
UWY.clim.MRm = zeros(length(z),length(yearAr));
UWY.clim.MRs = zeros(length(z),length(yearAr));
UWY.clim.z = z;
UWY.clim.years = yearAr;
for x=1:length(yearAr)
    UWY.clim.Pm(:,x)  = UWY.data(x).P(:,end-1);
    UWY.clim.Ps(:,x)  = UWY.data(x).P(:,end);    
    UWY.clim.Tm(:,x)  = UWY.data(x).T(:,end-1);
    UWY.clim.Ts(:,x)  = UWY.data(x).T(:,end);
    UWY.clim.RHm(:,x) = UWY.data(x).RH(:,end-1);
    UWY.clim.RHs(:,x) = UWY.data(x).RH(:,end);
    UWY.clim.MRm(:,x) = UWY.data(x).MR(:,end-1);
    UWY.clim.MRs(:,x) = UWY.data(x).MR(:,end);
end

%save as mat file
save(UWYsavedir_name,'UWY');

end


%Only use dates in given range
if ~isequal(UWY.clim.years,yearAr)
    UWY = rmfield(UWY,'clim');
    UWY.clim.z = z;
    UWY.clim.years = yearAr;
    %See where dates are the same
    for y=1:length(UWY.data)
        findyeari = find(UWY.data(y).year==yearAr);
        if isempty(findyeari)
            findyear(y) = 0;
        else
            findyear(y) = 1;
        end    
    end
    %Only keep same years
    findyearAr = 1:length(findyear);
    findyearAr(findyear==0) =[];
    
    for x=1:length(findyearAr)
        UWY.clim.Pm(:,x)  = UWY.data(findyearAr(x)).P(:,end-1);
        UWY.clim.Ps(:,x)  = UWY.data(findyearAr(x)).P(:,end);    
        UWY.clim.Tm(:,x)  = UWY.data(findyearAr(x)).T(:,end-1);
        UWY.clim.Ts(:,x)  = UWY.data(findyearAr(x)).T(:,end);
        UWY.clim.RHm(:,x) = UWY.data(findyearAr(x)).RH(:,end-1);
        UWY.clim.RHs(:,x) = UWY.data(findyearAr(x)).RH(:,end);
        UWY.clim.MRm(:,x) = UWY.data(findyearAr(x)).MR(:,end-1);
        UWY.clim.MRs(:,x) = UWY.data(findyearAr(x)).MR(:,end);
    end
end    
    
%Choose clim option
switch ClimOption
    case 'monthlyALL'
        %Interpolate so input and UWY grids are the same
        if ~isequaln(z,UWY.clim.z)
           climMR = interp1(UWY.clim.z,UWY.clim.MRm,z);  
           climRH = interp1(UWY.clim.z,UWY.clim.RHm,z);
           climP  = interp1(UWY.clim.z,UWY.clim.Pm,z);
           climT  = interp1(UWY.clim.z,UWY.clim.Tm,z);
        else
            climMR = UWY.clim.MRm;
            climRH = UWY.clim.RHm;
            climT  = UWY.clim.Tm;
            climP  = UWY.clim.Pm;
        end  
    case '1month'
        %Interpolate so input and UWY grids are the same
        if ~isequaln(z,UWY.clim.z)
           climMR = interp1(UWY.clim.z,UWY.data(end).MR(:,1:end-2),z);  
           climRH = interp1(UWY.clim.z,UWY.data(end).RH(:,1:end-2),z);
           climP  = interp1(UWY.clim.z,UWY.data(end).P(:,1:end-2),z);
           climT  = interp1(UWY.clim.z,UWY.data(end).T(:,1:end-2),z);
        else
            climMR = UWY.data(end).MR(:,1:end-2);
            climRH = UWY.data(end).RH(:,1:end-2);
            climT  = UWY.data(end).T(:,1:end-2);
            climP  = UWY.data(end).P(:,1:end-2);
        end          
end






end

  




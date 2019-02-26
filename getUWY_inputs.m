function [in] = getUWY_inputs

%inputs
%Station name 
station_name = 'Stuttgart';%'Stuttgart';% 'LIML';
%Observation Time ('day' or 'night')
dayTime = 'night';
%Month to look at (numerical)
month = 6;
%Year to start at
startYr = 2017;%2018;%1995;
%Year to end at
stopYr = 2018;
ClimOption = 'monthlyALL';%'monthlyALL';%'1month';
%Where you want Radiosonde data files stored
RS_file_store_dir = '/Users/Jef/Documents/MATLAB/For_gitHub/RS_Data';




in = struct;
in.station_name = station_name;
in.dayTime = dayTime;
in.month = month;
in.startYr = startYr;
in.stopYr  = stopYr;
in.ClimOption = ClimOption;
in.RS_file_store_dir = RS_file_store_dir;

end
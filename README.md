# getUWY_climatology

getUWY_climatology retrieves Radiosonde measurements of pressure, temperature, relative
humidity, and mixing ratio available on the University of Wyoming Sounding database.

Files needed are:
getUWY_climatology.m
getUWY_inputs.m
readUWyomingData.m
UWYsites.csv

INPUT
Input parameters are entered into the getUWY_inputs function.

OUTPUT
The output structure for getUWY_climatology is UWY. It contains:
UWY.data - all daily data, separated by year for each atmospheric state.
UWY.clim - Pm/Tm/RHm/MRm are the means of the monthly values per year. Ps/Ts/RHs/MRs are the standard deviations.

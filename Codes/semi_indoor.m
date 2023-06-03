% 'semi_indoor_trajectory' MATLAB file plots the trajectory of RTK-GPS and  VINS in Google Map for visualization purposes.
% 
% This MATLAB file uses MATLAB funtion 'zoharby/plot_google​_map' which plots a google map on the current axes using the Google Static Maps API
% USAGE:plot_google_map('APIKey','%%%%SyCo89vOhcxOkACfpXS0T-%%%%%%%%%%%%');Add
% your APIKey for google map here.
% 
% This MATLAB file uses MATLAB funtion 'utm2deg' for converting UTM
% coordinates to Latitude & Longitude
% 
% Acknowledgments:
% Zohar Bar-Yehuda, Author of 'zoharby/plot_google​_map'
% Rafael Palacios, Author of 'utm2deg'
% 
% Authors:
% Team D-FAST, Northeastern University, Boston, MA

% Input
% Provide path to your bag files before running MATLAB CODE in line 6 and line 7. For example,
% 'semi_indoor_vins'  bag contains data for VINS trajectory and
% 'semi_indoor'  bag contains data for RTK GPS trajectory
bag1 = rosbag ('C:\Users\aruns\OneDrive\Desktop\RSN\final_project\semi_indoor_vins.bag');
bag2 = rosbag ('C:\Users\aruns\OneDrive\Desktop\RSN\final_project\semi_indoor.bag');

% Extracting required information for analysis from bag files
bsel1 = select(bag1,'Topic','/FrameTrajectory_TUM_Format');
bsel2 = select(bag2,'Topic','/ublox_driver/receiver_pvt');
bsel3 = select(bag2,'Topic','/ublox_driver/receiver_lla');
msgStructs1 = readMessages(bsel1,'DataFormat','struct');
msgStructs2 = readMessages(bsel2,'DataFormat','struct');
msgStructs3 = readMessages(bsel3,'DataFormat','struct');
orb_x = cellfun(@(m) double(m.Pose.Position.X), msgStructs1);
orb_y = cellfun(@(m) double(m.Pose.Position.Y), msgStructs1);
orb_z = cellfun(@(m) double(m.Pose.Position.Z), msgStructs1);
vins_x = orb_x(1:length(orb_x));
vins_y = orb_y(1:length(orb_y));
vins_z = orb_z(1:length(orb_z));
orb_timePoints_sec = cellfun(@(m) double(m.Header.Stamp.Sec),msgStructs1);
orb_timePoints_nanosec = cellfun(@(m) double(m.Header.Stamp.Nsec),msgStructs1);
orb_timePoints = double(orb_timePoints_sec + ( orb_timePoints_nanosec * 10^(-9)));
vins_timePoints = orb_timePoints(1:length(orb_timePoints));
lat_a = cellfun(@(m) double(m.Latitude), msgStructs3);
lon_a = cellfun(@(m) double(m.Longitude), msgStructs3);
lat = lat_a(575:length(lat_a)); % eliminate few initial points from RTK GPS since the bag recording for VINS
% was started few seconds later
lon = lon_a(575:length(lon_a));
gps_timePoints_sec = cellfun(@(m) double(m.Header.Stamp.Sec),msgStructs3);
gps_timePoints_nanosec = cellfun(@(m) double(m.Header.Stamp.Nsec),msgStructs3);
gps_timePoints_a = double(gps_timePoints_sec + ( gps_timePoints_nanosec * 10^(-9)));
gps_timePoints = gps_timePoints_a(575:length(gps_timePoints_a));

% convert latitude and longitude to UTM co-ordinates using inbuilt MATLAB
% function
p1 = [lat,lon];
z1 = utmzone(p1);
[ellipsoid,estr] = utmgeoid(z1);
utmstruct = defaultm('utm');
utmstruct.zone = z1;
utmstruct.geoid = ellipsoid;
utmstruct = defaultm(utmstruct);
[gps_x,gps_y] = mfwdtran(utmstruct,lat,lon);

% Pre-processing to correct alignment of VINS trajectory before plotting since it is being represented in a local frame
VINS_slope = (vins_z(100) - vins_z(1)) /(vins_x(100) - vins_x(1)) ;
GPS_slope = (gps_y(100) - gps_y(1)) /(gps_x(100) - gps_x(1)) ;
GPS_inc = atan(GPS_slope) ;
VINS_inc = atan(VINS_slope);
theta_head = GPS_inc - VINS_inc;
R_head = [cos(theta_head) -sin(theta_head); sin(theta_head) cos(theta_head)];
R_x_e = (R_head * [vins_x,vins_z]')';
figure;
plot(-(R_x_e(:,1) - R_x_e(1,1)), -(R_x_e(:,2) - R_x_e(1,2)),'DisplayName','Aligned-VINS-trajectory');
hold on;
plot(gps_x - gps_x(1),gps_y - gps_y(1),'DisplayName','GPS-trajectory');
axis equal;
xlabel('X(m)');
ylabel('Y(m)');
title('Trajectory');
legend

% converting local trajectory to UTM coordinates
vins_delta_x = (-(R_x_e(:,1) - R_x_e(1,1)));
vins_delta_y = (-(R_x_e(:,2) - R_x_e(1,2)));
vins_easting = vins_delta_x + gps_x(1);
vins_northing = vins_delta_y + gps_y(1);
vins_zone = repmat('19 T',length (vins_easting),1);
[Lat,Lon] = utm2deg(vins_easting,vins_northing,vins_zone);
Lat = Lat - (Lat(1) - lat (1));

% plotting in Google MAPS
figure;
plot(lon,lat,'Color','b','LineWidth',1.5);
hold on;
plot(Lon,Lat,'Color','r','LineWidth',1.5);
% Add your APIKey for google map here.
plot_google_map('APIKey','%%%%SyCo89vOhcxOkACfpXS0T-%%%%%%%%%%%%');
xlabel('Longitude(deg)');
ylabel('Latitude(deg)');







   



















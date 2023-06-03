% 'complex_environment_trajectory' MATLAB file plots the trajectory of RTK-GPS and  VINS in Google Map for visualization purposes.
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
% 'complex_environment_gvins'  bag contains data for GVINS trajectory and
% 'complex_environment_gps'  bag contains data for RTK GPS trajectory

bag1 = rosbag ('C:\Users\aruns\OneDrive\Desktop\RSN\final_project\complex_environment_gps.bag');
bag2 = rosbag ('C:\Users\aruns\OneDrive\Desktop\RSN\final_project\complex_environment_gvins.bag');

% Extracting required information for analysis from bag files
bsel1 = select(bag1,'Topic','/gps');
msgStructs1 = readMessages(bsel1,'DataFormat','struct');
lat = cellfun(@(m) double(m.Latitude), msgStructs1);
lon = cellfun(@(m) double(m.Longitude), msgStructs1);
EastPoints_a = cellfun(@(m) double(m.UTMEasting), msgStructs1);
NorthPoints_b = cellfun(@(m) double(m.UTMNorthing), msgStructs1);
EastPoints = EastPoints_a(87:length(EastPoints_a)); % eliminate few initial points from RTK GPS since the bag recording for VINS
% was started few seconds later
NorthPoints = NorthPoints_b(87:length(NorthPoints_b));
AltPoints = cellfun(@(m) double(m.Altitude),msgStructs1);
timePoints_sec = cellfun(@(m) double(m.Header.Stamp.Sec),msgStructs1);
timePoints_nanosec = cellfun(@(m) double(m.Header.Stamp.Nsec),msgStructs1);
timePoints = double(timePoints_sec + ( timePoints_nanosec * 10^(-9)));
bsel3 = select(bag2,'Topic','/gnss_traj');
msgStructs3 = readMessages(bsel3,'DataFormat','struct');
gnss_x = cellfun(@(m) double(m.Pose.Position.X), msgStructs3);
gnss_y = cellfun(@(m) double(m.Pose.Position.Y), msgStructs3);

% convert latitude and longitude to UTM co-ordinates using inbuilt MATLAB
% function
p1 = [lat(87:length(lat)),lon(87:length(lon))];
z1 = utmzone(p1);
[ellipsoid,estr] = utmgeoid(z1); % delete row 2 of ellipsoid manually before execution of codes from next line.
utmstruct = defaultm('utm');
utmstruct.zone = z1;
utmstruct.geoid = ellipsoid;
utmstruct = defaultm(utmstruct);
[gps_x,gps_y] = mfwdtran(utmstruct,lat,lon);


% Pre-processing to correct alignment of VINS trajectory before plotting since it is being represented in a local frame
theta_head = -0.0191986;
R_head = [cos(theta_head) -sin(theta_head); sin(theta_head) cos(theta_head)];
R_x_e = (R_head * [gnss_x,gnss_y]')';
figure;
plot(R_x_e(:,1), R_x_e(:,2),'DisplayName','Aligned-GVINS-trajectory');
hold on;
plot(EastPoints,NorthPoints,'DisplayName','GPS-trajectory');
axis equal;
xlabel('X(m)');
ylabel('Y(m)');
title('Trajectory');
legend

% converting local trajectory to UTM coordinates
gvins_delta_x = R_x_e(:,1);
gvins_delta_y = R_x_e(:,2);
gvins_easting = gvins_delta_x + gps_x(1);
gvins_northing = gvins_delta_y + gps_y(1);
gvins_zone = repmat('50 Q',length (gvins_easting),1);
[Lat,Lon] = utm2deg(gvins_easting,gvins_northing,gvins_zone);
Lat = Lat - (Lat(1) - lat (87));

% plotting in Google MAPS
figure;
plot(lon(87:18200),lat(87:18200),'Color','b','LineWidth',1.5);
hold on;
plot(Lon,Lat,'Color','r','LineWidth',1.5);
plot_google_map('APIKey','%%%%SyCo89vOhcxOkACfpXS0T-%%%%%%%%%%%%');% Add your APIKey for google map here.
xlabel('Longitude(deg)')
ylabel('Latitude(deg)')

# Final-Project



## State Estimation: Investigating the Issues During Indoor-Outdoor Transitions 

 **Team D-FAST**: Damla Leblebicioglu, Francis Jacob Kalliath, Arun Madhusudhanan, Shankara Narayanan Vaidyanathan, Tejaswini Dilip Deore

[Project Report](report.pdf)

## Rosbag links

| name | link | 
| :--: |:--: |
| open_outdoor.bag | [OneDrive](https://northeastern-my.sharepoint.com/:u:/g/personal/vaidyanathan_sh_northeastern_edu/Efrl4id25cFDiHSyVB6ihKcB-bfJY0ZBGCrS8GzD4BQfdA?e=yJyCPb) |
| urban_outdoor.bag | [OneDrive](https://northeastern-my.sharepoint.com/:u:/g/personal/vaidyanathan_sh_northeastern_edu/EaOPDkP7WVtMmcOhK9DRKkgB91QAfJzZWEkuyJv9Qx_fWA?e=VpIiZg) |
| semi_indoor.bag | [OneDrive](https://northeastern-my.sharepoint.com/:u:/g/personal/vaidyanathan_sh_northeastern_edu/ETzn91pYvCRBvSpGH23LRJUBkxd3kxa8uYPVD0yNv36kFw?e=EaTtUA) |
| complex_environment dataset  | [HKUST-OneDrive](https://hkustconnect-my.sharepoint.com/:u:/g/personal/scaoad_connect_ust_hk/EalZKULm8QFPqNZlf53C31QBmcQ1KUsWnOQ6N2rIefNBYA?e=QUbvHe) |

## Code Details

The MATLAB files in Codes/ folder can be used to plot the trajectory of RTK-GPS and VINS in Google Map for visualization purposes. These files use a MATLAB function 'zoharby/plot_google​_map' to plot on google maps using the Google Static Maps API. You have to generate your own API key to use these for your analysis. 

The Python files can be used to convert nav_msgs/Path messages given my GVINS to geometry_msgs/PoseStamped Messages to perforn pose error analysis on the [evo](https://github.com/MichaelGrupp/evo) package. 

## Dataset analysis
[GVINS](https://github.com/HKUST-Aerial-Robotics/GVINS) was used to perform global state estimation on the complex bag dataset. 

Follow the build instructions mentioned in the GVINS repo to run it on the complex_environment dataset. 

## To work on your own Hardware setup 
ORB SLAM 3 was used to analyze Visual-Inertial Navigation Systems. 

Use the ORB-SLAM3 [repo](https://github.com/UZ-SLAMLab/ORB_SLAM3) and follow the instructions to run on your setup. 

**To use RTK-GPS**: 

Configure your GNSS receiver to output raw measurement and convert them as ros messages. Use the [ublox_driver](https://github.com/HKUST-Aerial-Robotics/ublox_driver) package. 

To configure your device:

Use UART1 to send ```UBX-RXM-RAWX```, ```UBX-RXM-SFRBX``` and ```UBX-PVT``` message via USB-UART module to your laptop, and send RTCM3 message to UART2 via USB-UART module to F9P. So - ```UBX``` in ```Protocol out``` of UART1 is needed, and ```RTCM3``` in ```Protocol in``` of UART2 is needed.

Message rate in ```Configure-RATE``` may also be set to 10Hz.

## Acknowledgement

We thank the authors of GVINS, ORB-SLAM3, NTRIP-ROS, ublox_driver for their excellent packages!



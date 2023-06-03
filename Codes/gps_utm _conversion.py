'''
The Python code below converts GPS co-ordinates from sensor_msgs/NavSatFix to UTM co-ordinates

'''

import rospy
#from std_msgs.msg import String
from sensor_msgs.msg import NavSatFix
from geometry_msgs.msg import PoseStamped
import utm

#Convert latitude and longitude to utm easting and northing
def gps_conversion(data):

    lat = data.latitude
    long = data.longitude
    altitude = data.altitude
    utm_data = utm.from_latlon(lat, long)
    return utm_data[0], utm_data[1], altitude

def callback_1(data):
    global pub, count, gps_x_init, gps_z_init, gps_y_init

    msg = PoseStamped()
    msg.header = data.header

    gps_x, gps_y, gps_z = gps_conversion(data)

    print(count)
    if count == 0:
        gps_x_init = gps_x
        gps_y_init = gps_y
        gps_z_init = gps_z
        count = count  + 1

    #Normalizing utm co-ordinates
    msg.pose.position.x = gps_x - gps_x_init
    msg.pose.position.y = gps_y - gps_y_init
    msg.pose.position.z = gps_z - gps_z_init
    msg.pose.orientation.w = 1
    #print("Entered callback")
    
    #Publish to the topic /gps_traj
    pub.publish(msg)
    if count < 3:
        count = count + 1

def listener():
    global pub
    global count
    count = 0
    #Define node name
    rospy.init_node('gps_utm')
    print("Initialized node")

    #Declare topic to publish
    pub = rospy.Publisher('/gps_traj', PoseStamped, queue_size=10)
    
    #Declare the topic being subscribed
    rospy.Subscriber('/ublox_driver/receiver_lla', NavSatFix, callback_1)
    
    rate = rospy.Rate(10)

    try:
        while not rospy.is_shutdown():

            rate.sleep()
    except rospy.ROSInterruptException:
        pass

if __name__ == '__main__':
    
    listener()
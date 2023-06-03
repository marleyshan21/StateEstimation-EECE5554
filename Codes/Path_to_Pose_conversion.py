'''
The python code below converts nav_msgs/Path Messages to geometry_msgs/PoseStamped Messages

'''

import rospy
#from std_msgs.msg import String
from nav_msgs.msg import Path
from geometry_msgs.msg import PoseStamped

def callback_1(data):
    global pub1
    msg = PoseStamped()
    #Get last obtained Pose
    msg = data.poses[-1]
    #Publish to the topic /gnss_traj
    pub1.publish(msg)

def callback_2(data):
    global pub2
    msg = PoseStamped()
    #Get last obtained Pose
    msg = data.poses[-1]
    #Publish to the topic /gvins_traj
    pub2.publish(msg)

def listener():
    global pub1, pub2

    #Define node name
    rospy.init_node('path_to_odom')
    print("Initialized node")

    #Declare topic(s) to publish
    pub1 = rospy.Publisher('/gnss_traj', PoseStamped, queue_size=10)
    pub2 = rospy.Publisher('/gvins_traj', PoseStamped, queue_size=10)

    #Declare the topic(s) being subscribed
    rospy.Subscriber('/gvins/gnss_enu_path', Path, callback_1)
    rospy.Subscriber('/gvins/path', Path, callback_2)
    
    rate = rospy.Rate(10) #freq 10Hz 

    try:
        while not rospy.is_shutdown():

            rate.sleep()
    except rospy.ROSInterruptException:
        pass

if __name__ == '__main__':
    
    listener()
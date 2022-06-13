Class SAMDemo.PythonMetric Extends %SYS.Monitor.SAM.Abstract
{

Parameter PRODUCT = "SAMDemo";

Method GetSensors() As %Status [ Language = python ]
{
#import random
#self.SetSensor("pythoncounter",random.randint(5,20))
#return 1

import psutil
self.SetSensor("batterypercent",psutil.sensors_battery().percent)

if (psutil.sensors_battery().power_plugged==True):
	self.SetSensor("batterysecsleft",-1) 
else:
	self.SetSensor("batteryminutesleft",psutil.sensors_battery().secsleft//60)
}

}
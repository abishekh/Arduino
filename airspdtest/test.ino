# include "Airspeed.h"
#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_BMP085.h>


Adafruit_BMP085 bmp = Adafruit_BMP085(10085);
Airspeed aspd = Airspeed();
int airspeedVolts;
float sensorValue = 0.00;
void setup(){


Serial.begin(115200);

 
 
 if(!bmp.begin())
  {
    /* There was a problem detecting the BMP085 ... check your connections */
    Serial.print("NO BMP085 detected !");
    while(1);
  }
  else if (bmp.begin())
  {
    Serial.println("BMP check ...[OK] ");
  }


}

void loop()
{
  delay(1000);
sensors_event_t event;
bmp.getEvent(&event);
if (event.pressure){
  float BMPpressure = event.pressure;
  float BMPtemp;
  float Ipresssure;
  bmp.getTemperature(&BMPtemp);
 float speedK = 0.00;
 sensorValue = analogRead(0);
 Serial.print(" Raw:");
 Serial.print(sensorValue); 
 speedK=aspd.get_speed(sensorValue,BMPpressure,BMPtemp);
 
 Serial.print(" Speed:");
 Serial.print(speedK);
 Serial.println("");

}

  
  






}




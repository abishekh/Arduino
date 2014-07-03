#include <Math.h>
#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_BMP085.h>
#include <Adafruit_GPS.h>
#include <SoftwareSerial.h>

#define R 287.06

Adafruit_BMP085 bmp = Adafruit_BMP085(10085);

void setup()
{
  Serial.begin(115200);
  
      
      delay(1000);
  
   if(!bmp.begin())
  {
    /* There was a problem detecting the BMP085 ... check your connections */
    Serial.print("Ooops, no BMP085 detected ... Check your wiring or I2C ADDR!");
    while(1);
  }
}

void loop()
{
  
  float temperature=0.00;
  float Ktemperature=0.00;
  float staticpressureinPascals=0.00;
  int pValue = analogRead(0);
  int tempp=0;
  float tempval= 0.00;
 sensors_event_t event;
  bmp.getEvent(&event);
  
   if (event.pressure)
  {
    
    staticpressureinPascals = event.pressure *100;
    bmp.getTemperature(&temperature);
    Ktemperature=temperature+273.15;
  }
  double density = staticpressureinPascals/(R * Ktemperature);
 
for (int i=0;i<=7;i++)
{
tempp=tempp+pValue;

}
float fullscale=tempp/8;
  double voltavg = fullscale*(5.0/1024);
  double pressure = (voltavg/5- 0.5)/0.2;
  double airspeed= sqrt(2*(pressure*1000)/density);
  double airspeedInFts = airspeed*3.28084;

 Serial.print("| V: ");
 Serial.print(voltavg);
 Serial.print("| PD: ");
 Serial.print(pressure);
 Serial.print(" Pa \t");
 Serial.print(" | Aspd: ");
 Serial.print(airspeed);
 Serial.print(" m/s |");
 Serial.print("\n");
     
  
 
 
 delay(1000); 
}


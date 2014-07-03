//
// Test for Airspeed Sensor
// D.M.K.K. Venkateswara Rao

#include <FastSerial.h>
#include <AP_Common.h>
#include <Wire.h>	    // Arduino I2C lib
#include <AP_ADC.h>         // ArduPilot Mega Analog to Digital Converter Library
#include <AP_Math.h>        // ArduPilot Mega Vector/Matrix math Library

FastSerialPort0(Serial);

AP_ADC_ADS7844  adc;

float time;
float ref_pressure, air_pressure, pressure_diff;
float airspeed_ratio = 1.5191;
float airspeed;
int AIRSPEED_CH = 7;

void setup()
{
    int i;
    
    adc.Init();
    Serial.begin(38400);
    delay(1000);
    
    Serial.println("Initializing...");
    
    ref_pressure = adc.Ch(AIRSPEED_CH);
    
    for (i=1;i<=200;i++)
    {
      ref_pressure = (adc.Ch(AIRSPEED_CH))*0.25 + ref_pressure*0.75;
      
      delay(20);
    }
}

void loop()
{    
    if ((millis() - time) >= 20)
    {
      time = millis();
      
      air_pressure = adc.Ch(AIRSPEED_CH)*0.25 + air_pressure*0.75;
      
      if (air_pressure >= ref_pressure)
      {
        pressure_diff = air_pressure - ref_pressure;
      }
      else
      {
        pressure_diff = 0.0;
      }
      
      airspeed = sqrt(pressure_diff*airspeed_ratio);
      
      Serial.print("air speed: ");
      Serial.print(airspeed);
      Serial.println(" m/s");
    }
}

# include "airspeed.h"

int sensorValue;

void setup(){
  sensorValue = 0;
sensorValue = analogRead(0);
Serial.begin(115200);
Serial.println("Airspeed ");

}

void loop()
{
delay(100);
float airspeed = get_speed(sensorValue);


Serial.println(airspeed);


}




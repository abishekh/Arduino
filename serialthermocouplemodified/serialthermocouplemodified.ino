/*************************************************** 
  This is an example for the Adafruit Thermocouple Sensor w/MAX31855K

  Designed specifically to work with the Adafruit Thermocouple Sensor
  ----> https://www.adafruit.com/products/269

  These displays use SPI to communicate, 3 pins are required to  
  interface
  Adafruit invests time and resources providing this open source code, 
  please support Adafruit and open-source hardware by purchasing 
  products from Adafruit!

  Written by Limor Fried/Ladyada for Adafruit Industries.  
  BSD license, all text above must be included in any redistribution
 ****************************************************/

#include "Adafruit_MAX31855.h"




int thermoDO = 2;
int thermo1CS = 3;
int thermo2CS = 5;
int thermo3CS = 6;
int thermoCLK = 4;

Adafruit_MAX31855 thermocouple1(thermoCLK, thermo1CS, thermoDO);
Adafruit_MAX31855 thermocouple2(thermoCLK, thermo2CS, thermoDO);
Adafruit_MAX31855 thermocouple3(thermoCLK, thermo3CS, thermoDO);


void setup() {
  Serial.begin(115200);
  
 // Serial.println("MAX31855 test");
  Serial.println("USC ADT Flight recorder");
  
  // wait for MAX chip to stabilize
  delay(500);



}

void loop() {
  // basic readout test, just print the current temp
   //Serial.print("Internal Temp = ");
   //Serial.println(thermocouple.readInternal());

   double c1 = thermocouple1.readCelsius();
   double c2 = thermocouple2.readCelsius();
   double c3 = thermocouple3.readCelsius();
   if (isnan(c1)) {
     Serial.println("Something wrong with thermocouple 1!");
   } 
   if (isnan(c2)) {
     Serial.println("Something wrong with thermocouple 2!");
   }
   if (isnan(c3)) {
     Serial.println("Something wrong with thermocouple 3!");
   }else {
     Serial.print(" C1 = "); 
  
     Serial.print(c1);
     Serial.print("\t");
     Serial.print(" C2 = "); 
     Serial.print(c2);
     Serial.print("\t");
     Serial.print(" C3 = "); 
     Serial.print(c3);
     
   }
   //Serial.print("F = ");
   //Serial.println(thermocouple.readFarenheit());
 
 
   delay(1000);
}

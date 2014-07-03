/* vi:set wm=0 ai sm tabstop=4 shiftwidth=4: */
/* BMP085 Extended Example Code
  by: Jim Lindblom
  SparkFun Electronics
  date: 1/18/11
  license: CC BY-SA v3.0 - http://creativecommons.org/licenses/by-sa/3.0/
  
  Get pressure and temperature from the BMP085 and calculate altitude.
  Serial.print it out at 9600 baud to serial monitor.
*/

void get_altitude()
{
	float pres_pa;
	float f_alt;
	float f_temp;
	float koll_pa = system_vars.kollsman_value;

	// pressure is in Pa, temp is in C
	get_pressure(pres_pa, f_temp);
	disp_vars.static_pressure = pres_pa * .001; // kPa
	// returns altitude in meters
	// pass in pressure and SLP in Pa
	f_alt = (float)44330 * (1 - pow(((float) pres_pa/koll_pa), 0.190295));
	if (system_vars.units == us)
	{
		f_alt *= M_TO_FT_MULT;
		f_temp = (f_temp * 1.8) + 32;
	}
	disp_vars.altitude = (int)f_alt;
	disp_vars.temp = (int)f_temp;
}

/*
* void get_altitude()
* {
	* disp_vars.altitude++;
* }
*/

void get_pressure(float & pressure, float & temperature)
{
	static int hist_index = 0;
	int temp;
	int i;
	int j;
	float pres;
	float pres_accu;
	float f_temperature;
	float pressure_pa;

	// order is important -- find temp first, then pressure
	temp = bmp085GetTemperature(bmp085ReadUT());
	f_temperature = (float)temp * .1;

	pres = bmp085GetPressure(bmp085ReadUP());

	history[hist_index % HIST_BUFF] = pres;
	hist_index++;
	hist_index = hist_index % HIST_BUFF;
	pres_accu = 0.0;
	for(i=0; i<HIST_BUFF; i++)
	{
		j = (i + hist_index) % HIST_BUFF;
		pres_accu += history[j];
	}
	pressure_pa = pres_accu / HIST_BUFF;

	pressure = pressure_pa;
	temperature = f_temperature;
}

// calculate vertical speed value
int calc_vsi_timedelay(struct disp * display)
{
	int time_diff = millis() - (display -> last_vsi_time);
	int alt_diff;
	float vsi;

	if (time_diff < VSI_INTERVAL)
		return display -> vsi;

	alt_diff = (display -> altitude) - (display -> last_alt);
	display -> last_vsi_time = millis();
	display -> last_alt = display -> altitude;
	vsi = ((float)alt_diff / (float)time_diff) * 60000;
	return((int)vsi);
}

// calculate vertical speed value
float calc_vsi(struct disp * display)
{
	static int hist_index = 0;
	int i;
	int j;
	float vsi_accu;
	int alt_diff;
	int time_diff;
	float vsi;

	time_diff = millis() - (display -> last_vsi_time);
	alt_diff = (display -> altitude) - (display -> last_alt);

	switch (system_vars.units)
	{
		// feet per *minute*
		case us:
			vsi_history[hist_index % HIST_BUFF] = ((float)alt_diff / 
				(float)time_diff) * 60000;
			break;

		// meters per *second*
		case metric:
			vsi_history[hist_index % HIST_BUFF] = ((float)alt_diff / 
				(float)time_diff) * 1000;
			break;
	}

	hist_index++;
	hist_index = hist_index % HIST_BUFF;
	vsi_accu = 0.0;
	for(i=0; i<HIST_BUFF; i++)
	{
		j = (i + hist_index) % HIST_BUFF;
		vsi_accu += vsi_history[j];
	}
	vsi = vsi_accu / HIST_BUFF;

	display -> last_vsi_time = millis();
	display -> last_alt = display -> altitude;

	//Serial.print("raw VSI: ");
	//Serial.println(vsi);

	return(vsi);
}

float temp_in_kelvin()
{
	switch (system_vars.units)
	{
		case metric:
			return(disp_vars.temp + 273.15);
			break;

		case us:
			return(((disp_vars.temp - 32.0) * 5/9) + 273.15);
			break;
	}
}


// Stores all of the bmp085's calibration values into global variables
// Calibration values are required to calculate temp and pressure
// This function should be called at the beginning of the program
void bmp085Calibration()
{
  ac1 = bmp085ReadInt(0xAA);
  ac2 = bmp085ReadInt(0xAC);
  ac3 = bmp085ReadInt(0xAE);
  ac4 = bmp085ReadInt(0xB0);
  ac5 = bmp085ReadInt(0xB2);
  ac6 = bmp085ReadInt(0xB4);
  b1 = bmp085ReadInt(0xB6);
  b2 = bmp085ReadInt(0xB8);
  mB = bmp085ReadInt(0xBA);
  mc = bmp085ReadInt(0xBC);
  md = bmp085ReadInt(0xBE);
}

// Calculate temperature given ut.
// Value returned will be in units of 0.1 deg C
short bmp085GetTemperature(unsigned int ut)
{
  long x1, x2;
  
  x1 = (((long)ut - (long)ac6)*(long)ac5) >> 15;
  x2 = ((long)mc << 11)/(x1 + md);
  b5 = x1 + x2;

  return ((b5 + 8)>>4);  
}

// Calculate pressure given up
// calibration values must be known
// b5 is also required so bmp085GetTemperature(...) must be called first.
// Value returned will be pressure in units of Pa.
long bmp085GetPressure(unsigned long up)
{
  long x1, x2, x3, b3, b6, p;
  unsigned long b4, b7;
  
  b6 = b5 - 4000;
  // Calculate B3
  x1 = (b2 * (b6 * b6)>>12)>>11;
  x2 = (ac2 * b6)>>11;
  x3 = x1 + x2;
  b3 = (((((long)ac1)*4 + x3)<<OSS) + 2)>>2;
  
  // Calculate B4
  x1 = (ac3 * b6)>>13;
  x2 = (b1 * ((b6 * b6)>>12))>>16;
  x3 = ((x1 + x2) + 2)>>2;
  b4 = (ac4 * (unsigned long)(x3 + 32768))>>15;
  
  b7 = ((unsigned long)(up - b3) * (50000>>OSS));
  if (b7 < 0x80000000)
    p = (b7<<1)/b4;
  else
    p = (b7/b4)<<1;
    
  x1 = (p>>8) * (p>>8);
  x1 = (x1 * 3038)>>16;
  x2 = (-7357 * p)>>16;
  p += (x1 + x2 + 3791)>>4;
  
  return p;
}

// Read 1 byte from the BMP085 at 'address'
char bmp085Read(unsigned char address)
{
  unsigned char data;
  
  Wire.beginTransmission(BMP085_ADDRESS);
  Wire.send(address);
  Wire.endTransmission();
  
  Wire.requestFrom(BMP085_ADDRESS, 1);
  while(!Wire.available())
    ;
    
  return Wire.receive();
}

// Read 2 bytes from the BMP085
// First byte will be from 'address'
// Second byte will be from 'address'+1
int bmp085ReadInt(unsigned char address)
{
  unsigned char msb, lsb;
  
  Wire.beginTransmission(BMP085_ADDRESS);
  Wire.send(address);
  Wire.endTransmission();
  
  Wire.requestFrom(BMP085_ADDRESS, 2);
  while(Wire.available()<2)
    ;
  msb = Wire.receive();
  lsb = Wire.receive();
  
  return (int) msb<<8 | lsb;
}

// Read the uncompensated temperature value
unsigned int bmp085ReadUT()
{
  unsigned int ut;
  
  // Write 0x2E into Register 0xF4
  // This requests a temperature reading
  Wire.beginTransmission(BMP085_ADDRESS);
  Wire.send(0xF4);
  Wire.send(0x2E);
  Wire.endTransmission();
  
  // Wait at least 4.5ms
  delay(5);
  
  // Read two bytes from registers 0xF6 and 0xF7
  ut = bmp085ReadInt(0xF6);
  return ut;
}

// Read the uncompensated pressure value
unsigned long bmp085ReadUP()
{
  unsigned char msb, lsb, xlsb;
  unsigned long up = 0;
  
  // Write 0x34+(OSS<<6) into register 0xF4
  // Request a pressure reading w/ oversampling setting
  Wire.beginTransmission(BMP085_ADDRESS);
  Wire.send(0xF4);
  Wire.send(0x34 + (OSS<<6));
  Wire.endTransmission();
  
  // Wait for conversion, delay time dependent on OSS
  delay(2 + (3<<OSS));
  
  // Read register 0xF6 (MSB), 0xF7 (LSB), and 0xF8 (XLSB)
  Wire.beginTransmission(BMP085_ADDRESS);
  Wire.send(0xF6);
  Wire.endTransmission();
  Wire.requestFrom(BMP085_ADDRESS, 3);
  
  // Wait for data to become available
  while(Wire.available() < 3)
    ;
  msb = Wire.receive();
  lsb = Wire.receive();
  xlsb = Wire.receive();
  
  up = (((unsigned long) msb << 16) | ((unsigned long) lsb << 8) | (unsigned long) xlsb) >> (8-OSS);
  
  return up;
}

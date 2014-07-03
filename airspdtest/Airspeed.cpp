/* vi:set wm=0 ai sm tabstop=4 shiftwidth=4: */

/***********************************************************************
* my first arduino sketch.  try to read an analog value from a
* differential pressure sensor and turn it into miles per hour of 
* ram-air
* 
* reset the AREF to get the following top airspeeds:
* 5V (no AREF): 181 MPH
* 4V: 157 MPH
* 3V: 128 MPH
* 2.5V: 111 MPH
* 2V: 90 MPH
*
* 3V probably makes the most sense, just in case we're rolling downhill
* into a gale at absolute top speed (will the chip fry if the sensor
* provides more voltage than AREF?).  it appears overvoltage just peaks
* out, vs. doing actual damage.
*
* use two 500 ohm resistors to make 2.5V voltage divider
***********************************************************************/

#if ARDUINO >= 100
 #include "Arduino.h"
#else
 #include "WProgram.h"
#endif



#include "Airspeed.h"
float Airspeed :: get_speed(float sensorValue,float staticPressure,float tempKelvin)
{
	static int hist_index = 0;
	int i;
	int j;
	float sound_k;
	float speed;
	float speed_accu;
	float kPa = convert_sv_to_kPa(sensorValue);
	float temp_k;

//	switch (system_vars.units)
//	{
//		case us:
//#ifdef USE_KNOTS
			sound_k = SEALEVEL_SOUND_KNOTS;
//#else
	
	//		sound_k = SEALEVEL_SOUND_MPH;

/*
#endif 
			break;

		case metric:
			sound_k = SEALEVEL_SOUND_KPH;
			break;
	}
*/	
	// just go with the TAS calculation -- why would we ever want IAS?
			temp_k = tempKelvin + 273.15 ;
	
	speed = sound_k * sqrt(5 * 
		((pow((kPa/staticPressure)+1,(2.0/7.0))-1) * 
		(temp_k/288.15)));
/*
    spd_history[hist_index % HIST_BUFF] = speed;
    hist_index++;
    hist_index = hist_index % HIST_BUFF;
    speed_accu = 0.0;
    for(i=0; i<HIST_BUFF; i++)
    {
        j = (i + hist_index) % HIST_BUFF;
        speed_accu += spd_history[j];
    }
    speed = speed_accu / HIST_BUFF;
    */

	return((float)speed);
}

float Airspeed ::convert_sv_to_kPa(float sensorValue)
{
	// full-scale is 5.0V, which is 1024.
	// with AREF set to 4.0V, full-scale 1024 now represents 4V
	// sensor reading at 0 kPa is 1.0V
	// sensor reading at 3 kPa is 4.0V
	// reading should be linear

	//float pct = sensorValue / FULL_SCALE;
	//float kPa = pct * MAX_VOLTS;
	float pct = (float)sensorValue / FULL_SCALE;
	float kPa = pct * MAX_VOLTS;
	

	return(kPa);
}


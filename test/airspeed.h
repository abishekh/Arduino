#ifndef AIRSPEED_H
#define AIRSPEED_H

#define SEALEVEL_SOUND_KNOTS 661.4788
#define SEALEVEL_SOUND_MPH 767.716535
#define SEALEVEL_SOUND_KPH 1235.52
#define SEALEVEL_PRESSURE_PSI 14.6959465
#define SEALEVEL_PRESSURE_KPA 101.325
#define KPA_IN_PSI 0.145037738
#define FULL_SCALE 1024u 			// 10 bit ADC
#define MAX_VOLTS 2.5				// if we reset AREF
#define INHG_IN_KPA .295301

//#define USE_KNOTS	// uncomment this line and recompile to use knots
			// instead of MPH under US units

float spd_history[HIST_BUFF];

int get_speed(int sensorValue);
float convert_sv_to_kPa(int sensorValue);

#endif /* AIRSPEED_H */

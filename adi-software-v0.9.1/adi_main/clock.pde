/* vi:set wm=0 ai sm tabstop=4 shiftwidth=4: */

#include "clock.h"

void get_time() 
{
    DateTime now = RTC.now();
    
	snprintf(disp_vars.time, 6, "%02d:%02d", (int)now.hour(), 
		(int)now.minute());
}

// this is ridiculous, but will set the time to something
void init_clock()
{
	RTC.adjust(DateTime(__DATE__, __TIME__));
	//Serial.println("Resetting clock");
}

int get_hour()
{
	DateTime now = RTC.now();

	return((int)now.hour());
}

int get_minute()
{
	DateTime now = RTC.now();

	return((int)now.minute());
}

void set_hour(int hour)
{
	DateTime now = RTC.now();
	DateTime update = DateTime(now.year(), now.month(), now.day(), 
		(uint8_t)hour, now.minute(), (uint8_t)0);

	//Serial.print("adjusting hour to ");
	//Serial.println(update.hour(), DEC);

	RTC.adjust(update);
}

void set_minute(int minute)
{
	DateTime now = RTC.now();
	DateTime update = DateTime(now.year(), now.month(), now.day(), now.hour(), 
		(uint8_t)minute, (uint8_t)0);

	RTC.adjust(update);
}

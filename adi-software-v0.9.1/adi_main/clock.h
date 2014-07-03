/* vi:set wm=0 ai sm tabstop=4 shiftwidth=4: */

#ifndef CLOCK_H
#define CLOCK_H

RTC_DS1307 RTC;

void get_time();
void init_clock();

#endif /* CLOCK_H */

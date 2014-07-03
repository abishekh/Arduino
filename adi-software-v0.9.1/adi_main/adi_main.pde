/* vi:set wm=0 ai sm tabstop=4 shiftwidth=4: */

#include <stdio.h>

#include <EEPROM.h>
#include <Wire.h>
#include <LiquidCrystal.h>
#include <string.h>
#include <RTClib.h>
#include <avr/pgmspace.h>

#include "adi_main.h"
#include "airspeed.h"
#include "pressure.h"
#include "clock.h"
#include "menu.h"

/***********************************************************************
* main program
***********************************************************************/

LiquidCrystal lcd(7,8,9,10,11,12);

void setup()
{
	// for some reason, LOW is the only state that will take one int per
	// button press
	// interrupt if SET is pressed
	attachInterrupt(0, set_handler, LOW);

	analogReference(EXTERNAL);

	pinMode(led_pin, OUTPUT);
	pinMode(plus_btn_pin, INPUT);
	pinMode(minus_btn_pin, INPUT);
	pinMode(set_btn_pin, INPUT);

	// eliminate the need for pull-up resistors
	digitalWrite(plus_btn_pin, HIGH);
	digitalWrite(minus_btn_pin, HIGH);
	digitalWrite(set_btn_pin, HIGH);

	Wire.begin();
	bmp085Calibration();

	RTC.begin();

	if (!RTC.isrunning())
	{
		init_clock();
	}

#ifdef SERIAL_ON
	Serial.begin(9600);
#endif

	lcd.begin(16,2);

	init_vars(&system_vars); // pull data from EEPROM
	init_menu(); // set up menu items and options

	snprintf(disp_vars.vsi_unit, 4, "%s", "FPM");
	disp_vars.last_vsi_time = 0;

	splash_screen();
}

void loop()
{
	static int led_state = HIGH;
	static int prev_button = 0;
	int plus;
	int minus;

	if (set_pressed)
	{
		if (millis() - last_interrupt > debounce_limit)
		{
			show_menu();
		}
		last_interrupt = millis();
		set_pressed = false;
	}

	// timer to break us out of menu display
	if (millis() - last_interrupt > system_vars.menu_timeout * 1000)
	{
		in_menu = false;
	}

	if (in_menu)
	{
		plus = digitalRead(plus_btn_pin);
		minus = digitalRead(minus_btn_pin);
		if (prev_button == 0)
		{
			if (plus == LOW)
			{
				if (millis() - last_interrupt > debounce_limit)
				{
					prev_button = 1;
					increment_menu_item();
				}
				last_interrupt = millis();
			}
			else if (minus == LOW)
			{
				if (millis() - last_interrupt > debounce_limit)
				{
					prev_button = 1;
					decrement_menu_item();
				}
				last_interrupt = millis();
			}
		}
		else
		{
			if (minus == HIGH && plus == HIGH)
				prev_button = 0;
		}
	}
	else
	{
		dpsensorValue = analogRead(0);
		disp_vars.airspeed = get_speed(dpsensorValue);
		get_altitude();
		get_time();
		disp_vars.vsi = calc_vsi(&disp_vars);
		update_display();
		digitalWrite(led_pin, led_state);
		led_state = !led_state;
		delay(100);
	}
}

/*----------------------------------------------------------------------
* EEPROM addresses are set in adi_main.h
----------------------------------------------------------------------*/
void init_vars(struct vars * sysvars_ref)
{
	int i;
	int check;
	byte tmpval;
	union // union type: all vars refer to same memory space
	{
		byte as_bytes[4];
		float as_float;
	} float_v;
	int ee_addr;

	tmpval = EEPROM.read(UNITS_ADDR);
	sysvars_ref -> units = (tmpval == 255) ? us : (enum unit_types)tmpval;

	last_unit_type = sysvars_ref -> units;

	// remember to set the kollsman value *after* setting the units...
	for (i=0; i<=3; i++)
	{
		ee_addr = i + KOLL_ADDR;
		float_v.as_bytes[i] = EEPROM.read(ee_addr);
	}
	sysvars_ref -> kollsman_value = (float_v.as_float > 90000.0 && 
		float_v.as_float < 106000.0) ?  float_v.as_float : 101320.74891;
	sysvars_ref -> disp_kollsman_value = 
		conv_2_disp_pres(sysvars_ref -> kollsman_value);

	tmpval = EEPROM.read(TIMEOUT_ADDR);
	sysvars_ref -> menu_timeout = (tmpval == 255) ? 5 : tmpval;

	tmpval = EEPROM.read(BACKLIGHT_ADDR); 
	sysvars_ref -> backlight = (tmpval == 255) ? 5 : tmpval;

	for (i=0; i<=3; i++)
	{
		ee_addr = i + SPEED_OFFSET_ADDR;
		float_v.as_bytes[i] = EEPROM.read(ee_addr);
	}
	sysvars_ref -> speed_offset = (float_v.as_float > 0.75 && 
		float_v.as_float < 1.25) ?  float_v.as_float : 1.0;
}


/*----------------------------------------------------------------------
* call when changing kollsman value or units
* pass display kollsman value
----------------------------------------------------------------------*/
void change_koll(float koll)
{
	float l_koll;
	const enum unit_types curr_unit_type = system_vars.units;

	if (last_unit_type != curr_unit_type)
	{
		system_vars.units = last_unit_type;
		l_koll = conv_2_int_pres(koll);
		system_vars.units = curr_unit_type;
		system_vars.kollsman_value = l_koll;
		system_vars.disp_kollsman_value = conv_2_disp_pres(l_koll);
		menu_items[KOLL_MENU_ITEM].float_value = 
			system_vars.disp_kollsman_value;
	}
	else
	{
		menu_items[KOLL_MENU_ITEM].float_value = koll;
		system_vars.kollsman_value = conv_2_int_pres(koll);
		system_vars.disp_kollsman_value = koll;
	}

	switch (system_vars.units)
	{
		case us: // inches of Hg
			menu_items[KOLL_MENU_ITEM].float_max = 31.3;
			menu_items[KOLL_MENU_ITEM].float_min = 26.58;
			break;

		case metric: // millibars
			menu_items[KOLL_MENU_ITEM].float_max = 1060.0;
			menu_items[KOLL_MENU_ITEM].float_min = 900.0;
			break;
	}

	last_unit_type = curr_unit_type;
}


/*----------------------------------------------------------------------
* set_handler just sets a flag, then show_menu happens as part of the 
* main loop
----------------------------------------------------------------------*/
void set_handler()
{
	set_pressed = true;
}

/*----------------------------------------------------------------------
* format the various display variables for the LCD screen
----------------------------------------------------------------------*/
void update_display()
{
	char line_one[17];
	char line_two[17];
	char * vsi;

	/*  pre-clock display
	snprintf(line_one, 17, "%3d %3s    %3d%c%s", disp_vars.airspeed, 
		disp_vars.speed_unit, disp_vars.temp, 
		(char)223, disp_vars.temp_unit);

	snprintf(line_two, 17, "%5d%s %5d %3s", disp_vars.altitude, 
		disp_vars.alt_unit, disp_vars.vsi, disp_vars.vsi_unit);
	*/

	snprintf(line_one, 17, "%3d %3s   %5d%s", disp_vars.airspeed, 
		disp_vars.speed_unit, disp_vars.altitude, disp_vars.alt_unit);

	// the VSI is a float when in metric mode
	switch (system_vars.units)
	{
		case us:
			snprintf(line_two, 17, "%5s %3d%s %s%04d", disp_vars.time, 
				disp_vars.temp, disp_vars.temp_unit, (disp_vars.vsi 
				< 0.0) ? "-" : "+", abs((int)disp_vars.vsi));
			break;

		case metric:
			snprintf(line_two, 17, "%5s %3d%s %s%02d.%01d", disp_vars.time, 
				disp_vars.temp, disp_vars.temp_unit, (disp_vars.vsi 
				< 0.0) ? "-" : "+", abs((int)disp_vars.vsi), 
				abs((int)(disp_vars.vsi*100)%100));
			break;
	}

	output_line(0, line_one);
	output_line(1, line_two);
}

/*----------------------------------------------------------------------
* simple function to output a line of data.
----------------------------------------------------------------------*/
void output_line(int lineno, char * string)
{
	// let's keep from spamming the serial line, shall we?
	/* Uncomment for any serious serial usage */
	/*
	* if (millis() - last_print < 100)
	* {
		* last_print = millis();
		* return;
	* }
	*/
	//printf("%d: %s\n", lineno, string);
	//Serial.println(string);

	lcd.setCursor(0, lineno);
	lcd.print(string);
}

/*----------------------------------------------------------------------
* simple function to put up a little splash screen
* update strings in adi_main.h
----------------------------------------------------------------------*/
void splash_screen()
{
	static int iter = 0;
	char disp[17];
	char i;
	
	for(iter=0; iter<=5; iter++)
	{
		strcpy_P(disp, (char*)pgm_read_word(&(splash_strings[iter])));

		if (iter > 4)
		{
			lcd.leftToRight();
			lcd.clear();
			lcd.noAutoscroll();
			lcd.setCursor(0,0);
			strcpy(disp, "");
		}

		for(i=0; i<LCD_WIDTH; i++)
		{
			// draw the first string on the top line, others on the second
			lcd.setCursor(i,(iter==0?0:1));
			if (iter<5) lcd.write(disp[i]);
			get_altitude();
		}
		delay(500);
	}
}

/*----------------------------------------------------------------------
* convert from Pa to display-unit pressure.  Pa is used internally (the
* pressure sensor returns Pa).
----------------------------------------------------------------------*/
float conv_2_disp_pres(float pressure)
{
	float disp;

	switch (system_vars.units)
	{
		case us: // inches of mercury
			disp = (pressure * 0.000295301);
			break;

		case metric: // millibars
			disp = (pressure * 0.01);
			break;

		default:
			disp = (-1);
			break;
	}

	return(disp);
}

/*----------------------------------------------------------------------
* convert from display-unit pressure to internal pressure.  Pa is used
* internally.
----------------------------------------------------------------------*/
float conv_2_int_pres(float pressure)
{
	switch (system_vars.units)
	{
		case us: // inches of Hg
			return(pressure * 3386.3753);
			break;

		case metric: // millibars
			return(pressure * 100);
			break;

		default:
			return(-1);
			break;
	}
}

/*----------------------------------------------------------------------
* write an EEPROM value
----------------------------------------------------------------------*/
void write_mem(struct menu_item * item)
{
	int i;
	int j;
	union // union type: all vars refer to same memory space
	{
		byte as_bytes[4];
		float as_float;
	} float_v;

	switch (item -> display_type)
	{
		case int_value:
			EEPROM.write(item -> addr, item -> int_value);
			break;

		case float_value:
			if (item -> addr == KOLL_ADDR)
				float_v.as_float = conv_2_int_pres(item -> float_value);
			else
				float_v.as_float = item -> float_value;

			//Serial.print("Writing float:");
			//Serial.println(float_v.as_float);

			for(i=0; i<=3; i++)
			{
				j = i + item -> addr;
				EEPROM.write(j, float_v.as_bytes[i]);
			}
			break;

		case enum_value:
			EEPROM.write(item -> addr, (byte)item -> enum_value);
			break;

		default:
			break;
	}
}

/*----------------------------------------------------------------------
* this is where all changes to the menu are dispersed through the system
* call any time a value has changed in the menu
----------------------------------------------------------------------*/
void update_sys_vars()
{
	system_vars.disp_kollsman_value = menu_items[KOLL_MENU_ITEM].float_value;
	system_vars.units = (enum unit_types)menu_items[UNITS_MENU_ITEM].enum_value;
	switch (system_vars.units)
	{
		case us:
#ifdef USE_KNOTS
			snprintf(disp_vars.speed_unit, 4, "KNT");
#else
			snprintf(disp_vars.speed_unit, 4, "MPH");
#endif /* USE_KNOTS */
			snprintf(disp_vars.temp_unit, 2, "F");
			snprintf(disp_vars.alt_unit, 2, "'");
			break;

		case metric:
			snprintf(disp_vars.speed_unit, 4, "KPH");
			snprintf(disp_vars.temp_unit, 2, "C");
			snprintf(disp_vars.alt_unit, 2, "m");
			break;
	}

	system_vars.menu_timeout = menu_items[TIMEOUT_MENU_ITEM].int_value;
	system_vars.kollsman_value = 
		conv_2_int_pres(system_vars.disp_kollsman_value);
	system_vars.backlight = menu_items[BACKLIGHT_MENU_ITEM].int_value;
	analogWrite(backlight_pin, (menu_items[BACKLIGHT_MENU_ITEM].int_value * 
		(255/5)));
	system_vars.speed_offset = menu_items[SPD_MENU_ITEM].float_value;
	get_altitude();
}

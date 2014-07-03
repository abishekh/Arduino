/* vi:set wm=0 ai sm tabstop=4 shiftwidth=4: */

/***********************************************************************
* first attempts at working out a menu system
*
* use a button as an interrupt to get to the menu system
***********************************************************************/

#ifndef ADI_MAIN_H
#define ADI_MAIN_H

/***********************************************************************
* #defines
***********************************************************************/

#define KOLL_ADDR 0 // float; next var must be this + 4
#define TIMEOUT_ADDR 4
#define UNITS_ADDR 5
#define BACKLIGHT_ADDR 6
#define SPEED_OFFSET_ADDR 7 // float; next var must be this + 4

// how many entries to use in the various smoothing buffers
#define HIST_BUFF 16

//#define SERIAL_ON

// these don't have a lot of effect yet, just for the splash screen
#define LCD_WIDTH 16
#define LCD_HEIGHT 2

/***********************************************************************
* data structure declarations
***********************************************************************/

// define some unit enums
enum unit_types {us, metric};
enum display_t {enum_value, int_value, float_value, clock_value};

enum unit_types last_unit_type;

// automatically drop us into the menu first time around
bool set_pressed = true;

// the main system variables and their defaults. 
// internal units are:
// pressure: Pa
// speed: kph
// altitude: meters
// temperature: C
struct vars
{
	int menu_timeout;
	enum unit_types units;
	float kollsman_value;
	float disp_kollsman_value; // what actually gets shown to the human
	int backlight;
	float speed_offset;
};

//declare the actual system variables data structure
struct vars system_vars;

struct disp
{
	int altitude;
	int airspeed;
	int temp;
	float vsi;
	char speed_unit[4];
	char alt_unit[2];
	char airspeed_mode[2];
	char temp_unit[2];
	char vsi_unit[4];
	unsigned long last_vsi_time;
	int last_alt;
	float static_pressure;  // kPa
	char time[6];
};

// the actual information to be displayed on the next display update
struct disp disp_vars;

/***********************************************************************
* global variables
***********************************************************************/
const int led_pin = 13;
const int set_btn_pin = 2;
const int plus_btn_pin = 4;
const int minus_btn_pin = 5;
const int backlight_pin = 6;

const int splash_time = 1000; // milliseconds of splashscreen
const long debounce_limit = 100; // milliseconds
long last_interrupt;
long last_print = 0;

int dpsensorValue;  // differential pressure sensor value, for airspeed

// splash screen text
prog_uchar splash_0[] PROGMEM = "Dangerpants Labs";
prog_uchar splash_1[] PROGMEM = "      Air       ";
prog_uchar splash_2[] PROGMEM = "      Data      ";
prog_uchar splash_3[] PROGMEM = "   Instrument   ";
prog_uchar splash_4[] PROGMEM = "      v0.9      ";

PROGMEM const prog_uchar * splash_strings[] =
{
	splash_0,
	splash_1,
	splash_2,
	splash_3,
	splash_4,
};

/***********************************************************************
* prototype declarations
***********************************************************************/
struct vars init_vars();
void update_display();
void output_line(int lineno, char * string);
float conv_2_disp_pres(float pressure);
float conv_2_int_pres(float pressure);
void write_mem(struct menu_item menu);
void splash_screen();

#endif /* ADI_MAIN_H */

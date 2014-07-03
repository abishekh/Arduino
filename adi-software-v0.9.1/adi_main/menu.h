/* vi:set wm=0 ai sm tabstop=4 shiftwidth=4: */

#ifndef MENU_H
#define MENU_H

/***********************************************************************
* #defines
***********************************************************************/

// these define the order of the menu items
#define KOLL_MENU_ITEM 0
#define HOUR_MENU_ITEM 1
#define MIN_MENU_ITEM 2
#define SPD_MENU_ITEM 3
#define BACKLIGHT_MENU_ITEM 4
#define UNITS_MENU_ITEM 5
#define TIMEOUT_MENU_ITEM 6

/***********************************************************************
* data structure declarations
***********************************************************************/

// define some unit enums
struct menu_item
{
	char name[17];
	char labels[3][17];
	char disp_labels[3][4];
	int enum_value;
	int int_value;
	int int_max;
	int int_min;
	float float_value;
	float float_max;
	float float_min;
	enum display_t display_type;
	int addr;
};

const int num_menu_items = 7;  // set in init_menu
struct menu_item menu_items[num_menu_items];

/***********************************************************************
* global variables
***********************************************************************/
bool in_menu = false;
int menu_index = 0;

/***********************************************************************
* prototype declarations
***********************************************************************/
void init_menu();
void show_menu();
void increment_menu_item();
void decrement_menu_item();
void increment_enum(struct menu_item * item);
void decrement_enum(struct menu_item * item);

#endif /* MENU_H */

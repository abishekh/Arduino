/* vi:set wm=0 ai sm shiftwidth=4 tabstop=4: */

void init_menu()
{
	size_t strlen = 17;

	snprintf(menu_items[KOLL_MENU_ITEM].name, strlen, "%-16s", "Kollsman:");
	change_koll(system_vars.disp_kollsman_value);
	menu_items[KOLL_MENU_ITEM].display_type = float_value;
	menu_items[KOLL_MENU_ITEM].addr = KOLL_ADDR;

	snprintf(menu_items[UNITS_MENU_ITEM].name, strlen, "%-16s", "Units:");
	snprintf(menu_items[UNITS_MENU_ITEM].labels[0], strlen, "%-16s", "US");
	snprintf(menu_items[UNITS_MENU_ITEM].labels[1], strlen, "%-16s", "Metric");
	menu_items[UNITS_MENU_ITEM].enum_value = system_vars.units;
	menu_items[UNITS_MENU_ITEM].display_type = enum_value;
	menu_items[UNITS_MENU_ITEM].addr = UNITS_ADDR;

	snprintf(menu_items[TIMEOUT_MENU_ITEM].name, strlen, "%-16s", 
		"Menu timeout:");
	menu_items[TIMEOUT_MENU_ITEM].int_value = system_vars.menu_timeout;
	menu_items[TIMEOUT_MENU_ITEM].int_max = 60;
	menu_items[TIMEOUT_MENU_ITEM].int_min = 2;
	menu_items[TIMEOUT_MENU_ITEM].display_type = int_value;
	menu_items[TIMEOUT_MENU_ITEM].addr = TIMEOUT_ADDR;

	snprintf(menu_items[BACKLIGHT_MENU_ITEM].name, strlen, "%-16s", 
		"Backlight:");
	menu_items[BACKLIGHT_MENU_ITEM].int_value = system_vars.backlight;
	menu_items[BACKLIGHT_MENU_ITEM].int_max = 5;
	menu_items[BACKLIGHT_MENU_ITEM].int_min = 0;
	menu_items[BACKLIGHT_MENU_ITEM].display_type = int_value;
	menu_items[BACKLIGHT_MENU_ITEM].addr = BACKLIGHT_ADDR;

	snprintf(menu_items[SPD_MENU_ITEM].name, strlen, "%-16s", "Speed offset:");
	menu_items[SPD_MENU_ITEM].float_max = 2.0;
	menu_items[SPD_MENU_ITEM].float_min = 0.9;
	menu_items[SPD_MENU_ITEM].float_value = system_vars.speed_offset;
	menu_items[SPD_MENU_ITEM].display_type = float_value;
	menu_items[SPD_MENU_ITEM].addr = SPEED_OFFSET_ADDR;

	snprintf(menu_items[HOUR_MENU_ITEM].name, strlen, "%-16s", "Clock hour:");
	menu_items[HOUR_MENU_ITEM].int_max = 23;
	menu_items[HOUR_MENU_ITEM].int_min = 0;
	menu_items[HOUR_MENU_ITEM].display_type = clock_value;

	snprintf(menu_items[MIN_MENU_ITEM].name, strlen, "%-16s", "Clock minute:");
	menu_items[MIN_MENU_ITEM].int_max = 59;
	menu_items[MIN_MENU_ITEM].int_min = 0;
	menu_items[MIN_MENU_ITEM].display_type = clock_value;
	// reset num_menu_items in the .h file if you add or subtract menu items

	update_sys_vars();
}

// show_menu is called as a result of an interrupt from the SET button, so it
// has to keep its own state, and be able to both show the menu, and 
// advance it to the next menu item
void show_menu()
{
	char output[33]; // probably actually wants to be 17
	float f_val;

	if (in_menu)
	{
		// advance the menu selection
		menu_index++;
		menu_index %= num_menu_items;
	}
	else
	{
		// start with position zero
		menu_index = 0;
	}
	in_menu = true;

	output_line(0, menu_items[menu_index].name);

	switch (menu_items[menu_index].display_type)
	{
		case int_value:
			snprintf(output, 17, "%-16d", menu_items[menu_index].int_value);
			output_line(1, output);
			break;

		case float_value:
			f_val = menu_items[menu_index].float_value;
			//get_altitude();
			switch(menu_index)
			{
				case KOLL_MENU_ITEM:
					switch(system_vars.units)
					{
						case us: // inches of Hg
							snprintf(output, 17, "%d.%02d [%5d%s]  ", 
								(int)f_val, (int)(f_val*100)%100, 
								disp_vars.altitude, disp_vars.alt_unit);
							break;

						case metric: // millibars
							snprintf(output, 17, "%d [%5d%s]   ", (int)f_val, 
								disp_vars.altitude, disp_vars.alt_unit);
							break;
					}
					break;

				case SPD_MENU_ITEM:
					snprintf(output, 17, "%d.%03d [%3d %s]  ", (int)f_val,
						(int)(f_val*1000)%1000, disp_vars.airspeed,
						disp_vars.speed_unit);
					break;
			}
			output_line(1, output);
			break;

		case enum_value:
			output_line(1, menu_items[menu_index].
				labels[(int)menu_items[menu_index].enum_value]);
			break;

		case clock_value:
			switch (menu_index)
			{
				case HOUR_MENU_ITEM:
					menu_items[menu_index].int_value = get_hour();
					snprintf(output, 17, "%-16d", get_hour());
					break;

				case MIN_MENU_ITEM:
					menu_items[menu_index].int_value = get_minute();
					snprintf(output, 17, "%-16d", get_minute());
					break;
			}
			output_line(1, output);
			break;

		default:
			output_line(1, "No data");
			break;
	}
}

void increment_menu_item()
{
	char output[17];
	float f_item;

	switch (menu_items[menu_index].display_type)
	{
		case int_value:
			if (++menu_items[menu_index].int_value > 
					menu_items[menu_index].int_max)
				menu_items[menu_index].int_value = 
					menu_items[menu_index].int_min;
			snprintf(output, 17, "%-16d", menu_items[menu_index].int_value);
			write_mem(&menu_items[menu_index]);
			break;

		case float_value:
			switch(menu_index)
			{
				case KOLL_MENU_ITEM:
					f_item = menu_items[menu_index].float_value;
					if (system_vars.units == metric)
					{
						f_item += 1.0;
						if (f_item > menu_items[menu_index].float_max)
							f_item = menu_items[menu_index].float_min;
						change_koll(f_item);
						get_altitude();
						snprintf(output, 17, "%d [%5d%s]", (int)f_item, 
							disp_vars.altitude, disp_vars.alt_unit);
					}
					else // must be inHg
					{
						f_item += .01;
						if (f_item > menu_items[menu_index].float_max)
							f_item = menu_items[menu_index].float_min;
						change_koll(f_item);
						get_altitude();
						snprintf(output, 17, "%d.%02d [%5d%s]", (int)f_item, 
							(int)(f_item*100)%100, disp_vars.altitude, 
							disp_vars.alt_unit);
					}
					break;

				case SPD_MENU_ITEM:
					f_item = menu_items[menu_index].float_value;
					f_item += .001;
					if (f_item > menu_items[menu_index].float_max)
						f_item = menu_items[menu_index].float_min;

					menu_items[menu_index].float_value = f_item;

					dpsensorValue = analogRead(0);
					disp_vars.airspeed = get_speed(dpsensorValue);

					snprintf(output, 17, "%d.%03d [%3d %s]  ", (int)f_item,
						(int)(f_item*1000)%1000, disp_vars.airspeed,
						disp_vars.speed_unit);
					break;
			}
			write_mem(&menu_items[menu_index]);
			break;

		case enum_value:
			increment_enum(&menu_items[menu_index]);
			snprintf(output, 17, "%-16s", menu_items[menu_index].
				labels[(int)menu_items[menu_index].enum_value]);
			write_mem(&menu_items[menu_index]);
			break;

		case clock_value:
			if (++menu_items[menu_index].int_value > 
					menu_items[menu_index].int_max)
				menu_items[menu_index].int_value = 
					menu_items[menu_index].int_min;
			snprintf(output, 17, "%-16d", menu_items[menu_index].int_value);
			switch (menu_index)
			{
				case HOUR_MENU_ITEM:
					set_hour(menu_items[menu_index].int_value);
					break;

				case MIN_MENU_ITEM:
					set_minute(menu_items[menu_index].int_value);
					break;
			}
			break;

		default:
			snprintf(output, 17, "Type not found");
			break;
	}

	update_sys_vars();
	change_koll(system_vars.disp_kollsman_value);
	output_line(1, output);
}

void decrement_menu_item()
{
	char output[17];
	float f_item;

	switch (menu_items[menu_index].display_type)
	{
		case int_value:
			if (--menu_items[menu_index].int_value < 
					menu_items[menu_index].int_min)
				menu_items[menu_index].int_value = 
					menu_items[menu_index].int_max;
			snprintf(output, 17, "%-16d", menu_items[menu_index].int_value);
			write_mem(&menu_items[menu_index]);
			break;

		case float_value: 
			switch(menu_index)
			{
				case KOLL_MENU_ITEM:
					f_item = menu_items[menu_index].float_value;
					if (system_vars.units == metric)
					{
						f_item -= 1.0;
						if (f_item < menu_items[menu_index].float_min)
							f_item = menu_items[menu_index].float_max;
						change_koll(f_item);
						get_altitude();
						snprintf(output, 17, "%d [%5d%s]", (int)f_item, 
							disp_vars.altitude, disp_vars.alt_unit);
					}
					else // must be inHg
					{
						f_item -= .01;
						if (f_item < menu_items[menu_index].float_min)
							f_item = menu_items[menu_index].float_max;
						change_koll(f_item);
						get_altitude();
						snprintf(output, 17, "%d.%02d [%5d%s]", (int)f_item, 
							(int)(f_item*100)%100, disp_vars.altitude, 
							disp_vars.alt_unit);
					}
					break;

				case SPD_MENU_ITEM:
					f_item = menu_items[menu_index].float_value;
					f_item -= .001;
					if (f_item < menu_items[menu_index].float_min)
						f_item = menu_items[menu_index].float_max;

					menu_items[menu_index].float_value = f_item;

					dpsensorValue = analogRead(0);
					disp_vars.airspeed = get_speed(dpsensorValue);

					snprintf(output, 17, "%d.%03d [%3d %s]  ", (int)f_item,
						(int)(f_item*1000)%1000, disp_vars.airspeed,
						disp_vars.speed_unit);
					break;
			}
			write_mem(&menu_items[menu_index]);
			break;

		case enum_value:
			decrement_enum(&menu_items[menu_index]);
			snprintf(output, 17, "%-16s", menu_items[menu_index].
				labels[(int)menu_items[menu_index].enum_value]);
			write_mem(&menu_items[menu_index]);
			break;

		case clock_value:
			if (--menu_items[menu_index].int_value < 
					menu_items[menu_index].int_min)
				menu_items[menu_index].int_value = 
					menu_items[menu_index].int_max;
			snprintf(output, 17, "%-16d", menu_items[menu_index].int_value);
			switch (menu_index)
			{
				case HOUR_MENU_ITEM:
					set_hour(menu_items[menu_index].int_value);
					break;

				case MIN_MENU_ITEM:
					set_minute(menu_items[menu_index].int_value);
					break;
			}
			break;

		default:
			snprintf(output, 17, "Type not found");
			break;
	}

	update_sys_vars();
	change_koll(system_vars.disp_kollsman_value);
	output_line(1, output);
}

void increment_enum(struct menu_item * item)
{
	item -> enum_value = (item -> enum_value == 0) ? 1 : 0;
}

void decrement_enum(struct menu_item * item)
{
	item -> enum_value = (item -> enum_value == 0) ? 1 : 0;
}


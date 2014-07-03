#ifndef PRESSURE_H
#define PRESSURE_H

#define BMP085_ADDRESS 0x77  // I2C address of BMP085

// the following were not defined in the original code
#define PA_TO_MB_MULT 0.01
#define PA_TO_INHG_MULT 0.000295301
#define INHG_TO_PA_MULT 3386.3753
#define M_TO_FT_MULT 3.2308399
#define VSI_INTERVAL 500 // milliseconds between VSI calculations

float history[HIST_BUFF];
float vsi_history[HIST_BUFF];

const unsigned char OSS = 3;  // Oversampling Setting

// Calibration values
int ac1;
int ac2; 
int ac3; 
unsigned int ac4;
unsigned int ac5;
unsigned int ac6;
int b1; 
int b2;
int mB;
int mc;
int md;

// b5 is calculated in bmp085GetTemperature(...), this variable is also used in bmp085GetPressure(...)
// so ...Temperature(...) must be called before ...Pressure(...).
long b5; 

short temperature;
float f_temp;
long pressure;

//void get_altitude(float & alt_meters, float & temp_c, float koll_pa);
void get_altitude();
void get_pressure(float * pressure, float * temperature);
float calc_vsi(struct disp * display);
float temp_in_kelvin();
void bmp085Calibration();
short bmp085GetTemperature(unsigned int ut);
long bmp085GetPressure(unsigned long up);
char bmp085Read(unsigned char address);
int bmp085ReadInt(unsigned char address);
unsigned int bmp085ReadUT();
unsigned long bmp085ReadUP();

#endif /* PRESSURE_H */

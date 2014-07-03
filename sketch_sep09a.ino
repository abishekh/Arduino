// Community of Robots//

//Dc motor example code//

int motorpin1 = 3;                  //define digital output pin no.

int motorpin2 = 4;                  //define digital output pin no.
int motorpin3 = 5;                  //define digital output pin no.

int motorpin4 = 6;
boolean once=0;
void setup () {

  pinMode(motorpin1,OUTPUT);        //set pin 3 as output

  pinMode(motorpin2,OUTPUT);        // set pin 4 as output
  
  pinMode(motorpin3,OUTPUT);
  pinMode(motorpin4,OUTPUT);

}

void loop () {
 //forward();
 left();
 //backward();
 right();
  /*digitalWrite(motorpin1,LOW);

  digitalWrite(motorpin2,HIGH);
  
  digitalWrite(motorpin3,LOW);
  digitalWrite(motorpin4,HIGH);
  
  delay(2000);
  digitalWrite(motorpin1,HIGH);

  digitalWrite(motorpin2,LOW);
  
  digitalWrite(motorpin3,HIGH);
  digitalWrite(motorpin4,LOW);
  
  delay(2000);*/

}

void right()
{
  
  digitalWrite(motorpin1,HIGH);
  digitalWrite(motorpin2,LOW);
  digitalWrite(motorpin3,LOW);
  digitalWrite(motorpin4,HIGH);
  
  delay(1200);
 /* while(1)
  {
  digitalWrite(motorpin1,LOW);
  digitalWrite(motorpin2,LOW);
  digitalWrite(motorpin3,HIGH);
  digitalWrite(motorpin4,HIGH);
  }*/
  
}

void left()
{
  
  digitalWrite(motorpin1,LOW);
  digitalWrite(motorpin2,HIGH);
  digitalWrite(motorpin3,HIGH);
  digitalWrite(motorpin4,HIGH);
  
  delay(1200);
 /* while(1)
  {
  digitalWrite(motorpin1,LOW);
  digitalWrite(motorpin2,LOW);
  digitalWrite(motorpin3,HIGH);
  digitalWrite(motorpin4,HIGH);
  }*/
}

void forward()
{
  digitalWrite(motorpin1,LOW);

  digitalWrite(motorpin2,HIGH);
  
  digitalWrite(motorpin3,LOW);
  digitalWrite(motorpin4,HIGH);
  
  delay(1000);
}

void backward()
{
  digitalWrite(motorpin1,HIGH);

  digitalWrite(motorpin2,HIGH);
  
  digitalWrite(motorpin3,HIGH);
  digitalWrite(motorpin4,LOW);
  
  delay(1000);
}

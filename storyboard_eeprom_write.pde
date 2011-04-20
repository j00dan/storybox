#include <EEPROM.h>

#define EEPROM_SIZE 512
int addr = 0;
char msg;
char printmsg[128];
char temp;
int i = 0, j = 0;

void setup()
{
  Serial.begin(9600);
}

void loop()
{
  if(Serial.available() > 0){
    msg = Serial.read();
    Serial.println(msg);
    printmsg[i] = msg;
    i++;
  }
  
  else{
    i = 0;
    Serial.print("message: ");
    Serial.println(printmsg);
    delay(1000);
  }
}

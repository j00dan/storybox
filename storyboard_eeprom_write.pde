/*
 * EEPROM Write
 *
 * Stores values read from analog input 0 into the EEPROM.
 * These values will stay in the EEPROM when the board is
 * turned off and may be retrieved later by another sketch.
 */

#include <EEPROM.h>

// the current address in the EEPROM (i.e. which byte
// we're going to write to next)
#define EEPROM_SIZE 512
int addr = 0;
int msg;

void setup()
{
  //EEPROM.write(0, 0x52);
  Serial.begin(9600);
}

void loop()
{
  if(Serial.available() > 0){
    msg = Serial.read();
    //Serial.print(msg);
    //sprintf(char_msg, "%c", msg);
    if(addr < EEPROM_SIZE){
      EEPROM.write(addr, msg);
      addr++;
    }
  }
}

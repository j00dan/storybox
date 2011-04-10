#include <avr/pgmspace.h>
#include <Wire.h>


void i2c_eeprom_write_byte( int deviceaddress, unsigned int eeaddress, byte data ) {
    int rdata = data;
    Wire.beginTransmission(deviceaddress);
    Wire.send((int)(eeaddress >> 8)); // MSB
    Wire.send((int)(eeaddress & 0xFF)); // LSB
    Wire.send(rdata);
    Wire.endTransmission();
}

// WARNING: address is a page address, 6-bit end will wrap around
// also, data can be maximum of about 30 bytes, because the Wire library has a buffer of 32 bytes
void i2c_eeprom_write_page( int deviceaddress, unsigned int eeaddresspage, byte* data, byte length ) {
  Wire.beginTransmission(deviceaddress);
  Wire.send((int)(eeaddresspage >> 8)); // MSB
  Wire.send((int)(eeaddresspage & 0xFF)); // LSB
  byte c;
  for ( c = 0; c < length; c++)
    Wire.send(data[c]);
  Wire.endTransmission();
}

byte i2c_eeprom_read_byte( int deviceaddress, unsigned int eeaddress ) {
  byte rdata = 0xFF;
  Wire.beginTransmission(deviceaddress);
  Wire.send((int)(eeaddress >> 8)); // MSB
  Wire.send((int)(eeaddress & 0xFF)); // LSB
  Wire.endTransmission();
  Wire.requestFrom(deviceaddress,1);
  if (Wire.available()) rdata = Wire.receive();
  return rdata;
}

// maybe let's not read more than 30 or 32 bytes at a time!
void i2c_eeprom_read_buffer( int deviceaddress, unsigned int eeaddress, byte *buffer, int length ) {
  Wire.beginTransmission(deviceaddress);
  Wire.send((int)(eeaddress >> 8)); // MSB
  Wire.send((int)(eeaddress & 0xFF)); // LSB
  Wire.endTransmission();
  Wire.requestFrom(deviceaddress,length);
  int c = 0;
  for ( c = 0; c < length; c++ )
    if (Wire.available()) buffer[c] = Wire.receive();
}

// i2c_eeprom_write_page(0x50, 0, (byte *)somedata, sizeof(somedata)); // write to EEPROM 

prog_uchar words[] PROGMEM  =  {
    "aardvark_addax_alligator_alpaca_anteater_antelope_aoudad_ape_argali_~"
   };



void setup() {
  Serial.begin(9600);
  Wire.begin();   // Initialize the i2c
}


void WriteDataToEEprom() {
  int i;
  byte c;

  Serial.println("Writing to i2c eeprom.");
  i=0;
  do {
    c = pgm_read_byte_near(words+i); 
    i2c_eeprom_write_byte(0x50, i, c);
    Serial.println(i);
    i++;
    delay(100);
  } while (c!='~');
  Serial.println();
  Serial.println("Writing done.");
}



void loop() {
  int addr=0;
  byte b; 

  WriteDataToEEprom();


  Serial.println("**START**");

  do {
    b = i2c_eeprom_read_byte(0x50, addr); 
    addr++; //increase address
    if (b=='_') {  // End of word - write a crlf
      Serial.println();
    } else {
      Serial.print((char)b); 
    }
  } while (b!='~');

  Serial.println("**END**");
  for (;;);
}

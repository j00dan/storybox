 #include <Wire.h> //I2C library



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



  /* Code started here */
  /* NOTICE: Shall NULL eeprom before write data in */
  
  char words[] = "";
  char* words_list[] = {};
  int i = 0, j = 0, k = 0;
  char temp[] = "";
    
  void setup() 
  {
    Wire.begin(); // initialise the connection
    Serial.begin(9600);
  }

  void loop() 
  {
    if(Serial.available() > 0){
      words[i] = Serial.read();
      Serial.println("word: ");
      Serial.println(words[i]); 
      if(words[i] == '~'){
        i2c_eeprom_write_page(0x50, 0, (byte *)words, sizeof(words)); //write into eeprom
        int addr = 0;
        byte b = i2c_eeprom_read_byte(0x50, 0); //access the first address of memory
        while (b!=0){
          store_words_list((char)b);
          addr++;
          b = i2c_eeprom_read_byte(0x50, addr);
        }
      }
      i++;
    }
    delay(2000);
  }
  
  void store_words_list(char c){
    if(c == '_' || c == '~'){
      words_list[k] = temp;
      for(int a = 0; a < j; a++){
        temp[a] = '\0';
      }
      k++;
      j = 0;
    }
    else{
      temp[j] = c;
      j++;
    }
  }

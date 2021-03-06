#include <LCD4Bit_mod.h> 
#include <EEPROM.h>
//create object to control an LCD.  
//number of lines in display=1
LCD4Bit_mod lcd = LCD4Bit_mod(2); 


int  adc_key_val[5] ={30, 150, 360, 535, 760 };
int NUM_KEYS = 5;
int adc_key_in;
int key=-1;
int oldkey=-1;
long randno;
int EEPROM_SIZE = 1024;
void setup() { 
  pinMode(13, OUTPUT);  //we'll use the debug LED to output a heartbeat

  lcd.init();
  //optionally, now set up our application-specific display settings, overriding whatever the lcd did in lcd.init()
  //lcd.commandWrite(0x0F);//cursor on, display on, blink on.  (nasty!)
  lcd.clear();
  lcd.printIn("GGHC Phase 0");
  randomSeed(analogRead(0));
}

void loop(){
  adc_key_in = analogRead(0);
  key = get_key(adc_key_in);
  if(key != oldkey){
    delay(50);
    adc_key_in = analogRead(0);
    key = get_key(adc_key_in);
    if(key != oldkey){
      oldkey = key;
      if(key >= 0){
        randno = random(7);
        read_word(randno);
      }
    }
  }
}

int get_key(unsigned int input)
{
  int k;
    
  for (k = 0; k < NUM_KEYS; k++)
  {
    if (input < adc_key_val[k])
    {     
      return k;
    }
  }
    
  if (k >= NUM_KEYS)
      k = -1;     // No valid key pressed
    
  return k;
}

void load_word(){
  char words[255] = "Hello:I:am:happy:sad:very:not";
  for(int i=0;i<29;i++){
    EEPROM.write(i,words[i]);
  }
}

void print_clear(){
 lcd.clear();  
}

void print_word(char *c,int pos){
  //Just so we can abstract out lcd
  lcd.cursorTo(1,pos);
  lcd.printIn(c);
}

void read_word(int pos){
  char check="";
  int count = 0;
  int new_pos = seek_delimiter(pos);
  print_clear();
  while(check != ":"){
    check = EEPROM.read(new_pos);
    if(check==":"){
      break;
    }
    print_word(check,count);
    count++;
    new_pos++;
  }
}

int seek_delimiter(int pos){
  char check;
  int new_pos=-1;
  int i = 0;
  
  while(1){
    check = EEPROM.read(i);
    if(check == ':'){
      new_pos = i + 1;
      break;
    }
    if(i == EEPROM_SIZE){
      i = 0;
    }
    i++;
  }
  return new_pos;
}

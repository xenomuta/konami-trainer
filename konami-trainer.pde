/*

 NES Controller Pins
 +----> Power  (white)
 |
 5+---------+  7
 | x  x  o   \
 | o  o  o  o |
 4+------------+ 1
 |  |  |  |
 |  |  |  +-> Ground (brown)
 |  |  +----> Pulse  (red)
 |  +-------> Latch  (orange)
 +----------> Data   (yellow)
 
 */

#define NES_UP 0x77
#define NES_DOWN 0x7B
#define NES_LEFT 0x7D
#define NES_RIGHT 0x7E
#define NES_SELECT 0x5F
#define NES_START 0x6F
#define NES_B 0x3F
#define NES_A 0x7F
#define NES_NONE 0xFF

// Set to true for Serial port debugging. Good for n00bs
#define DEBUG true

int clock = 12; // set the clock pin
int latch = 11; // set the latch pin
int datin = 4;  // set the data in pin

byte controller_data = 0;

byte button_down = false;

int ledpin = 13, ledstatus = LOW;

int konami_offset = 0, konami_time, konami_code[] = {
  NES_UP, NES_UP, NES_DOWN, NES_DOWN, NES_LEFT, NES_RIGHT, NES_LEFT, NES_RIGHT, NES_B, NES_A
};

void setup() {
  if (DEBUG) {
    Serial.begin(57600);
    Serial.println("Konami Trainer - XenoMuta <xenomuta@gmail.com>");
  }
  pinMode(latch,OUTPUT);
  pinMode(clock,OUTPUT);
  pinMode(datin,INPUT);
  pinMode(ledpin, OUTPUT);

  digitalWrite(ledpin,ledstatus);
  digitalWrite(latch,HIGH);
  digitalWrite(clock,HIGH);
}

void controllerRead() {
  controller_data = 0;
  digitalWrite(latch,LOW);
  digitalWrite(clock,LOW);

  digitalWrite(latch,HIGH);
  delayMicroseconds(2);
  digitalWrite(latch,LOW);

  controller_data = digitalRead(datin);

  for (int i = 1; i <= 7; i ++) {
    digitalWrite(clock,HIGH);
    delayMicroseconds(2);
    controller_data = controller_data << 1;
    controller_data = controller_data + digitalRead(datin) ;
    delayMicroseconds(4);
    digitalWrite(clock,LOW);
  }
}

void debugNES(int button) {
  if (button_down) return;
  switch (button) {
  case NES_UP: 
    Serial.println("Up"); 
    break;
  case NES_DOWN: 
    Serial.println("Down"); 
    break;
  case NES_LEFT: 
    Serial.println("Left"); 
    break;
  case NES_RIGHT: 
    Serial.println("Right"); 
    break;
  case NES_SELECT: 
    Serial.println("Select"); 
    break;
  case NES_START: 
    Serial.println("Start"); 
    break;
  case NES_B: 
    Serial.println("B"); 
    break;
  case NES_A: 
    Serial.println("A"); 
    break;
  case NES_NONE: 
    break;
  default:
    Serial.println(button, HEX);
  }
}

void loop() {
  controllerRead();

  if (DEBUG) debugNES(controller_data);

  int cambio = button_down;
  button_down = (controller_data != NES_NONE);
  cambio = button_down != cambio;
  
  if (button_down && cambio && controller_data == konami_code[konami_offset]) {
    if (konami_offset == 0) konami_time = millis();
    if (millis() - konami_time < 500) {
      if (++konami_offset == 10) {
        konami_offset = 0;
        digitalWrite(ledpin, (ledstatus = !ledstatus));
        if (DEBUG) Serial.println("Konami Code detected!!!!");
      }
    } else konami_offset = 0;
    konami_time = millis();
  }
  
  delay(10);
}


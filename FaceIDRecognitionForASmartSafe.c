/* Configure the data bus and Control bus as per the hardware connection
   Dtatus bus is connected to PB4:PB7 and control bus PB0:PB2*/
#define LcdDataBus      PORTD
#define LcdControlBus   PORTD
#define LcdDataBusDirnReg   TRISD
#define LCD_RS     0
#define LCD_RW     1
#define LCD_EN     2
#define SBIT_TXEN 5
#define SBIT_SPEN 7
#define SBIT_CREN 4
unsigned int k;
char IncData;
unsigned int angle;
unsigned int cntr=0;
unsigned int cc;
unsigned int Dcntr;
unsigned char HL;//High Low
unsigned char flag;
unsigned int tick,i;
unsigned int T1overflow;
unsigned long T1counts;
unsigned long T1time;
unsigned long Distance;
unsigned int Kcntr;
void usDelay(unsigned int);
void msDelay(unsigned int);

/* local function to generate delay */
void delay(unsigned int count){
     cntr = 0;
     while(cntr < count);
}

//->servo motor
void myDelay(unsigned int x);
void interrupt(void){ //interrupt service routine
   if(INTCON&0x04){// will get here every 1ms (TMR0 overflow)
    TMR0=248; //reload TMR0
    cntr++;
    INTCON = INTCON & 0xFB; //clear T0IF
}
if(PIR1&0x04){             //CCP1 interrupt (every 20ms)
   if(HL){                 //high
     CCPR1H= angle >>8;    //To take the MSB
     CCPR1L= angle;        //To take the LSB
     HL=0;                 //next time low
     CCP1CON=0x09;         //next time Falling edge
     TMR1H=0;
     TMR1L=0;
   }
   else{  //low
     CCPR1H= (40000 - angle) >>8; //40000 is 20ms
     CCPR1L= (40000 - angle);     //40000 is 20ms
     CCP1CON=0x08;                //next time rising edge
     HL=1;                        //next time High
     TMR1H=0;                     //reset TMR1
     TMR1L=0;                     //reset TMR1
   }

 PIR1=PIR1&0xFB;
 }
 if(PIR1&0x01){                   //TMR1 ovwerflow
   PIR1=PIR1&0xFE;
 }

 }




/* Function to send the command to LCD.
   As it is 4bit mode, a byte of data is sent in two 4-bit nibbles */
void Lcd_CmdWrite(char cmd)
{
    LcdDataBus = (cmd & 0xF0);     //Send higher nibble
    LcdControlBus &= ~(1<<LCD_RS); // Send LOW pulse on RS pin for selecting Command register
    LcdControlBus &= ~(1<<LCD_RW); // Send LOW pulse on RW pin for Write operation
    LcdControlBus |= (1<<LCD_EN);  // Generate a High-to-low pulse on EN pin
    delay_ms(50);
    LcdControlBus &= ~(1<<LCD_EN);

    delay_ms(100);

    LcdDataBus = ((cmd<<4) & 0xF0); //Send Lower nibble
    LcdControlBus &= ~(1<<LCD_RS);  // Send LOW pulse on RS pin for selecting Command register
    LcdControlBus &= ~(1<<LCD_RW);  // Send LOW pulse on RW pin for Write operation
    LcdControlBus |= (1<<LCD_EN);   // Generate a High-to-low pulse on EN pin
    delay_ms(50);
    LcdControlBus &= ~(1<<LCD_EN);

    delay_ms(100);
}



/* Function to send the Data to LCD.
   As it is 4bit mode, a byte of data is sent in two 4-bit nibbles */
void Lcd_DataWrite(char dat)
{
    LcdDataBus = (dat & 0xF0);      //Send higher nibble
    LcdControlBus |= (1<<LCD_RS);   // Send HIGH pulse on RS pin for selecting data register
    LcdControlBus &= ~(1<<LCD_RW);  // Send LOW pulse on RW pin for Write operation
    LcdControlBus |= (1<<LCD_EN);   // Generate a High-to-low pulse on EN pin
//    delay(500);
    delay_ms(50);
    LcdControlBus &= ~(1<<LCD_EN);

    delay_ms(100);

    LcdDataBus = ((dat<<4) & 0xF0);  //Send Lower nibble
    LcdControlBus |= (1<<LCD_RS);    // Send HIGH pulse on RS pin for selecting data register
    LcdControlBus &= ~(1<<LCD_RW);   // Send LOW pulse on RW pin for Write operation
    LcdControlBus |= (1<<LCD_EN);    // Generate a High-to-low pulse on EN pin
    delay_ms(50);
    LcdControlBus &= ~(1<<LCD_EN);

    delay_ms(10);
}



int main()
{  unsigned char i,Denied[]={"Access Denied!!"};
   unsigned char n,Granted[]={"Access Granted!!"};
   unsigned char v,Welcome[]={"Welcome!"};
   unsigned char s,Students[]={"Three Failed"};
   unsigned char t,Try[]={"Attempts!"};
   unsigned char a;
   int counter=0;
    TRISB = 0x02;                   //RB1 is input
    PORTB = 0x00;
    TRISC = 0x80;                   //RC7 Input, Rest Output
    PORTC = 0x00;
    TMR1L=0;
    TMR1H=0;
    HL=1;                          //start high
    CCP1CON=0x08;                  //Compare mode, set output on match
    OPTION_REG = 0x87;             //Fosc/4 with 256 prescaler => incremetn every 0.5us*256=128us ==> overflow 8count*128us=1ms to overflow
    T1CON=0x01;                    //TMR1 On Fosc/4 (inc 0.5uS) with 0 prescaler (TMR1 overflow after 0xFFFF counts ==65535)==> 32.767ms
    INTCON = INTCON | 0xA0;        //Global interrupt enable, TMR0 interrupt enable
    PIE1=PIE1|0x04;                //Enable CCP1 interrupts
    CCPR1H=2000>>8;                //MSB
    CCPR1L=2000;                   //LSB
    LcdDataBusDirnReg = 0x00;      //Configure all the LCD pins as output


    Lcd_CmdWrite(0x02);        // Initialize Lcd in 4-bit mode
    Lcd_CmdWrite(0x28);        // enable 5x7 mode for chars
    Lcd_CmdWrite(0x0E);        // Display OFF, Cursor ON
    Lcd_CmdWrite(0x01);        // Clear Display
    Lcd_CmdWrite(0x80);        // Move the cursor to beginning of first line

    UART1_Init(9600);          // Initialize UART module at 9600 bps
    delay(100);                // Wait for UART module to stabilize

    //Lcd_CmdWrite(0xc0);      // Go to Next line and display Good Morning

    PORTB = PORTB | 0x02;
    angle=3045;                 //Closed
    while(1){
    PORTB = PORTB & 0x00;      //Make sure all the leds are closed
    PORTC = PORTC & 0X80;      //Make sure the door is closed
     if((PORTB | 0x00)==0){    //IR sensor detected a body
     PORTB = PORTB | 0x04;     //Yellow LED ON

        Lcd_CmdWrite(0x01);
        for(v=0;Welcome[v]!=0;v++){  //Display Welcome
        Lcd_DataWrite(Welcome[v]);}
        //----> Reading Data From Bluetooth:
         while(!UART1_Data_Ready()); //Read from Bluetooth
          if (UART1_Data_Ready()){
          IncData = UART1_Read();           //Store the received data in IncData
          if ( IncData == '1') {            //If it received 1, then this person is allowed to open the safe box
          PORTB = PORTB | 0X08;             //Turn on green
          Lcd_CmdWrite(0x01);               //Clear Display
           for(n=0;Granted[n]!=0;n++){      //Display Granted
                  Lcd_DataWrite(Granted[n]);}
           angle=1165;                      //Open the safe box's door
           delay(9000);
           angle=3045;                     //Close the safe box's door
           Lcd_CmdWrite(0x01);             //Clear display
           delay(2500);

      }
        else if (IncData == '0')  {
      counter++;
      PORTB = PORTB & 0X00;
      PORTB = PORTB | 0X20;               //Open red led
      Lcd_CmdWrite(0x01);
      for(i=0;Denied[i]!=0;i++)           //Denied
          {
              Lcd_DataWrite(Denied[i]);
          }
           delay(4000);
           Lcd_CmdWrite(0x01);

       if(counter == 3) {
         PORTB = PORTB & 0X00;           //Make sure all other Leds are off
         PORTB = PORTB | 0X30;           //Red led On, buzzer on
         delay(2000);

         counter = 0;
         for(s=0;Students[s]!=0;s++)     //Denied
          {
              Lcd_DataWrite(Students[s]);
          }
      Lcd_CmdWrite(0xc0);
           for(t=0;Try[t]!=0;t++)         //Denied
          {
              Lcd_DataWrite(Try[t]);
          }
          delay(2500);
          PORTB = PORTB & 0X20;           //Turn of buzzer
          Lcd_CmdWrite(0x01);
       }
      delay(2000);
      angle=3045;                        //Close safe box door
             }
      }
       PORTB = PORTB & 0x00;
       }

      else {
          PORTB = PORTB & 0x00;          //LEds OFF
      }


}
}
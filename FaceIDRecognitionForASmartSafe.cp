#line 1 "C:/Users/Public/Documents/Mikroelektronika/mikroC PRO for PIC/Examples/FaceIDRecognitionForASmartSafe.c"
#line 12 "C:/Users/Public/Documents/Mikroelektronika/mikroC PRO for PIC/Examples/FaceIDRecognitionForASmartSafe.c"
unsigned int k;
char IncData;
unsigned int angle;
unsigned int cntr=0;
unsigned int cc;
unsigned int Dcntr;
unsigned char HL;
unsigned char flag;
unsigned int tick,i;
unsigned int T1overflow;
unsigned long T1counts;
unsigned long T1time;
unsigned long Distance;
unsigned int Kcntr;
void usDelay(unsigned int);
void msDelay(unsigned int);


void delay(unsigned int count){
 cntr = 0;
 while(cntr < count);
}


void myDelay(unsigned int x);
void interrupt(void){
 if(INTCON&0x04){
 TMR0=248;
 cntr++;
 INTCON = INTCON & 0xFB;
}
if(PIR1&0x04){
 if(HL){
 CCPR1H= angle >>8;
 CCPR1L= angle;
 HL=0;
 CCP1CON=0x09;
 TMR1H=0;
 TMR1L=0;
 }
 else{
 CCPR1H= (40000 - angle) >>8;
 CCPR1L= (40000 - angle);
 CCP1CON=0x08;
 HL=1;
 TMR1H=0;
 TMR1L=0;
 }

 PIR1=PIR1&0xFB;
 }
 if(PIR1&0x01){
 PIR1=PIR1&0xFE;
 }

 }
#line 74 "C:/Users/Public/Documents/Mikroelektronika/mikroC PRO for PIC/Examples/FaceIDRecognitionForASmartSafe.c"
void Lcd_CmdWrite(char cmd)
{
  PORTD  = (cmd & 0xF0);
  PORTD  &= ~(1<< 0 );
  PORTD  &= ~(1<< 1 );
  PORTD  |= (1<< 2 );
 delay_ms(50);
  PORTD  &= ~(1<< 2 );

 delay_ms(100);

  PORTD  = ((cmd<<4) & 0xF0);
  PORTD  &= ~(1<< 0 );
  PORTD  &= ~(1<< 1 );
  PORTD  |= (1<< 2 );
 delay_ms(50);
  PORTD  &= ~(1<< 2 );

 delay_ms(100);
}
#line 99 "C:/Users/Public/Documents/Mikroelektronika/mikroC PRO for PIC/Examples/FaceIDRecognitionForASmartSafe.c"
void Lcd_DataWrite(char dat)
{
  PORTD  = (dat & 0xF0);
  PORTD  |= (1<< 0 );
  PORTD  &= ~(1<< 1 );
  PORTD  |= (1<< 2 );

 delay_ms(50);
  PORTD  &= ~(1<< 2 );

 delay_ms(100);

  PORTD  = ((dat<<4) & 0xF0);
  PORTD  |= (1<< 0 );
  PORTD  &= ~(1<< 1 );
  PORTD  |= (1<< 2 );
 delay_ms(50);
  PORTD  &= ~(1<< 2 );

 delay_ms(10);
}



int main()
{ unsigned char i,Denied[]={"Access Denied!!"};
 unsigned char n,Granted[]={"Access Granted!!"};
 unsigned char v,Welcome[]={"Welcome!"};
 unsigned char s,Students[]={"Three Failed"};
 unsigned char t,Try[]={"Attempts!"};
 unsigned char a;
 int counter=0;
 TRISB = 0x02;
 PORTB = 0x00;
 TRISC = 0x80;
 PORTC = 0x00;
 TMR1L=0;
 TMR1H=0;
 HL=1;
 CCP1CON=0x08;
 OPTION_REG = 0x87;
 T1CON=0x01;
 INTCON = INTCON | 0xA0;
 PIE1=PIE1|0x04;
 CCPR1H=2000>>8;
 CCPR1L=2000;
  TRISD  = 0x00;


 Lcd_CmdWrite(0x02);
 Lcd_CmdWrite(0x28);
 Lcd_CmdWrite(0x0E);
 Lcd_CmdWrite(0x01);
 Lcd_CmdWrite(0x80);

 UART1_Init(9600);
 delay(100);



 PORTB = PORTB | 0x02;
 angle=3045;
 while(1){
 PORTB = PORTB & 0x00;
 PORTC = PORTC & 0X80;
 if((PORTB | 0x00)==0){
 PORTB = PORTB | 0x04;

 Lcd_CmdWrite(0x01);
 for(v=0;Welcome[v]!=0;v++){
 Lcd_DataWrite(Welcome[v]);}

 while(!UART1_Data_Ready());
 if (UART1_Data_Ready()){
 IncData = UART1_Read();
 if ( IncData == '1') {
 PORTB = PORTB | 0X08;
 Lcd_CmdWrite(0x01);
 for(n=0;Granted[n]!=0;n++){
 Lcd_DataWrite(Granted[n]);}
 angle=1165;
 delay(9000);
 angle=3045;
 Lcd_CmdWrite(0x01);
 delay(2500);

 }
 else if (IncData == '0') {
 counter++;
 PORTB = PORTB & 0X00;
 PORTB = PORTB | 0X20;
 Lcd_CmdWrite(0x01);
 for(i=0;Denied[i]!=0;i++)
 {
 Lcd_DataWrite(Denied[i]);
 }
 delay(4000);
 Lcd_CmdWrite(0x01);

 if(counter == 3) {
 PORTB = PORTB & 0X00;
 PORTB = PORTB | 0X30;
 delay(2000);

 counter = 0;
 for(s=0;Students[s]!=0;s++)
 {
 Lcd_DataWrite(Students[s]);
 }
 Lcd_CmdWrite(0xc0);
 for(t=0;Try[t]!=0;t++)
 {
 Lcd_DataWrite(Try[t]);
 }
 delay(2500);
 PORTB = PORTB & 0X20;
 Lcd_CmdWrite(0x01);
 }
 delay(2000);
 angle=3045;
 }
 }
 PORTB = PORTB & 0x00;
 }

 else {
 PORTB = PORTB & 0x00;
 }


}
}

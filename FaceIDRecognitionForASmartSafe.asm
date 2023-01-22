
_delay:

;FaceIDRecognitionForASmartSafe.c,30 :: 		void delay(unsigned int count){
;FaceIDRecognitionForASmartSafe.c,31 :: 		cntr = 0;
	CLRF       _cntr+0
	CLRF       _cntr+1
;FaceIDRecognitionForASmartSafe.c,32 :: 		while(cntr < count);
L_delay0:
	MOVF       FARG_delay_count+1, 0
	SUBWF      _cntr+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__delay42
	MOVF       FARG_delay_count+0, 0
	SUBWF      _cntr+0, 0
L__delay42:
	BTFSC      STATUS+0, 0
	GOTO       L_delay1
	GOTO       L_delay0
L_delay1:
;FaceIDRecognitionForASmartSafe.c,33 :: 		}
L_end_delay:
	RETURN
; end of _delay

_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;FaceIDRecognitionForASmartSafe.c,37 :: 		void interrupt(void){ //interrupt service routine
;FaceIDRecognitionForASmartSafe.c,38 :: 		if(INTCON&0x04){// will get here every 1ms (TMR0 overflow)
	BTFSS      INTCON+0, 2
	GOTO       L_interrupt2
;FaceIDRecognitionForASmartSafe.c,39 :: 		TMR0=248; //reload TMR0
	MOVLW      248
	MOVWF      TMR0+0
;FaceIDRecognitionForASmartSafe.c,40 :: 		cntr++;
	INCF       _cntr+0, 1
	BTFSC      STATUS+0, 2
	INCF       _cntr+1, 1
;FaceIDRecognitionForASmartSafe.c,41 :: 		INTCON = INTCON & 0xFB; //clear T0IF
	MOVLW      251
	ANDWF      INTCON+0, 1
;FaceIDRecognitionForASmartSafe.c,42 :: 		}
L_interrupt2:
;FaceIDRecognitionForASmartSafe.c,43 :: 		if(PIR1&0x04){             //CCP1 interrupt (every 20ms)
	BTFSS      PIR1+0, 2
	GOTO       L_interrupt3
;FaceIDRecognitionForASmartSafe.c,44 :: 		if(HL){                 //high
	MOVF       _HL+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt4
;FaceIDRecognitionForASmartSafe.c,45 :: 		CCPR1H= angle >>8;    //To take the MSB
	MOVF       _angle+1, 0
	MOVWF      R0+0
	CLRF       R0+1
	MOVF       R0+0, 0
	MOVWF      CCPR1H+0
;FaceIDRecognitionForASmartSafe.c,46 :: 		CCPR1L= angle;        //To take the LSB
	MOVF       _angle+0, 0
	MOVWF      CCPR1L+0
;FaceIDRecognitionForASmartSafe.c,47 :: 		HL=0;                 //next time low
	CLRF       _HL+0
;FaceIDRecognitionForASmartSafe.c,48 :: 		CCP1CON=0x09;         //next time Falling edge
	MOVLW      9
	MOVWF      CCP1CON+0
;FaceIDRecognitionForASmartSafe.c,49 :: 		TMR1H=0;
	CLRF       TMR1H+0
;FaceIDRecognitionForASmartSafe.c,50 :: 		TMR1L=0;
	CLRF       TMR1L+0
;FaceIDRecognitionForASmartSafe.c,51 :: 		}
	GOTO       L_interrupt5
L_interrupt4:
;FaceIDRecognitionForASmartSafe.c,53 :: 		CCPR1H= (40000 - angle) >>8; //40000 is 20ms
	MOVF       _angle+0, 0
	SUBLW      64
	MOVWF      R3+0
	MOVF       _angle+1, 0
	BTFSS      STATUS+0, 0
	ADDLW      1
	SUBLW      156
	MOVWF      R3+1
	MOVF       R3+1, 0
	MOVWF      R0+0
	CLRF       R0+1
	MOVF       R0+0, 0
	MOVWF      CCPR1H+0
;FaceIDRecognitionForASmartSafe.c,54 :: 		CCPR1L= (40000 - angle);     //40000 is 20ms
	MOVF       R3+0, 0
	MOVWF      CCPR1L+0
;FaceIDRecognitionForASmartSafe.c,55 :: 		CCP1CON=0x08;                //next time rising edge
	MOVLW      8
	MOVWF      CCP1CON+0
;FaceIDRecognitionForASmartSafe.c,56 :: 		HL=1;                        //next time High
	MOVLW      1
	MOVWF      _HL+0
;FaceIDRecognitionForASmartSafe.c,57 :: 		TMR1H=0;                     //reset TMR1
	CLRF       TMR1H+0
;FaceIDRecognitionForASmartSafe.c,58 :: 		TMR1L=0;                     //reset TMR1
	CLRF       TMR1L+0
;FaceIDRecognitionForASmartSafe.c,59 :: 		}
L_interrupt5:
;FaceIDRecognitionForASmartSafe.c,61 :: 		PIR1=PIR1&0xFB;
	MOVLW      251
	ANDWF      PIR1+0, 1
;FaceIDRecognitionForASmartSafe.c,62 :: 		}
L_interrupt3:
;FaceIDRecognitionForASmartSafe.c,63 :: 		if(PIR1&0x01){                   //TMR1 ovwerflow
	BTFSS      PIR1+0, 0
	GOTO       L_interrupt6
;FaceIDRecognitionForASmartSafe.c,64 :: 		PIR1=PIR1&0xFE;
	MOVLW      254
	ANDWF      PIR1+0, 1
;FaceIDRecognitionForASmartSafe.c,65 :: 		}
L_interrupt6:
;FaceIDRecognitionForASmartSafe.c,67 :: 		}
L_end_interrupt:
L__interrupt44:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_Lcd_CmdWrite:

;FaceIDRecognitionForASmartSafe.c,74 :: 		void Lcd_CmdWrite(char cmd)
;FaceIDRecognitionForASmartSafe.c,76 :: 		LcdDataBus = (cmd & 0xF0);     //Send higher nibble
	MOVLW      240
	ANDWF      FARG_Lcd_CmdWrite_cmd+0, 0
	MOVWF      PORTD+0
;FaceIDRecognitionForASmartSafe.c,77 :: 		LcdControlBus &= ~(1<<LCD_RS); // Send LOW pulse on RS pin for selecting Command register
	BCF        PORTD+0, 0
;FaceIDRecognitionForASmartSafe.c,78 :: 		LcdControlBus &= ~(1<<LCD_RW); // Send LOW pulse on RW pin for Write operation
	BCF        PORTD+0, 1
;FaceIDRecognitionForASmartSafe.c,79 :: 		LcdControlBus |= (1<<LCD_EN);  // Generate a High-to-low pulse on EN pin
	BSF        PORTD+0, 2
;FaceIDRecognitionForASmartSafe.c,80 :: 		delay_ms(50);
	MOVLW      130
	MOVWF      R12+0
	MOVLW      221
	MOVWF      R13+0
L_Lcd_CmdWrite7:
	DECFSZ     R13+0, 1
	GOTO       L_Lcd_CmdWrite7
	DECFSZ     R12+0, 1
	GOTO       L_Lcd_CmdWrite7
	NOP
	NOP
;FaceIDRecognitionForASmartSafe.c,81 :: 		LcdControlBus &= ~(1<<LCD_EN);
	BCF        PORTD+0, 2
;FaceIDRecognitionForASmartSafe.c,83 :: 		delay_ms(100);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      4
	MOVWF      R12+0
	MOVLW      186
	MOVWF      R13+0
L_Lcd_CmdWrite8:
	DECFSZ     R13+0, 1
	GOTO       L_Lcd_CmdWrite8
	DECFSZ     R12+0, 1
	GOTO       L_Lcd_CmdWrite8
	DECFSZ     R11+0, 1
	GOTO       L_Lcd_CmdWrite8
	NOP
;FaceIDRecognitionForASmartSafe.c,85 :: 		LcdDataBus = ((cmd<<4) & 0xF0); //Send Lower nibble
	MOVF       FARG_Lcd_CmdWrite_cmd+0, 0
	MOVWF      R0+0
	RLF        R0+0, 1
	BCF        R0+0, 0
	RLF        R0+0, 1
	BCF        R0+0, 0
	RLF        R0+0, 1
	BCF        R0+0, 0
	RLF        R0+0, 1
	BCF        R0+0, 0
	MOVLW      240
	ANDWF      R0+0, 0
	MOVWF      PORTD+0
;FaceIDRecognitionForASmartSafe.c,86 :: 		LcdControlBus &= ~(1<<LCD_RS);  // Send LOW pulse on RS pin for selecting Command register
	BCF        PORTD+0, 0
;FaceIDRecognitionForASmartSafe.c,87 :: 		LcdControlBus &= ~(1<<LCD_RW);  // Send LOW pulse on RW pin for Write operation
	BCF        PORTD+0, 1
;FaceIDRecognitionForASmartSafe.c,88 :: 		LcdControlBus |= (1<<LCD_EN);   // Generate a High-to-low pulse on EN pin
	BSF        PORTD+0, 2
;FaceIDRecognitionForASmartSafe.c,89 :: 		delay_ms(50);
	MOVLW      130
	MOVWF      R12+0
	MOVLW      221
	MOVWF      R13+0
L_Lcd_CmdWrite9:
	DECFSZ     R13+0, 1
	GOTO       L_Lcd_CmdWrite9
	DECFSZ     R12+0, 1
	GOTO       L_Lcd_CmdWrite9
	NOP
	NOP
;FaceIDRecognitionForASmartSafe.c,90 :: 		LcdControlBus &= ~(1<<LCD_EN);
	BCF        PORTD+0, 2
;FaceIDRecognitionForASmartSafe.c,92 :: 		delay_ms(100);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      4
	MOVWF      R12+0
	MOVLW      186
	MOVWF      R13+0
L_Lcd_CmdWrite10:
	DECFSZ     R13+0, 1
	GOTO       L_Lcd_CmdWrite10
	DECFSZ     R12+0, 1
	GOTO       L_Lcd_CmdWrite10
	DECFSZ     R11+0, 1
	GOTO       L_Lcd_CmdWrite10
	NOP
;FaceIDRecognitionForASmartSafe.c,93 :: 		}
L_end_Lcd_CmdWrite:
	RETURN
; end of _Lcd_CmdWrite

_Lcd_DataWrite:

;FaceIDRecognitionForASmartSafe.c,99 :: 		void Lcd_DataWrite(char dat)
;FaceIDRecognitionForASmartSafe.c,101 :: 		LcdDataBus = (dat & 0xF0);      //Send higher nibble
	MOVLW      240
	ANDWF      FARG_Lcd_DataWrite_dat+0, 0
	MOVWF      PORTD+0
;FaceIDRecognitionForASmartSafe.c,102 :: 		LcdControlBus |= (1<<LCD_RS);   // Send HIGH pulse on RS pin for selecting data register
	BSF        PORTD+0, 0
;FaceIDRecognitionForASmartSafe.c,103 :: 		LcdControlBus &= ~(1<<LCD_RW);  // Send LOW pulse on RW pin for Write operation
	BCF        PORTD+0, 1
;FaceIDRecognitionForASmartSafe.c,104 :: 		LcdControlBus |= (1<<LCD_EN);   // Generate a High-to-low pulse on EN pin
	BSF        PORTD+0, 2
;FaceIDRecognitionForASmartSafe.c,106 :: 		delay_ms(50);
	MOVLW      130
	MOVWF      R12+0
	MOVLW      221
	MOVWF      R13+0
L_Lcd_DataWrite11:
	DECFSZ     R13+0, 1
	GOTO       L_Lcd_DataWrite11
	DECFSZ     R12+0, 1
	GOTO       L_Lcd_DataWrite11
	NOP
	NOP
;FaceIDRecognitionForASmartSafe.c,107 :: 		LcdControlBus &= ~(1<<LCD_EN);
	BCF        PORTD+0, 2
;FaceIDRecognitionForASmartSafe.c,109 :: 		delay_ms(100);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      4
	MOVWF      R12+0
	MOVLW      186
	MOVWF      R13+0
L_Lcd_DataWrite12:
	DECFSZ     R13+0, 1
	GOTO       L_Lcd_DataWrite12
	DECFSZ     R12+0, 1
	GOTO       L_Lcd_DataWrite12
	DECFSZ     R11+0, 1
	GOTO       L_Lcd_DataWrite12
	NOP
;FaceIDRecognitionForASmartSafe.c,111 :: 		LcdDataBus = ((dat<<4) & 0xF0);  //Send Lower nibble
	MOVF       FARG_Lcd_DataWrite_dat+0, 0
	MOVWF      R0+0
	RLF        R0+0, 1
	BCF        R0+0, 0
	RLF        R0+0, 1
	BCF        R0+0, 0
	RLF        R0+0, 1
	BCF        R0+0, 0
	RLF        R0+0, 1
	BCF        R0+0, 0
	MOVLW      240
	ANDWF      R0+0, 0
	MOVWF      PORTD+0
;FaceIDRecognitionForASmartSafe.c,112 :: 		LcdControlBus |= (1<<LCD_RS);    // Send HIGH pulse on RS pin for selecting data register
	BSF        PORTD+0, 0
;FaceIDRecognitionForASmartSafe.c,113 :: 		LcdControlBus &= ~(1<<LCD_RW);   // Send LOW pulse on RW pin for Write operation
	BCF        PORTD+0, 1
;FaceIDRecognitionForASmartSafe.c,114 :: 		LcdControlBus |= (1<<LCD_EN);    // Generate a High-to-low pulse on EN pin
	BSF        PORTD+0, 2
;FaceIDRecognitionForASmartSafe.c,115 :: 		delay_ms(50);
	MOVLW      130
	MOVWF      R12+0
	MOVLW      221
	MOVWF      R13+0
L_Lcd_DataWrite13:
	DECFSZ     R13+0, 1
	GOTO       L_Lcd_DataWrite13
	DECFSZ     R12+0, 1
	GOTO       L_Lcd_DataWrite13
	NOP
	NOP
;FaceIDRecognitionForASmartSafe.c,116 :: 		LcdControlBus &= ~(1<<LCD_EN);
	BCF        PORTD+0, 2
;FaceIDRecognitionForASmartSafe.c,118 :: 		delay_ms(10);
	MOVLW      26
	MOVWF      R12+0
	MOVLW      248
	MOVWF      R13+0
L_Lcd_DataWrite14:
	DECFSZ     R13+0, 1
	GOTO       L_Lcd_DataWrite14
	DECFSZ     R12+0, 1
	GOTO       L_Lcd_DataWrite14
	NOP
;FaceIDRecognitionForASmartSafe.c,119 :: 		}
L_end_Lcd_DataWrite:
	RETURN
; end of _Lcd_DataWrite

_main:

;FaceIDRecognitionForASmartSafe.c,123 :: 		int main()
;FaceIDRecognitionForASmartSafe.c,124 :: 		{  unsigned char i,Denied[]={"Access Denied!!"};
	MOVLW      65
	MOVWF      main_Denied_L0+0
	MOVLW      99
	MOVWF      main_Denied_L0+1
	MOVLW      99
	MOVWF      main_Denied_L0+2
	MOVLW      101
	MOVWF      main_Denied_L0+3
	MOVLW      115
	MOVWF      main_Denied_L0+4
	MOVLW      115
	MOVWF      main_Denied_L0+5
	MOVLW      32
	MOVWF      main_Denied_L0+6
	MOVLW      68
	MOVWF      main_Denied_L0+7
	MOVLW      101
	MOVWF      main_Denied_L0+8
	MOVLW      110
	MOVWF      main_Denied_L0+9
	MOVLW      105
	MOVWF      main_Denied_L0+10
	MOVLW      101
	MOVWF      main_Denied_L0+11
	MOVLW      100
	MOVWF      main_Denied_L0+12
	MOVLW      33
	MOVWF      main_Denied_L0+13
	MOVLW      33
	MOVWF      main_Denied_L0+14
	CLRF       main_Denied_L0+15
	MOVLW      65
	MOVWF      main_Granted_L0+0
	MOVLW      99
	MOVWF      main_Granted_L0+1
	MOVLW      99
	MOVWF      main_Granted_L0+2
	MOVLW      101
	MOVWF      main_Granted_L0+3
	MOVLW      115
	MOVWF      main_Granted_L0+4
	MOVLW      115
	MOVWF      main_Granted_L0+5
	MOVLW      32
	MOVWF      main_Granted_L0+6
	MOVLW      71
	MOVWF      main_Granted_L0+7
	MOVLW      114
	MOVWF      main_Granted_L0+8
	MOVLW      97
	MOVWF      main_Granted_L0+9
	MOVLW      110
	MOVWF      main_Granted_L0+10
	MOVLW      116
	MOVWF      main_Granted_L0+11
	MOVLW      101
	MOVWF      main_Granted_L0+12
	MOVLW      100
	MOVWF      main_Granted_L0+13
	MOVLW      33
	MOVWF      main_Granted_L0+14
	MOVLW      33
	MOVWF      main_Granted_L0+15
	CLRF       main_Granted_L0+16
	MOVLW      87
	MOVWF      main_Welcome_L0+0
	MOVLW      101
	MOVWF      main_Welcome_L0+1
	MOVLW      108
	MOVWF      main_Welcome_L0+2
	MOVLW      99
	MOVWF      main_Welcome_L0+3
	MOVLW      111
	MOVWF      main_Welcome_L0+4
	MOVLW      109
	MOVWF      main_Welcome_L0+5
	MOVLW      101
	MOVWF      main_Welcome_L0+6
	MOVLW      33
	MOVWF      main_Welcome_L0+7
	CLRF       main_Welcome_L0+8
	MOVLW      84
	MOVWF      main_Students_L0+0
	MOVLW      104
	MOVWF      main_Students_L0+1
	MOVLW      114
	MOVWF      main_Students_L0+2
	MOVLW      101
	MOVWF      main_Students_L0+3
	MOVLW      101
	MOVWF      main_Students_L0+4
	MOVLW      32
	MOVWF      main_Students_L0+5
	MOVLW      70
	MOVWF      main_Students_L0+6
	MOVLW      97
	MOVWF      main_Students_L0+7
	MOVLW      105
	MOVWF      main_Students_L0+8
	MOVLW      108
	MOVWF      main_Students_L0+9
	MOVLW      101
	MOVWF      main_Students_L0+10
	MOVLW      100
	MOVWF      main_Students_L0+11
	CLRF       main_Students_L0+12
	MOVLW      65
	MOVWF      main_Try_L0+0
	MOVLW      116
	MOVWF      main_Try_L0+1
	MOVLW      116
	MOVWF      main_Try_L0+2
	MOVLW      101
	MOVWF      main_Try_L0+3
	MOVLW      109
	MOVWF      main_Try_L0+4
	MOVLW      112
	MOVWF      main_Try_L0+5
	MOVLW      116
	MOVWF      main_Try_L0+6
	MOVLW      115
	MOVWF      main_Try_L0+7
	MOVLW      33
	MOVWF      main_Try_L0+8
	CLRF       main_Try_L0+9
	CLRF       main_counter_L0+0
	CLRF       main_counter_L0+1
;FaceIDRecognitionForASmartSafe.c,131 :: 		TRISB = 0x02;                   //RB1 is input
	MOVLW      2
	MOVWF      TRISB+0
;FaceIDRecognitionForASmartSafe.c,132 :: 		PORTB = 0x00;
	CLRF       PORTB+0
;FaceIDRecognitionForASmartSafe.c,133 :: 		TRISC = 0x80;                   //RC7 Input, Rest Output
	MOVLW      128
	MOVWF      TRISC+0
;FaceIDRecognitionForASmartSafe.c,134 :: 		PORTC = 0x00;
	CLRF       PORTC+0
;FaceIDRecognitionForASmartSafe.c,135 :: 		TMR1L=0;
	CLRF       TMR1L+0
;FaceIDRecognitionForASmartSafe.c,136 :: 		TMR1H=0;
	CLRF       TMR1H+0
;FaceIDRecognitionForASmartSafe.c,137 :: 		HL=1;                          //start high
	MOVLW      1
	MOVWF      _HL+0
;FaceIDRecognitionForASmartSafe.c,138 :: 		CCP1CON=0x08;                  //Compare mode, set output on match
	MOVLW      8
	MOVWF      CCP1CON+0
;FaceIDRecognitionForASmartSafe.c,139 :: 		OPTION_REG = 0x87;             //Fosc/4 with 256 prescaler => incremetn every 0.5us*256=128us ==> overflow 8count*128us=1ms to overflow
	MOVLW      135
	MOVWF      OPTION_REG+0
;FaceIDRecognitionForASmartSafe.c,140 :: 		T1CON=0x01;                    //TMR1 On Fosc/4 (inc 0.5uS) with 0 prescaler (TMR1 overflow after 0xFFFF counts ==65535)==> 32.767ms
	MOVLW      1
	MOVWF      T1CON+0
;FaceIDRecognitionForASmartSafe.c,141 :: 		INTCON = INTCON | 0xA0;        //Global interrupt enable, TMR0 interrupt enable
	MOVLW      160
	IORWF      INTCON+0, 1
;FaceIDRecognitionForASmartSafe.c,142 :: 		PIE1=PIE1|0x04;                //Enable CCP1 interrupts
	BSF        PIE1+0, 2
;FaceIDRecognitionForASmartSafe.c,143 :: 		CCPR1H=2000>>8;                //MSB
	MOVLW      7
	MOVWF      CCPR1H+0
;FaceIDRecognitionForASmartSafe.c,144 :: 		CCPR1L=2000;                   //LSB
	MOVLW      208
	MOVWF      CCPR1L+0
;FaceIDRecognitionForASmartSafe.c,145 :: 		LcdDataBusDirnReg = 0x00;      //Configure all the LCD pins as output
	CLRF       TRISD+0
;FaceIDRecognitionForASmartSafe.c,148 :: 		Lcd_CmdWrite(0x02);        // Initialize Lcd in 4-bit mode
	MOVLW      2
	MOVWF      FARG_Lcd_CmdWrite_cmd+0
	CALL       _Lcd_CmdWrite+0
;FaceIDRecognitionForASmartSafe.c,149 :: 		Lcd_CmdWrite(0x28);        // enable 5x7 mode for chars
	MOVLW      40
	MOVWF      FARG_Lcd_CmdWrite_cmd+0
	CALL       _Lcd_CmdWrite+0
;FaceIDRecognitionForASmartSafe.c,150 :: 		Lcd_CmdWrite(0x0E);        // Display OFF, Cursor ON
	MOVLW      14
	MOVWF      FARG_Lcd_CmdWrite_cmd+0
	CALL       _Lcd_CmdWrite+0
;FaceIDRecognitionForASmartSafe.c,151 :: 		Lcd_CmdWrite(0x01);        // Clear Display
	MOVLW      1
	MOVWF      FARG_Lcd_CmdWrite_cmd+0
	CALL       _Lcd_CmdWrite+0
;FaceIDRecognitionForASmartSafe.c,152 :: 		Lcd_CmdWrite(0x80);        // Move the cursor to beginning of first line
	MOVLW      128
	MOVWF      FARG_Lcd_CmdWrite_cmd+0
	CALL       _Lcd_CmdWrite+0
;FaceIDRecognitionForASmartSafe.c,154 :: 		UART1_Init(9600);          // Initialize UART module at 9600 bps
	MOVLW      51
	MOVWF      SPBRG+0
	BSF        TXSTA+0, 2
	CALL       _UART1_Init+0
;FaceIDRecognitionForASmartSafe.c,155 :: 		delay(100);                // Wait for UART module to stabilize
	MOVLW      100
	MOVWF      FARG_delay_count+0
	MOVLW      0
	MOVWF      FARG_delay_count+1
	CALL       _delay+0
;FaceIDRecognitionForASmartSafe.c,159 :: 		PORTB = PORTB | 0x02;
	BSF        PORTB+0, 1
;FaceIDRecognitionForASmartSafe.c,160 :: 		angle=3045;                 //Closed
	MOVLW      229
	MOVWF      _angle+0
	MOVLW      11
	MOVWF      _angle+1
;FaceIDRecognitionForASmartSafe.c,161 :: 		while(1){
L_main15:
;FaceIDRecognitionForASmartSafe.c,162 :: 		PORTB = PORTB & 0x00;      //Make sure all the leds are closed
	MOVLW      0
	ANDWF      PORTB+0, 1
;FaceIDRecognitionForASmartSafe.c,163 :: 		PORTC = PORTC & 0X80;      //Make sure the door is closed
	MOVLW      128
	ANDWF      PORTC+0, 1
;FaceIDRecognitionForASmartSafe.c,164 :: 		if((PORTB | 0x00)==0){    //IR sensor detected a body
	MOVF       PORTB+0, 0
	MOVWF      R1+0
	MOVF       R1+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_main17
;FaceIDRecognitionForASmartSafe.c,165 :: 		PORTB = PORTB | 0x04;     //Yellow LED ON
	BSF        PORTB+0, 2
;FaceIDRecognitionForASmartSafe.c,167 :: 		Lcd_CmdWrite(0x01);
	MOVLW      1
	MOVWF      FARG_Lcd_CmdWrite_cmd+0
	CALL       _Lcd_CmdWrite+0
;FaceIDRecognitionForASmartSafe.c,168 :: 		for(v=0;Welcome[v]!=0;v++){  //Display Welcome
	CLRF       main_v_L0+0
L_main18:
	MOVF       main_v_L0+0, 0
	ADDLW      main_Welcome_L0+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	XORLW      0
	BTFSC      STATUS+0, 2
	GOTO       L_main19
;FaceIDRecognitionForASmartSafe.c,169 :: 		Lcd_DataWrite(Welcome[v]);}
	MOVF       main_v_L0+0, 0
	ADDLW      main_Welcome_L0+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      FARG_Lcd_DataWrite_dat+0
	CALL       _Lcd_DataWrite+0
;FaceIDRecognitionForASmartSafe.c,168 :: 		for(v=0;Welcome[v]!=0;v++){  //Display Welcome
	INCF       main_v_L0+0, 1
;FaceIDRecognitionForASmartSafe.c,169 :: 		Lcd_DataWrite(Welcome[v]);}
	GOTO       L_main18
L_main19:
;FaceIDRecognitionForASmartSafe.c,171 :: 		while(!UART1_Data_Ready()); //Read from Bluetooth
L_main21:
	CALL       _UART1_Data_Ready+0
	MOVF       R0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_main22
	GOTO       L_main21
L_main22:
;FaceIDRecognitionForASmartSafe.c,172 :: 		if (UART1_Data_Ready()){
	CALL       _UART1_Data_Ready+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main23
;FaceIDRecognitionForASmartSafe.c,173 :: 		IncData = UART1_Read();           //Store the received data in IncData
	CALL       _UART1_Read+0
	MOVF       R0+0, 0
	MOVWF      _IncData+0
;FaceIDRecognitionForASmartSafe.c,174 :: 		if ( IncData == '1') {            //If it received 1, then this person is allowed to open the safe box
	MOVF       R0+0, 0
	XORLW      49
	BTFSS      STATUS+0, 2
	GOTO       L_main24
;FaceIDRecognitionForASmartSafe.c,175 :: 		PORTB = PORTB | 0X08;             //Turn on green
	BSF        PORTB+0, 3
;FaceIDRecognitionForASmartSafe.c,176 :: 		Lcd_CmdWrite(0x01);               //Clear Display
	MOVLW      1
	MOVWF      FARG_Lcd_CmdWrite_cmd+0
	CALL       _Lcd_CmdWrite+0
;FaceIDRecognitionForASmartSafe.c,177 :: 		for(n=0;Granted[n]!=0;n++){      //Display Granted
	CLRF       main_n_L0+0
L_main25:
	MOVF       main_n_L0+0, 0
	ADDLW      main_Granted_L0+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	XORLW      0
	BTFSC      STATUS+0, 2
	GOTO       L_main26
;FaceIDRecognitionForASmartSafe.c,178 :: 		Lcd_DataWrite(Granted[n]);}
	MOVF       main_n_L0+0, 0
	ADDLW      main_Granted_L0+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      FARG_Lcd_DataWrite_dat+0
	CALL       _Lcd_DataWrite+0
;FaceIDRecognitionForASmartSafe.c,177 :: 		for(n=0;Granted[n]!=0;n++){      //Display Granted
	INCF       main_n_L0+0, 1
;FaceIDRecognitionForASmartSafe.c,178 :: 		Lcd_DataWrite(Granted[n]);}
	GOTO       L_main25
L_main26:
;FaceIDRecognitionForASmartSafe.c,179 :: 		angle=1165;                      //Open the safe box's door
	MOVLW      141
	MOVWF      _angle+0
	MOVLW      4
	MOVWF      _angle+1
;FaceIDRecognitionForASmartSafe.c,180 :: 		delay(9000);
	MOVLW      40
	MOVWF      FARG_delay_count+0
	MOVLW      35
	MOVWF      FARG_delay_count+1
	CALL       _delay+0
;FaceIDRecognitionForASmartSafe.c,181 :: 		angle=3045;                     //Close the safe box's door
	MOVLW      229
	MOVWF      _angle+0
	MOVLW      11
	MOVWF      _angle+1
;FaceIDRecognitionForASmartSafe.c,182 :: 		Lcd_CmdWrite(0x01);             //Clear display
	MOVLW      1
	MOVWF      FARG_Lcd_CmdWrite_cmd+0
	CALL       _Lcd_CmdWrite+0
;FaceIDRecognitionForASmartSafe.c,183 :: 		delay(2500);
	MOVLW      196
	MOVWF      FARG_delay_count+0
	MOVLW      9
	MOVWF      FARG_delay_count+1
	CALL       _delay+0
;FaceIDRecognitionForASmartSafe.c,185 :: 		}
	GOTO       L_main28
L_main24:
;FaceIDRecognitionForASmartSafe.c,186 :: 		else if (IncData == '0')  {
	MOVF       _IncData+0, 0
	XORLW      48
	BTFSS      STATUS+0, 2
	GOTO       L_main29
;FaceIDRecognitionForASmartSafe.c,187 :: 		counter++;
	INCF       main_counter_L0+0, 1
	BTFSC      STATUS+0, 2
	INCF       main_counter_L0+1, 1
;FaceIDRecognitionForASmartSafe.c,188 :: 		PORTB = PORTB & 0X00;
	MOVLW      0
	ANDWF      PORTB+0, 1
;FaceIDRecognitionForASmartSafe.c,189 :: 		PORTB = PORTB | 0X20;               //Open red led
	BSF        PORTB+0, 5
;FaceIDRecognitionForASmartSafe.c,190 :: 		Lcd_CmdWrite(0x01);
	MOVLW      1
	MOVWF      FARG_Lcd_CmdWrite_cmd+0
	CALL       _Lcd_CmdWrite+0
;FaceIDRecognitionForASmartSafe.c,191 :: 		for(i=0;Denied[i]!=0;i++)           //Denied
	CLRF       main_i_L0+0
L_main30:
	MOVF       main_i_L0+0, 0
	ADDLW      main_Denied_L0+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	XORLW      0
	BTFSC      STATUS+0, 2
	GOTO       L_main31
;FaceIDRecognitionForASmartSafe.c,193 :: 		Lcd_DataWrite(Denied[i]);
	MOVF       main_i_L0+0, 0
	ADDLW      main_Denied_L0+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      FARG_Lcd_DataWrite_dat+0
	CALL       _Lcd_DataWrite+0
;FaceIDRecognitionForASmartSafe.c,191 :: 		for(i=0;Denied[i]!=0;i++)           //Denied
	INCF       main_i_L0+0, 1
;FaceIDRecognitionForASmartSafe.c,194 :: 		}
	GOTO       L_main30
L_main31:
;FaceIDRecognitionForASmartSafe.c,195 :: 		delay(4000);
	MOVLW      160
	MOVWF      FARG_delay_count+0
	MOVLW      15
	MOVWF      FARG_delay_count+1
	CALL       _delay+0
;FaceIDRecognitionForASmartSafe.c,196 :: 		Lcd_CmdWrite(0x01);
	MOVLW      1
	MOVWF      FARG_Lcd_CmdWrite_cmd+0
	CALL       _Lcd_CmdWrite+0
;FaceIDRecognitionForASmartSafe.c,198 :: 		if(counter == 3) {
	MOVLW      0
	XORWF      main_counter_L0+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main48
	MOVLW      3
	XORWF      main_counter_L0+0, 0
L__main48:
	BTFSS      STATUS+0, 2
	GOTO       L_main33
;FaceIDRecognitionForASmartSafe.c,199 :: 		PORTB = PORTB & 0X00;           //Make sure all other Leds are off
	MOVLW      0
	ANDWF      PORTB+0, 1
;FaceIDRecognitionForASmartSafe.c,200 :: 		PORTB = PORTB | 0X30;           //Red led On, buzzer on
	MOVLW      48
	IORWF      PORTB+0, 1
;FaceIDRecognitionForASmartSafe.c,201 :: 		delay(2000);
	MOVLW      208
	MOVWF      FARG_delay_count+0
	MOVLW      7
	MOVWF      FARG_delay_count+1
	CALL       _delay+0
;FaceIDRecognitionForASmartSafe.c,203 :: 		counter = 0;
	CLRF       main_counter_L0+0
	CLRF       main_counter_L0+1
;FaceIDRecognitionForASmartSafe.c,204 :: 		for(s=0;Students[s]!=0;s++)     //Denied
	CLRF       main_s_L0+0
L_main34:
	MOVF       main_s_L0+0, 0
	ADDLW      main_Students_L0+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	XORLW      0
	BTFSC      STATUS+0, 2
	GOTO       L_main35
;FaceIDRecognitionForASmartSafe.c,206 :: 		Lcd_DataWrite(Students[s]);
	MOVF       main_s_L0+0, 0
	ADDLW      main_Students_L0+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      FARG_Lcd_DataWrite_dat+0
	CALL       _Lcd_DataWrite+0
;FaceIDRecognitionForASmartSafe.c,204 :: 		for(s=0;Students[s]!=0;s++)     //Denied
	INCF       main_s_L0+0, 1
;FaceIDRecognitionForASmartSafe.c,207 :: 		}
	GOTO       L_main34
L_main35:
;FaceIDRecognitionForASmartSafe.c,208 :: 		Lcd_CmdWrite(0xc0);
	MOVLW      192
	MOVWF      FARG_Lcd_CmdWrite_cmd+0
	CALL       _Lcd_CmdWrite+0
;FaceIDRecognitionForASmartSafe.c,209 :: 		for(t=0;Try[t]!=0;t++)         //Denied
	CLRF       main_t_L0+0
L_main37:
	MOVF       main_t_L0+0, 0
	ADDLW      main_Try_L0+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	XORLW      0
	BTFSC      STATUS+0, 2
	GOTO       L_main38
;FaceIDRecognitionForASmartSafe.c,211 :: 		Lcd_DataWrite(Try[t]);
	MOVF       main_t_L0+0, 0
	ADDLW      main_Try_L0+0
	MOVWF      FSR
	MOVF       INDF+0, 0
	MOVWF      FARG_Lcd_DataWrite_dat+0
	CALL       _Lcd_DataWrite+0
;FaceIDRecognitionForASmartSafe.c,209 :: 		for(t=0;Try[t]!=0;t++)         //Denied
	INCF       main_t_L0+0, 1
;FaceIDRecognitionForASmartSafe.c,212 :: 		}
	GOTO       L_main37
L_main38:
;FaceIDRecognitionForASmartSafe.c,213 :: 		delay(2500);
	MOVLW      196
	MOVWF      FARG_delay_count+0
	MOVLW      9
	MOVWF      FARG_delay_count+1
	CALL       _delay+0
;FaceIDRecognitionForASmartSafe.c,214 :: 		PORTB = PORTB & 0X20;           //Turn of buzzer
	MOVLW      32
	ANDWF      PORTB+0, 1
;FaceIDRecognitionForASmartSafe.c,215 :: 		Lcd_CmdWrite(0x01);
	MOVLW      1
	MOVWF      FARG_Lcd_CmdWrite_cmd+0
	CALL       _Lcd_CmdWrite+0
;FaceIDRecognitionForASmartSafe.c,216 :: 		}
L_main33:
;FaceIDRecognitionForASmartSafe.c,217 :: 		delay(2000);
	MOVLW      208
	MOVWF      FARG_delay_count+0
	MOVLW      7
	MOVWF      FARG_delay_count+1
	CALL       _delay+0
;FaceIDRecognitionForASmartSafe.c,218 :: 		angle=3045;                        //Close safe box door
	MOVLW      229
	MOVWF      _angle+0
	MOVLW      11
	MOVWF      _angle+1
;FaceIDRecognitionForASmartSafe.c,219 :: 		}
L_main29:
L_main28:
;FaceIDRecognitionForASmartSafe.c,220 :: 		}
L_main23:
;FaceIDRecognitionForASmartSafe.c,221 :: 		PORTB = PORTB & 0x00;
	MOVLW      0
	ANDWF      PORTB+0, 1
;FaceIDRecognitionForASmartSafe.c,222 :: 		}
	GOTO       L_main40
L_main17:
;FaceIDRecognitionForASmartSafe.c,225 :: 		PORTB = PORTB & 0x00;          //LEds OFF
	MOVLW      0
	ANDWF      PORTB+0, 1
;FaceIDRecognitionForASmartSafe.c,226 :: 		}
L_main40:
;FaceIDRecognitionForASmartSafe.c,229 :: 		}
	GOTO       L_main15
;FaceIDRecognitionForASmartSafe.c,230 :: 		}
L_end_main:
	GOTO       $+0
; end of _main

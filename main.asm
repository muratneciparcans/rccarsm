; ***************************************************************************
;    
;        Date:    20,04,2016
;
;      Device:    ATmega328p
;   Assembler:    AvrAssembler
;      Author:    Murat Necip Arcan
;     Subject:    USB Port Programming - Web Based Remote Control Car using 3G
;    
;    
; ***************************************************************************
	
	.include "m328pdef.inc" ; Include ATmega328p library to source code

	.device atmega328p

	;Beginning of the Machine (The awakening of Machine)
	.org 0x0000
	 jmp Main

	.org 0x0024 ; Start with 0x0024 part of ATmega328p, and USART Receive Interrupt Vector
	 jmp read_data ; jump to read_data function

	.org 0x0040

	Main:
	  ; Port Manipulation of ATmega328p
	  ; Set the ports for L9110 Dual Channel Motor Drivers 
	  sbi DDRB,0   ;set the port 8 as enable on the map of DDRB
	  sbi DDRB,1   ;set the port 9 as enable on the map of DDRB
	  sbi DDRB,2   ;set the port 10 as enable on the map of DDRB
	  sbi DDRB,3   ;set the port 11 as enable on the map of DDRB

	  cli

	  call Serialread ; Set up USART (Usb Programming)

	  sei ;Allow interrupts

	
	loop:
	rjmp loop ;Wait here until the end of time.


	;Serialread - Initialize the USART (Start serial port communication)
	;Set BAUD rate to 9600 (16MHz system clock)
	Serialread: 
	  clr r17         ; clean the r17 register 
	  sts UBRR0H, r17 ; Write back
	  ldi r16, 0x67   ; Load 0x67 to r16 register
	  sts UBRR0L, r16 ; 

	 
	  
	  ldi r16, 0x98   ;Enable transmitter and receiver.
	  sts UCSR0B, r16 ;Enable interrupts for USART Receive.

	

	read_data:      ; Read the byte data from UDR0 then load to r16 register
	  lds r16,UDR0  ; load the data of UDR0 to r16
	  cpi r16, '1'  ; Compare 1 with r16
	  breq forward  ; if r16 is equal to 1, go to forward function
	                ; if it is not equal to 1, keep the flow to down
	  cpi r16, '2'  ; Compare 2 with r16
	  breq backward ; if r16 is equal to 2, go to backward function
	                ; if it is not equal to 2, keep the flow to down
	  cpi r16, '3'  ; Compare 3 with r16
	  breq left     ; if r16 is equal to 3, go to left function
	                ; if it is not equal to 3, keep the flow to down
	  cpi r16, '4'  ; Compare 4 with r16
	  breq right    ; if r16 equal to 4, go to right function
	                ; if it is not equal to 4, keep the flow to down
	  cpi r16, '5'  ; Compare 5 with r16
	  breq stop     ; if r16 equal to 5, go to stop function
	                ; if it is not equal to 5, keep the flow to down
	  jmp read_data ; If any conditions not true go to read_data, (loop)


	 forward:      ; to Drive forward
	 sbi PORTB, 0  ; Give voltage to PORTB(0) - 8.port on the ATmega328p
	 sbi PORTB, 2  ; Give voltage to PORTB(2) - 10.Port on the ATmega328p
	 lds r16,UDR0  ; load the data of UDR0 to r16
	 cpi r16, '1'  ; Compare 1 with r16
	 breq forward  ; if r16 is equal to 1, go to forward function
	               ; if it is not equal to 1, keep the flow to down
	 cbi PORTB, 0  ; Stop the voltage to PORTB(0)
	 cbi PORTB, 2  ; Stop the voltage to PORTB(2)
	 clr r16       ; clean the r16 register
	 jmp read_data ; go back to read_data
	 
	 backward:     ; to Drive backward
	 sbi PORTB, 1  ; Give voltage to PORTB(1) - 9.port on the ATmega328p
	 sbi PORTB, 3  ; Give voltage to PORTB(3) - 11.port on the ATmega328p
	 lds r16,UDR0  ; load the data of UDR0 to r16
	 cpi r16, '2'  ; Compare 2 with r16
	 breq backward ; if r16 is equal to 2, go to backward function
	               ; if it is not equal to 2, keep the flow to down
	 cbi PORTB, 1  ; Stop the voltage to PORTB(1)
	 cbi PORTB, 3  ; Stop the voltage to PORTB(3)
	 clr r16       ; clean the r16 register
	 jmp read_data ; go back to read_data

	 left:         ; to Drive left
	 sbi PORTB, 0  ; Give voltage to PORTB(1) - 8.port on the ATmega328p
	 sbi PORTB, 1  ; Give voltage to PORTB(3) - 9.port on the ATmega328p
	 lds r16, UDR0 ; load the data of UDR0 to r16
	 cpi r16, '3'  ; Compare 3 with r16
	 breq left     ; if r16 is equal to 3, go to left function
	               ; if it is not equal to 3, keep the flow to down
	 cbi PORTB, 0  ; Stop the voltage to PORTB(0)
	 cbi PORTB, 1  ; Stop the voltage to PORTB(1)
	 clr r16       ; clean the r16 register
	 jmp read_data ; go back to read_data

	 right:        ; to Drive right
	 sbi PORTB, 2  ; Give voltage to PORTB(2) - 10.port on the ATmega328p
	 sbi PORTB, 3  ; Give voltage to PORTB(3) - 11.port on the ATmega328p
	 lds r16, UDR0 ; load the data of UDR0 to r16
	 cpi r16, '4'  ; Compare 4 with r16
	 breq right    ; if r16 is equal to 4, go to right function
	               ; if it is not equal to 4, keep the flow to down
	 cbi PORTB, 2  ; Stop the voltage to PORTB(2)
	 cbi PORTB, 3  ; Stop the voltage to PORTB(3)
	 clr r16       ; clean the r16 register
	 jmp read_data ; go back to read_data


	 stop:         ; to Stop the motors
     NOP           ; do nothing, stop the loops
	 NOP           ; do nothing, stop the loops
	 lds r16, UDR0 ; load the data of UDR0 to r16
	 cpi r16, '5'  ; Compare 5 with r16
	 breq stop     ; if r16 is equal to 4, go to right function
	 clr r16       ; clean the r16 register
	 jmp read_data ; go back to read_data
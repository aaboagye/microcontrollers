

;; void smbus_setup (void)
;; void smbus_send (uint16 eepromaddr, uint8 len, uint8 xdata * buffer);
;; void smbus_receive (uint16 eepromaddr, uint8 len, uint8 xdata * buffer);

;first argument   R7      R6 & R7, MSB in R6
;second argument  R5      R4 & R5, MSB in R4
;third argument   R3      R2 & R3, MSB in R2

;; after sending slave address (on write), send two-byte memory address (always)
;; after sending memory address, 
;;   if write, sending data transmitting 
;;   if read, sending repeated start

;---------------------------------------------------------------------------------
;
; modified from code from SiLabs, Copyright 2001 
;
; Example code to interface a single 256-byte EEPROM to a C8051F00x via the SMBus
; Code assumes a single EEPROM with  slave address 1010000 is connected on 
; the SDA and SCL lines, and no other masters are on the bus.
; 
; The SEND routine performs a 1-byte write to the EEPROM.  This consists of (1) START, 
; (2) slave address + W, (3) memory location byte write, and (4) a data byte write.
; 
; STEPS FOR WRITING TO EEPROM:
;   1) Load slave address into SLA_ADD
;   2) Load memory address into MEM_ADD
;   3) Load data byte into TRANSMIT_BYTE. 
;   4) Call SEND
;
; The RECEIVE routine performs a 1-byte read from the EEPROM. This consists of (1)
; START, (2) slave address + W, (3) memory location byte write, (4) repeated START,
; (5) slave address + R, (6) data byte read.
;
; STEPS FOR RECEIVING DATA:
;   1) Load slave address into SLA_ADD
;   2) Load memory address into MEM_ADD
;   3) Call RECEIVE
;   4) Read RECEIVE_BYTE
;
; The SMBus state table is broken into 8-byte state segments, allowing the SMBus 
; status code (SMB0STA) to be used as a state index.  Note that this leaves only
; 8 bytes of code space per SMBus state definition. As a result, certain tasks
; have been altered to limit state definition lengths:
;
; 1) The SMB_MTDBACK state (Master transmitter, data byte sent, ACK received) is 
; reduced to a bit-check and branch operation.  The branch is outside of the state 
; table, so that a larger code segment may be executed for this state. 
;
; 2) Three data bytes are used for slave address storage: SLA_ADD, WRI_ADD, READ_ADD.
; Rather than using bit-wise operations in the SMBus states, each transfer routine 
; pre-loads the address values.  Since a RECEIVE includes both a WRITE and READ
; transfer, two address bytes are necessary - WRI_ADD and READ_ADD.  SLA_ADD is used
; as a generic slave chip select before a function call. 
;
; Note that SLA_ADD is equivalent to WRI_ADD, since WRI_ADD = SLA_ADD + W (W=0). 
; The two are left separate to clarify the demonstration.
;
;-----------------------------------------------------------------------------------
$NOMOD51

public SMBus_Setup, _SMBUS_SEND, _SMBUS_RECEIVE

;-----------------------------------------------------------------------------------
; EQUATES
;-----------------------------------------------------------------------------------

 $include (c8051f120.inc)          ; Include register definition file.

   WRI_ADD         EQU   0A0h      ; EEPROM slave address for write
   READ_ADD        EQU   0A1h      ; EEPROM slave address for read

   ; SMBus States
   SMB_BUS_ERROR   EQU   00h         ; (all modes) BUS ERROR
   SMB_START       EQU   08h         ; (MT & MR) START transmitted
   SMB_RP_START    EQU   10h         ; (MT & MR) repeated START
   SMB_MTADDACK    EQU   18h         ; (MT) Slave address + W transmitted;
                                     ;  ACK received
   SMB_MTADDNACK   EQU   20h         ; (MT) Slave address + W transmitted;
                                     ;  NACK received
   SMB_MTDBACK     EQU   28h         ; (MT) data byte transmitted; ACK rec'vd
   SMB_MTDBNACK    EQU   30h         ; (MT) data byte transmitted; NACK rec'vd
   SMB_MTARBLOST   EQU   38h         ; (MT) arbitration lost
   SMB_MRADDACK    EQU   40h         ; (MR) Slave address + R transmitted;
                                     ;  ACK received
   SMB_MRADDNACK   EQU   48h         ; (MR) Slave address + R transmitted;
                                     ;  NACK received
   SMB_MRDBACK     EQU   50h         ; (MR) data byte rec'vd; ACK transmitted
   SMB_MRDBNACK    EQU   58h         ; (MR) data byte rec'vd; NACK transmitted


;-----------------------------------------------------------------------------------
; VARIABLES
;-----------------------------------------------------------------------------------


SMBDATA     SEGMENT DATA            ; declare DATA segment
            RSEG  SMBDATA            ; select DATA segment


   MEMMSB_ADD:     DS    1           ; EEPROM memory location to be accessed
   MEMLSB_ADD:     DS    1
   bufmsb:         DS    1           ; external memory buffer address
   buflsb:         DS    1
   buflen:         DS    1           ; number of bytes to transfer
    
SMBUSBITS      SEGMENT BIT
            RSEG  SMBUSBITS

   RW:             DBIT  1           ; R/W command bit. 1=READ, 0=WRITE
   SM_BUSY:        DBIT  1           ; SMBus Busy flag (kept in software)
   NACK_STAT:                        ; Double-up the use of this bit; on
                                     ; read, hold the NACK status after the
                                     ; memory address is transmitted
   MSB_SENT:       DBIT  1           ; Used to indicate address xmit state
   LSB_SENT:       DBIT  1           ; MSB_SENT=1: just sent address MSB 
                                     ; LSB_SENT=1: just sent address LSB 
                                     ; LSB_SENT=0: sending data
   
;------------------------------------------------------------------------------------
; INTERRUPT VECTOR
;------------------------------------------------------------------------------------
   
; SMBus Interrupt Vector
            CSEG AT 03BH
    ljmp  SMBus_ISR

SMBCODE     SEGMENT CODE
            RSEG SMBCODE
            USING 0
   
;---------------------------------------------------------------------------------------
; SUBROUTINES
;---------------------------------------------------------------------------------------

;---------------------------------------------------------------------------------------
; SMBus_Setup
; SMbus setup routine: internal software only


SMBus_Setup:
   clr   SM_BUSY        ; Clears SM_Busy flag for first transfer.
   ret

;---------------------------------------------------------------------------------------
; SEND subroutine.  Assumes that the slave address, memory location, and transmit
; data have all been loaded into their associated variables. This routine manages
; the SM_BUSY bit, sets RW=WRITE, loads the WRI_ADD, and initiates the transfer.
;


;;  memaddr: address in SMBus memory device
;;        R6 & R7
;;  len: number of bytes in buffer
;;        R5
;;  buffer: local buffer to read/write
;;        R2 & R3

_SMBUS_SEND:
   push   ACC                        ; Preserve accumulator
   jb     SM_BUSY, $                 ; Wait for SMBus to be free
   clr    RW                         ; RW = 0 (WRITE)

   mov    MEMMSB_ADD, R6
   mov    MEMLSB_ADD, R7
   mov    buflen, R5
   mov    bufmsb, R2
   mov    buflsb, R3

   setb   SM_BUSY                    ; Occupy SMBus
   setb   STA                        ; Initiate Transfer
   pop    ACC                        ; Restore accumulator

   ret

;---------------------------------------------------------------------------------------
; RECEIVE subroutine. Assumes that the slave address and memory location have been 
; loaded into their associated variables. This routine manages the SM_BUSY bit, sets
; RW=READ, loads the READ_ADD and WRI_ADD, and initiates the transfer.
; 
; Note that the RECEIVE transfer consists of a WRITE of the memory location to be accessed,
; followed by a repeated START and a READ operation.  Therefore, both WRI_ADD
; and READ_ADD are used by this routine.
_SMBUS_RECEIVE:

   push  ACC                          ; Preserve accumulator
   jb    SM_BUSY, $                   ; Wait for SMBus to be free
   setb  RW                           ; RW = 1 (READ)

   mov    MEMMSB_ADD, R6
   mov    MEMLSB_ADD, R7
   mov    buflen, R5
   mov    bufmsb, R2
   mov    buflsb, R3

   setb  SM_BUSY                      ; Occupy SMBus
   setb  STA                          ; Initiate Transfer

   jb    SM_BUSY, $                   ; Wait for receive to finish
   pop   ACC                          ; Restore accumulator

   ret

;--------------------------------------------------------------------------------------
; INTERRUPT VECTOR
;--------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------
; SMBus ISR
;
; Implemented as a state table lookup, with the SMBus status register as the index.
; SMBus status codes are multiples of 8; thus the status code can be used to index
; program segments that are spaced by 8 bytes. Each 'org' command indicates
; a new state, offset from the beginning of the table by its status code value.
; 
; Note that only 8 bytes are available to process each state.  In the cases where
; more than 8 bytes are necessary, the code jumps to a program location outside
; of the state table. This is only necessary in the state 'SMB_MTDBACK'.

SMBus_ISR:

   push   PSW                         ;
   push   ACC                         ;
   push   DPH                         ; Resource preservation
   push   DPL                         ;

   mov   A, SMB0STA                   ; Load accumulator with current SMBus state.
                                      ; State corresponds to the address offset
                                      ; for each state execution

   anl   A, #7Fh                      ; Mask out upper bit, since any states that
                                      ; set this bit are not defined in this code.

   mov   DPTR, #SMB_STATE_TABLE       ; Point DPTR to the beginning of the state table
   jmp   @A+DPTR                      ; Jump to the current state

; SMBus State Table------------------------------------------------------------------------

SMB_STATE_TABLE:                  
   
   ; SMB_BUS_ERROR
   ; All Modes: Bus Error
   ; Reset hardware by setting STOP bit
   org    SMB_STATE_TABLE + SMB_BUS_ERROR
   
      setb  STO
      jmp   SMB_ISR_END               ; Jump to exit ISR

   ; SMB_START
   ; Master Transmitter/Receiver: START transmitted.
   ; The R/W bit will always be a zero (W) in this state because
   ; for both write and read, the memory address must first be written.
   org SMB_STATE_TABLE + SMB_START

      mov   SMB0DAT, #WRI_ADD          ; Load slave address + W
      clr   STA                       ; Manually clear START bit
      jmp   SMB_ISR_END               ; Jump to exit ISR

   ; SMB_RP_START
   ; Master Transmitter/Receiver: Repeated START transmitted.
   ; This state should only occur during a read, after the memory 
   ; address has been sent and acknowledged.
   org    SMB_STATE_TABLE + SMB_RP_START

      mov   SMB0DAT, #READ_ADD         ; Load slave address + R
      clr   STA                       ; Manually clear START bit
      jmp   SMB_ISR_END

   ; SMB_MTADDACK
   ; Master Transmitter: Slave address + WRITE transmitted.
   ; ACK received
   org   SMB_STATE_TABLE + SMB_MTADDACK

; ### transmit MSB of memory address
      mov   SMB0DAT, MEMMSB_ADD       ; Load memory address   
      setb  MSB_SENT                  ; MSB_SENT=1: In the next ISR call,
                                      ; the memory address will have just been
                                      ; sent.                        
      jmp   SMB_ISR_END

   ; SMB_MTADDNACK
   ; Master Transmitter: Slave address + WRITE transmitted. 
   ; NACK received. The slave is not responding. Try again with
   ; acknowledge polling. Send STOP + START.
   org SMB_STATE_TABLE + SMB_MTADDNACK

      setb  STO                              
      setb  STA
      jmp   SMB_ISR_END

   ; SMB_MTDBACK
   ; Master Transmitter: Data byte transmitted. ACK received.
   ; This state is used in both read and write operations.
   ; Check MSB_SENT and LSB_SENT
   org    SMB_STATE_TABLE + SMB_MTDBACK
   
      jbc   MSB_SENT, ADDRMSB_SENT     ; If MSB_SENT=1, clear bit and
                                       ; jump to send the first byte of
                                       ; memory address
      jbc   LSB_SENT, ADDRLSB_SENT     ; If LSB_SENT=1, clear bit and
                                       ; jump to send the second byte of
                                       ; memory address
      jmp   SEND_BUFFER                ; otherwise send the data
   
   ; SMB_MTDBNACK
   ; Master Transmitter: Data byte transmitted.  NACK received.
   ; Slave not responding.  Send STOP followed by START to try again.
   org SMB_STATE_TABLE + SMB_MTDBNACK

      setb  STO
      setb  STA
      jmp   SMB_ISR_END

   ; SMB_MTARBLOST
   ; Master Transmitter: Arbitration Lost.
   ; Should not occur.  If so, restart transfer.
   org SMB_STATE_TABLE + SMB_MTARBLOST

      setb  STO
      setb  STA
      jmp   SMB_ISR_END

   ; SMB_MRADDACK
   ; Master Receiver: Slave address + READ transmitted. ACK received.
   ; Set to transmit NACK after next transfer since it will be the
   ; last (only) byte.
   org SMB_STATE_TABLE + SMB_MRADDACK

      mov   c, NACK_STAT  ; get value for AA flag
      mov   AA, c
      jmp   SMB_ISR_END

   ; SMB_MRADDNACK
   ; Master Receiver: Slave address + READ transmitted. NACK received.
   ; Slave not responding. Send repeated START to try again.
   org SMB_STATE_TABLE + SMB_MRADDNACK
      
      clr   STO
      setb  STA
      jmp   SMB_ISR_END

   ; SMB_MRDBACK
   ; Master Receiver: Data byte received. ACK transmitted.
   ; Should not occur because AA is cleared in previous state.
   ; Send STOP if state does occur.
   org SMB_STATE_TABLE + SMB_MRDBACK

		   jmp	SMB_store

   ; SMB_MRDBNACK
   ; Master Receiver: Data byte received. NACK transmitted.
   ; Read operation completed. Read data register and send STOP
   org SMB_STATE_TABLE + SMB_MRDBNACK
   
      setb  STO
      setb  AA                       ; Set AA for next transfer
      clr   SM_BUSY   
;;    jmp   SMB_store

; End of State Table--------------------------------------------------------------

;---------------------------------------------------------------------------------
; Program segment to handle SMBus states that require more than 8 bytes of program
; space.

; Data bytes being received.  Place into the buffer and determine when to send
; the NACK
SMB_store:
      mov   DPH, bufmsb               ; get buffer pointer
      mov   DPL, buflsb
      mov   A, SMB0DAT                ; store received byte
      movx  @DPTR, A
      inc   DPTR                      ; update the pointer
      mov   bufmsb, DPH
      mov   buflsb, DPL
      dec   buflen                    ; adjust buffer count
      jb    STO, SMB_ISR_END
      mov   a, buflen                 ; if there is more than one
      jnz   SMB_ISR_END               ; byte left, send ACK
      clr   AA
      jmp   SMB_ISR_END

; MSB Address byte has just been sent.  Now send LSB Address byte
ADDRMSB_SENT:
      mov   SMB0DAT, MEMLSB_ADD       ; Load memory address   
      setb  LSB_SENT                  ; LSB_SENT=1: In the next ISR call,
                                      ; the memory address will have just been
                                      ; sent.                        
      jmp   SMB_ISR_END

; LSB Address byte has just been sent.  Check RW.  If R (1), jump to RW_READ.
; If W, load data to transmit into SMB0DAT.
ADDRLSB_SENT:
      jb    RW, RW_READ               ; this is a READ operation

SEND_BUFFER:
      mov   A, buflen                 ; get buffer size
      jz    DATA_SENT                 ; if last byte transmitted, send STOP
      mov   DPH, bufmsb               ; get buffer pointer
      mov   DPL, buflsb
      movx  A,@DPTR                   ; get next piece of data
      mov   SMB0DAT, A                ; send it
      inc   DPTR                      ; increment pointer
      mov   bufmsb, DPH
      mov   buflsb, DPL
      dec   buflen                    ; count the byte
      jmp   SMB_ISR_END               ; Jump to exit ISR

; Operation is a READ, and the address byte has just been sent.  Send
; repeated START to initiate memory read.
RW_READ:
      clr   STO
      setb  STA                         ; Send repeated START

      dec   buflen
      mov   a, #-1                      ; If there is only one byte to
      add   a, buflen                   ; transmit, send NACK after the
      mov   NACK_STAT, c                ; next data byte
      jmp   SMB_ISR_END                 ; Jump to exit ISR

; Operation is a WRITE, and the last data byte has just been sent.  Transfer
; is finished.  Send STOP, free the bus, and exit the ISR.
DATA_SENT:

      setb  STO                         ; Send STOP and exit ISR.
      clr   SM_BUSY                     ; Free SMBus
      jmp   SMB_ISR_END                 ; Jump to exit ISR   
;---------------------------------------------------------------------------------

; SMBus ISR exit. 
; Restore registers, clear SI bit, and return from interrupt.   
SMB_ISR_END:

      clr   SI
      pop   DPL
      pop   DPH
      pop   ACC
      pop   PSW

      reti

END


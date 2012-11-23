//------------------------------------------------------------------------------------
//
// Example code for interfacing a C8051F0xx to three EEPROMs via the SMBus.
// Code assumes that three 16-bit address space EEPROMs are connected
// on the SCL and SDA lines, and configured so that their slave addresses
// are as follows:
// CHIP_A = 1010000
// CHIP_B = 1010001
// CHIP_C = 1010010
//
// Slave and arbitration states are not defined.  Assume the CF000 is the only
// master in the system.
// Functions: SM_Send performs a 1-byte write to the specified EEPROM
// SM_Receive performs a 1-byte read of the specified EEPROM address (both include
// memory address references).
//

//------------------------------------------------------------------------------------
// Global CONSTANTS
//------------------------------------------------------------------------------------

#define WRITE 0x00                  // SMBus WRITE command
#define READ  0x01                  // SMBus READ command

// Device addresses (7 bits, lsb is a don't care)
#define CHIP_A 0xA0                 // Device address for chip A
#define CHIP_B 0xA2                 // Device address for chip B
#define CHIP_C 0xA4                 // Device address for chip C

// SMBus states:
// MT = Master Transmitter
// MR = Master Receiver
#define  SMB_BUS_ERROR  0x00        // (all modes) BUS ERROR
#define  SMB_START      0x08        // (MT & MR) START transmitted
#define  SMB_RP_START   0x10        // (MT & MR) repeated START
#define  SMB_MTADDACK   0x18        // (MT) Slave address + W transmitted;
                                    //  ACK received
#define  SMB_MTADDNACK  0x20        // (MT) Slave address + W transmitted;
                                    //  NACK received
#define  SMB_MTDBACK    0x28        // (MT) data byte transmitted; ACK rec'vd
#define  SMB_MTDBNACK   0x30        // (MT) data byte transmitted; NACK rec'vd
#define  SMB_MTARBLOST  0x38        // (MT) arbitration lost
#define  SMB_MRADDACK   0x40        // (MR) Slave address + R transmitted;
                                    //  ACK received
#define  SMB_MRADDNACK  0x48        // (MR) Slave address + R transmitted;
                                    //  NACK received
#define  SMB_MRDBACK    0x50        // (MR) data byte rec'vd; ACK transmitted
#define  SMB_MRDBNACK   0x58        // (MR) data byte rec'vd; NACK transmitted


//-----------------------------------------------------------------------------------
//Global VARIABLES
//-----------------------------------------------------------------------------------
char COMMAND;                       // Holds the slave address + R/W bit for
                                    // use in the SMBus ISR.

char WORD;                          // Holds data to be transmitted by the SMBus
                                    // OR data that has just been received.

char BYTE_NUMBER;                   // Used by ISR to check what data has just been
                                    // sent - High address byte, Low byte, or data
                                    // byte

unsigned char HIGH_ADD, LOW_ADD;    // High & Low byte for EEPROM memory address

bit SM_BUSY;                        // This bit is set when a send or receive
                                    // is started. It is cleared by the
                                    // ISR when the operation is finished.


//------------------------------------------------------------------------------------
// Function PROTOTYPES
//------------------------------------------------------------------------------------

void SMBus_ISR (void);
void SM_Send (char chip_select, unsigned int byte_address, char out_byte);
char SM_Receive (char chip_select, unsigned int byte_address);


// SMBus byte write function-----------------------------------------------------
// Writes a single byte at the specified memory location.
//
// out_byte = data byte to be written
// byte_address = memory location to be written into (2 bytes)
// chip_select = device address of EEPROM chip to be written to
void SM_Send (char chip_select, unsigned int byte_address, char out_byte)
{
   while (SM_BUSY);                          // Wait for SMBus to be free.
   SM_BUSY = 1;                              // Occupy SMBus (set to busy)
   SMB0CN = 0x44;                            // SMBus enabled,
                                             // ACK on acknowledge cycle

   BYTE_NUMBER = 2;                          // 2 address bytes.
   COMMAND = (chip_select | WRITE);          // Chip select + WRITE

   HIGH_ADD = ((byte_address >> 8) & 0x00FF);// Upper 8 address bits
   LOW_ADD = (byte_address & 0x00FF);        // Lower 8 address bits

   WORD = out_byte;                          // Data to be writen
   
   STO = 0;
   STA = 1;                                  // Start transfer

}

// SMBus random read function------------------------------------------------------
// Reads 1 byte from the specified memory location.
//
// byte_address = memory address of byte to read
// chip_select = device address of EEPROM to be read from
char SM_Receive (char chip_select, unsigned int byte_address)
{
   while (SM_BUSY);                          // Wait for bus to be free.
   SM_BUSY = 1;                              // Occupy SMBus (set to busy)
   SMB0CN = 0x44;                            // SMBus enabled, ACK on acknowledge cycle

   BYTE_NUMBER = 2;                          // 2 address bytes
   COMMAND = (chip_select | READ);           // Chip select + READ

   HIGH_ADD = ((byte_address >> 8) & 0x00FF);// Upper 8 address bits
   LOW_ADD = (byte_address & 0x00FF);        // Lower 8 address bits
   
   STO = 0;
   STA = 1;                                  // Start transfer
   while (SM_BUSY);                          // Wait for transfer to finish
   return WORD;
}


//------------------------------------------------------------------------------------
// Interrupt Service Routine
//------------------------------------------------------------------------------------


// SMBus interrupt service routine:

void SMBUS_ISR (void) interrupt 7
{
   switch (SMB0STA){                   // Status code for the SMBus (SMB0STA register)

      // Master Transmitter/Receiver: START condition transmitted.
      // The R/W bit of the COMMAND word sent after this state will
      // always be a zero (W) because for both read and write,
      // the memory address must be written first.
      case SMB_START:
         SMB0DAT = (COMMAND & 0xFE);   // Load address of the slave to be accessed.
         STA = 0;                      // Manually clear START bit
         break;

      // Master Transmitter/Receiver: Repeated START condition transmitted.
      // This state should only occur during a read, after the memory address has been
      // sent and acknowledged.
      case SMB_RP_START:
         SMB0DAT = COMMAND;            // COMMAND should hold slave address + R.
         STA = 0;
         break;

      // Master Transmitter: Slave address + WRITE transmitted.  ACK received.
      case SMB_MTADDACK:
         SMB0DAT = HIGH_ADD;           // Load high byte of memory address
                                       // to be written.
         break;

      // Master Transmitter: Slave address + WRITE transmitted.  NACK received.
      // The slave is not responding.  Send a STOP followed by a START to try again.
      case SMB_MTADDNACK:
         STO = 1;
         STA = 1;
         break;

      // Master Transmitter: Data byte transmitted.  ACK received.
      // This state is used in both READ and WRITE operations.  Check BYTE_NUMBER
      // for memory address status - if only HIGH_ADD has been sent, load LOW_ADD.
      // If LOW_ADD has been sent, check COMMAND for R/W value to determine 
      // next state.
      case SMB_MTDBACK:
         switch (BYTE_NUMBER){
            case 2:                    // If BYTE_NUMBER=2, only HIGH_ADD
               SMB0DAT = LOW_ADD;      // has been sent.
               BYTE_NUMBER--;          // Decrement for next time around.
               break;
            case 1:                    // If BYTE_NUMBER=1, LOW_ADD was just sent.
               if (COMMAND & 0x01){    // If R/W=READ, sent repeated START.
                  STO = 0;
                  STA = 1;

               } else { 
                  SMB0DAT = WORD;      // If R/W=WRITE, load byte to write.
                  BYTE_NUMBER--;
               }
               break;
            default:                   // If BYTE_NUMBER=0, transfer is finished.
               STO = 1;
               SM_BUSY = 0;            // Free SMBus
            }
         break;


      // Master Transmitter: Data byte transmitted.  NACK received.
      // Slave not responding.  Send STOP followed by START to try again.
      case SMB_MTDBNACK:
         STO = 1;
         STA = 1;
         break;

      // Master Transmitter: Arbitration lost.
      // Should not occur.  If so, restart transfer.
      case SMB_MTARBLOST:
         STO = 1;
         STA = 1;
         break;

      // Master Receiver: Slave address + READ transmitted.  ACK received.
      // Set to transmit NACK after next transfer since it will be the last (only)
      // byte.
      case SMB_MRADDACK:
         AA = 0;                       // NACK sent on acknowledge cycle.
         break;

      // Master Receiver: Slave address + READ transmitted.  NACK received.
      // Slave not responding.  Send repeated start to try again.
      case SMB_MRADDNACK:
         STO = 0;
         STA = 1;
         break;

      // Data byte received.  ACK transmitted.
      // State should not occur because AA is set to zero in previous state.
      // Send STOP if state does occur.
      case SMB_MRDBACK:
         STO = 1;
         SM_BUSY = 0;
         break;

      // Data byte received.  NACK transmitted.
      // Read operation has completed.  Read data register and send STOP.
      case SMB_MRDBNACK:
         WORD = SMB0DAT;
         STO = 1;
         SM_BUSY = 0;                  // Free SMBus
         break;

      // All other status codes meaningless in this application. Reset communication.
      default:
         STO = 1;                      // Reset communication.
         SM_BUSY = 0;
         break;
      }

   SI=0;                               // clear interrupt flag
}

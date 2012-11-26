;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;       Name:   Aseda Gyeke Aboagye
;               Joe Orr
;               Doug Hewitt
;
;       kbd.asm --  This module is for handling the scancodes generated from
;                   the PS/2 keyboard. Implemented is a state machine which
;                   checks the framing of the transaction and checks to
;                   ensure that the parity is set correctly.
;
;                   Once the scancode is received, it inserts the value
;                   from the lookup table into a ringbuffer to be used by
;                   the main program.
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;------------------------------------------------------------------------------
; The "include"...
;------------------------------------------------------------------------------
	.globl _P7_7
	.globl _P7_6
	.globl _P7_5
	.globl _P7_4
	.globl _P7_3
	.globl _P7_2
	.globl _P7_1
	.globl _P7_0
	.globl _SPIF
	.globl _WCOL
	.globl _MODF
	.globl _RXOVRN
	.globl _NSSMD1
	.globl _NSSMD0
	.globl _TXBMT
	.globl _SPIEN
	.globl _P6_7
	.globl _P6_6
	.globl _P6_5
	.globl _P6_4
	.globl _P6_3
	.globl _P6_2
	.globl _P6_1
	.globl _P6_0
	.globl _AD2EN
	.globl _AD2TM
	.globl _AD2INT
	.globl _AD2BUSY
	.globl _AD2CM2
	.globl _AD2CM1
	.globl _AD2CM0
	.globl _AD2WINT
	.globl _AD0EN
	.globl _AD0TM
	.globl _AD0INT
	.globl _AD0BUSY
	.globl _AD0CM1
	.globl _AD0CM0
	.globl _AD0WINT
	.globl _AD0LJST
	.globl _P5_7
	.globl _P5_6
	.globl _P5_5
	.globl _P5_4
	.globl _P5_3
	.globl _P5_2
	.globl _P5_1
	.globl _P5_0
	.globl _CF
	.globl _CR
	.globl _CCF5
	.globl _CCF4
	.globl _CCF3
	.globl _CCF2
	.globl _CCF1
	.globl _CCF0
	.globl _CY
	.globl _AC
	.globl _F0
	.globl _RS1
	.globl _RS0
	.globl _OV
	.globl _F1
	.globl _P
	.globl _P4_7
	.globl _P4_6
	.globl _P4_5
	.globl _P4_4
	.globl _P4_3
	.globl _P4_2
	.globl _P4_1
	.globl _P4_0
	.globl _TF4
	.globl _EXF4
	.globl _EXEN4
	.globl _TR4
	.globl _CT4
	.globl _CPRL4
	.globl _TF3
	.globl _EXF3
	.globl _EXEN3
	.globl _TR3
	.globl _CT3
	.globl _CPRL3
	.globl _TF2
	.globl _EXF2
	.globl _EXEN2
	.globl _TR2
	.globl _CT2
	.globl _CPRL2
	.globl _MAC0HO
	.globl _MAC0Z
	.globl _MAC0SO
	.globl _MAC0N
	.globl _BUSY
	.globl _ENSMB
	.globl _STA
	.globl _STO
	.globl _SI
	.globl _AA
	.globl _SMBFTE
	.globl _SMBTOE
	.globl _PT2
	.globl _PS
	.globl _PS0
	.globl _PT1
	.globl _PX1
	.globl _PT0
	.globl _PX0
	.globl _P3_7
	.globl _P3_6
	.globl _P3_5
	.globl _P3_4
	.globl _P3_3
	.globl _P3_2
	.globl _P3_1
	.globl _P3_0
	.globl _EA
	.globl _ET2
	.globl _ES
	.globl _ES0
	.globl _ET1
	.globl _EX1
	.globl _ET0
	.globl _EX0
	.globl _P2_7
	.globl _P2_6
	.globl _P2_5
	.globl _P2_4
	.globl _P2_3
	.globl _P2_2
	.globl _P2_1
	.globl _P2_0
	.globl _S1MODE
	.globl _MCE1
	.globl _REN1
	.globl _TB81
	.globl _RB81
	.globl _TI1
	.globl _RI1
	.globl _SM00
	.globl _SM10
	.globl _SM20
	.globl _REN
	.globl _REN0
	.globl _TB80
	.globl _RB80
	.globl _TI
	.globl _TI0
	.globl _RI
	.globl _RI0
	.globl _P1_7
	.globl _P1_6
	.globl _P1_5
	.globl _P1_4
	.globl _P1_3
	.globl _P1_2
	.globl _P1_1
	.globl _P1_0
	.globl _FLHBUSY
	.globl _CP1EN
	.globl _CP1OUT
	.globl _CP1RIF
	.globl _CP1FIF
	.globl _CP1HYP1
	.globl _CP1HYP0
	.globl _CP1HYN1
	.globl _CP1HYN0
	.globl _CP0EN
	.globl _CP0OUT
	.globl _CP0RIF
	.globl _CP0FIF
	.globl _CP0HYP1
	.globl _CP0HYP0
	.globl _CP0HYN1
	.globl _CP0HYN0
	.globl _TF1
	.globl _TR1
	.globl _TF0
	.globl _TR0
	.globl _IE1
	.globl _IT1
	.globl _IE0
	.globl _IT0
	.globl _P0_7
	.globl _P0_6
	.globl _P0_5
	.globl _P0_4
	.globl _P0_3
	.globl _P0_2
	.globl _P0_1
	.globl _P0_0
	.globl _MAC0RND
	.globl _MAC0ACC
	.globl _MAC0A
	.globl _RCAP4
	.globl _TMR4
	.globl _DAC1
	.globl _RCAP3
	.globl _TMR3
	.globl _PCA0CP5
	.globl _PCA0CP4
	.globl _PCA0CP3
	.globl _PCA0CP2
	.globl _PCA0CP1
	.globl _PCA0CP0
	.globl _PCA0
	.globl _DAC0
	.globl _ADC0LT
	.globl _ADC0GT
	.globl _ADC0
	.globl _RCAP2
	.globl _TMR2
	.globl _TMR1
	.globl _TMR0
	.globl _P7
	.globl _P6
	.globl _XBR2
	.globl _XBR1
	.globl _XBR0
	.globl _P5
	.globl _P4
	.globl _FLACL
	.globl _P1MDIN
	.globl _P3MDOUT
	.globl _P2MDOUT
	.globl _P1MDOUT
	.globl _P0MDOUT
	.globl _CCH0LC
	.globl _CCH0TN
	.globl _CCH0CN
	.globl _P7MDOUT
	.globl _P6MDOUT
	.globl _P5MDOUT
	.globl _P4MDOUT
	.globl _CCH0MA
	.globl _CLKSEL
	.globl _SFRPGCN
	.globl _PLL0FLT
	.globl _PLL0MUL
	.globl _PLL0DIV
	.globl _OSCXCN
	.globl _OSCICL
	.globl _OSCICN
	.globl _PLL0CN
	.globl _FLSTAT
	.globl _MAC0RNDH
	.globl _MAC0RNDL
	.globl _MAC0CF
	.globl _MAC0AH
	.globl _MAC0AL
	.globl _MAC0STA
	.globl _MAC0OVR
	.globl _MAC0ACC3
	.globl _MAC0ACC2
	.globl _MAC0ACC1
	.globl _MAC0ACC0
	.globl _MAC0BH
	.globl _MAC0BL
	.globl _ADC2CN
	.globl _TMR4H
	.globl _TMR4L
	.globl _RCAP4H
	.globl _RCAP4L
	.globl _TMR4CF
	.globl _TMR4CN
	.globl _ADC2LT
	.globl _ADC2GT
	.globl _ADC2
	.globl _ADC2CF
	.globl _AMX2SL
	.globl _AMX2CF
	.globl _CPT1MD
	.globl _CPT1CN
	.globl _DAC1CN
	.globl _DAC1H
	.globl _DAC1L
	.globl _TMR3H
	.globl _TMR3L
	.globl _RCAP3H
	.globl _RCAP3L
	.globl _TMR3CF
	.globl _TMR3CN
	.globl _SBUF1
	.globl _SCON1
	.globl _CPT0MD
	.globl _CPT0CN
	.globl _PCA0CPH1
	.globl _PCA0CPL1
	.globl _PCA0CPH0
	.globl _PCA0CPL0
	.globl _PCA0H
	.globl _PCA0L
	.globl _SPI0CN
	.globl _RSTSRC
	.globl _PCA0CPH4
	.globl _PCA0CPL4
	.globl _PCA0CPH3
	.globl _PCA0CPL3
	.globl _PCA0CPH2
	.globl _PCA0CPL2
	.globl _ADC0CN
	.globl _PCA0CPH5
	.globl _PCA0CPL5
	.globl _PCA0CPM5
	.globl _PCA0CPM4
	.globl _PCA0CPM3
	.globl _PCA0CPM2
	.globl _PCA0CPM1
	.globl _PCA0CPM0
	.globl _PCA0MD
	.globl _PCA0CN
	.globl _DAC0CN
	.globl _DAC0H
	.globl _DAC0L
	.globl _REF0CN
	.globl _SMB0CR
	.globl _TH2
	.globl _TMR2H
	.globl _TL2
	.globl _TMR2L
	.globl _RCAP2H
	.globl _RCAP2L
	.globl _TMR2CF
	.globl _TMR2CN
	.globl _ADC0LTH
	.globl _ADC0LTL
	.globl _ADC0GTH
	.globl _ADC0GTL
	.globl _SMB0ADR
	.globl _SMB0DAT
	.globl _SMB0STA
	.globl _SMB0CN
	.globl _ADC0H
	.globl _ADC0L
	.globl _ADC0CF
	.globl _AMX0SL
	.globl _AMX0CF
	.globl _SADEN0
	.globl _FLSCL
	.globl _SADDR0
	.globl _EMI0CF
	.globl __XPAGE
	.globl _EMI0CN
	.globl _EMI0TC
	.globl _SPI0CKR
	.globl _SPI0DAT
	.globl _SPI0CFG
	.globl _SBUF
	.globl _SBUF0
	.globl _SCON
	.globl _SCON0
	.globl _SSTA0
	.globl _PSCTL
	.globl _CKCON
	.globl _TH1
	.globl _TH0
	.globl _TL1
	.globl _TL0
	.globl _TMOD
	.globl _TCON
	.globl _WDTCN
	.globl _EIP2
	.globl _EIP1
	.globl _B
	.globl _EIE2
	.globl _EIE1
	.globl _ACC
	.globl _PSW
	.globl _IP
	.globl _PSBANK
	.globl _P3
	.globl _IE
	.globl _P2
	.globl _P1
	.globl _PCON
	.globl _SFRLAST
	.globl _SFRNEXT
	.globl _SFRPAGE
	.globl _DPH
	.globl _DPL
	.globl _SP
	.globl _P0
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
	.area RSEG    (ABS,DATA)
	.org 0x0000
_P0	=	0x0080
_SP	=	0x0081
_DPL	=	0x0082
_DPH	=	0x0083
_SFRPAGE	=	0x0084
_SFRNEXT	=	0x0085
_SFRLAST	=	0x0086
_PCON	=	0x0087
_P1	=	0x0090
_P2	=	0x00a0
_IE	=	0x00a8
_P3	=	0x00b0
_PSBANK	=	0x00b1
_IP	=	0x00b8
_PSW	=	0x00d0
_ACC	=	0x00e0
_EIE1	=	0x00e6
_EIE2	=	0x00e7
_B	=	0x00f0
_EIP1	=	0x00f6
_EIP2	=	0x00f7
_WDTCN	=	0x00ff
_TCON	=	0x0088
_TMOD	=	0x0089
_TL0	=	0x008a
_TL1	=	0x008b
_TH0	=	0x008c
_TH1	=	0x008d
_CKCON	=	0x008e
_PSCTL	=	0x008f
_SSTA0	=	0x0091
_SCON0	=	0x0098
_SCON	=	0x0098
_SBUF0	=	0x0099
_SBUF	=	0x0099
_SPI0CFG	=	0x009a
_SPI0DAT	=	0x009b
_SPI0CKR	=	0x009d
_EMI0TC	=	0x00a1
_EMI0CN	=	0x00a2
__XPAGE	=	0x00a2
_EMI0CF	=	0x00a3
_SADDR0	=	0x00a9
_FLSCL	=	0x00b7
_SADEN0	=	0x00b9
_AMX0CF	=	0x00ba
_AMX0SL	=	0x00bb
_ADC0CF	=	0x00bc
_ADC0L	=	0x00be
_ADC0H	=	0x00bf
_SMB0CN	=	0x00c0
_SMB0STA	=	0x00c1
_SMB0DAT	=	0x00c2
_SMB0ADR	=	0x00c3
_ADC0GTL	=	0x00c4
_ADC0GTH	=	0x00c5
_ADC0LTL	=	0x00c6
_ADC0LTH	=	0x00c7
_TMR2CN	=	0x00c8
_TMR2CF	=	0x00c9
_RCAP2L	=	0x00ca
_RCAP2H	=	0x00cb
_TMR2L	=	0x00cc
_TL2	=	0x00cc
_TMR2H	=	0x00cd
_TH2	=	0x00cd
_SMB0CR	=	0x00cf
_REF0CN	=	0x00d1
_DAC0L	=	0x00d2
_DAC0H	=	0x00d3
_DAC0CN	=	0x00d4
_PCA0CN	=	0x00d8
_PCA0MD	=	0x00d9
_PCA0CPM0	=	0x00da
_PCA0CPM1	=	0x00db
_PCA0CPM2	=	0x00dc
_PCA0CPM3	=	0x00dd
_PCA0CPM4	=	0x00de
_PCA0CPM5	=	0x00df
_PCA0CPL5	=	0x00e1
_PCA0CPH5	=	0x00e2
_ADC0CN	=	0x00e8
_PCA0CPL2	=	0x00e9
_PCA0CPH2	=	0x00ea
_PCA0CPL3	=	0x00eb
_PCA0CPH3	=	0x00ec
_PCA0CPL4	=	0x00ed
_PCA0CPH4	=	0x00ee
_RSTSRC	=	0x00ef
_SPI0CN	=	0x00f8
_PCA0L	=	0x00f9
_PCA0H	=	0x00fa
_PCA0CPL0	=	0x00fb
_PCA0CPH0	=	0x00fc
_PCA0CPL1	=	0x00fd
_PCA0CPH1	=	0x00fe
_CPT0CN	=	0x0088
_CPT0MD	=	0x0089
_SCON1	=	0x0098
_SBUF1	=	0x0099
_TMR3CN	=	0x00c8
_TMR3CF	=	0x00c9
_RCAP3L	=	0x00ca
_RCAP3H	=	0x00cb
_TMR3L	=	0x00cc
_TMR3H	=	0x00cd
_DAC1L	=	0x00d2
_DAC1H	=	0x00d3
_DAC1CN	=	0x00d4
_CPT1CN	=	0x0088
_CPT1MD	=	0x0089
_AMX2CF	=	0x00ba
_AMX2SL	=	0x00bb
_ADC2CF	=	0x00bc
_ADC2	=	0x00be
_ADC2GT	=	0x00c4
_ADC2LT	=	0x00c6
_TMR4CN	=	0x00c8
_TMR4CF	=	0x00c9
_RCAP4L	=	0x00ca
_RCAP4H	=	0x00cb
_TMR4L	=	0x00cc
_TMR4H	=	0x00cd
_ADC2CN	=	0x00e8
_MAC0BL	=	0x0091
_MAC0BH	=	0x0092
_MAC0ACC0	=	0x0093
_MAC0ACC1	=	0x0094
_MAC0ACC2	=	0x0095
_MAC0ACC3	=	0x0096
_MAC0OVR	=	0x0097
_MAC0STA	=	0x00c0
_MAC0AL	=	0x00c1
_MAC0AH	=	0x00c2
_MAC0CF	=	0x00c3
_MAC0RNDL	=	0x00ce
_MAC0RNDH	=	0x00cf
_FLSTAT	=	0x0088
_PLL0CN	=	0x0089
_OSCICN	=	0x008a
_OSCICL	=	0x008b
_OSCXCN	=	0x008c
_PLL0DIV	=	0x008d
_PLL0MUL	=	0x008e
_PLL0FLT	=	0x008f
_SFRPGCN	=	0x0096
_CLKSEL	=	0x0097
_CCH0MA	=	0x009a
_P4MDOUT	=	0x009c
_P5MDOUT	=	0x009d
_P6MDOUT	=	0x009e
_P7MDOUT	=	0x009f
_CCH0CN	=	0x00a1
_CCH0TN	=	0x00a2
_CCH0LC	=	0x00a3
_P0MDOUT	=	0x00a4
_P1MDOUT	=	0x00a5
_P2MDOUT	=	0x00a6
_P3MDOUT	=	0x00a7
_P1MDIN	=	0x00ad
_FLACL	=	0x00b7
_P4	=	0x00c8
_P5	=	0x00d8
_XBR0	=	0x00e1
_XBR1	=	0x00e2
_XBR2	=	0x00e3
_P6	=	0x00e8
_P7	=	0x00f8
_TMR0	=	0x8c8a
_TMR1	=	0x8d8b
_TMR2	=	0xcdcc
_RCAP2	=	0xcbca
_ADC0	=	0xbfbe
_ADC0GT	=	0xc5c4
_ADC0LT	=	0xc7c6
_DAC0	=	0xd3d2
_PCA0	=	0xfaf9
_PCA0CP0	=	0xfcfb
_PCA0CP1	=	0xfefd
_PCA0CP2	=	0xeae9
_PCA0CP3	=	0xeceb
_PCA0CP4	=	0xeeed
_PCA0CP5	=	0xe2e1
_TMR3	=	0xcdcc
_RCAP3	=	0xcbca
_DAC1	=	0xd3d2
_TMR4	=	0xcdcc
_RCAP4	=	0xcbca
_MAC0A	=	0xc2c1
_MAC0ACC	=	0x96959493
_MAC0RND	=	0xcfce
;--------------------------------------------------------
; special function bits
;--------------------------------------------------------
	.area RSEG    (ABS,DATA)
	.org 0x0000
_P0_0	=	0x0080
_P0_1	=	0x0081
_P0_2	=	0x0082
_P0_3	=	0x0083
_P0_4	=	0x0084
_P0_5	=	0x0085
_P0_6	=	0x0086
_P0_7	=	0x0087
_IT0	=	0x0088
_IE0	=	0x0089
_IT1	=	0x008a
_IE1	=	0x008b
_TR0	=	0x008c
_TF0	=	0x008d
_TR1	=	0x008e
_TF1	=	0x008f
_CP0HYN0	=	0x0088
_CP0HYN1	=	0x0089
_CP0HYP0	=	0x008a
_CP0HYP1	=	0x008b
_CP0FIF	=	0x008c
_CP0RIF	=	0x008d
_CP0OUT	=	0x008e
_CP0EN	=	0x008f
_CP1HYN0	=	0x0088
_CP1HYN1	=	0x0089
_CP1HYP0	=	0x008a
_CP1HYP1	=	0x008b
_CP1FIF	=	0x008c
_CP1RIF	=	0x008d
_CP1OUT	=	0x008e
_CP1EN	=	0x008f
_FLHBUSY	=	0x0088
_P1_0	=	0x0090
_P1_1	=	0x0091
_P1_2	=	0x0092
_P1_3	=	0x0093
_P1_4	=	0x0094
_P1_5	=	0x0095
_P1_6	=	0x0096
_P1_7	=	0x0097
_RI0	=	0x0098
_RI	=	0x0098
_TI0	=	0x0099
_TI	=	0x0099
_RB80	=	0x009a
_TB80	=	0x009b
_REN0	=	0x009c
_REN	=	0x009c
_SM20	=	0x009d
_SM10	=	0x009e
_SM00	=	0x009f
_RI1	=	0x0098
_TI1	=	0x0099
_RB81	=	0x009a
_TB81	=	0x009b
_REN1	=	0x009c
_MCE1	=	0x009d
_S1MODE	=	0x009f
_P2_0	=	0x00a0
_P2_1	=	0x00a1
_P2_2	=	0x00a2
_P2_3	=	0x00a3
_P2_4	=	0x00a4
_P2_5	=	0x00a5
_P2_6	=	0x00a6
_P2_7	=	0x00a7
_EX0	=	0x00a8
_ET0	=	0x00a9
_EX1	=	0x00aa
_ET1	=	0x00ab
_ES0	=	0x00ac
_ES	=	0x00ac
_ET2	=	0x00ad
_EA	=	0x00af
_P3_0	=	0x00b0
_P3_1	=	0x00b1
_P3_2	=	0x00b2
_P3_3	=	0x00b3
_P3_4	=	0x00b4
_P3_5	=	0x00b5
_P3_6	=	0x00b6
_P3_7	=	0x00b7
_PX0	=	0x00b8
_PT0	=	0x00b9
_PX1	=	0x00ba
_PT1	=	0x00bb
_PS0	=	0x00bc
_PS	=	0x00bc
_PT2	=	0x00bd
_SMBTOE	=	0x00c0
_SMBFTE	=	0x00c1
_AA	=	0x00c2
_SI	=	0x00c3
_STO	=	0x00c4
_STA	=	0x00c5
_ENSMB	=	0x00c6
_BUSY	=	0x00c7
_MAC0N	=	0x00c0
_MAC0SO	=	0x00c1
_MAC0Z	=	0x00c2
_MAC0HO	=	0x00c3
_CPRL2	=	0x00c8
_CT2	=	0x00c9
_TR2	=	0x00ca
_EXEN2	=	0x00cb
_EXF2	=	0x00ce
_TF2	=	0x00cf
_CPRL3	=	0x00c8
_CT3	=	0x00c9
_TR3	=	0x00ca
_EXEN3	=	0x00cb
_EXF3	=	0x00ce
_TF3	=	0x00cf
_CPRL4	=	0x00c8
_CT4	=	0x00c9
_TR4	=	0x00ca
_EXEN4	=	0x00cb
_EXF4	=	0x00ce
_TF4	=	0x00cf
_P4_0	=	0x00c8
_P4_1	=	0x00c9
_P4_2	=	0x00ca
_P4_3	=	0x00cb
_P4_4	=	0x00cc
_P4_5	=	0x00cd
_P4_6	=	0x00ce
_P4_7	=	0x00cf
_P	=	0x00d0
_F1	=	0x00d1
_OV	=	0x00d2
_RS0	=	0x00d3
_RS1	=	0x00d4
_F0	=	0x00d5
_AC	=	0x00d6
_CY	=	0x00d7
_CCF0	=	0x00d8
_CCF1	=	0x00d9
_CCF2	=	0x00da
_CCF3	=	0x00db
_CCF4	=	0x00dc
_CCF5	=	0x00dd
_CR	=	0x00de
_CF	=	0x00df
_P5_0	=	0x00d8
_P5_1	=	0x00d9
_P5_2	=	0x00da
_P5_3	=	0x00db
_P5_4	=	0x00dc
_P5_5	=	0x00dd
_P5_6	=	0x00de
_P5_7	=	0x00df
_AD0LJST	=	0x00e8
_AD0WINT	=	0x00e9
_AD0CM0	=	0x00ea
_AD0CM1	=	0x00eb
_AD0BUSY	=	0x00ec
_AD0INT	=	0x00ed
_AD0TM	=	0x00ee
_AD0EN	=	0x00ef
_AD2WINT	=	0x00e8
_AD2CM0	=	0x00e9
_AD2CM1	=	0x00ea
_AD2CM2	=	0x00eb
_AD2BUSY	=	0x00ec
_AD2INT	=	0x00ed
_AD2TM	=	0x00ee
_AD2EN	=	0x00ef
_P6_0	=	0x00e8
_P6_1	=	0x00e9
_P6_2	=	0x00ea
_P6_3	=	0x00eb
_P6_4	=	0x00ec
_P6_5	=	0x00ed
_P6_6	=	0x00ee
_P6_7	=	0x00ef
_SPIEN	=	0x00f8
_TXBMT	=	0x00f9
_NSSMD0	=	0x00fa
_NSSMD1	=	0x00fb
_RXOVRN	=	0x00fc
_MODF	=	0x00fd
_WCOL	=	0x00fe
_SPIF	=	0x00ff
_P7_0	=	0x00f8
_P7_1	=	0x00f9
_P7_2	=	0x00fa
_P7_3	=	0x00fb
_P7_4	=	0x00fc
_P7_5	=	0x00fd
_P7_6	=	0x00fe
_P7_7	=	0x00ff
;--------------------------------------------------------
; overlayable register banks
;--------------------------------------------------------
	.area REG_BANK_0	(REL,OVR,DATA)
	.ds 8

.globl	kbinit
.globl	kbcheck

QUEUELEN =    4                                   ; queue holds four characters

.area kbdidat (DATA,REL)
kbdq:   .ds      QUEUELEN                            ; the actual queue

.area kbddata (DATA,REL)                             ; variable storage
queuesize: .ds   1                                   ; count of items in the queue
head:   .ds      1                                   ; address of queue head (insertion)
tail:   .ds      1                                   ; address of queue tail (extraction)
state:      .ds      1                               ; state variable
scan_code:  .ds      1                               ; scan code from kb
kbchar:     .ds      1                               ; ascii char from scan code
count:      .ds      1                               ; used in switch statement

.area kbdbits (BIT,REL)                              ; bit variables
parity = 0x0000
cparity = 0x0001
start_bit = 0x0002
stop_bit = 0x0003
char_ready = 0x0004									; kbchar is valid and ready
shifted = 0x0005
ctrled = 0x0006
breaked = 0x0007

.area HOME (CODE)
        ;cseg    at 0*8+3                            ; interrupt is priority 0
		; we will need to set this in the linker process
		; --code-loc 0x0003
        ljmp    kbprocess                           ; these aren't the droids you're looking for
 
.area kbdcode (CODE,REL)

kbinit:
        ;extrn   code(keytab, keytab2), number(minkey, maxkey)
		.globl	keytab
		.globl	keytab2
		.globl	minkey
		.globl	maxkey
        aparity     =     _PSW_0                   ; psw even parity bit for A
        kbpin       =     _P2_2
        sc_error    =		0                   ; error code? i'm really just making stuff up at this point
        mov         state,#0
        clr         shifted
        clr         ctrled
        clr         breaked

        mov     queuesize, #QUEUELEN                ; initialize the queue
        mov     head, #kbdq
        mov     tail, #kbdq
        mov     r0, #kbdq                           ; for testing, put "no character" value
        mov     @r0,#0x0ff                           ;   at the tail of the queue

        mov     SFRPAGE,#0x0F
        orl     IE,#1                               ; enable external interrupt
        orl     IP,#1
        orl     XBR1,#0b00000100
        mov     SFRPAGE,#0
        setb    IT0
        ret

kbprocess:
        push    ACC                                 ; save general registers' state
        push    B
        push    DPH
        push    DPL
        push    PSW
        mov     A,state
        rl      A                                   ; x2 to account for ajmp in table
        mov     DPTR,#table
        jmp     @A+DPTR
table:  ajmp  rx_start_bit                          ; state 0
        ajmp  rx_data                               ; state 1
        ajmp  rx_parity                             ; state 2
        ajmp  rx_stop_bit                           ; state 3
  rx_start_bit:
        mov     C,kbpin
        mov     start_bit,C
        mov     scan_code,#0x80                      ; same as 10000000B (MSB set for flagging rx_data as done)
        mov     kbchar,#sc_error
        inc     state
        ljmp     done
  rx_data:
        mov     C,kbpin
        mov     A,scan_code
        rrc     A                                   ; add bit to carry, shift right into MSB
        mov     scan_code,A
        jnc     hack                                ; if carry is set, we're done with data, otherwise repeat this state
        inc     state
        ljmp     done
hack:   ljmp done
  rx_parity:
        mov     C,kbpin
        mov     parity,C
        mov     A,scan_code
        mov     C,aparity
        cpl     C
        mov     cparity,C                           ; calculated odd parity
        inc     state
        ljmp     done
  rx_stop_bit:
        mov     C,kbpin
        mov     stop_bit,C
  valid_chk:                                        ; for a valid scan_code: start_bit = 0 && cparity = parity && stop_bit = 1
        mov     C,parity
        anl     C,cparity
        jc      framing                             ; check if cparity == 1 && parity == 1
        mov     C,parity
        orl     C,cparity                           ; check if cparity == 0 && parity == 0     
        jc      rx_error
    framing:
        mov     C,stop_bit
        anl     C,/start_bit                        ; check if start_bit = 0 && stop_bit = 1
        jnc     rx_error
  lookup:
        mov     A,scan_code                         ; get scancode
        clr     C
        subb    A,#minkey                           ; check if scancode is smaller than minkey
        jc      rx_error
        mov     DPTR,#keytab                        ; assume no control key
        jnb     ctrled,next                         ; if ctrl was pressed, use keytab2 instead
        mov     DPTR,#keytab2
    next:
        mov     C,shifted
        cpl     C
        rlc     A
        movc    A,@A+DPTR
        mov     kbchar,A
        jb      ACC.7,special_key
        jb      breaked,clrbreak
        ljmp     valid_char                          ; value in kbchar is ready for whatever (ring buffer)
    clrbreak:
        mov     kbchar,#sc_error                    ; if the breaked flag is set, ignore char
        clr     breaked
  reset_state:
        mov     state,#0
        ljmp     done
  rx_error:
        mov     scan_code,#sc_error
        mov     kbchar,#sc_error
        sjmp    reset_state
  special_key:
        mov     DPTR,#cases                         ; cases, case, and switch should all work together like a switch statement, but who knows
        maxC    = 4                               ; # of cases      
        mov     count,#-1
    case:
        inc     count
        mov     A,count
        cjne    A,#maxC,continue                    ; jump to else case if no cases match
        ljmp     case_end
        continue:
        movc    A,@A+DPTR
        cjne    A,scan_code,case
        mov     A,count
        rl      A
        mov     DPTR,#switch
        jmp     @A+DPTR
    cases:  .db      0x012                            ; left shift
            .db      0x059                            ; right shift
            .db      0x014                            ; ctrl
            .db      0x0F0                            ; break
    switch: ajmp    case_shift
            ajmp    case_shift
            ajmp    case_ctrl
            ajmp    case_break
    case_shift:
        setb    shifted
        jnb     breaked,nobreaks                    ; if break code is flagged, unset shift and break flags
        clr     shifted
        clr     breaked
      nobreaks:
        ljmp     case_end
    case_ctrl:
        setb    ctrled
        jnb     breaked,nobreakc                    ; if break code is flagged, unset ctrl and break flags
        clr     ctrled
        clr     breaked
      nobreakc:
        sjmp     case_end
    case_break:
        setb    breaked
        sjmp     case_end
    case_end:                                       ; end of case statement
        mov     kbchar,#sc_error
        ljmp     reset_state
valid_char:
        push    ar0                                 ; save R0
        mov     R0,head
        mov     @R0,kbchar                          ; ring[head] = item(kbchar)
				inc     head
				dec			queuesize
				mov			A,head
        cjne    A,#kbdq+QUEUELEN,nowrap             ; how much is free in ring buffer
				mov			head,#kbdq
nowrap:
        pop     ar0
        ljmp     reset_state
done:
        pop     _PSW                                 ; restore general registers
        pop     _DPL
        pop     _DPH
        pop     _B
        pop     _ACC
        reti                                         ;from kbprocess

kbcheck:
        push    acc
;;;;    REMOVE THESE 4 LINES WHEN YOU HAVE IMPLEMENTED RING BUFFER INSERTION
;        mov     a,#0ffH         ; get "no character" value
;        mov     r0, #kbdq
;        xch     a, @r0          ; swap actual character with "no character"
;        mov     R7,a            ; move into return register
;        jmp     wraptail        ; exit
;;;;
        mov     a, queuesize                        ; see if there are chars in queue
        cjne    a, #QUEUELEN, gotchar               ; not equal means yes
        mov     r7, #-1                             ; return "no char" value
        pop     acc
        ret
gotchar:
        ;; clr     EA                               ; avoid race condition
        mov     r0,tail                             ; get queue tail pointer
        mov     a,@r0                               ; get from queue
        mov     r7,a                                ; put in register to return
        inc     queuesize                           ; adjust free count
        ;; setb    EA
        inc     tail                                ; update tail pointer
        mov     a, tail
        cjne    a, #kbdq+QUEUELEN, wraptail         ; check for queue wrap
        mov     tail, #kbdq
wraptail:
        pop     acc
        ret


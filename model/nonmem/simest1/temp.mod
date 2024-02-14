$PROB Template Estimation for Simulation Runs

$INPUT C, LINE, STUDY, ID, ATFD = TIME, ATLD, NTFD, NTLD, AMT, DV, LDV, EVID, CMT, MDV,
          BLQ, LLOQ, DOSEA, DOSEN, BWT, BHT, BBMI, BAGE, SEXF, RACEN, PTYPE, 
          BECOG, BALB, BCRCL, BHFC, REGN, FOOD

$DATA sim{{j}}.csv
      IGNORE=@
      IGNORE=(BLQ.GT.0)

$SUBROUTINE ADVAN4 TRANS4

$PK
OBESE = 0
IF(BBMI.GT.30) OBESE = 1

ALB1 = 3.4
IF(BALB.GT.0) ALB1 = BALB

TVCL = THETA(1)
CL   = TVCL * EXP(ETA(1)) * (1 + OBESE*THETA(6)) * (ALB1/3.4)**THETA(8)

TVV2 = THETA(2)
V2   = TVV2 * EXP(ETA(2)) * (1 + OBESE*THETA(7))

TVV3 = THETA(3)
V3   = TVV3 * EXP(ETA(3))

TVQ  = THETA(4)
Q    = TVQ * EXP(ETA(4))

TVKA = THETA(5)
KA   = TVKA * EXP(ETA(5))

S2 = V2/1000 ; dose in mg, conc in ng/mL

$ERROR (OBSERVATION ONLY)
IPRED = F
Y=IPRED*(1+EPS(1)) + EPS(2)

$THETA
(0, 0.3)     ; THETA1 CL {L/hr}
(0, 16)      ; THETA2 V2 {L}
8.77 FIX     ; THETA3 V3 {L}
1.72 FIX     ; THETA4 Q {L/hr}
0.817 FIX    ; THETA5 KA {1/hr}
0.21 FIX     ;6 OBESE ~ CL
0.23 FIX     ;7 OBESE ~ VC
-0.3 FIX     ;8 ALB ~ CL


$OMEGA
0.1                ;1 IIV on CL
0.1                ;2 IIV on V2
5.95E-02 FIX       ;3 IIV on V3
0 FIX              ;4 IIV on Q
0.72 FIX           ;5 IIV on KA

$SIGMA
0.05        ;Proportional Error
0 FIX      ;Additive Error {ng/mL}

$EST MAXEVAL=9999 METHOD=1 INTER SIGL=6 NSIG=3 PRINT=1 NOABORT MSFO=./sim{{j}}.msf


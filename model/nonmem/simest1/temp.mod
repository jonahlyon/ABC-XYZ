$PROB Template Estimation for Simulation Runs

$INPUT C, LINE, STUDY, ID, ATFD = TIME, ATLD, NTFD, NTLD, AMT, DV, LDV, EVID, CMT, MDV,
          BLQ, LLOQ, DOSEA, DOSEN, BWT, BHT, BBMI, BAGE, SEXF, RACEN, PTYPE, 
          BECOG, BALB, BCRCL, BHFC, REGN, FOOD

$DATA sim{{j}}.csv
      IGNORE=@

$SUBROUTINE ADVAN6 TRANS1 TOL=6

$MODEL
COMP=(DEPOT)
COMP=(CENTRAL)
COMP=(PERIPH)

$PK

TVCL = THETA(1)
CL   = TVCL * EXP(ETA(1))

TVVC = THETA(2)
VC   = TVVC * EXP(ETA(2))

TVVP = THETA(3)
VP   = TVVP * EXP(ETA(3))

TVQ  = THETA(4)
Q    = TVQ * EXP(ETA(4))

TVKA = THETA(5)
KA   = TVKA * EXP(ETA(5))

S2 = VC/1000 ; dose in mg, conc in ng/mL

$DES
k12 = Q/VC
k21 = Q/VP

DADT(1) = -KA*A(1)
DADT(2) =  KA*A(1) -CL/VC*A(1) - A(1)*k12 + A(2)*k21
DADT(3) =                        A(1)*k12 - A(2)*k21

$ERROR (OBSERVATION ONLY)
IPRED = F
Y=IPRED*(1+EPS(1)) + EPS(2)

$THETA
(0, 0.586)     ; THETA1 CL {L/hr}
(0, 15.8)      ; THETA2 V2 {L}
8.23  FIX      ; THETA3 V3 {L}
0.871 FIX      ; THETA4 Q {L/hr}
0.87  FIX      ; THETA5 KA {1/hr}

$OMEGA BLOCK(2)
0.1                ;1 IIV on CL
0.01 0.1           ;2 IIV on V2

$OMEGA
0.077 FIX       ;3 IIV on V3
0 FIX           ;4 IIV on Q
1.34 FIX        ;5 IIV on KA

$SIGMA
0.009    ;Proportional Error
20.4     ;Additive Error {ng/mL}

$EST MAXEVAL=9999 METHOD=1 INTER SIGL=6 NSIG=3 PRINT=1 MSFO=./{{j}}.msf


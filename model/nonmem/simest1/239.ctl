$PROB Template Estimation for Simulation Runs

$INPUT C, LINE, STUDY, ID, ATFD = TIME, ATLD, NTFD, NTLD, AMT, DV, LDV, EVID, CMT, MDV,
          BLQ, LLOQ, DOSEA, DOSEN, BWT, BHT, BBMI, BAGE, SEXF, RACEN, PTYPE, 
          BECOG, BALB, BCRCL, BHFC, REGN, FOOD

$DATA ../sim239.csv
      IGNORE=@

$SUBROUTINE ADVAN6 TRANS1 TOL=6

$MODEL
COMP=(DEPOT)
COMP=(CENTRAL)
COMP=(PERIPH)

$PK
;Baseline Covariates
OBESE = 0
IF(BBMI.GE.30) OBESE = 1

HEP = 0
IF(BHFC.GE.2) HEP=1 ; Mild 19 subjects, Moderate 1 subject

FED = 0
IF(FOOD.GE.0) FED=FOOD

ECOG = 0
IF(BECOG.GE.0) ECOG = BECOG

SEX = 0
IF(SEXF.GE.0) SEX = SEXF

HV = 0
IF(PTYPE.EQ.0) HV=1

CRCLREF = 103 ;Median from dataset
CRCL = CRCLREF
IF(BCRCL.GT.0) CRCL=BCRCL

WTREF = 70
WT = WTREF
IF(BWT.GT.0) WT=BWT

ALBREF = 4
ALB=ALBREF
IF(BALB.GT.0) ALB=BALB


AGEREF = 52 ;Median from dataset
AGE=AGEREF
IF(BAGE.GT.0) AGE=BAGE

;;CL Covariates
ECOGCL = (1 + ECOG*THETA(8))
HVCL = (1 + HV*THETA(9))
HEPCL = (1 + HEP*THETA(10))
WTCL = ((WT/WTREF)**THETA(11))
CRCLCL = ((CRCL/CRCLREF)**THETA(12))
AGECL = ((AGE/AGEREF)**THETA(13))
ALBCL = ((ALB/ALBREF)**THETA(14))

;V Covariates
WTVC = ((WT/WTREF)**THETA(15))
ALBVC = ((ALB/ALBREF)**THETA(16))

WTVP = ((WT/WTREF)**THETA(17))


TVCL = THETA(1)
CL   = TVCL * ECOGCL* HVCL * HEPCL * WTCL* CRCLCL * AGECL * ALBCL * EXP(ETA(1))

TVVC = THETA(2)
VC   = TVVC * WTVC * ALBVC * EXP(ETA(2))

TVVP = THETA(3)
VP   = TVVP * WTVP * EXP(ETA(3))

TVQ  = THETA(4)
Q    = TVQ * EXP(ETA(4))

TVKA = THETA(5)
KA   = TVKA * (1 + FED*THETA(6)) * EXP(ETA(5))

F1 = 1 + OBESE*THETA(18)

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

-0.905 FIX     ; THETA6 FOOD ~ KA 
0.00179 FIX    ; THETA7 FOOD ~ F1
0.093 FIX      ; THETA8 ECOG ~ CL
-0.0835 FIX    ; THETA9 HV ~ CL
-0.120 FIX     ; THETA10 HEP ~ CL
0.302 FIX      ; THETA11 WT ~ CL
0.157 FIX      ; THETA12 CRCL ~ CL
-0.0147 FIX    ; THETA13 AGE ~ CL
-0.702 FIX     ; THETA14 ALB ~ CL
0.918 FIX      ; THETA15 WT ~ VC
-0.720 FIX     ; THETA16 ALB ~ VC
0.731 FIX      ; THETA17 WT ~ VP
-0.230 FIX     ; THETA18 OBESE ~ F1

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

$EST MAXEVAL=9999 METHOD=1 INTER SIGL=6 NSIG=3 PRINT=1 MSFO=./239.msf


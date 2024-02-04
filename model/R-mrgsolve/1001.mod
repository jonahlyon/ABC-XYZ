$PARAM
THETA1 =  0.586
THETA2 = 15.8
THETA3 = 8.23
THETA4  = 0.871
THETA5 = 0.87

THETA6 = -0.905
THETA7 = 0.00179

THETA8 = 0.093
THETA9 = -0.0835
THETA10 = -0.120
THETA11 = 0.302
THETA12 = 0.157
THETA13 = -0.0147
THETA14 = -0.702
THETA15 = 0.918
THETA16 = -0.720
THETA17 = 0.731
THETA18 = -0.230

IETA1 = 0
IETA2 = 0
IETA3 = 0
IETA4 = 0
IETA5 = 0

$PARAM
@covariates
// dataset values - initialize in model
// subjects will receive reference value if not available in dataset
BHFC = 0
FOOD = 0
BECOG = 0
SEXF = 0
PTYPE = 0
BCRCL = 0
BWT = 0
BALB = 0
BAGE = 0
BBMI = 0


$CMT GUT CENT PERIPH AUC


$MAIN
double OBESE = 0;
double HEP = 0;
double FED = 0;
double ECOG = 0;
double HV = 0;
double CRCL = 103;
double WT = 70;
double AGE = 52;
double ALB = 4;


//covariate effects
if(BBMI > 30) OBESE = 1;
if(BHFC>0) HEP = BHFC;
if(FED > 0) FED = FOOD;
if(BECOG > 0) ECOG = BECOG;
if(PTYPE > 0) HV = 1;
if(BCRCL > 0) CRCL = BCRCL;
if(BWT > 0) WT = BWT;
if(BAGE > 0) AGE = BAGE;
if(BALB > 0) ALB = BALB;

double ECOGCL = (1 + ECOG*THETA8);
double HVCL = (1 + HV*THETA9);
double HEPCL = (1 + HEP*THETA10);
double WTCL = pow((WT/70), THETA11);
double CRCLCL = pow((CRCL/103), THETA12);
double AGECL = pow((AGE/52), THETA13);
double ALBCL = pow((ALB/4), THETA14);

double WTVC = pow((WT/70), THETA15);
double ALBVC = pow((ALB/4), THETA16);

double WTVP = pow((WT/70), THETA17);


//PK parameters
double TVCL =  THETA1*ECOGCL*HVCL*HEPCL*WTCL*CRCLCL*AGECL*ALBCL;
double CL = TVCL*exp(ETA1);

double TVV2 = THETA2*WTVC*ALBVC;
double V2 = TVV2*exp(ETA2);

double TVV3 = THETA3*WTVP;
double V3 = TVV3*exp(ETA3);

double TVQ = THETA4;
double Q = TVQ*exp(ETA4);

double TVKA = THETA5 * (1 + FED*THETA6);
double KA = TVKA*exp(ETA5);

F_GUT = F1;
double F1 = 1 + FED*THETA7 + OBESE*THETA18;

$OMEGA @block @labels ETA1 ETA2
0.107
0.01 0.0772

$OMEGA @labels ETA3 ETA4 ETA5
0.077
0
1.34

$SIGMA @labels PROP ADD
0.009 20.4

$ODE
dxdt_GUT = -KA*GUT;
dxdt_CENT = KA*GUT - (CL/V2)*CENT - (Q/V2)*CENT + (Q/V3)*PERIPH;
dxdt_PERIPH = (Q/V2)*CENT  - (Q/V3)*PERIPH;
dxdt_AUC = (CENT/V2*1000);

$TABLE
capture IPRED = CENT/V2*1000;
capture Y = IPRED*(1 + PROP);

$CAPTURE Y IPRED CL V2 V3 Q KA F1

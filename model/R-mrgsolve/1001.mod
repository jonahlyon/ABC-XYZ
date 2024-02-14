$PARAM
THETA1 =  0.318
THETA2 = 15.8
THETA3 = 8.77
THETA4  = 1.72
THETA5 = 0.817
THETA6 = 0.21
THETA7 = 0.23
THETA8 = -0.3

BBMI = 0
BALB = 0
IETA1 = 0
IETA2 = 0
IETA3 = 0
IETA4 = 0
IETA5 = 0

$CMT GUT CENT PERIPH

$MAIN
if(BALB > 0) double ALB1 = BALB;
if(BBMI > 30) double OBESE = 1;

double TVCL = THETA1;
double CL = TVCL*exp(ETA1)*exp(IETA1)*(1 + THETA6*OBESE)*pow((ALB1/3.4), THETA8);

double TVV2 = THETA2;
double V2 = TVV2*exp(ETA2)*exp(IETA2)*(1 + THETA7*OBESE);

double TVV3 = THETA3;
double V3 = TVV3*exp(ETA3)*exp(IETA3);

double TVQ = THETA4;
double Q = TVQ;      // Q is fixed

double TVKA = THETA5;
double KA = TVKA*exp(ETA5)*exp(IETA5);


$OMEGA @labels ETA1 ETA2 ETA3 ETA4 ETA5
0.141 0.161 0.0595 0 0.72

$SIGMA @annotated
PROP:  0.05   : Proportional residual error
ADD :  0       : Additive residual error


$ODE
dxdt_GUT = -KA*GUT;
dxdt_CENT = KA*GUT - (CL/V2)*CENT - (Q/V2)*CENT + (Q/V3)*PERIPH;
dxdt_PERIPH = (Q/V2)*CENT  - (Q/V3)*PERIPH;

$TABLE
capture IPRED = CENT/V2*1000;
capture Y = IPRED*(1+PROP)+ADD;

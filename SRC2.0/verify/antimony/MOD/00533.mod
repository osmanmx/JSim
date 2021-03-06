// This model generated automatically from SBML

// unit definitions
import nsrunit;
unit conversion off;

// SBML property definitions
property sbmlRole=string;
property sbmlName=string;
property sbmlCompartment=string;

// SBML reactions
// reaction1: S1 S2 <=> S3 
// reaction2: S3 <=> S1 S2 
// reaction3: S3 <=> S1 S4 

math main {
  realDomain time second;
  time.min=0;
  extern time.max;
  extern time.delta;

  // variable definitions
  real C = 1 L;
  real k1 = 10;
  real k2(time);
  real k3 = .7;
  real S1(time) M;
  real S2(time) M;
  real S3(time) M;
  real S4(time) M;
  real reaction1(time) katal;
  real reaction2(time) katal;
  real reaction3(time) katal;

  // equations
  when (time=time.min) S1 = .2/C;
  (S1*C):time = -1*reaction1 + reaction2 + reaction3;
  when (time=time.min) S2 = .2/C;
  (S2*C):time = -1*reaction1 + reaction2;
  when (time=time.min) S3 = 0;
  (S3*C):time = reaction1 + -1*reaction2 + -1*reaction3;
  when (time=time.min) S4 = 0;
  (S4*C):time = reaction3;
  reaction1 = C*k1*S1*S2;
  reaction2 = C*k2*S3;
  reaction3 = C*k3*S3;
  k2+(-0.9) = 0;

  // variable properties
  C.sbmlRole="compartment";
  k1.sbmlRole="parameter";
  k2.sbmlRole="parameter";
  k3.sbmlRole="parameter";
  S1.sbmlRole="species";
  S1.sbmlCompartment="C";
  S2.sbmlRole="species";
  S2.sbmlCompartment="C";
  S3.sbmlRole="species";
  S3.sbmlCompartment="C";
  S4.sbmlRole="species";
  S4.sbmlCompartment="C";
  reaction1.sbmlRole="rate";
  reaction2.sbmlRole="rate";
  reaction3.sbmlRole="rate";
}


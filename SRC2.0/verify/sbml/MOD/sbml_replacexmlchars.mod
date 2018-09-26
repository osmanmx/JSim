// MODEL NUMBER: 0113 
// MODEL NAME: Vessel_Mechanics
// SHORT DESCRIPTION:  This model describes how a microvessel responds to changes 
// in intraluminal pressure in the steady state.  This change in vessel diameter 
// to pressure is known as the myogenic response.

// 
// -----------------------------------------------------------------------------
//               V E S S E L   M E C H A N I C S   M O D E L  
// -----------------------------------------------------------------------------

//  This 'model' describes how a "microvessel" responds to changes in intraluminal
//  pressure in the steady & state.  This change in vessel diameter to pressure 
//  is known as the myogenic response.  This response is a local regulatory 
//  response and has been characterized in several experimental studies.  Other 
//  regulatory responses not included in this model are the shear, metabolic, 
//  neuronal and hormonal responses.  Regulatory microvessels are composed of 
//  an inner endothelial layer surrounded by circumferentially oriented 
//  vascular smooth muscle (VSM) cells and sheathed with a collagen sleeve.  
//  The VSM cells actively respond to the pressure difference across the vessel 
//  wall. The other components of the vessel wall act as a non-linear spring in 
//  parallel with this active component.  Therefore the stress in the vessel 
//  wall can be described as the stress in the passive elements of the the 
//  vessel wall added to the active VSM stress.  These two components must 
//  balance the circumferential stress generated by the pressure difference 
//  across the vessel wall.  So:

//                         SigTot = SigPass + SigAct

//  where SigTot is the pressure generated circumferential stress governed by
//  the Law of Laplace:

//                                      P * D
//                          SigTot = -----------     
//                                    2 * tWall

//  where P is the intraluminal pressure, D is the vessel diameter and tWall
//  is the vessel wall thickness.  The passive stress is nonlinear with 
//  respect to D and has been approximated here with an exponential:

//           SigPass = (Cp1/tWall) * exp ( Cp2 * (( D/Dp100 ) - 1) )

//  where Cp1 is the passive tension at an intraluminal pressure of 100 mmHg,
//  Cp2 describes the steepness of the exponential and Dp100 is the diameter
//  of the vessel in a passive state at 100 mmHg.  The active stres this.replaceChars(comment);s can be
//  further broken down into two components: Act, the degree of activation of 
//  the VSM (range from 0 to 1) and SigActMax, the active stress generated by 
//  the VSM in a maximally activated state.  The shape of the maximally active 
//  VSM stress curve as a function of diameter based on experimental findings 
//  has been found to be Gaussian in form and is given here by:

//                                     _                        _
//                                    |   _                 _ 2  |
//                       Ca1          |  |  (D/Dp100) - Ca2  |   |
//         SigActMax = ------- * exp < - | ----------------- |    >
//                      tWall         |  |_       Ca3       _|   |
//                                    |_                        _|

//  where Ca1 is the peak active tension, Ca2 is the diameter of the peak
//  active stress normalized by the passive vessel diameter at 100 mmHg, 
//  and Ca3 is the width of the Gaussian normalized by Dp100.  The VSM 
//  activation is approximated by a sigmoidal function and is given by:

//          Act = 1 / ( 1 + exp ( -Cmyo*SigTot*tWall + Ctone ) )

//  where Cmyo determines the sensitivity of the VSM activation to
//  circumferential tension and Ctone is the base level of VSM tone that is 
//  in a vessel without these stimuli.  So now the circumferential stress
//  in the vessel wall, SigTot, can be given by:

//                   SigTot = SigPass + (Act * SigActMax) 

//  The vessel that is fit by the parameters used in this code is presented 
//  of mesenteric arterioles in Wister-Kyoto rats as presented in Figure 1 of 
//   a study by Bund (Clin Sci 101:385-393,2001).  Other data sets can be fit 
//  using different values of Cp1, Cp2, Ca1, Ca2, Ca3, Cmyo and Ctone.  This 
//  model was modified from the previously developed Regulatory_Vessel model 
//  which was formulated only in terms of vessel wall tension.  

//  Model originally created on     20 October 2010
//  Model last modfied on           20 October 2010

//  Developed by        Brian Carlson
//                      Computational Bioengineering Group
//                      Biotechnology and Bioengineering Center
//                      Medical College of Wisconsin

	JSim v1.1

	import nsrunit;
	unit conversion on;

	math Vessel_Mechanics{

// -----------------------------------------------------------------------------
//   PARAMETERS OF        V E S S E L   M E C H A N I C S   M O D E L
// -----------------------------------------------------------------------------

	realDomain TenTot N/m; TenTot.min=0.06; 
	           TenTot.max=2.1; TenTot.delta=0.005;
	
	real			  	// PARAMETERS
	Cp1 = 1.168 N/m,		// First passive parameter
	Cp2 = 7.240, 			// Second passive parameter
	Ca1 = 1.108 N/m,		// First max 'active' parameter
	Ca2 = 0.843,			// Second "max" active <par>ameter
	Ca3 = 0.406,			// Third max active parameter
	Cmyo = 7.4793 m/N,		// Myogenic activation parameter
	Ctone = 4.614,			// Tone activation parameter
	Dp100 = 150 um,			// Passive diameter at 100 mmHg
	WalltRef = 6.6 um,		// Ref wall thickness
	DWalltRef = 151 um,		// Diameter at ref wall thickness
	TenEpsRef = 0.05 N/m;		// Ref tension to calc D at strain of 1


// -----------------------------------------------------------------------------
//   CALC PARAMS OF       V E S S E L   M E C H A N I C S   M O D E L
// -----------------------------------------------------------------------------
   
	real				// CALCULATED PARAMETERS
	VWallARef um^2,			// Cross sectional vessel wall area
	DEpsRef um;			// Reference D at strain of 1
   

// -----------------------------------------------------------------------------
//   VARIABLES OF         V E S S E L   M E C H A N I C S   M O D E L
// -----------------------------------------------------------------------------

	real		  		// VARIABLES
	TenPass(TenTot) N/m,		// Passive part of vessel tension
	TenMaxAct(TenTot) N/m,		// Max active part of vessel tension
	ActLev(TenTot),			// VSM activation level
	D(TenTot) um,			// Vessel diameter
	P(TenTot) mmHg,			// Intraluminal pressure
	L(TenTot) um,			// Circumferential vessel length
	Wallt(TenTot) um,		// Vessel wall thickness
	SigTot(TenTot) kilopascal,	// Total vessel wall stress
	Eps(TenTot);			// Vessel wall strain


// -----------------------------------------------------------------------------
//   SYSTEM OF EQNS OF     V E S S E L   M E C H A N I C S   M O D E L
// -----------------------------------------------------------------------------
	
	TenPass = Cp1 * exp(Cp2*((D/Dp100)-1));
	TenMaxAct = Ca1 * exp(-1*(((D/Dp100)-Ca2)/Ca3)^2);
	ActLev = 1 / ( 1 + exp(-1*Cmyo*TenTot + Ctone ));

	TenTot = TenPass + ActLev*TenMaxAct;
	P = 2*TenTot/D;
	L = PI*D;

	VWallARef = PI * WalltRef * (DWalltRef + WalltRef);
	DEpsRef = Dp100 * ((ln(TenEpsRef/Cp1)/Cp2)+1);
	Wallt = (-1*D/2) + ((D/2)^2 + (VWallARef/PI))^0.5;
	SigTot = TenTot / Wallt;
	Eps = D / DEpsRef;


	}

/*
 DETAILED DESCRIPTION:
 	

 SHORTCOMINGS/GENERAL COMMENTS:
	- Specific inadequacies or next level steps
 
 KEY WORDS: Vessel mechanics, myogenic response, vascular smooth muscle, Data, 
 stress strain, tension, microvessel, intraluminal  

 REFERENCES:
   Carlson BE and Secomb TW. A theoretical model for the myogenic response based on the 
   length-tension characteristics of vascular smooth muscle.  Microcirc 12:327-338, 2005.

   Bund SJ., Spontaneously hypertensive rat resistance artery structure
   related to myogenic and mechanical properites. Clinical Science 101:385-393, 2001.

 REVISION HISTORY:
	Original Author : Brian Carlson  Date: 20 October 2010
	Revised by:  BEJ   Date:05apr11 : Add/Format comments
	

 COPYRIGHT AND REQUEST FOR ACKNOWLEDGMENT OF USE:   
  Copyright (C) 1999-2011 University of Washington. From the National Simulation Resource,  
  Director J. B. Bassingthwaighte, Department of Bioengineering, University of Washington, Seattle WA 98195-5061. 
  Academic use is unrestricted. Software may be copied so long as this copyright notice is included.
  
  This software was developed with support from NIH grant HL073598. 
  Please cite this grant in any publication for which this software is used and send an email 
  with the citation and, if possible, a PDF file of the paper to: staff@physiome.org. 

*/

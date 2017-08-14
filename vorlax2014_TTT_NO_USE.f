*     PROGRAM (INPUT,OUTPUT,TAPE5=INPUT,TAPE6=OUTPUT,TAPE1,TAPE2, 
*     *TAPE3,TAPE4,TAPE7,TAPE9,TAPE11,TAPE12)                           

      PROGRAM VORLAX 


C********************************************************************** 
C                                                                       
C  GENERALIZED VORTEX LATTICE PROGRAM (SUBSONIC/SUPERSONIC NONPLANAR)   
C  LUIS R. MIRANDA (DEPT. 75-41) /BLDG. 63G /(213) 847-6812/            
C  WILLIAM M. BAKER (DEPT. 80-34) /BLDG. 67 /(213) 847-3537/            
C  ***** LOCKHEED-CALIFORNIA COMPANY, BURBANK, CALIFORNIA *****         
C  COMPUTER SERVICES JOB NUMBER  4565                                   
C                                                                       
C********************************************************************** 
C
C  THIS VERSION OF VORLAX  IS BASED UPON A VERSION DOWNLOADED FROM 
C   THE RUTGERS UNIVERSITY WEB-SITE
C
C   HTTP://WWW.CAIP.RUTGERS.EDU/~ZHANG/CLASS/FLUID/AIRFOIL/ .F
C
C********************************************************************** 
C
C  MODIFIED BY T. TAKAHASHI
C
C  CODE REVISIONS -
C    FREE-FORMAT I/O WHENEVER POSSIBLE
C    COMMENT CARD TOSSER -   CC-TOSSED INPUT TO UNIT=99 - VORLAX.SCR
C    REVISED OUTPUT FORMAT - VERBOSE OUTPUT  TO UNIT=7  - VORLAX.LOG
C                            CONCISE OUTPUT  TO UNIT=6  - Display
C
C    REVISED NUMERICAL SOLVER - REDUCED DEPENDENCE ON FILE I/O
C
C    INVESTIGATE SIGN DISCREPANCY W.R.T. SIDE FORCE COEFFICIENT
C      REVISE OUTPUTS TO PROPERLY GENERALIZE STABILITY AXES
C                                                                        
C-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*- 
C                                                                        
C          V       V   OOO   RRRRR  L          A      X   X              
C           V     V   O   O  R   R  L         A A      X X               
C            V   V    O   O  RRRRR  L        AAAAA      X                
C             V V     O   O  R  R   L       A     A    X X               
C              V       OOO   R   R  LLLLL  A       A  X   X              
C                                                                        
C-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*- 
C                                                                        
C                                                                        
C...                                                                     
C...DEFINITION OF VARIABLES STORED IN COMMON BLOCKS.                     
C...                                                                     
C...X, Y, Z             COORDINATES OF HORSESHOE VORTEX CENTROIDS        
C...                    (MIDPOINTS OF TRANSVERSE LEGS).                  
C...B2                  COMPRESSIBILITY FACTOR (M **2 - 1.)              
C...CD, CL, CM, CN      PANEL DRAG, LIFT, PITCHING MOMENT, AND NORMAL    
C...                    FORCE COEFFICIENTS.                              
C...CX, CY              PANEL X- AND Y-FORCE COEFFICIENTS.               
C...DL                  DIHEDRAL OF CHORDWISE ROW OF HORSESHOE VORTI     
C...                    CES.                                             
C...FN, FY              PANEL NORMAL AND Y-FORCE PER UNIT Q.             
C...IH, IQ              ANGLE OF ATTACK AND MACH NUMBER INDICES.         
C...NT                  TOTAL NUMBER OF CHORDWISE ROWS OF VORTICES.      
C...RM                  PANEL ROLLING MOMENT PER UNIT Q.                 
C...SX                  SPANWISE LOCATION INDEX.                         
C...XS                  ABSCISSAE OF FLOW FIELD SURVEY CROSS-PLANES.     
C...YM                  PANEL YAWING MOMENT PER UNIT Q.                  
C...YY                  Y-COORDINATE OF HORSESHOE VORTEX CENTROIDS.      
C...ZC                  NORMAL CAMBER COORDINATE IN FRACTION OF CHORD.   
C...ZZ                  Z-COORDINATE OF HORSESHOE VORTEX CENTROIDS.      
C...BIG                 MAXIMUM CHANGE PER RELAXATION CYCLE.             
C...CDC, CNC            CHORDWISE CD AND CN TIMES LOCAL CHORD.           
C...CRM, CYM            PANEL ROLLING AND YAWING MOMENT COEFFICIENTS.    
C...DCP                 PRESSURE COEFFICIENTS (EITHER LOAD OR            
C...                    SURFACE).                                        
C...EPS                 ACCEPTABLE FINAL RELAXATION CYCLE CHANGE.        
C...HAG                 HEIGHT ABOVE GROUND OF MOMENT REFERENCE          
C...                    CENTER.                                          
C...ITS, JTS            PANEL AND STRIP FLOW EXPOSURE FLAGS.             
C...LAX,LAY             LATTICE CHORDWISE AND SPANWISE DISTRIBUTION      
C...                    FLAGS.                                           
C...NPP                 PANEL CHORDWISE NONPLANARITY FLAG.               
C...NXS, NYS, NZS       NUMBER OF FLOW FIELD SURVEY PLANES (ORTHOGO      
C...                    NAL TO THE COORDINATE AXES).                     
C...PDL                 PANEL SPANWISE NONPLANARITY FLAG. ALSO PANEL     
C...                    PANEL DIHEDRAL IF PANEL IS FLAT IN THE SPAN      
C...                    WISE DIRECTION.                                  
C...PSI                 YAW ANGLE (POSITIVE WHEN FLOW COMES FROM         
C...                    PORTSIDE).                                       
C...RCS                 CROSS-SECTION RADIUS VECTOR.                     
C...RLM                 APPROXIMATE VALUE OF EIGENVALUE RADIUS OF        
C...                    NORMALWASH MATRIX.                               
C...SLE                 SLOPE AT LEADING EDGE.                           
C...SPC                 PANEL LEADING EDGE SUCTION FACTOR.               
C...TNL                 TANGENT OF LEADING EDGE SWEEP.                   
C...TNT                 TANGENT OF TRAILING EDGE SWEEP.                  
C...VSP                 TANGENT OF SKEWED VORTEX LINE.                   
C...VSS                 SEMISPAN OF CHORDWISE VORTEX ROW.                
C...VST                 ACTUAL HORSESHOE VORTEX SEMISPAN.                
C...XAF                 CHORDWISE PERCENT COORDINATES AT WHICH CAMBER    
C...                    IS INPUT.                                        
C...XTE                 TRAILING EDGE ABSCISSA OF VORTEX ROW.            
C...ALFA                ANGLE OF ATTACK (IN RADIANS).                    
C...ALOC                COMPONENT OF FREE-STREAM AND ONSET FLOWS NOR     
C...                    MAL TO THE SURFACE AT THE CONTROL POINTS. ALSO   
C...                    AUXILIARY ARRAY.                                 
C...BETA                PRANDTL-GLAUERT FACTOR.                          
C...CBAR                REFERENCE CHORD.                                 
C...CMTC                CHORDWISE TORSIONAL MOMENT ABOUT QUARTER CHORD   
C...                    TIMES LOCAL CHORD.                               
C...CSUC                PANEL LEADING EDGE THRUST PER UNIT Q.            
C...DRAG                PANEL INDUCED DRAG PER UNIT Q.                   
C...HEAD                PANEL DESCRIPTION INFORMATION.                   
C...IDES                DESIGN (SYNTHESIS) FLAG.                         
C...IPAN                HORSESHOE STRIP PANEL INDEX.                     
C...ITER                ACTUAL NUMBER OF RELAXATION CYCLES.              
C...LIFT                PANEL LIFT PER UNIT Q.                           
C...MACH                FREE-STREAM MACH NUMBER.                         
C...NPAN                NUMBER OF PANELS DEFINED IN THE DATA INPUT.      
C...NVOR                NUMBER OF PANEL CHORDWISE STRIPS OF VORTICES.    
C...RNCV                CHORDWISE NUMBER OF HORSESHOE VORTICES FOR A     
C...                    GIVEN PANEL.                                     
C...SLE1, SLE2          SURFACE SLOPES AT LEADING EDGE OF PANEL SIDE     
C...                    EDGES.                                           
C...SMAX                NT.                                              
C...SREF                CONFIGURATION REFERENCE AREA.                    
C...SURF                PANEL SURFACE AREA (PLANFORM AREA).              
C...VINF                REFERENCE FREE STREAM VELOCITY.                  
C...XBAR                ABSCISSA OF MOMENT REFERENCE CENTER.             
C...XSUC                PANEL LEADING EDGE THRUST PER UNIT Q.            
C...YAWQ                YAW RATE (DEGS/SEC).                             
C...YNOT                BUTTLINE ORIGIN OF FLOW FIELD SURVEY GRID.       
C...ZBAR                ORDINATE OF MOMENT REFERENCE CENTER.             
C...ZETA                INCIDENCE OF STREAMWISE VORTEX ROW (STRIP)       
C...                    CHORDLINE.                                       
C...ZLE1, ZLE2          LEADING EDGE OFFSET OF CAMBERLINE AT THE         
C...                    PANEL SIDE EDGES.                                
C...ZNOT                WATERLINE ORIGIN OF FLOW FIELD SURVEY GRID.      
C...AINC1, AINC2        CHORDLINE INCIDENCE AT SIDE EDGES OF PANEL.      
C...ALPHA               ANGLE OF ATTACK (DEGS).                          
C...CDTOT               TOTAL INDUCED DRAG COEFFICIENT.                  
C...CHORD               CHORD LENGTH MEASURED ALONG CENTRLINE OF         
C...                    STREAMWISE ROW OF HORSESHOE VORTICES.            
C...CLTOT               TOTAL LIFT COEFFICIENT.                          
C...CMTOT               TOTAL PITCHING MOMENT COEFFICIENT.               
C...CNTOT               TOTAL YAWING MOMENT COEFFICIENT.                 
C...CRTOT               TOTAL ROLLING MOMENT COEFFICIENT.                
C...CYTOT               TOTAL SIDE FORCE COEFFICIENT.                    
C...DNDX1, DNDX2        SURFACE SLOPES AT THE CONTROL POINTS MEASURED    
C...                    ALONG THE PANEL SIDE EDGES. IF DESIGN IS IN      
C...                    VOKED, THEY ARE THE LOAD COEFFICIENTS AT THE     
C...                    LOAD POINTS ALONG THE PANEL SIDE EDGES.          
C...GAMMA               HORSESHOE VORTEX CIRCULATION . ALSO USED         
C...                    AS TEMPORARY DATA STORAGE.                       
C...ISOLV               FLAG DETERMINING SYSTEM OF SOLUTION FOR THE      
C...                    BOUNDARY CONDITION EQUATIONS.                    
C...LESWP               PANEL LEADING EDGE SWEEP (DEGS).                 
C...NMACH               NUMBER OF MACH NUMBERS PER CASE.                 
C...ONSET               ONSET FLOW VELOCITIES GENERATED BY THE           
C...                    ROTATION OF THE CONFIGURATION ABOUT THE          
C...                    MOMENT REFERENCE CENTER.                         
C...PSPAN               PANEL SPAN.                                      
C...RFLAG               COEFFICIENT MULTIPLIER IN SYSTEM OF BOUNDARY     
C...                    CONDITION EQUATIONS.                             
C...RNMAX               NUMBER OF VORTICES FOR A GIVEN CHORDWISE ROW.    
C...ROLLQ               ROLL RATE (DEGS/SEC).                            
C...SLOPE               SURFACE SLOPE AT THE LATTICE CONTROL POINTS.     
C...SYNTH               PANEL SYNTHESIS (DESIGN) FLAG.                   
C...TAPER               PANEL TAPER RATIO.                               
C...TITLE               CASE TITLE.                                      
C...WSPAN               CONFIGURATION REFERENCE WING SPAN.               
C...XAPEX, YAPEX, ZAPEX COORDINATES OF PANEL FIRST SIDE EDGE LEADING     
C...                    EDGE (PANEL APEX).                               
C...CSTART              CHORD LENGTH OF PANEL FIRST SIDE EDGE.           
C...DELTAY, DELTAZ      BUTTLINE AND WATERLINE SPACING OF FLOW FIELD     
C...                    SURVEY GRID.                                     
C...FLOATX, FLOATY      VORTEX WAKE FLOATATION PARAMETERS.               
C...INTRAC              PANEL LATERAL NONPLANARITY PARAMETER.            
C...INVERS              DESIGN (SYNTHESIS) FLAG.                         
C...IQUANT              PANEL SYMMETRY FLAG.                             
C...ITRMAX              MAXIMUM ALLOWABLE NUMBER OF RELAXATION CYCLES.   
C...LATRAL              CONFIGURATION OR FLIGHT CONDITION SYMMETRY       
C...                    FLAG.                                            
C...MOMENT              PANEL PITCHING MOMENT PER UNIT Q.                
C...NALPHA              NUMBER OF ANGLES OF ATTACK PER CASE.             
C...NPANAS              TOTAL NUMBER OF PANELS THAT HAVE TO BE TAKEN     
C...                    INTO ACCOUNT IN THE ACTUAL COMPUTATION           
C...                    PROCESS.                                         
C...PHIMED              ANGULAR COORDINATE OF CROSS-SECTION RADIUS       
C...                    VECTOR.                                          
C...PITCHQ              PITCH RATE (DEGS/SEC).                           
C...                                                                     
C.......................[PER UNIT Q[ MEANS [PER UNIT FREE-STREAM         
C.......................DYNAMIC PRESSURE[.                               
C...                                                                     
C                                                                        
C                   
C 2014 UPGRADES
C    16 MACH #'s
C    16 ANGLES OF ATTACK
C 

      DIMENSION C1 (60), C2 (60), RO (61), PHI (61)                      

      DIMENSION XAF (60), ZC1 (60), ZC2 (60)                             

      DIMENSION EW (12000), EWX (6001), EWY (6001), EU (6001), AV (6001)  

      DIMENSION DESCRP (10)                                              

C                                                                        

      INTEGER*4 TITLE
      CHARACTER*80 XTITLE
      INTEGER CX, SX
      REAL MACH, NVOR, LIFT, MOMENT, LESWP                               

C...                                                                     

      COMMON LAX, LAY, IQ, IH, LATRAL, PSI, PITCHQ, ROLLQ, YAWQ, HAG,    
     * FLOATX, FLOATY, INVERS, ISOLV                                     

      COMMON /SET1 /X (12000), Y (1000), Z (1000), ZC (60)                  

      COMMON /SET2 /DCP (12000), SLOPE (12000), VSP (12000)                 

      COMMON /SET3 /CX (12000), SX (12000), RFLAG (12000), IDES (12000)      

      COMMON /SET4 /DNDX1 (400), DNDX2 (400), AINC1 (90), AINC2 (90)     

      COMMON /SET5 /XAPEX (60), YAPEX (60), ZAPEX (60), PDL (60),        
     * LESWP (60), SYNTH (60), IQUANT (60), CSTART (60), TAPER (60),     
     * PSPAN (60), NVOR (60)                                             

      COMMON /SET6 /TITLE (90), HEAD (200), ALOC (12000)                  

      COMMON /SET7 /RNCV (90), RNMAX (1000), ITS (90), JTS (1000)          

      COMMON /SET8 /LIFT (60), DRAG (60), MOMENT (60), CL (60),          
     * CD (60), CM (60), FN (60), CN (60), FY (60), CY (60),             
     * RM (60), CRM (60), YM (60), CYM (60), XSUC (60), SURF (60)        

      COMMON /SET9 /CDC (1000), CNC (1000)                                 

      COMMON /SET10 /CHORD (1000), DL (1000), VSS (1000), TNL (1000),    
     * TNT (1000), XTE (1000), IPAN (1000)                               

      COMMON /SET11 /MACH (16), ALPHA (16), ALFA, VINF, NMACH, NALPHA   

      COMMON /SET12 /CLTOT, CDTOT, CMTOT, SREF, CYTOT, CRTOT, CNTOT      

      COMMON /SET13 /BIG, ITER, ITRMAX, EPS , WSPAN, RLM                 

      COMMON /SET14 /NPAN, NT, SMAX , NPANAS                             

      COMMON /SET15 /B2, BETA, CBAR, XBAR, ZBAR                          

      COMMON /SET16 /GAMMA  (12000) , ONSET  (12000)                       

      COMMON /SET17 /CSUC (1000), CMTC (1000), SPC (60)                  

      COMMON /SET18 /NXS, NYS, NZS, YNOT, DELTAY, ZNOT, DELTAZ, XS (90)  

      COMMON /SET19 /SLE1 (90), SLE2 (90), SLE (1000), ZETA (1000)       

      COMMON /SET20 /ZLE1 (90), ZLE2 (90), PHIMED (1000), RCS (1000),    
     * NPP (90), INTRAC (90), YY (12000), ZZ(12000), VST(12000)             

C    COMMON /EMATRIX/ EMAT(2000,2000)

C...                                                                     
C...                                                                     
C...                                                                     
C...                                                                     

      PI = 3.14159                                                       
      DTR = .01745329                                                    

      OPEN(UNIT=8, FILE='VORLAX.IN', ACTION='READ')  
      OPEN(UNIT=7,FILE='VORLAX.LOG')
    
      WRITE (7,*) ' ** VORLAX 2014  ** '
      WRITE (7,*) ''
      WRITE (7,*) ' EXPANDED MODEL SIZE:'
      WRITE (7,*) '    UP TO 12000 TOTAL VORTICIES '
      WRITE (7,*) '    RNCV LIMIT RAISED TO 60 '
      WRITE (7,*) '    NVOR LIMIT RAISED TO 60 '
      WRITE (7,*) ''
      
      CALL CCTOSS


      WRITE (7,*) ' ******** INPUT DECK ********* '
      WRITE (7,*)

      OPEN(UNIT=99,FILE='VORLAX.SCR')

 10   READ  (99, *) XTITLE

      WRITE (7,50) XTITLE  
      WRITE (7,*)

      WRITE (6, 55) XTITLE
      WRITE (6, 56) 
  
      READ (99, *) ISOLV, LAX, LAY, REXPAR, HAG, FLOATX, FLOATY,ITRMAX 

      IF (ITRMAX .EQ. 0 ) ITRMAX = 99                                  
      IF (REXPAR .LT. 0.01) REXPAR = 0.10                                

      WRITE (7, *) 
      WRITE (7, *) 'ISOLV : =0, ITERATIVE; =1, DIRECT (PURCELL);',
     &             ' =2, IN-CORE ITERATIVE'
      WRITE (7, *) 'LAX   : =0, COS SPC (M<1); =1, LINEAR SPC (M>1)'
      WRITE (7, *) 'LAY   : =0, COSINE SPC; =1, LINEAR SPC'
      WRITE (7, *) 'REXPAR: RELAXATION COEFF FOR ITR SOLVER'
      WRITE (7, *) 'HAG   : HT. ABOVE GND. (=0, OUT OF GROUND EFF)'
      WRITE (7, *) 'FLOATX: '
      WRITE (7, *) 'FLOATY: '
      WRITE (7, *) 'ITRMAX: CONVERGENCE LIMIT FOR ITR SOLVER, TYP 99'
      WRITE (7, *)
      WRITE (7, *) 'ISOLV     LAX       LAY         REXPAR   HAG     ',
     & 'FLOATX  FLOATY  ITRMAX'
      WRITE (7, 40) ISOLV, LAX, LAY, REXPAR, HAG, FLOATX, FLOATY,ITRMAX                                                        
      WRITE (7, *)

 40   FORMAT (3 (I2, 8X), 4F8.2, 4X, I3)  
 50   FORMAT (20A4)
 55   FORMAT ('*',20A4)
 56   FORMAT ('*MACH,ALFA,PSI,PITCHR,ROLLR,YAWR, ,',
     &              'HAG,SREF,CBAR,WSPAN,XBAR,ZBAR, ,',
     &              'CL,CD,CY,CPM,CRM,CYM')
C...                                                                     

      CALL INPUT                                                         

      CALL GEOM (ITOTAL)                                                 

C                                                                        

 60   DO 100 IQ = 1, NMACH                                               
       B2 = MACH (IQ) **2 - 1.0                                           
       BETA = SQROOT (ABS (B2))                                             
       ALFA = 0.0                                                         
       ICALL = 0                                                          
       IF (FLOATX .NE. 0.0 .OR. HAG .NE. 0.0) ICALL = 1                   
       IM = ICALL + NXS                                                   
       IF (ICALL .EQ. 0) CALL MATRX (EW, EU, ITOTAL)                      
       IF(IM .EQ. NXS .AND. IM .GT. 0) CALL SURVEY(EW, EWX, EWY, ITOTAL)  

C                                                                        

       DO 90 IH = 1, NALPHA                                                
        ALFA = ALPHA (IH) *DTR                                             
        IF (ICALL .EQ. 1) CALL MATRX (EW, EU, ITOTAL)                      
        IF(IM.GT.NXS .AND. NXS.GT.0) CALL SURVEY (EW, EWX, EWY, ITOTAL)    
        NX1 = ITOTAL + 1                                                   
        CALL BOUNDY (ITOTAL)                                               
        IF (ISOLV.EQ.0) CALL GAUSS (ITOTAL, REXPAR, EW, EWX)               
        IF (ISOLV.EQ.2) CALL NEWGAUSS (ITOTAL, REXPAR, EW, EWX)  
        IF (ISOLV.EQ.1) CALL VECTOR (ITOTAL, NX1, AV, EW, EU, EWX, EWY)    
        CALL PRESS (ITOTAL, EU)                                            
        CALL AERO (EW, ITOTAL)                                             
        CALL PRINT (ITOTAL, EW, EWX, EWY)                                  

        IPASS = 1 - INVERS                                                 
        INVERS = 0                                                         
        IF (IPASS .EQ. 1) GO TO 90                                         

        DO 70 IRR = 1, ITOTAL                                              
 70     IDES (IRR) = 0                                                     

       GO TO 60                                                           

 90    CONTINUE                                                           
100   CONTINUE                                                           


 110  WRITE (7, *) 'NORMAL TERMINATION'
      
      CLOSE(UNIT=5)
      CLOSE(UNIT=6)
      CLOSE(UNIT=7)
      CLOSE(UNIT=10)

      STOP                                                               

C                                                                        

      END                                                                

CONTROL*VRLX.AERO                                                        

C...                                                                     

      SUBROUTINE AERO (EW, ITOTAL)                                       

C...                                                                     

C...PURPOSE    TO COMPUTE FORCE AND MOMENT DATA BY INTEGRATION OF        
C...           PRESSURE DISTRIBUTION DATA AND BY TAKING INTO ACCOUNT     
C...           EDGE SUCTION FORCES.                                      

C...                                                                     

C...INPUT      CALLING SEQUENCE@                                         
C...           EW = NORMALWASH AT LEADING EDGE INFLUENCE COEFFICIENT     
C...                MATRIX (RETRIEVED ROW BY ROW FROM UNIT 9).           

C...           COMMON@                                                   
C...           X, Y, Z, B2, DL, SX, YY, ZZ, DCP, JTS, LAX, PSI,          
C...           SPC, VSS, VST, XTE, ALFA, MACH, NPAN, NVOR, SREF,         
C...           VINF, XBAR, YAWQ, ZBAR, ZETA, CHORD, GAMMA, LESWP,        
C...           PSPAN,, RNMAX, ROLLQ, SLOPE, TAPER, CSTART, IQUANT,       
C...           LATRAL, NPANAS, PITCHQ.                                   

C...                                                                     

C...OUTPUT     CALLING SEQUENCE@                                         
C...           NONE.                                                     

C...           COMMON@                                                   
C...           CD, CL, CM, CN, CX, CY, FN, FY, RM, YM, CDC, CNC,         
C...           CRM, CYM, CMTC, CSUC, DRAG, LIFT, SURF, XSUC,             
C...           CDTOT, CLTOT, CMTOT, CNTOT, CRTOT, CYTOT, MOMENT.         
C...                                                                     

C...SUBROUTINES                                                          
C...CALLED     NONE.                                                     

C...                                                                     

C...DISCUSSION SUBROUTINE AERO COMPUTES THE AERODYNAMIC FORCE AND        
C...           MOMENT COEFFICIENTS BY INTEGRATING THE PRESSURE           
C...           DISTRIBUTION AND COMPUTING THE LEADING EDGE SUCTION       
C...           FORCES IN ACCORDANCE WITH LAN"S PROCEDURE. THERE ARE      
C...           THREE CLASSES OF COEFFICIENTS, AS FOLLOWS @ (1) TOTAL     
C...           CONFIGURATION COEFFICIENTS, (2) PANEL COEFFICIENTS,       
C...           AND (3) STRIPWISE, OR CHORDWISE, COEFFICIENTS. ALL        
C...           TOTAL COEFFICIENTS ARE REFERENCED TO WIND AXES. CLASS     
C...           (2) AND (3) COEFFICIENTS ARE REFERENCED EITHER TO BODY    
C...           OR TO WIND AXES AS REQUIRED BY THE CORRESPONDING COEFF.   
C...           DEFINITION. AERO SUBROUTINE IS CALLED BY MAIN FOR EVERY   
C...           ANGLE OF ATTACK AND MACH NUMBER COMBINATION.              
C                                                                        
C                                                                        

      DIMENSION EW (ITOTAL)                                              

C                                                                        

      COMMON LAX, LAY, IQ, IH, LATRAL, PSI, PITCHQ, ROLLQ, YAWQ, HAG,    
     * FLOATX, FLOATY, INVERS                                            

      COMMON /SET1 /X (12000), Y (1000), Z (1000), ZC (60)                  

      COMMON /SET2 /DCP (12000), SLOPE (12000), VSP (12000)                 

      COMMON /SET3 /CX (12000), SX (12000), RFLAG (12000), IDES (12000)      

      COMMON /SET5 /XAPEX (60), YAPEX (60), ZAPEX (60), PDL (60),        
     * LESWP (60), SYNTH (60), IQUANT (60), CSTART (60), TAPER (60),     
     * PSPAN (60), NVOR (60)                                             

      COMMON /SET7 /RNCV (90), RNMAX (1000), ITS (90), JTS (1000)          

      COMMON /SET8 /LIFT (60), DRAG (60), MOMENT (60), CL (60),          
     * CD (60), CM (60), FN (60), CN (60), FY (60), CY (60),             
     * RM (60), CRM (60), YM (60), CYM (60), XSUC (60), SURF (60)        

      COMMON /SET9 /CDC (1000), CNC (1000)                                 

      COMMON /SET10 /CHORD (1000), DL (1000), VSS (1000), TNL (1000),    
     * TNT (1000), XTE (1000), IPAN (1000)                               

      COMMON /SET11 /MACH (16), ALPHA (16), ALFA, VINF, NMACH, NALPHA   

      COMMON /SET12 /CLTOT, CDTOT, CMTOT, SREF, CYTOT, CRTOT, CNTOT      

      COMMON /SET13 /BIG, ITER, ITRMAX, EPS , WSPAN, RLM                 

      COMMON /SET14 /NPAN, NT, SMAX , NPANAS                             

      COMMON /SET15 /B2, BETA, CBAR, XBAR, ZBAR                          

      COMMON /SET16 /GAMMA  (12000) , ONSET  (12000)                       

      COMMON /SET17 /CSUC (1000), CMTC (1000), SPC (60)                  

      COMMON /SET19 /SLE1 (90), SLE2 (90), SLE (1000), ZETA (1000)      

      COMMON /SET20 /ZLE1 (90), ZLE2 (90), PHIMED (1000), RCS (1000),    
     * NPP (90), INTRAC (90), YY (12000), ZZ(12000), VST(12000)             

C                                                                        

      REAL MACH, NVOR, LIFT, MOMENT, LESWP                               

      INTEGER CX, SX                                                     

      PI = 3.14159                                                       

      DTR = 0.01745329                                                   

C                                                                        

      PSIRAD = PSI *DTR                                                  

      FLAX = LAX                                                         

C                                                                        

C...UNIT 9 CONTAINS THE LEADING EDGE NORMALWASH INFLUENCE COEFFICIENT    

C...MATRIX AS COMPUTED IN SUBROUTINE MATRIX. MATRIX STORED BY ROWS.      

C                                                                        

      REWIND 9                                                           

C                                                                        

C...ALFA = ANGLE OF ATTACK IN RADIANS.                                   

C...PSIRAD = ANGLE OF YAW IN RADIANS.                                    

C                                                                        

      SINALF = SIN (ALFA)                                                

      COSALF = COS (ALFA)                                                

      SINPSI = SIN (PSIRAD)                                              

      COPSI = COS (PSIRAD)                                               

      COSIN = COSALF *SINPSI *2.0                                        

      COSINP = COSALF *SINPSI                                            

      COSCOS = COSALF *COPSI                                             

      PITCH = DTR *PITCHQ /VINF                                          

      ROLL = DTR *ROLLQ /VINF                                            

      YAW = DTR *YAWQ /VINF                                              

C                                                                        

C...LIFT = PANEL LIFT PER UNIT Q                                         
C...DRAG = PANEL DRAG PER UNIT Q                                         
C...XSUC = PANEL LEADING EDGE THRUST PER UNIT Q                          
C...MOMENT = PANEL PITCHING MOMENT ABOUT REF. CENTER PER UNIT Q          
C...FN = PANEL NORMAL FORCE PER UNIT Q                                   
C...FY = PANEL SIDE FORCE PER UNIT Q                                     
C...RM = PANEL ROLLING MOMENT PER UNIT Q                                 
C...YM = PANEL YAWING MOMENT PER UNIT Q                                  
C...ALL ABOVE PANEL FORCES ARE REFERENCED TO WIND AXES EXCEPT FOR FN     
C...WHICH IS IN BODY AXES.                                               
C                                                                        

C...INITIALIZE PANEL FORCE ARRAYS                                        

C                                                                        

      DO 10 IX = 1, NPANAS                                               

      LIFT (IX) = 0.                                                     

      DRAG (IX) = 0.                                                     

      XSUC (IX) = 0.                                                     

      MOMENT (IX) = 0.                                                   

      FN (IX) = 0.                                                       

      FY (IX) = 0.                                                       

      RM (IX) = 0.                                                       

      YM (IX) = 0.                                                       

 10   CONTINUE                                                           

C                                                                        

C                                                                        

C...HORSESHOE VORTEX STREAMWISE STRIPS ARE IDENTIFIED BY                 
C...A SPANWISE OR LATERAL INDEX, IR. EACH HORSESHOE VORTEX IS            
C...IDENTIFIED BY AN ELEMENT INDEX, IRT. EACH MAJOR PANEL IS             
C...IDENTIFIED BY AN INDEX (IR) WHICH GENERATES AN AUXILIARY INDEX (I).  
C...WHEN I = IX THEN INPUT HALF OF CONFIGURATION IS BEING DEALT WITH.    
C...WHEN I ^ IX THEN MIRRORED (ABOUT X-Z PLANE) COMPONENTS ARE BEING     
C...CONSIDERED. I AND IX ARE DIFFERENT ONLY FOR ASYMMETRICAL             
C...CONFIGURATIONS AND/OR FLIGHT CONDITIONS. ICYCLE IS AN AUXILIARY      
C...INDEX@ ICYCLE = 1 FOR IX = I? ICYCLE = 2 FOR IX % I.                 

C...                                                                     

C...                                                                     
C...INITIALIZE INDICES@                                                  
C...                                                                     

      IRT = 0                                                            

      IR = 0                                                             

      I = 1                                                              

      IX = 0                                                             

      ICYCLE = 1                                                         

 20   IX = IX + 1                                                        

C...                                                                     

C...COMPUTE PANEL REFERENCE AREA, TANGENT OF LEADING EDGE SWEEP (TLE),   
C...TANGENT OF TRAILING EDGE SWEEP (TTE), AND THE PRINCIPAL PART         
C...PARAMETER (STB).                                                     

C...                                                                     

      SURF (IX) = CSTART (I) *(1. + TAPER (I)) /2. *PSPAN (I)            

      TEPAR = 2. *SURF (IX) /PSPAN (I) **2                               

      TEPAR = TEPAR *(1. - TAPER (I)) / (1. + TAPER (I))                 

      NV = NVOR (I)                                                      

      TLE = TAN (DTR *LESWP (I))                                         

      TTE = TLE - TEPAR                                                  

      IF (ICYCLE .EQ. 2) TLE = - TLE                                     

      IF (ICYCLE .EQ. 2) TTE = - TTE                                     

      T2 = TLE **2                                                       

      STB = 0.0                                                          

      IF (B2 .LT. T2) STB = SQROOT (T2 - B2)                               

C                                                                        

C...THERE ARE NV STREAMWISE STRIPS OF HORSESHOE VORTICES FOR THE         
C...PANEL (IX) UNDER CONSIDERATION. THE DO-LOOP ENDED BY LABEL 110       
C...COMPUTES THE FORCE AND MOMENT CONTRIBUTION OF EACH STRIP AND         
C...THEN PERFORMS THE CORRESPONDING SUMMATIONS TO OBTAIN THE             
C...INTEGRATED PANEL FORCES AND MOMENTS (PER UNIT Q).                    

C...                                                                     

      DO 110 J = 1, NV                                                   

      IR = IR + 1                                                        

C...                                                                     

C...DL IS THE DIHEDRAL ANGLE (WITH RESPECT TO THE X-Y PLANE) OF          

C...THE IR STREAMWISE STRIP OF HORSESHOE VORTICES.                       

C...                                                                     

      SID = SIN (DTR *DL (IR))                                           

      COD = COS (DTR *DL (IR))                                           

C...                                                                     

C...STRIPWISE PARAMETERS OR COEFFICIENTS@                                

C...CNC = NORMAL (TO LOCAL CHORDLINE) FORCE COEFF. TIMES LOCAL           
C...      CHORD LENGTH?                                                  

C...CDC = DRAG COEFF. (WIND AXES) TIMES LOCAL CHORD LENGTH?              

C...CSUC = LEADING EDGE THRUST COEFF. MEASURED IN A PLANE                
C...       PARALLEL TO THE X-X AXIS AND ALONG THE TANGENT                
C...       TO THE CAMBER LINE IN SAME PLANE?                             

C...CMTC = PITCHING MOMENT (BODY AXES) ABOUT LOCAL QUARTER CHORD         
C...       TIMES LOCAL CHORD LENGTH?                                     

C...                                                                     
C...INITIALIZE COEFFICIENTS @                                            
C...                                                                     

C...                                                                     

      CNC (IR) = 0.                                                      

      CDC (IR) = 0.0                                                     

      CSUC (IR) = 0.                                                     

      CMTC (IR) = 0.0                                                    

C                                                                        

      MAX = RNMAX (IR)                                                   

      PION = (PI *(1.0 - FLAX) + 2.0 *FLAX) /RNMAX (IR)                  

      ADC = 0.5 *PION                                                    

      IF (JTS (IR) .GT. 0) ADC = - 0.5 *PION                             

C...                                                                     
C...XLE = LOCATION OF FIRST VORTEX MIDPOINT IN FRACTION OF CHORD.        
C...                                                                     

      XLE=.5 *(1.0 - COS (.5 *PION)) *(1.0 - FLAX) + 0.125 *PION *FLAX   

C...                                                                     
C...BMLE = PITCHING MOMENT ABOUT FIRST VORTEX MIDPOINT IN BODY AXES.     
C...CAXL = AXIAL (X-AXIS) FORCE COEFFICIENT.                             
C...SICPLE = COUPLE (ABOUT STRIP CENTERLINE) DUE TO SIDESLIP.            
C...                                                                     

      BMLE = 0.                                                          

      CAXL = 0.0                                                         

      SICPLE = 0.0                                                       

C                                                                        

      RJTS = JTS (IR)                                                    

      GAF = 0.5 + 0.5 *RJTS **2                                          

C                                                                        

C...THE DO-LOOP ENDED BY LABEL 60 PERFORMS PRESSURE COEFF.               
C...INTGRATIONS ALONG THE STRIP TO OBTAIN CNC (PRESENTLY TREATED         
C...AS CN), CAXL, BMLE, AND SICPLE.                                      
C...                                                                     

C                                                                        

      DO 60 K = 1, MAX                                                   

      IRT = IRT + 1                                                      

      RK = K                                                             

C...                                                                     

C...CORMED IS LENGTH OF STRIP CENTERLINE BETWEEN LOAD POINT              
C...AND TRAILING EDGE? THIS PARAMETER IS USED IN THE COMPUTATION         
C...OF THE STRIP ROLLING COUPLE CONTRIBUTION DUE TO SIDESLIP.            

C...                                                                     

      CORMED = XTE (IR) - X (IRT)                                        

C...                                                                     

C...SINF REFERENCES THE LOAD CONTRIBUTION OF IRT-VORTEX TO THE           
C...STRIP NOMINAL AREA, I.E., AREA OF STRIP ASSUMING CONSTANT            
C...(CHORDWISE) HORSESHOE SPAN.                                          

C...                                                                     

      SINF = (FLAX + (1.0 - FLAX) *SIN ((RK - .5) *PION)) *ADC           
     * *DCP (IRT) *VST (IRT) /VSS (IR)                                   

      CNC (IR) = CNC (IR) + SINF                                         

      SICPLE = SICPLE + SINF *CORMED                                     

C...                                                                     

C...COMPUTE SLOPE (TX) WITH RESPECT TO X-AXIS AT LOAD POINTS BY INTER    
C...POLATING BETWEEN CONTROL POINTS AND TAKING INTO ACCOUNT THE LOCAL    
C...INCIDENCE.                                                           

C...                                                                     

      XX = .5 *(1. - COS ((RK - .5) *PION))                              

      XX = XX *(1.0 - FLAX) + (RK - .75) *PION /2.0 *FLAX                

      IF (K .GT.1) GO TO 30                                              

      KX = K                                                             

      IRTX = IRT                                                         

      GO TO 40                                                           

 30   KX = K - 1                                                         

      IRTX = IRT - 1                                                     

 40   RKX = KX                                                           

      X1 = .5 *(1. - COS (RKX *PION))                                    

      X1 = X1 *(1.0 - FLAX) + (RKX - .25) *PION /2.0 *FLAX               

      X2 = .5 *(1. - COS ((RKX + 1.) *PION))                             

      X2 = X2 *(1.0 - FLAX) + (RKX + .75) *PION /2.0 *FLAX               

      F1 = SLOPE (IRTX)                                                  

      F2 = SLOPE (IRTX + 1)                                              

      TANX = (XX - X2) /(X1 - X2) *F1 + (XX - X1) /(X2 - X1) *F2         

      TX = TANX - ZETA (IR)                                              

      CAXL = CAXL - SINF *TX /(1.0 + TX **2)                             

 50   BMLE = BMLE + (XLE - XX) *SINF                                     

 60   CONTINUE                                                           

C                                                                        

      SICPLE = - SICPLE *COSIN *COD *GAF                                 

C                                                                        

C...                                                                     

C...IRTLE = VALUE OF IRT INDEX FOR FIRST (ALONG CHORD) HORSESHOE         
C...VORTEX, I.E., LEADING EDGE ELEMENT.                                  

C...                                                                     

      IRTLE = IRT - MAX + 1                                              

C...                                                                     

C...                                                                     

C...COMPUTE LEADING EDGE THRUST COEFF. (CSUC) BY CALCULATING             
C...THE TOTAL INDUCED FLOW AT THE LEADING EDGE. THIS COMPUTATION         
C...ONLY PERFORMED FOR COSINE CHORDWISE SPACING (LAX = 0).               

C...                                                                     

C...                                                                     

      CLE = 0.0                                                          

      IF (LAX .EQ. 1) GO TO 90                                           

C                                                                        

      READ (9) EW                                                        

C                                                                        

      DO II = 1, ITOTAL 
       CLE = CLE + EW (II) *GAMMA (II)                                    
      END DO

C                                                                        

C...XGIRO, YGIRO, ZGIRO ARE THE COORDINATES OF THE STRIP LEADING EDGE    
C...MIDPOINT WITH RESPECT TO THE POINT OF AIRCRAFT ROTATION (IF ANY).    

C...                                                                     

      XGIRO = X (IRTLE) - CHORD (IR) *XLE - XBAR                         

      YGIRO = YY (IRTLE)                                                 

      ZGIRO = ZZ (IRTLE) - ZBAR                                          

C...                                                                     

C...VX, VY, VZ ARE THE FLOW ONSET VELOCITY COMPONENTS AT THE LEADING     
C...EDGE (STRIP MIDPOINT). VX, VY, VZ AND THE ROTATION RATES ARE         
C...REFERENCED TO THE FREE STREAM VELOCITY.                              

C...                                                                     

      VX = COSCOS - PITCH *ZGIRO + YAW *YGIRO                            

      VY = COSINP - YAW *XGIRO + ROLL *ZGIRO                             

      VZ = SINALF - ROLL *YGIRO + PITCH *XGIRO                           

C...                                                                     

C...CCNTL AND SCNTL ARE DIRECTION COSINE PARAMETERS OF TANGENT TO        
C...CAMBERLINE AT LEADING EDGE.                                          

C...                                                                     

      CCNTL = 1. /SQROOT (1.0 + SLE (IR) **2)                              

      SCNTL = SLE (IR) *CCNTL                                            

C...                                                                     

C...EFFINC = COMPONENT OF ONSET FLOW ALONG NORMAL TO CAMBERLINE AT       
C...         LEADING EDGE.                                               

C...                                                                     

      EFFINC = VX *SCNTL + VY *CCNTL *SID - VZ *CCNTL *COD               

      CLE = CLE - EFFINC                                                 

 80   IF (STB .GT. 0.0) CLE = CLE /RNMAX (IR) /STB                       

 90   XX = XLE                                                           

      CLE = CLE + 0.5 *DCP (IRTLE) *SQROOT (XX) *FLAX                      

      CSUC (IR) = 0.5 *PI *ABS (SPC (I)) *CLE **2 *STB                   

C...                                                                     

C...END OF L.E. THRUST COEFF. (CSUC) COMPUTATION FOR STRIP IR.           

C...                                                                     

C...                                                                     
C...ORIENT L.E. THRUST VECTOR ACCORDING TO SIGN OF SPC PARAMETER@        

C...IF SPC % 0 THEN L.E. THRUST VECTOR IS TANGENTIAL TO CAMBER           
C...SURFACE? OTHERWISE IT IS NORMAL TO IT. IF THE FIRST ELEMENT          
C...CARRIES A POSITIVE LOAD THEN THE THRUST VECTOR IS NORMAL TO THE      
C...CAMBER SURFACE ALONG THE POSITIVE NORMAL DIRECTION? OTHERWISE        
C...IT IS ALONG THE NEGATIVE NORMAL (THE PARAMETER FKEY DETER-           
C...-MINES THIS DIRECTION @ FKEY = + 1, POSITIVE NORMAL?                 
C...FKEY = - 1, NEGATIVE NORMAL).                                        

C...TFX AND TFZ ARE THE COMPONENTS OF LEADING EDGE FORCE VECTOR ALONG    
C...ALONG THE X AND Z BODY AXES.                                         

C...                                                                     

      FKEY = 1 - JTS (IR) *(1 + JTS (IR))                                

      XCOS = 1.0 /SQROOT (1.0 + (SLE (IR) - ZETA (IR)) **2)                

      XSIN = (SLE (IR) - ZETA (IR)) *XCOS                                

      TFX = XCOS                                                         

      IF (SPC (I) .LT. 0.0 ) TFX = XSIN *SIGN (1.0, DCP (IRTLE)) *FKEY   

      CAXL = CAXL - TFX *CSUC (IR)                                       

      TFZ = - XSIN                                                       

      IF (SPC (I) .LT. 0.0) TFZ = SIGN (XCOS, DCP(IRTLE)) *FKEY          

      CNC (IR) = CNC (IR) + CSUC (IR) *SQROOT (1.0 + T2) *TFZ              

C...                                                                     

C...FCOS AND FSIN ARE THE COSINE AND SINE OF THE ANGLE BETWEEN           
C...THE CHORDLINE OF THE IR-STRIP AND THE X-AXIS                         

C...                                                                     

 100  FCOS = 1. /SQROOT (1. + ZETA (IR) *ZETA (IR))                        

      FSIN = FCOS *ZETA (IR)                                             

C...                                                                     

C...BFX, BFY, AND BFZ ARE THE COMPONENTS ALONG THE BODY AXES             
C...OF THE STRIP FORCE CONTRIBUTION.                                     

C...                                                                     

      BFX = - CNC (IR) *FSIN + CAXL *FCOS                                

      BFY = - (CNC (IR) *FCOS + CAXL *FSIN) *SID                         

      BFZ = (CNC (IR) *FCOS + CAXL *FSIN) *COD                           

C...                                                                     

C...CONVERT CNC FROM CN INTO CNC (COEFF. *CHORD).                        

C...                                                                     

      CNC (IR) = CNC (IR) *CHORD (IR)                                    

      BMLE = BMLE *CHORD (IR)                                            

C...                                                                     

C...BMX, BMY, AND BMZ ARE THE COMPONENTS ALONG THE BODY AXES             
C...OF THE STRIP MOMENT (ABOUT MOM. REF. POINT) CONTRIBUTION.            

C...                                                                     

      BMX = BFZ *Y (IR) - BFY *(Z (IR) - ZBAR)                           

      BMX = BMX + SICPLE                                                 

      BMY = BMLE *COD + BFX * (Z (IR) - ZBAR) - BFZ * (X (IRTLE) -XBAR)  

      BMZ = BMLE *SID - BFX *Y (IR) + BFY * (X (IRTLE) - XBAR)           

      CDC (IR) = BFZ *SINALF +  (BFX *COPSI + BFY *SINPSI) *COSALF       

      CDC (IR) = CDC (IR) *CHORD (IR)                                    

      CMTC (IR) = BMLE + CNC (IR) * (0.25 - XLE)                         

C                                                                        

      ES = 2.0 *VSS (IR)                                                 

      STRIP = ES *CHORD (IR)                                             

      LIFT (IX) = (BFZ *COSALF - (BFX *COPSI + BFY *SINPSI) *SINALF)     

     * *STRIP + LIFT (IX)                                                

      DRAG (IX) = CDC (IR) *ES + DRAG (IX)                               

      FY (IX) = (BFY *COPSI - BFX *SINPSI) *STRIP + FY (IX)              

C                                                                        

      FN (IX) = FN (IX) + CNC (IR) *ES                                   

C                                                                        

      MOMENT (IX) = MOMENT (IX) + STRIP *(BMY *COPSI - BMX *SINPSI)      

      RM (IX) = RM (IX) + STRIP *(BMX *COSALF *COPSI + BMY *COSALF       
     * *SINPSI + BMZ *SINALF)                                            

      YM (IX) = YM (IX) + STRIP *(BMZ *COSALF - (BMX *COPSI + BMY        
     * *SINPSI) *SINALF)                                                 

      XSUC (IX) = XSUC (IX) + CSUC (IR) *STRIP /SURF (IX)                

C                                                                        

 110  CONTINUE                                                           

C                                                                        

C                                                                        

      IF (ICYCLE .EQ. 2) GO TO 130                                       

      I = I + 1                                                          

      IF (I - NPAN) 20, 20, 120                                          

 120  IF (LATRAL .EQ. 0) GO TO 140                                       

      ICYCLE = 2                                                         

      I = 0                                                              

 130  I = I + 1                                                          

      IF (I .GT. NPAN) GO TO 140                                         

      IF (IQUANT (I) .EQ. 1) GO TO 130                                   

      GO TO 20                                                           

C                                                                        

C...INITIALIZE TOTAL FORCE AND MOMENT COEFFICIENTS.                      

C                                                                        

 140  CLTOT = 0.                                                         
      CDTOT = 0.0                                                        
      CMTOT = 0.0                                                        
      CYTOT = 0.0                                                        
      CRTOT = 0.0                                                        
      CNTOT = 0.0                                                        

C...                                                                     

C...THE PARAMETERS AX AND AY INTRODUCE THE PROPER REFERENCE AREA         
C...AND DETERMINE WHETHER A PANEL CONTRIBUTION HAS TO BE DUPLICA         
C...TED (SYMMETRICAL CASE) OR NOT.                                       

C...                                                                     

      AX = 1.0 /SREF                                                     

      IF (LATRAL .EQ. 0) AX = 2.0 *AX                                    

      AY = 1.0 /SREF                                                     

      IF (LATRAL .EQ. 0) AY = 0.0                                        

C                                                                        
C...THE DO-LOOP ENDED BY LABEL 150 COMPUTES PANEL AND TOTAL              
C...FORCE AND MOMENT COEFFICIENTS. MOMENT COEFFICIENTS ARE NOT           
C...DIMENSIONLESS YET? THEY STILL CARRY A LENGTH DIMENSION.              
C...                                                                     

      DO IX = 1, NPANAS  

      CL (IX) = LIFT (IX) /SURF (IX)                                     
      CD (IX) = DRAG (IX) /SURF (IX)                                     
      CM (IX) = MOMENT (IX) /SURF (IX)                                   
      CN (IX) = FN (IX) /SURF (IX)                                       
      CY (IX) = FY (IX) /SURF (IX)                                       
      CRM (IX) = RM (IX) /SURF (IX)                                      
      CYM (IX) = YM (IX) /SURF (IX)                                      
      CLTOT = CLTOT + LIFT (IX) *AX                                      
      CDTOT = CDTOT + DRAG (IX) *AX                                      
      CMTOT = CMTOT + MOMENT (IX) *AX                                    
      CYTOT = CYTOT + FY (IX) *AY                                        
      CRTOT = CRTOT + RM (IX) *AY                                        
      CNTOT = CNTOT + YM (IX) *AY                                        

      END DO

      REWIND 9                                                           

C                                                                        

C                                                                        

      RETURN                                                             

      END                                                                

CONTROL*VRLX.BOUNDY                                             9/17/76  

C...                                                                     

      SUBROUTINE BOUNDY (ITOTAL)                                         

C...                                                                     

C...PURPOSE    TO CALCULATE THE ONSET FLOW COMPONENT NORMAL TO           
C...           THE BOUNDARY SURFACE AT THE VORTEX LATTICE CON            
C...           TROL POINTS.                                              

C...                                                                     

C...INPUT      CALLING SEQUENCE @                                        
C...           ITOTAL = TOTAL NUMBER OF HORSESHOE VORTICES.              

C...           COMMON @                                                  
C...           ALFA, PSI, VINF, PITCHQ, ROLLQ, YAWQ, LAX, RNMAX,         
C...           SX, CX, X, YY, ZZ, DL, CHORD, XBAR, ZBAR, SLOPE,          
C...           RFLAG.                                                    

C...                                                                     

C...OUTPUT     COMMON @                                                  
C...           ALOC, ONSET.                                              

C...                                                                     

C...SUBROUTINES                                                          
C...CALLED     NONE.                                                     

C...                                                                     

C...DISCUSSION THE ONSET FLOW COMPONENT NORMAL TO THE BOUNDARY           
C...           AT THE VORTEX LATTICE CONTROL POINTS IS CALCULATED        
C...           BY PROJECTING THE FREE-STREAM VELOCITY VECTOR             
C...           ALONG THE SURFACE NORMAL AND TAKING INTO ACCOUNT          
C...           A RIGID BODY ROTATION ABOUT THE POINT (XBAR, 0,           
C...           ZBAR). THE ONSET FLOW NORMAL COMPMONENT IS ALOC.          
C...           ONSET DENOTES THE RIGID BODY ROTATION INDUCED             
C...           VELOCITY COMPONENT ALONG THE X-AXIS. BOTH ARRAY           
C...           ALOC AND ONSET, ARE DIMENSIONLESS, I.E., THEY ARE         
C...           REFERENCED TO THE FREE-STREAM VELOCITY.                   

C...                                                                     

C...                                                                     

      COMMON LAX, LAY, IQ, IH, LATRAL, PSI, PITCHQ, ROLLQ, YAWQ, HAG,    
     * FLOATX, FLOATY, INVERS                                            

      COMMON /SET1 /X (12000), Y (1000), Z (1000), ZC (60)                  

      COMMON /SET2 /DCP (12000), SLOPE (12000), VSP (12000)                 

      COMMON /SET3 /CX (12000), SX (12000), RFLAG (12000), IDES (12000)      

      COMMON /SET6 /TITLE (90), HEAD (200), ALOC (12000)                  

      COMMON /SET7 /RNCV (90), RNMAX (1000), ITS (90), JTS (1000)          

      COMMON /SET10 /CHORD (1000), DL (1000), VSS (1000), TNL (1000),    
     * TNT (1000), XTE (1000), IPAN (1000)                               

      COMMON /SET11 /MACH (16), ALPHA (16), ALFA, VINF, NMACH, NALPHA  

      COMMON /SET13 /BIG, ITER, ITRMAX, EPS , WSPAN, RLM                 

      COMMON /SET15 /B2, BETA, CBAR, XBAR, ZBAR                          

      COMMON /SET16 /GAMMA  (12000) , ONSET  (12000)                       

      COMMON /SET20 /ZLE1 (90), ZLE2 (90), PHIMED (1000), RCS (1000),      

     * NPP (90), INTRAC (90), YY (12000), ZZ(12000), VST(12000)             

      INTEGER CX, SX                                                     

C                                                                        

      PI = 3.14159                                                       

      DTR = 0.01745329                                                   

      PITCH = DTR *PITCHQ /VINF                                          

      ROLL = DTR *ROLLQ /VINF                                            

      YAW = DTR *YAWQ /VINF                                              

      PSIRAD = DTR *PSI                                                  

      SINALF = SIN (ALFA)                                                

      COSIN = COS (ALFA) *SIN (PSIRAD)                                   

      COSCOS = COS (ALFA) *COS (PSIRAD)                                  

      FLAX = LAX                                                         

C                                                                        

      DO 10 IR = 1, ITOTAL                                               

C...                                                                     

C...LOCATE VORTEX LATTICE CONTROL POINT WITH RESPECT TO THE              

C...ROTATION CENTER (XBAR, 0, ZBAR). THE RELATIVE COORDINATES            

C...ARE XGIRO, YGIRO, AND ZGIRO.                                         

C...                                                                     

      PION = PI /RNMAX (SX (IR))                                         

      RCX = CX (IR)                                                      

      RSX = SX (IR)                                                      

      DELTAX = 0.5 * (COS ((RCX - .5) *PION) - COS (RCX *PION))          

      DELTAX = DELTAX *(1. - FLAX) + 0.5/RNMAX (SX (IR)) *FLAX           

      XGIRO = X (IR) + CHORD (SX (IR)) *DELTAX - XBAR                    

      YGIRO = YY (IR)                                                    

      ZGIRO = ZZ (IR) - ZBAR                                             

C                                                                        

C...COMPUTE ONSET FLOW (FREE-STREAM + RIGID BODY ROTATION)               

C...VELOCITY COMPONENTS ALONG BODY AXES, VX, VY, AND VZ.                 

C...                                                                     

      VX = COSCOS - PITCH *ZGIRO + YAW *YGIRO                            

      VY = COSIN - YAW *XGIRO + ROLL *ZGIRO                              

      VZ = SINALF - ROLL *YGIRO + PITCH *XGIRO                           

C                                                                        

C...COMPUTE DIRECTION COSINES.                                           

C                                                                        

      SCNTL = SLOPE (IR) /SQROOT (1. + SLOPE (IR) **2)                     

      CCNTL = SQROOT (1.0 - SCNTL **2)                                     

      COD = COS (DTR *DL (SX (IR)))                                      

      SID = SIN (DTR *DL (SX (IR)))                                      

C                                                                        

C...COMPUTE ONSET FLOW COMPONENT ALONG THE OUTWARD NORMAL TO             
C...THE SURFACE AT THE CONTROL POINT, ALOC.                              

C...                                                                     

      ALOC (IR) = VX *SCNTL + VY *CCNTL *SID - VZ *CCNTL *COD            

C...                                                                     

C...THE VALUE OF RFLAG (0. OR 1.) DETERMINES WHETHER THE HORSE           
C...SHOE VORTEX IS SONIC (RFLAG = 0.) OR NOT (RFLAG = 1.). FOR           
C...A SONIC VORTEX THE BOUNDARY CONDITION EQUATION IS REPLACED           
C...BY AN AVERAGING PROCESS AND THEREFORE THE VALUE OF ALOC HAS          
C...TO BE ZEROED OUT.                                                    

C...                                                                     

      ALOC (IR) = ALOC (IR) *RFLAG (IR)                                  

C...                                                                     

C...COMPUTE VELOCITY COMPONENT ALONG X-AXIS INDUCED BY THE RIGID         

C...BODY ROTATION, ONSET.                                                

C...                                                                     

      ONSET (IR) = - PITCH *ZGIRO + YAW *YGIRO                           

 10   CONTINUE                                                           

C                                                                        

C                                                                        

      RETURN                                                             

      END                                                                

CONTROL*VRLX.GAUSS                                              9/13/76  

C...                                                                     

      SUBROUTINE GAUSS (ITOTAL, REXPAR, EW, XRT)                         

C...                                                                     

C...PURPOSE    TO SOLVE THE BOUNDARY CONDITION EQUATIONS BY THE          
C...           METHOD OF [CONTOLLED SUCCESSIVE OVER-RELAXATION[.         

C...                                                                     

C...INPUT      CALLING SEQUENCE@                                         
C...           ITOTAL = TOTAL NUMBER OF HORSESHOE VORTICES.              
C...           REXPAR = RELAXATION PARAMETER.                            
C...           EW = ROW OF NORMALWASH MATRIX.                            

C...           COMMON@                                                   
C...           CX, SX, LAX, ALOC, IDES, CHORD, RNMAX, INVERS,            
C...           ITRMAX.                                                   

C...                                                                     

C...OUTPUT     CALLING SEQUENCE@                                         
C...           XRT = AUXILIARY VECTOR USED IN C.S.O.R. SOLUTION.         

C...           COMMON@                                                   
C...           BIG, DCP, EPS, RLM, SLE, ITER, GAMMA, SLOPE.              

C...           GAMMA IS THE SOLUTION VECTOR OF BOUDARY CONDITION         
C...           EQUATIONS, I. E., HORSESHOE VORTEX CIRCULATION            
C...           STRENGTHS.                                                

C...           NOTE@ IF INVERS = 1 (DESIGN PROCESS) THEN GAMMA IS        
C...           PART INPUT AND PART OUTPUT.                               

C...                                                                     

C...SUBROUTINES                                                          
C...CALLED     NONE.                                                     

C...                                                                     

C...DISCUSSION THIS SUBROUTINE SOLVES FOR THE CIRCULATION STRENGTH       
C...           OF THE HORSESHOE VORTICES THAT SATISFY THE B.C. OF        
C...           NO MASS-FLUX ALONG THE NORMAL TO THE SURFACE AT THE       
C...           CONTROL POINTS. THIS SOLUTION IS PERFORMED ITERA          
C...           TIVELY ROW BY ROW BY USING THE C.S.O.R. METHOD. IF        
C...           A GIVEN ROW IS PART OF A PANEL TO BE DESIGNED, I.E.,      
C...           IDES = 1, THEN INSTEAD OF SOLVING FOR GAMMA(= XPR),       
C...           THE COMPUTATION OF THE SLOPE DISTRIBUTION ALONG           
C...           THAT ROW IS PERFORMED BY MATRIX MULTIPLICATION,           
C...           SLOPE = EW *GAMMA.                                        

C...                                                                     

C...                                                                     

      COMMON LAX, LAY, IQ, IH, LATRAL, PSI, PITCHQ, ROLLQ, YAWQ, HAG,    
     * FLOATX, FLOATY, INVERS                                            

      COMMON /SET2 /DCP (12000), SLOPE (12000), VSP (12000)                 

      COMMON /SET3 /CX (12000), SX (12000), RFLAG (12000), IDES (12000)      

      COMMON /SET6 /TITLE (90), HEAD (200), ALOC (12000)                  

      COMMON /SET7 /RNCV (90), RNMAX (1000), ITS (90), JTS (1000)          

      COMMON /SET10 /CHORD (1000), DL (1000), VSS (1000), TNL (1000),    
     * TNT (1000), XTE (1000), IPAN (1000)                               

      COMMON /SET13 /BIG, ITER, ITRMAX, EPS , WSPAN, RLM                 

      COMMON /SET16 /GAMMA  (12000) , ONSET  (12000)                       

      COMMON /SET19 /SLE1 (90), SLE2 (90), SLE (1000), ZETA (1000)       

      INTEGER CX, SX                                                     

      DIMENSION EW (ITOTAL), XRT (ITOTAL)

C                                                                        

      REWIND 1                                                           

C                                                                        

C...INITIALIZE ARRAYS.                                                   

C...                                                                     

      DO 20 IR = 1, ITOTAL                                               

C...                                                                     

C...GAMMA IS THE SOLUTION VECTOR  AND XRT IS AN AUXILIARY                

C...VECTOR TO BE USED IN THE RELAXATION SOLUTION.                        

C...                                                                     

      GAMMA (IR) = 0.0                                                   

      XRT (IR) = 0.0                                                     

C...                                                                     

C...IF THE IR-HORSESHOE VORTEX IS PART OF A DESIGN PANEL THEN            
C...ITS CIRCULATION STRENGTH IS DIRECTLY COMPUTED FROM THE INPUT         
C...LOAD DISTRIBUTION AND NO SOLUTION BY RELAXATION IS REQUIRED          
C...FOR THE IR-ELEMENT.                                                  

C...                                                                     

      IF (IDES (IR) .EQ. 0) GO TO 20                                     

      IF (LAX .NE. 1) THEN
          GAMMA (IR) = 0.5*DCP(IR)
      ELSE
          GAMMA (IR) = 0.5*DCP(IR) *CHORD (SX (IR)) /RNMAX (SX (IR))
      ENDIF
      
 20   CONTINUE                                                           

C                                                                        

C     **********  GAUSS-SEIDEL OVER-RELAXATION  **********               

C                                                                        

C                                                                        

      RX1 = 1.0 + REXPAR                                                 

      RX2 = 1.0 - REXPAR                                                 

      BIGO = 1.0                                                         

      ITER = 1                                                           

C                                                                        

C...BEGIN THE ITERATION SCHEME.                                          

C...                                                                     

 30   BIG = 0.0                                                          

      COUNT = 0.0                                                        

      EPSUM = 0.1E-11                                                    

C...                                                                     

C...INDEX IRR SELECTS A ROW.                                             

      DO 90 IRR = 1, ITOTAL                                              

C...                                                                     

C...FROM HERE THROUGH LABEL 70 THE SUM OF THE PRODUCTS OF INFLU-         
C...ENCE COEFF. TIMES CIRCULATION STRENGTH FOR A ROW IS COMPUTED         
C...EXCLUDING THE DIAGONAL TERM.                                         

C...                                                                     

 40   SUM = 0.0                                                          

C...                                                                     

C...UNIT 1 CONTAINS THE VORTEX CONTROL POINT NORMALWASH INFLUENCE        
C...COEFF. MATRIX.                                                       

C...                                                                     

      READ (1) EW                                                        

      IF (IDES (IRR) .EQ. 1) GO TO 90                                    

      IF (IRR .EQ. 1) GO TO 60                                           

      LAST = IRR - 1                                                     

      DO IR = 1, LAST     
       SUM = SUM + EW (IR) *GAMMA (IR)
      END DO

      IF (IRR .EQ. ITOTAL) GO TO 80                                      

 60   INITL  = IRR  + 1                                                  

      DO IR = INITL, ITOTAL    
       SUM = SUM + EW (IR) *GAMMA (IR)
      END DO

C...                                                                     

C...DETERMINE NEW VALUE OF A VARIABLE.                                   

C...                                                                     

 80   TEMP = (ALOC (IRR) - SUM) /EW (IRR)                                

C...                                                                     

C...APPLY OVER-RELAXATION USING A RELAXATION PARAMETER BASED ON          
C...VARIABLE VALUES FROM PREVIOUS CYCLE.                                 

C...                                                                     

      TEMP1 = TEMP - GAMMA (IRR)                                         

      RAX = RX1                                                          

      IF (TEMP1 *XRT (IRR) .LT. 0.) RAX =RX2                             

      XRT (IRR) = TEMP1                                                  

      TEMP2 = RAX *TEMP1                                                 

      GAMMA (IRR) = GAMMA (IRR) + TEMP2                                  

C...                                                                     

C...PUT LARGEST RELAXATION RESIDUAL IN BIG.                              

C...                                                                     

      VARMOD = ABS (TEMP2)                                               

      IF (VARMOD .GT. BIG) BIG = VARMOD                                  

C...                                                                     

C...COUNT DETERMINES THE NUMBER OF VARIABLES THAT ARE BEING              

C...SOLVED FOR.                                                          

C...                                                                     

      COUNT = COUNT + 1.0                                                

C...                                                                     

C...EPSUM IS TO BE USED IN CONJUCTION WITH COUNT TO DETERMINE A          

C...ROOT MEAN SQUARE VALUE OF ALL VARIABLES.                             

C...                                                                     

      EPSUM = EPSUM + GAMMA (IRR) *GAMMA (IRR)                           

 90   CONTINUE                                                           

      REWIND 1                                                           

C...                                                                     

C...RLM GIVES APPROXIMATE VALUE OF CONVERGENCE RATE OR MAGNIFI           

C...CATION FACTOR (MODULUS OF LARGEST EIGEN-VALUE).                      

C...                                                                     

      RLM = BIG /BIGO                                                    

C...                                                                     

C...ESTABLISH TOLERANCE LEVEL (EPS) AS A SMALL PERCENTAGE OF ROOT        

C...MEAN SQUARE VALUE OF ALL VARIABLES.                                  

C...                                                                     

      EPS = SQROOT (EPSUM /(COUNT + 1.0)) /200.0                           

C...                                                                     

C...IF LARGEST RESIDUAL IS LESS THEN EPS, PROCESS HAS CONVERGED.         

C...                                                                     

      IF (BIG .LT. EPS .OR. COUNT .LT. 0.5) GO TO 100                    

C...                                                                     

C...IF ITERATION COUNTER EXCEEDS MAXIMUM ALLOWABLE, END RELAXATION.      

C...                                                                     

      IF (ITER .GE. ITRMAX) GO TO 100                                    

      ITER = ITER + 1                                                    

      BIGO = BIG                                                         

      GO TO 30                                                           

C                                                                        

C     **********  END OF GAUSS-SEIDEL OVER-RELAXATION  **********        

C                                                                        

C...FROM HERE TO END OF SUBROUTINE THE DESIGN PROCESS IS PERFORMED.      
C...IF NO DESIGN IS INVOLVED (INVERS = 0) THEN THIS SEGMENT IS BY-       
C...PASSED.                                                              

C                                                                        

 100  IF (INVERS .EQ. 0) GO TO 150                                       

C...                                                                     

C...UNIT 9 CONTAINS THE LEADING EDGE NORMALWASH INFLUENCE COEFF.         
C...MATRIX.                                                              

C...                                                                     

      REWIND 9                                                           


      DO IRR = 1, ITOTAL   

C...                                                                     

C...UNIT 1 CONTAINS THE VORTEX CONTROL POINT NORMALWASH INFLUENCE        
C...COEFF. MATRIX.                                                       

C...                                                                     

      READ (1) EW                                                        

C...                                                                     

C...THE LEADING EDGE NORMALWASH INFLUENCE COEFF. MATRIX IS ONLY          
C...DEFINED FOR LEADING EDGE ELEMENTS (CX = 1). THEREFORE ITS            
C...READING IN IS BYPASSED IF THE ELEMENT IS NOT AT THE L. E..           

C...                                                                     

      IF (CX (IRR) .GT. 1) GO TO 110                                     

      READ (9) XRT                                                       

 110  IF (IDES (IRR) .EQ. 0) GO TO 140                                   

C...                                                                     
C...COMPUTE SURFACE SLOPE AT VORTEX CONTROL POINT LOCATION, SLOPE.       
C...                                                                     

      THETA = 0.                                                         

      DO IR = 1, ITOTAL   
       THETA = THETA + EW (IR) *GAMMA (IR)                                
      END DO

      SLOPE (IRR) = THETA                                                

C...                                                                     

C...COMPUTE SURFACE SLOPE AT LEADING EDGE OF VORTEX STRIP                
C...CENTERLINE, SLE.                                                     

C...                                                                     

      IF (CX (IRR) .GT. 1) GO TO 140                                     

       THETA = 0.0                                                      
       DO IR = 1, ITOTAL   
        THETA = THETA + XRT (IR) *GAMMA (IR)                              
       END DO

       SLE (SX (IRR)) = THETA                                           

 140  END DO
    
      REWIND 1                                                           

      REWIND 9                                                           

 150  RETURN                                                             

      END                                                                

CONTROL*VRLX.GEOM                                               9/16/76  


      SUBROUTINE NEWGAUSS (ITOTAL, REXPAR, EW, XRT)   

C...                                                                     

C...PURPOSE    TO SOLVE THE BOUNDARY CONDITION EQUATIONS BY THE          
C...           METHOD OF [CONTOLLED SUCCESSIVE OVER-RELAXATION[.         

C...                                                                     

C...INPUT      CALLING SEQUENCE@                                         
C...           ITOTAL = TOTAL NUMBER OF HORSESHOE VORTICES.              
C...           REXPAR = RELAXATION PARAMETER.                            
C...           EW = ROW OF NORMALWASH MATRIX.                            

C...           COMMON@                                                   
C...           CX, SX, LAX, ALOC, IDES, CHORD, RNMAX, INVERS,            
C...           ITRMAX.                                                   

C...                                                                     

C...OUTPUT     CALLING SEQUENCE@                                         
C...           XRT = AUXILIARY VECTOR USED IN C.S.O.R. SOLUTION.         

C...           COMMON@                                                   
C...           BIG, DCP, EPS, RLM, SLE, ITER, GAMMA, SLOPE.              

C...           GAMMA IS THE SOLUTION VECTOR OF BOUDARY CONDITION         
C...           EQUATIONS, I. E., HORSESHOE VORTEX CIRCULATION            
C...           STRENGTHS.                                                

C...           NOTE@ IF INVERS = 1 (DESIGN PROCESS) THEN GAMMA IS        
C...           PART INPUT AND PART OUTPUT.                               

C...                                                                     

C...SUBROUTINES                                                          
C...CALLED     NONE.                                                     

C...                                                                     

C...DISCUSSION THIS SUBROUTINE SOLVES FOR THE CIRCULATION STRENGTH       
C...           OF THE HORSESHOE VORTICES THAT SATISFY THE B.C. OF        
C...           NO MASS-FLUX ALONG THE NORMAL TO THE SURFACE AT THE       
C...           CONTROL POINTS. THIS SOLUTION IS PERFORMED ITERA          
C...           TIVELY ROW BY ROW BY USING THE C.S.O.R. METHOD. IF        
C...           A GIVEN ROW IS PART OF A PANEL TO BE DESIGNED, I.E.,      
C...           IDES = 1, THEN INSTEAD OF SOLVING FOR GAMMA(= XPR),       
C...           THE COMPUTATION OF THE SLOPE DISTRIBUTION ALONG           
C...           THAT ROW IS PERFORMED BY MATRIX MULTIPLICATION,           
C...           SLOPE = EW *GAMMA.                                        

C...                                                                     

C...                                                                     

      COMMON LAX, LAY, IQ, IH, LATRAL, PSI, PITCHQ, ROLLQ, YAWQ, HAG,    
     * FLOATX, FLOATY, INVERS                                            

      COMMON /SET2 /DCP (12000), SLOPE (12000), VSP (12000)                 

      COMMON /SET3 /CX (12000), SX (12000), RFLAG (12000), IDES (12000)      

      COMMON /SET6 /TITLE (90), HEAD (200), ALOC (12000)                  

      COMMON /SET7 /RNCV (90), RNMAX (1000), ITS (90), JTS (1000)          

      COMMON /SET10 /CHORD (1000), DL (1000), VSS (1000), TNL (1000),    
     * TNT (1000), XTE (1000), IPAN (1000)                               

      COMMON /SET13 /BIG, ITER, ITRMAX, EPS , WSPAN, RLM                 
 
      COMMON /SET16 /GAMMA  (12000) , ONSET  (12000)                       

      COMMON /SET19 /SLE1 (90), SLE2 (90), SLE (1000), ZETA (1000)         

      INTEGER CX, SX                                                     

      DIMENSION EW (ITOTAL), XRT (ITOTAL)
    
C     "IN CORE" STORAGE

      DIMENSION EMAT(2000,2000)

C    COMMON /EMATRIX/ EMAT(2000,2000)
    
C                                                                        

      REWIND 1                                                           

C                                                                        

C...INITIALIZE ARRAYS.                                                   

C...                                                                     

      DO IR = 1, ITOTAL     

C...GAMMA IS THE SOLUTION VECTOR  AND XRT IS AN AUXILIARY                
C...VECTOR TO BE USED IN THE RELAXATION SOLUTION.                        

      GAMMA (IR) = 0.0                                                   
      XRT (IR) = 0.0                                                     

C...IF THE IR-HORSESHOE VORTEX IS PART OF A DESIGN PANEL THEN            
C...ITS CIRCULATION STRENGTH IS DIRECTLY COMPUTED FROM THE INPUT         
C...LOAD DISTRIBUTION AND NO SOLUTION BY RELAXATION IS REQUIRED          
C...FOR THE IR-ELEMENT.                                                  

      IF (IDES (IR) .NE. 0) THEN
       IF (LAX .NE. 1) THEN
        GAMMA (IR) = 0.5*DCP(IR)
       ELSE
        GAMMA (IR) = 0.5*DCP(IR) *CHORD (SX (IR)) /RNMAX (SX (IR))
       ENDIF
      END IF
       
      END DO

C                                                                        
C     **********  GAUSS-SEIDEL OVER-RELAXATION  **********               
C                                                                        

      RX1 = 1.0 + REXPAR                                                 
      RX2 = 1.0 - REXPAR                                                 
      BIGO = 1.0                                                         
      ITER = 1                                                           

C    READ IN MATRIX ONLY ONCE

      DO IRR = 1, ITOTAL
       READ (1) EW
       DO IR = 1, ITOTAL
        EMAT(IRR,IR) = EW(IR)
       END DO
      END DO

C                                                                        

C...BEGIN THE ITERATION SCHEME.                                          

C...                                                                     

 30   BIG = 0.0                                                          
      COUNT = 0.0                                                        
      EPSUM = 0.1E-11                                                    



C...INDEX IRR SELECTS A ROW.                                             

      DO IRR = 1, ITOTAL  

C...                                                                     

C...FROM HERE THROUGH LABEL 70 THE SUM OF THE PRODUCTS OF INFLU-         
C...ENCE COEFF. TIMES CIRCULATION STRENGTH FOR A ROW IS COMPUTED         
C...EXCLUDING THE DIAGONAL TERM.                                         

C...                                                                     

 40   SUM = 0.0                                                          

C...                                                                     

C...UNIT 1 CONTAINS THE VORTEX CONTROL POINT NORMALWASH INFLUENCE        
C...COEFF. MATRIX.                                                       

C...                                                                     

C      READ (1) EW                                                        

      IF (IDES (IRR) .EQ. 1) GO TO 90                                    

      IF (IRR .NE. 1) THEN
       LAST = IRR - 1  
         DO IR = 1, LAST     
          SUM = SUM + EMAT(IRR,IR) *GAMMA (IR)
       END DO
         IF (IRR .NE. ITOTAL) THEN
          INITL  = IRR  + 1                                           
          DO IR = INITL, ITOTAL    
           SUM = SUM + EMAT(IRR,IR) *GAMMA (IR)
          END DO
       END IF
      ELSE
       INITL  = IRR  + 1                                              
       DO IR = INITL, ITOTAL    
        SUM = SUM + EMAT(IRR,IR) *GAMMA (IR)
       END DO
      END IF


C...                                                                     

C...DETERMINE NEW VALUE OF A VARIABLE.                                   

C...                                                                     

 80   TEMP = (ALOC (IRR) - SUM) /EMAT(IRR,IRR)   

C...                                                                     

C...APPLY OVER-RELAXATION USING A RELAXATION PARAMETER BASED ON          
C...VARIABLE VALUES FROM PREVIOUS CYCLE.                                 

C...                                                                     

      TEMP1 = TEMP - GAMMA (IRR)                                         

      RAX = RX1                                                          

      IF (TEMP1 *XRT (IRR) .LT. 0.) RAX =RX2                             

      XRT (IRR) = TEMP1                                                  

      TEMP2 = RAX *TEMP1                                                 
      GAMMA (IRR) = GAMMA (IRR) + TEMP2                                  

C...PUT LARGEST RELAXATION RESIDUAL IN BIG.                              

      VARMOD = ABS (TEMP2)                                               

      IF (VARMOD .GT. BIG) BIG = VARMOD                                  

C...COUNT DETERMINES THE NUMBER OF VARIABLES THAT ARE BEING              
C...SOLVED FOR.                                                          
C...                                                                     

       COUNT = COUNT + 1.

C...                                                                     
C...EPSUM IS TO BE USED IN CONJUCTION WITH COUNT TO DETERMINE A          
C...ROOT MEAN SQUARE VALUE OF ALL VARIABLES.                             
C...                                                                     

       EPSUM = EPSUM + GAMMA (IRR) *GAMMA (IRR)                           
    
90    END DO

C...RLM GIVES APPROXIMATE VALUE OF CONVERGENCE RATE OR MAGNIFI           
C...CATION FACTOR (MODULUS OF LARGEST EIGEN-VALUE).                      

      RLM = BIG /BIGO                                                    

C...ESTABLISH TOLERANCE LEVEL (EPS) AS A SMALL PERCENTAGE OF ROOT        
C...MEAN SQUARE VALUE OF ALL VARIABLES.                                  

      EPS = SQROOT (EPSUM /(COUNT + 1.0)) /200.0                           

C...IF LARGEST RESIDUAL IS LESS THEN EPS, PROCESS HAS CONVERGED.         

      IF (BIG .LT. EPS .OR. COUNT .LT. 0.5) GO TO 100                    

C...IF ITERATION COUNTER EXCEEDS MAXIMUM ALLOWABLE, END RELAXATION.      

      IF (ITER .GE. ITRMAX) GO TO 100                                    

      ITER = ITER + 1                                                    
      BIGO = BIG                                                         
    
      GO TO 30                                                           

C                                                                        
C     **********  END OF GAUSS-SEIDEL OVER-RELAXATION  **********        
C                                                                        

C...FROM HERE TO END OF SUBROUTINE THE DESIGN PROCESS IS PERFORMED.      
C...IF NO DESIGN IS INVOLVED (INVERS = 0) THEN THIS SEGMENT IS BY-       
C...PASSED.                                                              

C                                                                        

 100  IF (INVERS .EQ. 0) GO TO 150                                       

C...                                                                     

C...UNIT 9 CONTAINS THE LEADING EDGE NORMALWASH INFLUENCE COEFF.         
C...MATRIX.                                                              

C...                                                                     

      REWIND 9                                                           


      DO IRR = 1, ITOTAL   

C...                                                                     

C...UNIT 1 CONTAINS THE VORTEX CONTROL POINT NORMALWASH INFLUENCE        
C...COEFF. MATRIX.                                                       

C...                                                                     

C      READ (1) EW                                                        

C...THE LEADING EDGE NORMALWASH INFLUENCE COEFF. MATRIX IS ONLY          
C...DEFINED FOR LEADING EDGE ELEMENTS (CX = 1). THEREFORE ITS            
C...READING IN IS BYPASSED IF THE ELEMENT IS NOT AT THE L. E..           

      IF (CX (IRR) .GT. 1) GO TO 110                                     

      READ (9) XRT                                                       

 110  IF (IDES (IRR) .EQ. 0) GO TO 140                                   

C...COMPUTE SURFACE SLOPE AT VORTEX CONTROL POINT LOCATION, SLOPE.       

      THETA = 0.                                                         

      DO IR = 1, ITOTAL   
       THETA = THETA + EMAT(IRR,IR) *GAMMA (IR) 
      END DO

      SLOPE (IRR) = THETA                                                

C...COMPUTE SURFACE SLOPE AT LEADING EDGE OF VORTEX STRIP                
C...CENTERLINE, SLE.                                                     

      IF (CX (IRR) .LE. 1) THEN
       THETA = 0.0                                                      
       DO IR = 1, ITOTAL   
        THETA = THETA + XRT (IR) *GAMMA (IR)                              
       END DO
       SLE (SX (IRR)) = THETA                                           
      END IF

 140  END DO
    

      REWIND 9                                                           

 150  RETURN                                                             

      END                                                                


CONTROL*VRLX.GEOM                                               9/16/76  


C...                                                                     

      SUBROUTINE GEOM (ITOTAL)                                           

C...                                                                     

C...PURPOSE    TO COMPUTE THE VORTEX LATTICE GEOMETRY AND SURFACE        
C...           SLOPES AT THE CONTROL POINTS. ALSO TO COMPUTE THE         
C...           LOAD DISTRIBUTION AT THE CORRESPONDING LOAD POINTS        
C...           IF DESIGN PROCESS IS INVOKED (IDES = 1).                  

C...                                                                     

C...INPUT      CALLING SEQUENCE@                                         
C...           NONE.                                                     

C...           COMMON@                                                   
C...           DL, ITS, LAX, LAY, NPP, PDL, RCS, VSS, NPAN, NVOR,        
C...           RNCV, SLE1, SLE2, ZLE1, ZLE2, AINC1, AINC2, DNDX1,        
C...           DNDX2, GAMMA, LESWP, PSPAN, SYNTH, TAPER, XAPEX,          
C...           YAPEX, ZAPEX, CSTART, INTRAC, IQUANT, LATRAL,             
C...           PHIMED.                                                   

C...                                                                     

C...OUTPUT     CALLING SEQUENCE@                                         
C...           ITOTAL = TOTAL NUMBER OF HORSESHOE VORTICES.              

C...           COMMON@                                                   
C...           X, Y, Z, CX, DL, NT, SX, YY, ZZ, DCP, JTS, SLE,           
C...           TNL, TNT, VSP, VSS, VST, XTE, ALOC, IPAN, SMAX,           
C...           ZETA, CHORD, RNMAX, SLOPE, NPANAS.                        

C...           NOTE@ DL AND VSS MAY BE EITHER INPUT OR OUTPUT            
C...           DEPENDING ON CONFIGURATION CONDITIONS.                    

C...                                                                     

C...SUBROUTINES                                                          
C...CALLED     NONE.                                                     

C...                                                                     

C...DISCUSSION THE VORTEX LATTICE GEOMETRY IS LAID OUT PANEL BY          
C...           PANEL BASED ON THE GEOMETRIC AND VORTEX DISTRIBU          
C...           TION CHARACTERISTICS SPECIFIED FOR THE GIVEN PANEL        
C...           IN THE INPUT DATA (INPUT SUBROUTINE). EACH PANEL          
C...           IS SUBDIVIDED INTO A NUMBER OF X-AXIALWISE STRIPS         
C...           (NVOR), EACH STRIP CONTAINING A GIVEN NUMBER (RNMAX =     
C...           RNCV) OF HORSESHOE VORTICES WHOSE BOUND TRAILING LEGS     
C...           COINCIDE WITH THE X-AXIALWISE EDGES OF THE STRIP IF       
C...           THE PARAMETER NPP = 0. WHEN NPP = 1 THERE IS NO           
C...           LONGER A CONTINUOUS STRIP OF VORTICES SINCE THEY ARE      
C...           NOT LOCATED IN THE SAME PLANE? IN THIS CASE (NPP =        
C...           1) THE STRIP BECOMES AN ARRAY OR ROW OF VORTICES          
C...           LOCATED IN TANDEM BUT WHOSE SPANS ARE NOT NECES           
C...           SARILY EQUAL. EACH STRIP OR VORTEX ROW IS IDENTI          
C...           FIED BY AN INDEX (SX). EACH HORSESHOE VORTEX IN A         
C...           GIVEN STRIP OR ROW IS IDENTIFIED BY A SECOND INDEX        
C...           (CX), THE VALUE CX = 1 DENOTING THE LEADING EDGE          
C...           ELEMENT, AND CX = RNMAX = RNCV DENOTING THE LAST,         
C...           OR TRAILING EDGE, HORSESHOE OF THE ROW. THEREFORE         
C...           EACH AND EVERY HORSESHOE VORTEX IS UNIQUELY IDEN          
C...           TIFIED BY EITHER AN OVERALL INDEX (WHICH RUNS FROM        
C...           1 TO ITOTAL) OR BY THE PAIR OF VALUES (CX, SX).           
C...           THE SPATIAL LAY-OUT OF THE VORTEX LATTICE CORRES          
C...           PONDING TO A GIVEN PANEL DEPENDS ON THE VALUES OF         
C...           TWO PARAMETERS@ PDL AND NPP. IF PDL .LE. 360.0 THEN       
C...           THE TRANSVERSE VORTEX SEGMENTS OF THE SAME VALUE OF       
C...           CX FORM A CONTINUOUS STRAIGHT LINE? BUT IF PDL .GT.       
C...           360.0 THEN THE TRANSVERSE VORTEX SEGMENTS OF SAME CX,     
C...           THOUGH STILL CONTINUOUS, FORM A POLYGONAL LINE            
C...           WHEN PROJECTED ON A PLANE NORMAL TO THE X-AXIS. IF        
C...           NPP = 0 THEN ALL THE TRANSVERSE VORTEX SEGMENTS           
C...           OF A GIVEN ROW (SAME SX) LIE IN THE SAME PLANE?           
C...           BUT IF NPP = 1 THEN THE TRANSVERSE SEGMENTS OF A          
C...           ROW ARE LAID ON THE ACTUAL BODY SURFACE. THE BOUND        
C...           TRAILING LEGS OR SEGMENTS ARE ALWAYS PARALLEL TO          
C...           THE X-AXIS (UP TO THE TRAILING EDGE OF THE GIVEN          
C...           STRIP OR ROW).                                            


      COMMON LAX, LAY, IQ, IH, LATRAL, PSI, PITCHQ, ROLLQ, YAWQ, HAG,    
     * FLOATX, FLOATY, INVERS                                            

      COMMON /SET1 /X (12000), Y (1000), Z (1000), ZC (60)                  

      COMMON /SET2 /DCP (12000), SLOPE (12000), VSP (12000)                 

      COMMON /SET3 /CX (12000), SX (12000), RFLAG (12000), IDES (12000)      

      COMMON /SET4 /DNDX1 (400), DNDX2 (400), AINC1 (90), AINC2 (90)     

      COMMON /SET5 /XAPEX (60), YAPEX (60), ZAPEX (60), PDL (60),        
     * LESWP (60), SYNTH (60), IQUANT (60), CSTART (60), TAPER (60),     
     * PSPAN (60), NVOR (60)                                             

      COMMON /SET6 /TITLE (90), HEAD (200), ALOC (12000)                  

      COMMON /SET7 /RNCV (90), RNMAX (1000), ITS (90), JTS (1000)          

      COMMON /SET10 /CHORD (1000), DL (1000), VSS (1000), TNL (1000),    
     * TNT (1000), XTE (1000), IPAN (1000)                               

      COMMON /SET14 /NPAN, NT, SMAX , NPANAS                             

      COMMON /SET16 /GAMMA  (12000) , ONSET  (12000)                       

      COMMON /SET19 /SLE1 (90), SLE2 (90), SLE (1000), ZETA (1000)         

      COMMON /SET20 /ZLE1 (90), ZLE2 (90), PHIMED (1000), RCS (1000),      
     * NPP (90), INTRAC (90), YY (12000), ZZ(12000), VST(12000)             

      INTEGER TITLE, CX, SX                                              

      REAL NVOR, LESWP                                                   

      PI = 3.14159                                                       

      DTR = 0.01745329                                                   

C                                                                        

C  LATTICE GEOMETRY                                                      

C                                                                        
C...INITIALIZE INDICES.                                                  
C...                                                                     

      IR = 0                                                             
      IRR = 0                                                            
      SMAX = 0.                                                          
      NPANAS = 0                                                         
      KED = 0                                                            
      KEG = 0                                                            
      SIGN = 1.0                                                         
      I = 1                                                              
      ICYCLE = 1                                                         
      JUMP = 0                                                           

C                                                                        

C...IN DEFINING THE VORTEX LATTICE GEOMETRY, THE COMPUTATION IS          
C...PERFORMED ONE PANEL AT A TIME (STATEMENTS INCLUDED BETWEEN           
C...LABELS 10 AND 80). IF THE CONFIGURATION IS SYMMETRICAL THE           
C...COMPUTATION EXTENDS OVER ONE HALF OF IT ONLY (MIRROR SYM             
C...METRY IS ASSUMED). OTHERWISE THE COMPUTATIONAL CYCLE IS RE           
C...PEATED FOR THE OTHER HALF OF THE CONFIGURATION.                      

C                                                                        

 10   SMAX = SMAX + NVOR (I)                                             

      NPANAS = NPANAS + 1                                                

      DELTA = 0.5 *PSPAN (I) /NVOR (I)                                   

      ETA = 0.                                                           

      TAD = TAN (DTR * LESWP (I)) *SIGN                                  

      NV = NVOR (I)                                                      

      XNOT = XAPEX (I)                                                   

      YNOT = YAPEX (I) *SIGN                                             

      ZNOT = ZAPEX (I)                                                   

C                                                                        

C                                                                        

      KEDOR = KED                                                        

      KEGOR = KEG                                                        

C                                                                        

C                                                                        

      DO 80 J = 1, NV                                                    

      IR = IR + 1                                                        

      IPAN (IR) = I                                                      

      RNMAX (IR) = RNCV (I)                                              

C...                                                                     

C...DETERMINE DISTRIBUTION OF VORTEX TRAILING LEGS (LATERAL VORTEX       
C...SPACING)? IF LAY = 0 @ COSINE SPACING? IF LAY = 1 @ EQUAL            
C...SPACING. DELTA IS HALF THE LATERAL VORTEX SPACING.                   

C...                                                                     

      IF (LAY .EQ. 0 ) DELTA = 0.25 *PSPAN (I) *(COS (PI *FLOAT(J-1)/    

     * NVOR (I)) - COS (PI *FLOAT (J) /NVOR (I)))                        

C...                                                                     

C...IF PDL .LE. 360.0 THEN VSS AND DL HAVE TO BE COMPUTED? OTHER         
C...WISE (PDL .GT. 360.) THEY HAVE ALREADY BEEN COMPUTED DURING THE      
C...INPUT PROCESS (INPUT SUBROUTINE). THE INDEX JUMP HELPS DETER         
C...MINE THE VALUES TO BE MIRRORED WHEN BOTH LEFT AND RIGHT HALVES       
C...OF THE CONFIGURATION ARE BEING LATTICED (ASYMMETRICAL CASE,          
C...I. E., LATRAL = 1).                                                  

C...                                                                     

      IF (PDL (I) .LE. 360.) THEN
       VSS (IR) = DELTA  
       DL (IR) = PDL (I)
      ENDIF
    
      VSS (IR) = VSS (IR - JUMP)                                         
      RCS (IR) = RCS (IR - JUMP)                                         

      DL (IR) = DL (IR - JUMP) *SIGN                                     

      IF(INTRAC(I).EQ.0) PHIMED(IR) = 0.                                 

      PHIMED (IR) = PHIMED (IR - JUMP) *SIGN - 90.0 *(SIGN - 1.0)        

      SID = SIN (DTR *DL (IR))                                           

      COD = COS (DTR *DL (IR))                                           

      DTJ = VSS (IR)                                                     

      IF (J .GT.1) THEN
       XNOT = XLE + VSS (IR - 1) *TAD *SIGN                               
       YNOT = Y (IR - 1) + VSS (IR - 1) *COS (DTR *DL(IR - 1)) *SIGN      
       ZNOT = Z (IR - 1) + VSS (IR - 1) *SIN (DTR *DL (IR -1)) *SIGN      
       ETA = ETA + VSS (IR - 1) /PSPAN (I)                                
      END IF

C...                                                                     

C...DETERMINE LATERAL COORDINATES (Y, Z) OF STRIP CENTERLINE OR          

C...VORTEX ROW REFERENCE LINE. BY DEFINITION THIS LINE IS PARALLEL       

C...TO X-AXIS.                                                           

C...                                                                     

 30   Y (IR) = YNOT + DTJ *COD *SIGN                                     

      Z (IR) = ZNOT + DTJ *SID *SIGN                                     

      XLE = XNOT + DTJ *TAD *SIGN                                        

      ETA = ETA + DTJ /PSPAN (I)                                         

C...                                                                     

C...COMPUTE TANGENT OF LOCAL INCIDENCE (ANGLE BETWEEN CHORDLINE          

C...AND STRIP REFERENCE LINE) BY ASSUMING STRAIGHT ELEMENT LINE          

C...LOFTING (THE TANGENT IS CALLED DINC).                                

C...                                                                     

      DINC = AINC1 (I) *(1. - ETA) + AINC2 (I) *TAPER (I) *ETA           

      DINC = DINC /(1.0 - ETA + TAPER (I) *ETA)                          

C...                                                                     

C...THE PARAMETER INTRAC DETERMINES WHETHER THE PANEL UNDER CON          
C...SIDERATION IS PART OF A QUASI-CYLINDRICAL BODY OR PART OF A          
C...OR PART OF A FUSIFORM BODY (INTRAC = 1). FOR A FUSIFORM BODY         
C...AINC1 IS THE TANGENT OF THE INCIDENCE OF THE BODY AXIS WITH          
C...RESPECT TO THE X-Y PLANE, AND AINC2 IS THE TANGENT OF THE            
C...INCIDENCE OF THE BODY AXIS WITH RESPECT TO THE X-Z PLANE.            

C...                                                                     

      IF (INTRAC (I) .EQ. 1)  DINC = AINC1 (I) *COD + AINC2 (I) *SID     

C...                                                                     

C...COMPUTE CHORD LENGTH (CHORD) ALONG STRIP CENTERLINE BY               
C...ASSUMING STRAIGHT PANEL LEADING AND TRAILING EDGES AND               
C...NEGLECTING THE EFFECT OF TWIST.                                      

C...                                                                     

      CHORD (IR) = CSTART (I) *(1.0 + ETA *(TAPER (I) - 1.0))            

C...                                                                     

C...COMPUTE LEADING EDGE SLOPE (SLE).                                    

C...                                                                     

      SLE (IR) = SLE1 (I) *(1. - ETA) + SLE2 (I) *ETA + DINC             

      IF (INTRAC (I) .NE. 0)  THEN
       FRC = RCS (IR) /CHORD (IR)                                       
       CODIF = COS (DTR *(90.0 - PHIMED (IR) + DL (IR)))                
      ENDIF

 40   JTS (IR) = ITS (I)                                                 

      ZETA (IR) = DINC                                                   

C...                                                                     

C...COMPUTE TANGENT OF LEADING EDGE SWEEP (TNL), TANGENT OF              

C...TRAILING EDGE SWEEP (TNT), AND X-ORDINATE OF TRAILING EDGE           

C...OF STRIP CENTERLINE (XTE).                                           

C...                                                                     

      TNL (IR) = TAD                                                     

      TNT (IR) = TAD - SIGN *CSTART (I) *(1. - TAPER (I)) /PSPAN (I)     

      XTE (IR) = XLE + CHORD (IR)                                        

      MAX = RNMAX (IR)                                                   

      PION = PI /RNMAX (IR)                                              

C                                                                        

C                                                                        

C...THE DO-LOOP ENDED BY LABEL 70 COMPUTES FOR A GIVEN STRIP OR          
C...VORTEX ROW THE VALUES OF TRANSVERSE SEGMENT MIDPOINT X-ORDI          
C...NATES (X), THE TANGENT OF THE SWEEP OF THOSE SEGMENTS (VSP),         
C...THE SLOPE OF THE SURFACE AT THE CONTROL POINTS (SLOPE) AS            
C...DETERMINED BY STRAIGHT ELEMENT LINE LOFTING, OR IF A DESIGN          
C...PROCESS IS INVOKED (SYNTH = 1.), THE VALUE OF THE LOAD COEFF.        
C...(DCP) AT VORTEX MIDPOINT IS DETERMINED BY LINEAR INTERPOLATION.      
C...ALSO EACH HORSESHOE VORTEX IS GIVEN A VALUE OF IDES WHICH DE         
C...TERMINES WHETHER ITS LOAD COEFFICIENT IS A KNOWN (INPUT)             
C...QUANTITY (IDES = 1) OR IT IS TO BE SOLVED FOR (IDES = 0).            
C...IN ADDITION, THE HORSESHOE VORTICES ARE TAGGED WITH THE PROPER       
C...CX - SX VALUES. ALOC IS AN AUXILIARY ARRAY WHICH CONTAINS THE        
C...THE DISPLACEMENTS OF THE VORTEX MIDPOINTS (LOAD POINTS) WITH         
C...RESPECT TO THE STRIP REFERENCE LINE, IN PERCENT OF LOCAL             
C...CHORD LENGTH.                                                        

C...                                                                     

      DO 70 K = 1, MAX                                                   

      KEDK = KEDOR + K                                                   

      KEGK = KEGOR + K                                                   

      IF (J .GT. 1)  GO TO 50                                            

      KED = KED + 1                                                      

      KEG = KEG + 1                                                      

 50   IRR = IRR + 1                                                      

      CX (IRR) = K                                                       

      SX (IRR) = IR                                                      

      RK = K                                                             

      DTJ = .5 * (1.0 - COS ((RK - .5) *PION))                           

      IF (LAX .EQ. 1) DTJ = (RK - 0.75) /RNMAX (IR)                      

      X (IRR) = XLE + DTJ *CHORD (IR)                                    

      VSP(IRR) = TAD -DTJ *CSTART(I) *(1.-TAPER(I))/ABS(PSPAN(I)) *SIGN  

      ALOC (IRR) = 0.0                                                   

      IF (SYNTH (I) .GT. 0.5) GO TO 60                                   

      IDES (IRR) = 0                                                     

      SLOPE (IRR) = DNDX1 (KEDK) *(1. - ETA) + DNDX2 (KEDK) *ETA + DINC  

      KEGK2 = KEGK + MAX                                                 

      ALOC (IRR) = GAMMA (KEGK) *(1. - ETA) + GAMMA (KEGK2) *ETA         

      ALOC (IRR) = ALOC (IRR) +  DINC *DTJ *100.                         

      IF (INTRAC (I) .EQ. 0)  GO TO 70                                   

      SLOPE (IRR) = DNDX1 (KEDK) *COD + FRC *DNDX2 (KEDK) *CODIF + DINC  

      ALOC (IRR) = GAMMA (KEGK2)                                         

      GO TO 70                                                           

 60   DCP (IRR) = DNDX1 (KEDK) + (DNDX2 (KEDK) - DNDX1 (KEDK)) *ETA      

      IDES (IRR) = 1                                                     

      SLOPE (IRR) = 0.0                                                  

 70   CONTINUE                                                           

C                                                                        

C                                                                        

 80   CONTINUE                                                           

C                                                                        

C                                                                        

C                                                                        

      KEG = KEG + MAX                                                    

C                                                                        

C                                                                        

      IF (ICYCLE .EQ. 2) GO TO 100                                       

      I = I + 1                                                          

      IF (I - NPAN) 10, 10, 90                                           

 90   IF (LATRAL .EQ. 0) GO TO 110                                       

C...                                                                     

C...                                                                     

C...IF CONFIGURATION OR FLIGHT CONDITION IS ASYMMETRICAL (LATRAL         
C...= 1) THEN DETERMINE PANEL HAS TO BE DUPLICATED FOR OPPOSSITE         
C...HALF OF CONFIGURATION.                                               

C...                                                                     

C...                                                                     

      ICYCLE = 2                                                         

      JUMP = IR                                                          

      I = 0                                                              

      SIGN = - 1.0                                                       

      KED = 0                                                            

      KEG = 0                                                            

 100  I = I + 1                                                          

      IF (I .GT. NPAN) GO TO 110                                         

      NV = NVOR (I)                                                      

      NCORD = RNCV (I)                                                   

      IF (IQUANT(I) .EQ. 1)  KED = KED + NCORD                           

      IF (IQUANT(I) .EQ. 1)  KEG = KEG + 2 *NCORD                        

      JUMP = JUMP + NV * (IQUANT (I) - 2)                                

      IF (IQUANT (I) .EQ. 1) GO TO 100                                   

      GO TO 10                                                           

 110  ITOTAL = IRR                                                       

      NT = SMAX                                                          

C                                                                        

C                                                                        

      IRR = 0                                                            

C                                                                        

C...THE DO-LOOP ENDED BY LABEL 190 COMPUTES THE LATERAL COORDI           
C...NATES OF VORTEX MIDPOINTS (YY AND ZZ) AND THE SEMISPAN OF            
C...EACH HORSESHOE. IF NPP = 0 THE VORTEX MIDPOINT LATERAL CO            
C...ORDINATES COINCIDE WITH THOSE OF STRIP CENTERLINE.                   

C...                                                                     

      DO 190 IR = 1, NT                                                  

      MAX = RNMAX (IR)                                                   

      DNORM = CHORD (IR) *0.010                                          

      INX = IPAN (IR)                                                    

      ISEND = 1 + INTRAC (INX)                                           

      GO TO (120, 130), ISEND                                            

 120  CDL = COS (DTR *DL (IR))                                           

      SDL = SIN (DTR *DL (IR))                                           

      GO TO 140                                                          

 130  CDL = SIN (DTR *PHIMED (IR))                                       

      SDL = - COS (DTR *PHIMED (IR))                                     

 140  DO 180 L = 1, MAX                                                  

      IRR = IRR + 1                                                      

      YY (IRR) = Y (IR)                                                  

      ZZ (IRR) = Z (IR)                                                  

      VST (IRR) = VSS (IR)                                               

      IF (NPP (INX) .EQ. 0) GO TO 180                                    

      GO TO (150, 160), ISEND                                            

 150  DELTA = ALOC (IRR) *DNORM                                          

      GO TO 170                                                          

 160  DELTA = RCS (IR) *(0.1 *SQROOT (ALOC (IRR)) - 1.0)                   

 170  YY (IRR) = Y (IR) - DELTA *SDL                                     

      ZZ (IRR) = Z (IR) + DELTA *CDL                                     

      VOREX = 1.0                                                        

      IF (INTRAC (INX) .EQ. 1)  VOREX = (RCS (IR) + DELTA) /RCS (IR)     

      VST (IRR) = VOREX *VSS (IR)                                        

 180  CONTINUE                                                           

 190  CONTINUE                                                           

C                                                                        

C                                                                        

      RETURN                                                             

      END                                                                

CONTROL*VRLX.INPUT                                              9/16/76  

C...                                                                     

      SUBROUTINE INPUT                                                   

C...                                                                     

C...PURPOSE    TO READ IN INPUT DATA AND PREPARE SUCH DATA FOR           
C...           USE IN THE GENERATION OF VORTEX LATTICE GEOMETRY          
C...           TO BE DONE IN SUBROUTINE GEOM.                            

C...                                                                     

C...INPUT      CALLING SEQUENCE@                                         
C...           NONE.                                                     

C...           COMMON@                                                   
C...           LAX.                                                      

C...                                                                     

C...OUTPUT     CALLING SEQUENCE@                                         
C...           NONE.                                                     

C...           COMMON@                                                   

C...           DL, XS, ITS, NPP, NXS, NYS, NZS, PDL, PSI, RCS,           
C...           SPC, VSS, CBAR, HEAD, MACH, NPAN, NVOR, RNCV, SLE1,       
C...           SLE2, SREF, VINF, XBAR, YAWQ, YNOT, ZBAR, ZLE1,           
C...           ZLE2, ZNOT, AINC1, AINC2, ALPHA, DNDX1, DNDX2,            
C...           GAMMA, LESWP, NMACH, PSPAN, ROLLQ, SYNTH, TAPER,          
C...           WSPAN, XAPEX, YAPEX, ZAPEX, CSTART, DELTAY, DELTAZ,       
C...           INTRAC, INVERS, IQUANT, LATRAL, NALPHA, PHIMED,           
C...           PITCHQ.                                                   

C...                                                                     

C...SUBROUTINES                                                          
C...CALLED     NONE.                                                     

C...                                                                     

C...DISCUSSION A MASTER FRAME OF REFERENCE IS ASSUMED IN DEFINING        
C...           A CONFIGURATION. THIS FRAME OF REFERENCE IS AN            
C...           ORTHOGONAL CARTESIAN COORDINATE SYSTEM, THE X-Z           
C...           BEING THE CENTERLINE PLANE WITH THE X-AXIS POINTING       
C...           DOWNSTREAM, AND THE Z-AXIS DIRECTED UPWARD? THE           
C...           Y-AXIS POINTS TO STARBOARD. THE ORIGIN OF THE SYS         
C...           TEM CAN BE ANY CONVEVIENT POINT IN THE X-Z PLANE.         
C...           THE CONFIGURATION CAN BE MADE UP OF SYMMETRICAL           
C...           (ABOUT THE X-Z PLANE) AND/OR ASYMMETRICAL COMPO-          
C...           NENTS, AND IN DEFINING THE SYMMETRICAL COMPONENTS         
C...           ONLY THE STARBOARD ELEMENTS ARE SPECIFIED. THE            
C...           CONFIGURATION TO BE INPUT IS DIVIDED INTO A SET           
C...           OF MAJOR PANELS? UP TO 20 OF THESE PANELS CAN BE          
C...           INPUT, SYMMETRICAL COMPONENTS (LEFT + RIGHT) BEING        
C...           COUNTED ONLY ONCE. FOR INSTANCE, A WING OF ZERO           
C...           THICKNESS AND WITH STRAIGHT LEADING AND TRAILING          
C...           EDGES, AND WITH LINEAR LOFTING BETWEEN ROOT AND           
C...           TIP, CONSTITUTES A MAJOR PANEL. COMPLEX PLANFORMS,        
C...           AND NON-LINEAR CHANGES IN TWIST AND AIRFOIL SECTIONS      
C...           ARE DESCRIBED BY DEFINING MORE THAN ONE PANEL FOR A       
C...           GIVEN WING. SUBROUTINE INPUT PREPARES THE DATA SPE        
C...           CIFIED FOR EACH MAJOR PANEL SO THAT THEY CAN LATER        
C...           BE USED IN SUBROUTINE GEOM TO GENERATE THE PROPER         
C...           VORTEX LATTICE FOR EACH PANEL.                            
C...           AN AIRFOIL WITH THICKNESS CAN BE REPRESENTED BY A         
C...           DOUBLE VORTEX SHEET, I. E., BY DEFINING TWO MAJOR PA      
C...           NELS ARRANGED IN A "BIPLANE", OR "SANDWICH", FASHION?     
C...           ONE PANEL REPRESENTING THE UPPER SURFACE OF THE AIR       
C...           FOIL, AND THE OTHER PANEL REPRESENTING THE LOWER          
C...           SURFACE OF THE SAME AIRFOIL.                              
C...           FUSIFORM BODIES ARE MODELLED BY DEFINING AN AUXILIARY     
C...           BODYIDENTICAL IN CROSS-SECTIONAL SHAPE AND LONGITUDI      
C...           NAL AREA DISTRIBUTION TO THE ACTUAL BODY BUT WITHOUT      
C...           CAMBER. THE AUXILIARY BODY CROSS-SECTION IS APPROXI       
C...           MATED BY A POLYGON WHOSE SIDES DETERMINE THE TRANS        
C...           VERSE LEGS OF THE HORSESHOE VORTICES. THE VERTICES        
C...           OF THE POLYGON AND THE AUXILIARY BODY AXIS DEFINE         
C...           A SET OF RADIAL PLANES IN WHICH THE BOUND TRAILING        
C...           LEGS OF THE HORSESHOE VORTICES LIE PARALLEL TO THE        
C...           AXIS. AS THE CROSS-SECTION CHANGES SHAPE ALONG THE        
C...           AXIS, THE POLYGON CHANGES ACCORDINGLY BUT WITH THE        
C...           CONSTRAINT THAT THE POLYGONAL VERTICES MUST ALWAYS        
C...           LIE IN THE SAME SET OF RADIAL PLANES. THE BODY CAMBER     
C...           IS SPECIFIED INDEPENDENTLY.                               
C...                                                                     
C...                                                                     

C...                                                                     

      DIMENSION C1 (60), C2 (60), RO (61), PHI (61)                      

      DIMENSION XAF (60), ZC1 (60), ZC2 (60)                             

      DIMENSION DESCRP (10)                                              

      REAL MACH, NVOR, LIFT, MOMENT, LESWP                               

      INTEGER TITLE, CX, SX                                              

      COMMON LAX, LAY, IQ, IH, LATRAL, PSI, PITCHQ, ROLLQ, YAWQ, HAG,    
     * FLOATX, FLOATY, INVERS, ISOLV                                     

*      COMMON /SET1 /X (12000), Y (1000), Z (1000), ZC (90)                  

      COMMON /SET1 /X (12000), Y (1000), Z (1000), ZC (60)                  

      COMMON /SET2 /DCP (12000), SLOPE (12000), VSP (12000)                 

      COMMON /SET3 /CX (12000), SX (12000), RFLAG (12000), IDES (12000)      

      COMMON /SET4 /DNDX1 (400), DNDX2 (400), AINC1 (90), AINC2 (90)     

      COMMON /SET5 /XAPEX (60), YAPEX (60), ZAPEX (60), PDL (60),        
     * LESWP (60), SYNTH (60), IQUANT (60), CSTART (60), TAPER (60),     
     * PSPAN (60), NVOR (60)                                             

      COMMON /SET6 /TITLE (90), HEAD (200), ALOC (12000)                  

      COMMON /SET7 /RNCV (90), RNMAX (1000), ITS (90), JTS (1000)          

      COMMON /SET8 /LIFT (60), DRAG (60), MOMENT (60), CL (60),          
     * CD (60), CM (60), FN (60), CN (60), FY (60), CY (60),             
     * RM (60), CRM (60), YM (60), CYM (60), XSUC (60), SURF (60)        

      COMMON /SET9 /CDC (1000), CNC (1000)                                 

      COMMON /SET10 /CHORD (1000), DL (1000), VSS (1000), TNL (1000),    
     * TNT (1000), XTE (1000), IPAN (1000)                                  

      COMMON /SET11 /MACH (16), ALPHA (16), ALFA, VINF, NMACH, NALPHA 

      COMMON /SET12 /CLTOT, CDTOT, CMTOT, SREF, CYTOT, CRTOT, CNTOT      

      COMMON /SET13 /BIG, ITER, ITRMAX, EPS , WSPAN, RLM                 

      COMMON /SET14 /NPAN, NT, SMAX , NPANAS                             

      COMMON /SET15 /B2, BETA, CBAR, XBAR, ZBAR                          

      COMMON /SET16 /GAMMA  (12000) , ONSET  (12000)                       

      COMMON /SET17 /CSUC (1000), CMTC (1000), SPC (60)                  

      COMMON /SET18 /NXS, NYS, NZS, YNOT, DELTAY, ZNOT, DELTAZ, XS (90)  

      COMMON /SET19 /SLE1 (90), SLE2 (90), SLE (1000), ZETA (1000)         

      COMMON /SET20 /ZLE1 (90), ZLE2 (90), PHIMED (1000), RCS (1000),      
     * NPP (90), INTRAC (90), YY (12000), ZZ (12000), VST(12000)            

C                                                                        

      PI = 3.14159                                                       

      DTR = 0.01745329                                                   

C                                                                        

C...FLIGHT CONDITIONS AND CONFIGURATION REFERENCE PARAMETERS ARE         
C...ARE READ IN FIRST.                                                   

      READ (99, *) NMACH, (MACH (I), I = 1, NMACH)                      
      
      WRITE (7, *) 'NMACH         MACH'
      WRITE (7, 20) NMACH, (MACH (I), I = 1, NMACH)                      

 20   FORMAT (I2, 8X, 16F10.3) 

C...                                                                     


      READ (99, *) NALPHA, (ALPHA (I) , I = 1, NALPHA)                  

      WRITE (7, *) 'NALPHA         ALPHA'
      WRITE (7, 20) NALPHA, (ALPHA (I) , I = 1, NALPHA)                  

C...                                                                     

C...                                                                     

C...                                                                     

      READ (99, *) LATRAL, PSI, PITCHQ, ROLLQ, YAWQ, VINF               

      IF (PSI .NE. 0.) LATRAL = 1                                        
      IF (ROLLQ .NE. 0.) LATRAL = 1                                      
      IF (YAWQ .NE. 0.) LATRAL = 1                                       
      IF (VINF .LE. 0.001) VINF = 1.0                                    

      WRITE(7,*) 'LATRAL          PSI      PITCHQ    ROLLQ     YAWQ',
     &     '     VINF'
      WRITE(7,20) LATRAL, PSI, PITCHQ, ROLLQ, YAWQ, VINF            

      READ (99, *) NPAN, SREF, CBAR, XBAR, ZBAR, WSPAN               

 30   FORMAT (I2, 8X, 5F10.0)                                            

 40   FORMAT (I2, 8X, F10.2, 4F10.4)  

      IF (WSPAN .LE. 0.0001) WSPAN = 2.0                                 

      WRITE(7,*) 'NPAN          SREF      CBAR      XBAR      ZBAR',
     &     '     WSPAN'
      WRITE(7, 40) NPAN, SREF, CBAR, XBAR, ZBAR, WSPAN  

 50   FORMAT (8F10.0)                                                    
 60   FORMAT (4(F10.2, F10.4))                                   

C                                                                        
C...                                                                     
C...                                                                     

      INVERS = 0                                                         
      KED = 0                                                            
      KEG = 0                                                            
      KEGR = 0                                                           

C...                                                                     

C...THE DO-LOOP ENDED BY LABEL 365 READS IN THE COMPLETE DEFINITION      
C...OF EACH MAJOR PANEL MAKING UP THE CONFIGURATION, THERE BEING         
C...NPAN SUCH PANELS.                                                    

C...                                                                     

      DO 390 I = 1, NPAN                                                 
     
       WRITE (7, 70 ) I                               
 70    FORMAT (/10X'********** PANEL ', I3, ' **********')

 80    FORMAT (8F10.4)

C...                                                                     

C...DEFINE STREAMWISE EDGES (2) OF PANEL BY SPECIFYING COORDINATES       
C...OF LEADING EDGES (X1, Y1, Z1, X2, Y2, Z2) AND CHORD LENGTHS          
C...(CORD1, CORD2). CHORD LENGTHS ARE MEASURED PARALLEL TO X-AXIS.       
C...DESCRP IS ANY PANEL IDENTIFICATION LABEL.                            

C...                                                                     

      READ (99, 100) X1, Y1, Z1, CORD1, DESCRP                            

C                                                                        

C...SAVE PANEL DESCRIPTION INFORMATION FOR IDENTIFICATION IN             
C...PRINTOUT OF DATA IN SUBROUTINE PRINT.                                

C                                                                        

      ISTART = (I - 1) *10                                               

      DO IL = 1, 10  
       IM = ISTART + IL                                                  
       HEAD (IM) = DESCRP (IL)                                           
      END DO
    

C                                                                        

      WRITE (7, *) '        X1        Y1        Z1    CORD1'
      WRITE (7, 110) X1, Y1, Z1, CORD1, DESCRP                           

      READ (99, 100) X2, Y2, Z2, CORD2, DESCRP                            

      WRITE (7, *) '        X2        Y2        Z2    CORD2'
      WRITE (7, 110) X2, Y2, Z2, CORD2, DESCRP                           

C...                                                                     

C...DEFINE PANEL VORTEX LATTICE DENSITY BY SPECIFYING SPANWISE           
C...(NVOR) AND CHORDWISE (RNCV) NUMBERS OF HORSESHOE VORTICES.           
C...ALSO SPECIFY LEADING EDGE SUCTION CHARACTERISTICS FOR PANEL          
C...(SPC) AND PANEL LATERAL (OR SPANWISE) CURVATURE (OR SHAPE)           
C...CHARACTERISTC (PDL).                                                 

C...                                                                     

      READ (99, 100) NVOR (I), RNCV (I), SPC (I), PDL (I), DESCRP         
      WRITE (7,*) '      NVOR      RNCV       SPC       PDL'
      WRITE (7, 110) NVOR (I), RNCV (I), SPC (I), PDL (I), DESCRP        

 100  FORMAT (4F10.0, 10A4)                                              
 110  FORMAT (4F10.4,2X,10A4) 

C...                                                                     

C...                                                                     

C...PARAMETER INTRAC INDICATES WHETHER PANEL IS STRAIGHT IN THE          
C...LATERAL (OR SPANWISE) DIRECTION (INTRAC = 0), OR CURVED              
C...(POLYGONALLY SEGMENTED) IN SAME DIRECTION (INTRAC = 1).              

C...                                                                     

C...                                                                     

      INTRAC (I) = 1                                                     

      IF (PDL (I) .EQ. 0.0) INTRAC (I) = 0                               

      XAPEX (I) = X1                                                     
      YAPEX (I) = Y1                                                     
      ZAPEX (I) = Z1                                                     

      CSTART (I) = CORD1                                                 

      DELTAY = Y2 - Y1                                                   
      DELTAZ = Z2 - Z1                                                   

C...                                                                     

C...IF PANEL IS LATERALLY FLAT (INTRAC = 0) THEN MAKE PDL EQUAL          
C...TO PANEL DIHEDRAL AND COMPUTE PANEL SPAN (PSPAN) AND LEADING         
C...EDGE SWEEP.                                                          

C...                                                                     

C...                                                                     

C...                                                                     

      IF (INTRAC (I) .EQ. 0) PDL (I) = 1. /DTR *ATAN2 (DELTAZ, DELTAY)   
      IF (INTRAC (I) .EQ. 0) PSPAN (I) = SQROOT (DELTAY **2+DELTAZ **2)  

      DELTAX = X2 - X1                                                   

      IF(INTRAC (I) .EQ. 0) LESWP (I) = 1./DTR*ATAN2 (DELTAX, PSPAN(I))  

      TAPER (I) = CORD2 /CORD1                                           

C...                                                                     

C...                                                                     

C...IF PANEL IS LATERALLY CURVED OR SEGMENTED (INTRAC = 1) THEN          
C...DETERMINE THE VALUE OF LATERAL (OR SPANWISE) INDEX (EQUIVALENT       
C...TO SX, SEE SUBROUTINE GEOM) OF ITS FIRST STREAMWISE STRIP OR         
C...ROW OF VORTICES, IBOT.                                               

C...                                                                     

C...                                                                     

      IF ( INTRAC (I) .EQ. 0) GO TO 150                                  

      NV = NVOR (I)                                                      

      IBOT = 1                                                           

      IF (I .EQ. 1) GO TO 130                                            

      ITOP = I - 1                                                       

      DO 120 J = 1, ITOP                                                 
       INV = NVOR (J)                                                    
       IBOT = IBOT + INV                                                 
 120  CONTINUE                                                           

C...                                                                     

C...                                                                     
C...READ IN POLAR COORDINATES OF CONTROL SURFACE CYLINDER CROSS          
C...SECTION, OR AUXILIARY BODY MASTER CROSS-SECTION. ONLY                
C...APPLICABLE IF INTRAC = 1.                                            
C...                                                                     

C...                                                                     

 130  ITOP = IBOT + NV - 1                                               

      JJTOP = NVOR (I) + 1                                               

      WRITE (7,*) 'BODY CROSS SECTION DATA'
      DO JJ= 1, JJTOP
       READ (99, *)  PHI (JJ), RO (JJ)
       WRITE (7,60) PHI(JJ), RO(JJ)
      END DO
    
      PSPAN (I) = 0.0                                                    

C...                                                                     

C...                                                                     
C...COMPUTE CROSS-SECTIONAL PARAMETERS OF CONTROL SURFACE CYLINDER       
C...OR AUXILIARY BODY.                                                   
C...                                                                     

C...                                                                     

      DO 140 IR = IBOT, ITOP                                             

      JJ = IR - IBOT + 1                                                 

      DELTAZ = RO (JJ + 1) *SIN (DTR*PHI(JJ+ 1)) - RO (JJ) *             
     * SIN (DTR * PHI (JJ))                                              

      DELTAY = RO (JJ + 1) *COS (DTR*PHI(JJ + 1)) - RO (JJ) *            
     * COS (DTR * PHI (JJ))                                              

      DL (IR) = 1. /DTR *ATAN2 (DELTAZ, DELTAY)                          

      DMZ = RO (JJ) * SIN (DTR*PHI (JJ)) + 0.5 * DELTAZ                  

      DMY = RO (JJ) * COS (DTR * PHI (JJ)) + 0.5 * DELTAY                

      PHIMED (IR) = ATAN2 (DMZ, DMY) /DTR                                

      RCS (IR) = SQROOT (DMY **2 + DMZ **2)                                

      VSS (IR) = 0.5 *SQROOT (DELTAY **2 + DELTAZ **2)                     

      PSPAN (I) = PSPAN (I) + 2.0 *VSS (IR)                              

 140  CONTINUE                                                           

C...                                                                     

C...                                                                     

      LESWP (I) = 1. /DTR *ATAN2 (DELTAX, PSPAN (I))                     

C...                                                                     

C...                                                                     
C...CONTINUE READING IN DATA APPLICABLE TO BOTH INTRAC = 0 AND           
C...INTRAC = 1.                                                          
C...                                                                     

C...                                                                     
      
 150  write(*,*)AINC1(I),AINC2(I),ITS(I),NAP,IQUANT(I),ISYNT,NPP(I) 
       READ(99,*) AINC1(I),AINC2(I),ITS(I),NAP,IQUANT(I),ISYNT,NPP(I)   

C...                                                                     
C...MAKE APPROPIATE INPUT PARAMETERS COMPATIBLE WITH PANEL CHARAC        
C...TERISTICS TO PREVENT EXECUTION ERRORS.                               
C...                                                                     

      IF (INTRAC (I) .EQ. 1 .AND. NAP .LT. 3) NPP (I) = 0                

      IF (IQUANT (I) .EQ. 0) IQUANT (I) = 2                              

      IF (IQUANT (I) .EQ. 1) LATRAL = 1                                  

C...                                                                     
      WRITE(7,*) '    AINC1     AINC2 ITS      NAP    IQUANT',
     &  '     ISYNT        NPP'
      WRITE(7,170) AINC1(I),AINC2(I),ITS(I),NAP,IQUANT(I),ISYNT,NPP(I)   

C...                                                                     

 170  FORMAT (2F10.4, 5(I3, 7X))                          

C...                                                                     

      SYNTH (I) = ISYNT                                                  

      MAX = RNCV (I)                                                     

      ZLE1 (I) = 0.0                                                     

      ZLE2 (I) = 0.0                                                     

C...                                                                     

C...CLEAR OUT APPROPIATE SECTION OF ARRAY GAMMA WHICH IS TO BE           
C...USED AS TEMPORARY INPUT DATA STORAGE FOR LATER MANIPULATION          
C...IN SUBROUTINE GEOM.                                                  

C...                                                                     

      DO 180 L1 = 1, MAX                                                 

      KEG = KEG + 1                                                      

      KEG2 = KEG + MAX                                                   

      GAMMA (KEG) = 0.0                                                  

      GAMMA (KEG2) = 0.0                                                 

 180  CONTINUE                                                           

C...                                                                     

C...                                                                     
C...IF PANEL SURFACE WARP WILL NOT BE DESIGNED (ANALYSIS CASE)           
C...THEN BYPASS READING IN OF LOAD COEFFICIENTS.                         
C...                                                                     

C...                                                                     

      IF (ISYNT .EQ. 0) GO TO 190                                        

      WRITE(7,*) 'LOAD COEFFICIENTS'
      WRITE(7,*) 'C1'
      DO K=1,MAX
       READ  (99, *)  C1(K)
      END DO
    
      WRITE (7, 80) (C1(K), K = 1, MAX) 

      WRITE(7,*) 'C2'
      DO K=1,MAX
       READ  (99, *)  C2(K)
      END DO
    
      WRITE (7, 80) (C2(K), K = 1, MAX) 

C...                                                                     

C...INVERS INDICATES WHETHER THERE IS ONE (OR MORE) PANEL IN THE         
C...CONFIGURATION WHICH IS TO BE DESIGNED IN TERMS OF SURFACE WARP.      
C...INVERS = 1 @ CAMBER DESIGN REQUIRED FOR ONE OR MORE PANELS.          
C...INVERS = 0 @ NO PANEL IS TO BE DESIGNED.                             

C...                                                                     

      INVERS = 1                                                         

      SLE1 (I) = 0.                                                      

      SLE2 (I) = 0.                                                      

      GO TO 300                                                          

C...                                                                     

C...                                                                     
C...IF PANEL IS A FLAT PLATE THEN SKIP READING OF PANEL CAMBER           
C...DEFINITION DATA. IF NAP .LT. 3 PANEL IS ASSUMED TO BE FLAT .         
C...                                                                     

C...                                                                     

 190  IF (NAP .LT. 3) GO TO 280                                          

C                                                                        

C...IF PANEL IS EITHER UPPER SURFACE OR LOWER SURFACE OF AN AIRFOIL      
C...(ILE .EQ. 1 .OR. ILE .EQ. - 1) THEN THE CORRESPONDING LEADING        
C...EDGE RADII (RLE1, RLE2) HAVE TO BE READ IN.                          

C...                                                                     

      ILE = ITS (I) *(1 - INTRAC (I))                                    

      WRITE (7,*) 'XAF'
      DO JJ=1, NAP
       READ (99, *)  XAF (JJ)
      END DO
    
      WRITE (7, 80) (XAF (JJ), JJ = 1, NAP)        

      RLE1 = 0.0                                                         

      RLE2 = 0.0                                                         

      IF (ILE .NE. 0)  THEN
       WRITE(7,*) 'UPPER SURFACE'
       WRITE(7,*) 'RLE1'
       READ (99, *) RLE1   
       WRITE (7, 80) RLE1                                
      ENDIF

      IF (PDL(I).GT.360.) THEN
       WRITE(7,*) 'ZC1 - CAMBER OF BODY AXIS'
      ELSE
       WRITE(7,*) 'ZC1 - CAMBER OF WING ROOT'
      ENDIF

      DO JJ=1,NAP
       READ (99,*) ZC1 (JJ)
      END DO
    
      WRITE (7, 80) (ZC1 (JJ) , JJ = 1, NAP)                            

      IF (ILE .NE. 0) THEN
       WRITE(7,*) 'LOWER SURFACE'
       WRITE(7,*) 'RLE2'
       READ (99, *) RLE2    
       WRITE (7, 80) RLE2   
      ENDIF

      IF (PDL(I) .GT. 360.) THEN
       WRITE(7,*) 'ZC2 - AREA RATIO OF FUSIFORM BODY'
      ELSE
       WRITE(7,*) 'ZC2 - CAMBER OF WING TIP'
      ENDIF
    
      DO JJ=1,NAP
       READ (99, *) ZC2 (JJ)
      END DO
    
      WRITE (7, 80)  (ZC2 (JJ), JJ = 1, NAP)

      ZLE1 (I) = ZC1 (1)                                                 
      ZLE2 (I) = ZC2 (1)                                                 

C                                                                        
C                                                                        

      JC = 2                                                             

      MAXIM = MAX + 1                                                    

C...                                                                     

C...THE DO-LOOP ENDED BY LABEL 270 COMPUTES THE SLOPE OF THE             
C...SURFACE AT THE CORRESPONDING CONTROL POINTS ALONG THE                
C...STREAMWISE EDGES OF THE PANEL. THESE SLOPES ARE STORED IN            
C...ARRAYS DNDX1 (EDGE 1) AND DNDX2 (EDGE 2). THE SLOPE COMPUTATION      
C...IS DONE BY USING 3-POINT LAGRANGE POLYNOMIALS. IF ILE .NE. 0         
C...THEN SQUARE ROOT TYPE LAGRANGE POLYNOMIAL IS USED FOR THE            
C...COMPUTATION OF SLOPE NEAR THE LEADING EDGE.                          

C...                                                                     

      DO 270 JJX = 1, MAXIM                                              

      JX = JJX - 1                                                       

      IF (LAX .EQ. 1) THEN
       XX = (FLOAT (JX) - 0.25) /RNCV (I) *100.0                   
      ELSE
       XX = (1. - COS (PI *FLOAT (JX) /RNCV (I))) *50.0     
      END IF
    
      IF (XX .LT. 0.) XX = 0.    

 210  IF (XX .GE. XAF (JC - 1) .AND. XX .LE. XAF (JC)) GO TO 220         

      IF (JC .EQ. (NAP - 1)) GO TO 220                                   

      JC = JC + 1                                                        

      GO TO 210                                                          

 220  XX1 = XAF (JC - 1)                                                 

      XX2 = XAF (JC)                                                     

      XX3 = XAF (JC + 1)                                                 

      D1 = (XX1 - XX2) *(XX1 - XX3)                                      

      D2 = (XX2  - XX3) *(XX2 - XX1)                                     

      D3 = (XX3 - XX1) *(XX3 - XX2)                                      

      P1 = (XX2 + XX3) /D1                                               

      P2 = (XX3 + XX1) /D2                                               

      P3 = (XX1 + XX2) /D3                                               

      VI1 = ZC1 (JC - 1)                                                 

      VI2 = ZC1 (JC)                                                     

      VI3 = ZC1 (JC + 1)                                                 

      VO1 = ZC2 (JC - 1)                                                 

      VO2 = ZC2 (JC)                                                     

      VO3 = ZC2 (JC + 1)                                                 

      IF (ILE .EQ. 0 .OR. JC .GT. 2) GO TO 240                           

      IF (XX .LE. 0.0) GO TO 230                                         

C                                                                        

      SIGN1 = 1.0                                                        

      SIGN2 = 1.0                                                        

      IF (VI2 .LT. VI1) SIGN1 = -1.0                                     

      IF (VO2 .LT. VO1) SIGN2 = -1.0                                     

      B1AO = SIGN1 *SQROOT (2.0 *RLE1)                                     

      B2AO = SIGN2 *SQROOT (2.0 *RLE2)                                     

      B1C2 = VI2 - B1AO *SQROOT (XX2) - VI1                                

      B2C2 = VO2 - B2AO *SQROOT (XX2) - VO1                                

      B1C3 = VI3 - B1AO *SQROOT (XX3) - VI1                                

      B2C3 = VO3 - B2AO *SQROOT (XX3) - VO1                                

      B1A1 = (B1C2 *XX3 /XX2 - B1C3 *XX2 /XX3) /(XX3 - XX2)              

      B2A1 = (B2C2 *XX3 /XX2 - B2C3 *XX2 /XX3) /(XX3 - XX2)              

      B1A2 = (B1C2 /XX2 - B1C3 /XX3) /(XX2 - XX3)                        

      B2A2 = (B2C2 /XX2 - B2C3 /XX3) /(XX2 - XX3)                        

      C1VAL = 0.5 *B1AO /SQROOT (XX) + B1A1 + 2. *B1A2 *XX                 

      C2VAL = 0.5 *B2AO /SQROOT (XX) + B2A1 + 2. *B2A2 *XX                 

C                                                                        

      GO TO 250                                                          

 230  C1VAL = 0.0                                                        

      C2VAL = 0.0                                                        

      GO TO 250                                                          

 240  C1VAL = 2.0*(VI1/D1+VI2/D2+VI3/D3)*XX-P1*VI1-P2*VI2-P3*VI3         

      C2A = VO1 /D1 + VO2 /D2 + VO3 /D3                                  

      C2B = P1 *VO1 + P2 *VO2 + P3 *VO3                                  

      C2VAL = 2.0 *C2A *XX - C2B                                         

      IF (INTRAC (I) .EQ. 0) GO TO 250                                   

      C2C = VO1 *XX2 *XX3/D1 + VO2 *XX3 *XX1/D2 + VO3 *XX1 *XX2/D3       

      FTEMP = C2A *XX **2 - C2B *XX + C2C                                

      IF (FTEMP .GT. 0.0) C2VAL = 5.0 *C2VAL /SQROOT (FTEMP)               

      IF (FTEMP .LE. 0.0) C2VAL = -100.                                  

 250  IF (JJX .GT. 1) GO TO 260                                          

      SLE1 (I) = C1VAL                                                   

      SLE2 (I) = C2VAL                                                   

      GO TO 270                                                          

 260  C1 (JX) = C1VAL                                                    

      C2 (JX) = C2VAL                                                    

 270  CONTINUE                                                           

      GO TO 300                                                          

C...                                                                     

C...                                                                     

C...FOR FLAT PLATE PANEL MAKE SLOPES EQUAL TO ZERO.                      

C...                                                                     

C...                                                                     

 280  DO 290 K = 1, MAX                                                  

      C1 (K) = 0.0                                                       

      C2 (K) = 0.0                                                       

 290  CONTINUE                                                           

      SLE1 (I) = 0.                                                      

      SLE2 (I) = 0.                                                      

C...                                                                     

C...                                                                     

C...STORE SLOPES OR LOAD COEFFICIENTS (AS CASE MAY BE) IN ARRAYS         
C...DNDX1 AND DNDX2.                                                     

C...                                                                     

C...                                                                     

 300  DO 310 K = 1, MAX                                                  

      KED = KED + 1                                                      

      DNDX1 (KED) = C1 (K)                                               

      DNDX2 (KED) = C2 (K)                                               

 310  CONTINUE                                                           

C...                                                                     

C...                                                                     

C...IF VORTEX LATTICE IS TO BE LAID OUT ON BODY SURFACE RATHER           
C...THAN ON SOME CYLINDRICAL CONTROL SURFACE (NON = 1), THEN THE         
C...PROFILE OF THIS SURFACE AT THE PANEL EDGES IS COMPUTED IN THE        
C...DO-LOOP ENDED BY LABEL 370. THE RESULTS ARE STORED IN THE ARRAY      
C...GAMMA FOR USE IN SUBROUTINE GEOM. FOR FUSIFORM BODIES, BODY          
C...SURFACE IMPLIES AUXILIARY BODY SURFACE.                              

C...                                                                     

      NON = 1                                                            

      IF (NPP (I) .EQ. 0) NON = 0                                        

      IF (NAP .LT. 3) NON = 0                                            

      IF (ISYNT .EQ. 1) NON = 0                                          

      IF (NON .EQ. 0) GO TO 380                                          

C...                                                                     

C...                                                                     

      JC = 2                                                             

C...                                                                     

      DO 370 JX = 1, MAX                                                 

      KEGR = KEGR + 1                                                    

      RJX = JX                                                           

      IF (LAX .EQ. 1) THEN
       XX = (RJX - 0.75) /RNCV (I) *100.0   
      ELSE
       XX = (1.0 - COS ((RJX - 0.5) *PI /RNCV (I))) *50.0   
      END IF

 330  IF (XX .GE. XAF (JC - 1) .AND. XX .LE. XAF (JC))  GO TO 340        

      IF (JC .EQ. (NAP - 1)) GO TO 340                                   

      JC = JC + 1                                                        

      GO TO 330                                                          

 340  XX1 = XAF (JC - 1)                                                 

      XX2 = XAF (JC)                                                     

      XX3 = XAF (JC + 1)                                                 

      D1 = (XX1 - XX2) *(XX1 - XX3)                                      

      D2 = (XX2 - XX3) *(XX2 - XX1)                                      

      D3 = (XX3 - XX1) *(XX3 - XX2)                                      

      P1 = (XX2 + XX3) /D1                                               

      P2 = (XX3 + XX1) /D2                                               

      P3 = (XX1 + XX2) /D3                                               

      F1 = ZC1 (JC - 1)                                                  

      F2 = ZC1 (JC)                                                      

      F3 = ZC1 (JC + 1)                                                  

      FF1 = ZC2 (JC - 1)                                                 

      FF2 = ZC2 (JC)                                                     

      FF3 = ZC2 (JC + 1)                                                 

      C1A = F1 /D1 + F2 /D2 + F3 /D3                                     

      C1B = F1 *P1 + F2 *P2 + F3 *P3                                     

      C1C = F1 *XX2 *XX3 /D1 + F2 *XX3 *XX1 /D2 + F3 *XX1 *XX2 /D3       

      C2A = FF1 /D1 + FF2 /D2 + FF3 /D3                                  

      C2B = FF1 *P1 + FF2 *P2 + FF3 *P3                                  

      C2C = FF1 *XX2 *XX3 /D1 + FF2 *XX3 *XX1 /D2 + FF3 *XX1 *XX2 /D3    

      IF (ILE .EQ. 0 .OR. JC .GT. 2) GO TO 350                           

      B1AO = SQROOT (2.0 *RLE1)                                            

      B2AO = SQROOT (2.0 *RLE2)                                            

      B1C2 = F2 - B1AO *SQROOT (XX2) - F1                                  

      B2C2 = FF2 - B2AO *SQROOT (XX2) - FF1                                

      B1C3 = F3 - B1AO *SQROOT (XX3) - F1                                  

      B2C3 = FF3 - B2AO *SQROOT (XX3) - FF1                                

      B1A1 = (B1C2 *XX3 /XX2 - B1C3 *XX2 /XX3) /(XX3 - XX2)              

      B2A1 = (B2C2 *XX3 /XX2 - B2C3 *XX2 /XX3) /(XX3 - XX2)              

      B1A2 = (B1C2 /XX2 - B1C3 /XX3) /(XX2 - XX3)                        

      B2A2 = (B2C2 /XX2 - B2C3 /XX3) /(XX2 - XX3)                        

      C1VAL = F1 + B1AO *SQROOT (XX) + B1A1 *XX + B1A2 *XX **2             

      C2VAL = FF1 + B2AO *SQROOT (XX) + B2A1 *XX + B2A2 *XX **2            

      GO TO 360                                                          

 350  C1VAL = C1A *XX **2 - C1B *XX + C1C                                

      C2VAL = C2A *XX **2 - C2B *XX + C2C                                

 360  KEGR2 = KEGR + MAX                                                 

      GAMMA (KEGR) = C1VAL                                               

      GAMMA (KEGR2) = C2VAL                                              

 370  CONTINUE                                                           

C...                                                                     

C...                                                                     

C...INDICES KEG AND KEGR DETERMINE LOCATION WITHIN GAMMA OF              
C...CORRESPONDING PROFILE OR BODY GEOMETRY DATA.                         

C...                                                                     

C...ADJUST VALUES OF KEG AND KEGR.                                       

C...                                                                     

 380  KEG = KEG + MAX                                                    

      KEGR = KEG                                                         

 390  CONTINUE                                                           

C...                                                                     

C...END OF PANEL GEOMETRY DEFINITION.                                    

C...                                                                     

C...                                                                     

C...                                                                     

C...READ IN FLOW FIELD SURVEY INFORMATION, IF ANY.                       

C...                                                                     

      WRITE (7,*)      
      WRITE (7,*) 'SURVEY STATIONS'
      WRITE (7,*) 'NXS        NYS       NZS'

      READ  (99,*) NXS, NYS, NZS   
      WRITE (7, 410) NXS, NYS, NZS

  410 FORMAT (3 (I2, 8X))                                 

      IF (NXS .GT. 0) READ (99, 50) (XS (I), I = 1, NXS)                  

      IF (NXS .GT. 0) WRITE (7, 80) (XS (I), I = 1, NXS)                 

      IF (NXS .GT. 0) READ (99, 50) YNOT, DELTAY, ZNOT, DELTAZ            

      IF (NXS .GT. 0) WRITE (7, 80) YNOT, DELTAY, ZNOT, DELTAZ           

      WRITE (7, 420)                                                     

  420 FORMAT ('********* END OF INPUT DECK **********')

C                                                                        

C                                                                        

      RETURN                                                             

      END                                                                

CONTROL*VRLX.MAP                                                9/14/76  

C...                                                                     

      SUBROUTINE MAP (EW, EWX, EWY, ITOTAL)                              

C...                                                                     

C...PURPOSE    TO COMPUTE THE FLOW FIELD ABOUT THE CONFIGURATION.        
C...                                                                     

C...INPUT      CALLING SEQUENCE@                                         
C...           EW = UPWASH INFLUENCE COEFFICIENT MATRIX (RETRIEVED       
C...                ROW BY ROW FROM UNIT 3).                             
C...           EWX = AXIALWASH INFLUENCE COEFFICIENT MATRIX (RETRIEVED   
C...                 ROW BY ROW FROM UNIT 4).                            
C...           EWY = SIDEWASH INFLUENCE COEFFICIENT MATRIX (RETRIEVED    
C...                 ROW BY ROW FROM UNIT 7).                            
C...           ITOTAL = TOTAL NUMBER OF HORSESHOE VORTICES.              

C...           COMMON@                                                   
C...           IH, IQ, NT, XS, NXS, NYS, NZS, PSI, ALFA, MACH, YNOT,     
C...           ZNOT, ALPHA, GAMMA, RNMAX, DELTAY, DELTAZ.                
C...                                                                     
C...OUTPUT     CALLING SEQUENCE@                                         
C...           NONE.                                                     

C...           COMMON@                                                   
C...           NONE.                                                     

C...           DIRECT PRINT@                                             
C...           XS, YK1, ZK1 = FIELD GRID POINT COORDINATES (BODY AXIS    
C...                          SYSTEM).                                   
C...           VX, VF, WF = TOTAL DIMENSIONLESS (REFERENCED TO VELO      
C...                        CITY AT UPSTREAM INFINITY) VELOCITY COMPO-   
C...                        NENTS ALONG THE X-Y-Z AXES RESPECTIVELY      
C...                        (BODY AXIS SYSTEM).                          

C...           EPSLON = UPWASH FLOW ANGLE IN DEGREES.                    

C...           SIGMA = SIDEWASH FLOW ANGLE IN DEGREES.                   

C...           CP = LOCAL PRESSURE COEFFICIENT.                          

C...           RM = LOCAL MACH NUMBER.                                   

C...           PPTOT = (LOCAL STATIC PRESSURE)/(TOTAL PRESSURE).         

C...           PIF = (LOCAL STATIC PRESSURE)/(FREE STREAM STATIC PRES    
C...                 SURE).                                              

C...                                                                     

C...SUBROUTINES                                                          

C...CALLED     NONE.                                                     

C...                                                                     

C...DISCUSSION FLOW FIELD QUANTITIES ARE COMPUTED AT THE NODAL POINTS    
C...           OF A 3-D GRID DEFINED AROUND THE CONFIGURATION BY A SET   
C...           OF ORTHOGONAL PLANES ( X = CONST., Y = CONST., AND        
C...           Z = CONST. PLANES). THE VELOCITIES ARE CALCULATED BY      
C...           THE USE OF INFLUENCE COEFFICIENT MATRICES BASED ON THE    
C...           VORTEX LATTICE REPRESENTATION OF THE CONFIGURATION.       
C...           THESE MATRICES ARE COMPUTED IN SUBROUTINE SURVEY AND      
C...           STORED IN UNITS 3, 4, AND 7 (ONE MATRIX AND ONE UNIT      
C...           PER VELOCITY COMPONET). THE PRESSURE RATIOS AND RELATED   
C...           FLOW QUANTITIES ARE COMPUTED THROUGH THE USE OF ISEN      
C...           TROPIC FLOW RELATIONSHIPS.                                

C...                                                                     

      DIMENSION EW (ITOTAL), EWX (ITOTAL), EWY (ITOTAL)                  

      COMMON LAX, LAY, IQ, IH, LATRAL, PSI, PITCHQ, ROLLQ, YAWQ, HAG,    

     * FLOATX                                                            

      COMMON /SET6 /TITLE (90), HEAD (200), ALOC (12000)                  

      COMMON /SET7 /RNCV (90), RNMAX (1000), ITS (90), JTS (1000)          

      COMMON /SET11 /MACH (16), ALPHA (16), ALFA, VINF, NMACH, NALPHA  

      COMMON /SET14 /NPAN, NT, SMAX , NPANAS                             

      COMMON /SET16 /GAMMA  (12000) , ONSET  (12000)                       
  
      COMMON /SET18 /NXS, NYS, NZS, YNOT, DELTAY, ZNOT, DELTAZ, XS (90)  

      INTEGER TITLE                                                      

      REAL MACH                                                          

C                                                                        

      PI = 3.14159                                                       

      DTR = 0.01745329                                                   

C                                                                        

C                                                                        

      REWIND 3                                                           

      REWIND 4                                                           

      REWIND 7                                                           

      COSA = COS (ALFA)                                                  
      SINA = SIN (ALFA)                                                  

      COPSI = COS (DTR * PSI)                                            
      SIPSI = SIN (DTR * PSI)                                            

C                                                                        

C...LINE IS AN OUTPUT LINE COUNTER USED TO DETERMINE WHEN TO SWITCH      

C...TO A NEW PRINTOUT PAGE.                                              

C                                                                        

      LINE = 1                                                           

      DO 80 I = 1, NXS                                                   

      DO 70 J1 = 1, NZS                                                  

      RJ1 = J1                                                           

C                                                                        

C...COMPUTE COORDINATES IN CROSS-FLOW PLANE, ZK1 AND YK1.                

C                                                                        

      ZK1 = ZNOT + DELTAZ * (RJ1 - 1.)                                   

      DO 70 K1 = 1, NYS                                                  

      RK1 = K1                                                           

      YK1 = YNOT + DELTAY * (RK1 - 1.)                                   

C                                                                        

C...READ IN INDUCED VELOCITY COMPONENT INFLUENCE COEFFICIENTS.           

C                                                                        

      READ (3) EW                                                        

      READ (4) EWX                                                       

      READ (7) EWY                                                       

C                                                                        

C...COMPUTE INDUCED VELOCITY COMPONENTS.                                 

C                                                                        

      IR = 0                                                             

      UF = 0.                                                            

      VF = 0.                                                            

      WF = 0.                                                            

      DO 10 K = 1, NT                                                    

      MAX = RNMAX (K)                                                    

      DO 10 J = 1, MAX                                                   

      IR = IR + 1                                                        

      UF = UF + GAMMA (IR) *EWX (IR)                                     

      VF = VF + GAMMA (IR) *EWY (IR)                                     

      WF = WF + GAMMA (IR) *EW (IR)                                      

 10   CONTINUE                                                           

      VX = COSA *COPSI + UF                                              

      VF = COSA *SIPSI + VF                                              

      WF = SINA + WF                                                     

C                                                                        

C...IF AN INCOMPRESSIBLE CASE IS BEING CONSIDERED (MACH = 0.) THEN       

C...THE FLOW IS MADE SLIGHTLY COMPRESSIBLE (MACH = 0.01) TO ALLOW THE    

C...USE OF COMPRESSIBLE ISENTROPIC FLOW FORMULAS.                        

C                                                                        

      XM = 0.01                                                          

      IF (MACH (IQ) .GT. XM) XM = MACH (IQ)                              

      XM2 = XM **2                                                       

      A2 = (1. + .2 *XM2) /(1.2 *XM2)                                    

      VR2 = VX **2 + VF **2 + WF **2                                     

      VRATIO = VR2 /A2                                                   

      VCAL = VRATIO                                                      

      IF (VRATIO .GT. 5.5) VRATIO = 5.5                                  

C                                                                        

C...THE VELOCITIES INDUCED BY THE VORTEX LATTICE MAY BE TOO HIGH DUE     

C...TO THE NUMERICAL SINGULARITIES INHERENT TO A LATTICE GEOMETRY. CAL   

C...IS A CORRECTION APPLIED TO PREVENT LESS-THAN-VACUUM PRESSURES        

C...DUE TO SUCH SINGULARITIES.                                           

C                                                                        

      CAL = 1.0                                                          

      IF (VCAL .GT. 0.0) CAL = SQROOT (VRATIO /VCAL)                       

      VX = VX *CAL                                                       

      VF = VF *CAL                                                       

      WF = WF *CAL                                                       

      VR2 = VR2 *CAL *CAL                                                

      EPSLON = 1. /DTR *ATAN2 (WF, VX)                                   

      SIGMA = 1. /DTR *ATAN2 (VF, VX)                                    

      RM2 = 2. *VRATIO /(2.4 - .4 *VRATIO)                               

      PPTOT = (1.0 - .4 *VRATIO /2.4 ) **3.5                             

      PIPT = (1.0 - 0.4 /(2.4 *A2)) **3.5                                

      PIF = PPTOT /PIPT                                                  

      CP = ((1.0 + 0.2 *XM2 * (1. - VR2)) **3.5 - 1.) /(.7 * XM2)        

      IF (XM .LE. 0.1) CP = 1. - VR2                                     

      RM = SQROOT (RM2)                                                    

      IF (LINE .EQ. 1) WRITE (7, 20) TITLE                               

 20   FORMAT (20A4) 

      IF (LINE .EQ. 1) WRITE (7, 30) MACH (IQ), ALPHA (IH)               

 30   FORMAT ('MACH =',  F7.3, 6X,'ALPHA =',  F7.3,'DEG.')

      IF (LINE .EQ. 1) LINE = 3                                          

      IF (LINE .EQ. 3) WRITE (7, 40)                                     

 40   FORMAT ('     X         Y         Z         U    ',
     * '     V         W      EPSILON    SIGMA  ',
     * '     CP       MLOC      P/PTOT    P/PINF)')
     
      IF (LINE .EQ. 3) WRITE (7,*)

      IF (LINE .EQ. 3) LINE = 7                                          

      WRITE (7, 60 ) XS (I), YK1, ZK1, VX, VF, WF, EPSLON, SIGMA, CP,    
     * RM, PPTOT, PIF                                                    

 60   FORMAT (6F10.4, F8.2, F10.2, F12.4, 3F10.4)               

      LINE = LINE + 1                                                    

C      IF (LINE .GT. 45) LINE = 1                                         

 70   CONTINUE                                                           

      WRITE (7, *)

      IF (LINE .NE. 1) LINE = LINE + 2                                   

 80   CONTINUE                                                           

      REWIND 3                                                           

      REWIND 4                                                           

      REWIND 7                                                           

      RETURN                                                             

      END                                                                

CONTROL*VRLX.MATRX                                              9/16/76  

C...                                                                     

      SUBROUTINE MATRX (EW, EU, ITOTAL)                                  

C....                                                                    

C...PURPOSE    TO GENERATE THREE AERODYNAMIC INFLUENCE COEFF. MATRI      

C...           CES@ (1) THE NORMALWASH AT THE CONTROL POINTS             

C...           (EW / UNIT 1)? (2) THE AXIALWASH AT THE CONTROL POINTS    

C...           (EU / UNIT 2)? AND (3) THE NORMALWASH AT THE LEAD. EDGE   

C...           (EW / UNIT 9). THESE MATRICES REPRESENT THE INDUCED       

C...           VELOCITY FIELD DUE TO THE HORSESHOE VORTICES OF THE       

C...           LATTICE.                                                  

C...                                                                     

C...INPUT      CALLING SEQUENCE@                                         

C...           ITOTAL = TOTAL NUMBER OF HORSESHOE VORTICES.              

C...           COMMON@                                                   

C...           X, B2, CX, DL, NT, SX, YY, ZZ, HAG, LAX, NPP, PSI, TNT,   

C...           VSP, VST, XTE, ALFA, IPAN, XBAR, ZBAR, CHORD, RFLAG,      

C...           RNMAX, SLOPE, FLOATX, FLOATY, INVERS, LATRAL.             

C...                                                                     

C...OUTPUT     CALLING SEQUENCE@                                         

C...           EW = CONTROL POINT NORMALWASH MATRIX (STORED ROW BY       

C...                ROW IN UNIT 1).                                      

C...           EW = LEADING EDGE NORMALWASH MATRIX (STORED ROW BY        

C...                ROW IN UNIT 9).                                      

C...           EU = AXIALWASH MATRIX (STORED ROW BY ROW IN UNIT 2).      

C...           COMMON@                                                   

C...           NONE.                                                     

C...                                                                     

C...SUBROUTINES                                                          

C...CALLED     WASH, UXVEL.                                              

C...                                                                     

C...DISCUSSION THE ELEMENTS OF THE INFLUENCE COEFFICIENT MATRICES        

C...           ARE GENERATED BY COMPUTING THE CORRESPONDING VELOCITY     

C...           INDUCED AT THE (K1,J1) CONTROL POINT BY THE (K,J)         

C...           HORSESHOE VORTEX OF UNIT STRENGTH. IF K = K1 AND          

C...           J = J1 (SELF-INFLUENCE) THEN THE PRINCIPAL PART OF        

C...           THE DOWNWASH INTEGRAL IS ADDED TO THE COMPUTATION OF      

C...           THE CORRESPONDING EW COEFFICIENT. ALSO IF THE CONTROL     

C...           POINT IS WITHIN A GIVEN NEAR FIELD RADIUS OF THE          

C...           INDUCING HORSESHOE VORTEX, THE AXIALWASH CONTRIBUTION     

C...           IS COMPUTED BY INTERDIGITATED VORTEX SPLITTING.           

C...                                                                     

C...                                                                     

      DIMENSION EW (ITOTAL), EU (ITOTAL)                                 

      COMMON LAX, LAY, IQ, IH, LATRAL, PSI, PITCHQ, ROLLQ, YAWQ, HAG,    

     * FLOATX, FLOATY, INVERS, ISOLV                                     

      COMMON /SET1 /X (12000), Y (1000), Z (1000), ZC (60)                  

      COMMON /SET2 /DCP (12000), SLOPE (12000), VSP (12000)                 

      COMMON /SET3 /CX (12000), SX (12000), RFLAG (12000), IDES (12000)      

      COMMON /SET7 /RNCV (90), RNMAX (1000), ITS (90), JTS (1000)          

      COMMON /SET10 /CHORD (1000), DL (1000), VSS (1000), TNL (1000),        

     * TNT (1000), XTE (1000), IPAN (1000)                                  

      COMMON /SET11 /MACH (16), ALPHA (16), ALFA, VINF, NMACH, NALPHA  

      COMMON /SET14 /NPAN, NT, SMAX , NPANAS                             

      COMMON /SET15 /B2, BETA, CBAR, XBAR, ZBAR                          

      COMMON /SET20 /ZLE1 (90), ZLE2 (90), PHIMED (1000), RCS (1000),      

     * NPP (90), INTRAC (90), YY (12000), ZZ(12000), VST(12000)             

      INTEGER CX, SX , FLAG                                              

C                                                                        

      PI = 3.14159                                                       

      DTR = 0.01745329                                                   

C                                                                        

C                                                                        

      REWIND 1                                                           

      REWIND 2                                                           

      REWIND 9                                                           

      FLAX = LAX                                                         

      FAL = FLOATX *ALFA                                                 

      FBL = FLOATY *PSI * DTR                                            

      MM = 0                                                             

      IF (FAL .NE. 0.0 .OR. FBL .NE. 0.0) MM = 1                         

      SI2A = SIN  (2.0 *ALFA)                                            

      CO2A = COS (2.0 *ALFA)                                             

      HIM = HAG - ZBAR *COS (ALFA) + XBAR *SIN (ALFA)                    

      XIMO = 2.0 *HIM *SIN (ALFA)                                        

      ZIMO = - 2.0 *HIM *COS (ALFA)                                      

      TAN2A = SI2A /CO2A                                                 

C                                                                        

C                                                                        

C...THERE ARE TWO MAJOR DOUBLE DO-LOOPS THAT GENERATE THE COEFFICIENTS   

C...OF THE AERODYNAMIC INFLUENCE MATRICES @ (1) THOSE ENDED BY LABEL     

C...230 AND (2) THOSE ENDED BY LABEL 210. THE FIRST (OUTER) 230-LOOP     

C...DETERMINES THE VORTEX STRIP, AND THE SECOND (INNER) 230-LOOP         

C...LOCATES THE POINT WITHIN THAT STRIP AT WHICH THE INDUCED             

C...VELOCITIES WILL BE COMPUTED. THE FIRST (OUTER) 210-LOOP              

C...ESTABLISHES THE STRIP, AND THE SECOND (INNER) 210-LOOP DETERMINES    

C...THE HORSESHOE VORTEX WITHIN THAT STRIP WHOSE INFLUENCE IS TO BE      

C...COMPUTED. THE 210-LOOPS ARE NESTED WITHIN THE 130-LOOPS.             

C                                                                        

C                                                                        

      IRR = 1                                                            

C                                                                        

C                                                                        

C                                                                        

      DO 230 K1 = 1, NT                                                  

      KEY = IPAN(K1)                                                     

      MAX = RNMAX (K1)                                                   

      COX = 1.0 - FLAX + FLAX *CHORD (K1) /RNMAX (K1)                    

      PION = PI /RNMAX (K1)                                              

      MAXIM = MAX + 1                                                    

C                                                                        

      DO 230 JJ1 = 1, MAXIM                                              

C                                                                        

C...JJ1 = 1 CORRESPONDS TO THE VERY LEADING EDGE. IT IS NOT A CONTROL    

C...POINT IN THE CONVENTIONAL SENSE, BUT THE NORMALWASH INFLUENCE        

C...COEFFICIENT IS NEEDED FOR THE COMPUTATION OF THE LEADING EDGE        

C...SUCTION IN ACCORDANCE WITH LAN"S PROCEDURE.                          

C                                                                        

      J1 = JJ1 - 1                                                       

      RJ1 = J1                                                           

C                                                                        

C...LOCATE SENSING, OR RECEIVING, POINT ON CORRESPONDING CONTROL         

C...SURFACE, EITHER ON ACTUAL BODY SURFACE (NPP = 1) OR ON CYLINDRICAL   

C...SURFACE IN THE PROXIMITY OF BODY (NPP = 0).                          

C                                                                        

      DELTAX = .5 *(COS ((RJ1 - .5) *PION) - COS (RJ1*PION))             

      IF (J1 .EQ. 0) J1 = 1                                              

      IF (LAX .EQ. 1) DELTAX = .5 /RNMAX (K1)                            

      XCNTL = X (IRR) + DELTAX *CHORD (K1)                               

C                                                                        

      IRRB = IRR                                                         

      IF (CX(IRR) .LT. MAX) IRRB = IRR + 1                               

      IRRA = IRRB - 1                                                    

      RATIO = (XCNTL - X (IRRA)) /( X (IRRB) - X (IRRA))                 

      YCNTL = YY (IRRA) *(1.0 - RATIO) + YY (IRRB) *RATIO                

      ZCNTL = ZZ (IRRA) *(1.0 - RATIO) + ZZ (IRRB) *RATIO                

C                                                                        

C...IF NPP = 1 THEN THE SURFACE NORMAL DIRECTION COSINES ARE COMPUTED    

C...EXACTLY? OTHERWISE THE USUAL TRIGONOMETRIC APPROXIMATIONS ARE        

C...APPLIED, E.G., SINE = TANGENT = ARGUMENT.                            

C                                                                        

      COSINE = 1.0                                                       

      SINE = 0.0                                                         

      IF (NPP (KEY)  .EQ. 0)  GO TO 10                                   

      SINE = SLOPE (IRR) /SQROOT (1.0 + SLOPE (IRR) **2)                   

      COSINE = SQROOT (1.0 - SINE **2)                                     

 10   CONTINUE                                                           

C                                                                        

      IF (JJ1 .EQ. 1) GO TO 30                                           

C                                                                        

C...DETERMINE IF TRANSVERSE VORTEX LEG OF HORSESHOE ASSOCIATED TO THE    

C...CONTROL POINT UNDER CONSIDERATION IS SONIC (SWEPT PARALLEL TO MACH   

C...LINE)? IF SO THEN RFLAG = 0.0, OTHERWISE RFLAG = 1.0.                

C                                                                        

      FLAG = 0                                                           

      ESP1 = VSP (IRR)                                                   

      T2 = ESP1 *ESP1                                                    

      IF (B2 .LE. 0.0) GO TO 20                                          

      IF (J1 .EQ. 1) GO TO 20                                            

      IF (J1 .EQ. MAX) GO TO 20                                          

      ESPF = VSP (IRR - 1)                                               

      T2F = ESPF *ESPF                                                   

      ESPA = VSP (IRR + 1)                                               

      T2A = ESPA *ESPA                                                   

      TRANS = (B2 - T2F) * (B2 - T2A)                                    

      IF (TRANS .LT. 0.0) FLAG = 1                                       

 20   RFLAG (IRR) = 1 - FLAG                                             

C                                                                        

C...COMPUTE THE GENERALIZED PRINCIPAL PART OF THE VORTEX-INDUCED         

C...VELOCITY INTEGRAL, WWAVE.                                            

C                                                                        

      WWAVE = 0.0                                                        

      IF (B2 .GT. T2) WWAVE = - 0.5 *SQROOT (B2 - T2) /COX                 

 30   IR = 0                                                             

C                                                                        

C                                                                        

C...COMPUTE HORSESHOE VORTEX INDUCTION WORKING STREAMWISE ALONG A        
C...GIVEN STRIP, STRIP BY STRIP, I.E., THE OUTER 210-LOOP REFERS TO      
C...A CHORDWISE STRIP OF HORSESHOE VORTICES, AND THE INNER 210-LOOP      
C...RELATES TO A PARTICULAR HORSESHOE ON THE STRIP.                      

C                                                                        

C                                                                        

      DO 210 K = 1, NT                                                   

C                                                                        

C...COMPUTE PARAMETERS COMMON TO A GIVEN CHORDWISE STRIP OF HORSESHOE    
C...VORTICES.                                                            

C                                                                        

      PION2 = PI *.5 /RNMAX (K)                                          

      PION3 = 0.5 *PION2                                                 

      PION4 = PION2 /8.0                                                 

      DELX = CHORD (K) /RNMAX (K)                                        

      WEIGHT = 1.0                                                       

      WT1 = 0.25 *DELX                                                   

      CDL = COS (DTR *DL (K))                                            

      SDL = SIN (DTR *DL (K))                                            

      COS1 = COS (DTR *(DL (K1) - DL (K)))                               

      SIN1 = SIN (DTR *(DL (K1) - DL (K)))                               

      COS2 = COS (DTR *(DL (K1) + DL (K)))                               

      SIN2 = SIN (DTR *(DL (K1) + DL (K)))                               

      COSIM = COS (2.0 *DTR *DL (K))                                     

      SINIM = SIN (2.0 *DTR *DL (K))                                     

      MAX2 = RNMAX (K)                                                   

C                                                                        

      AA = FAL *CDL - FBL *SDL                                           

      AM = FBL *CDL + FAL *SDL                                           

C                                                                        

C                                                                        

 40   DO 210  J = 1, MAX2                                                

      IR = IR + 1                                                        

      XLOAD  = X (IR)                                                    

      X1 = XCNTL - XLOAD                                                 

      YP = YCNTL + YY (IR)                                               

      YS = YCNTL - YY (IR)                                               

      ZS = ZCNTL - ZZ (IR)                                               

      Y1 = YS *CDL + ZS *SDL                                             

      Z1 = ZS *CDL - YS *SDL                                             

      Y2 = YP *CDL - ZS *SDL                                             

      Z2 = ZS *CDL + YP *SDL                                             

      RYZ1 = Y1 *Y1 + Z1 *Z1                                             

      RYZ2 = Y2 *Y2 + Z2 *Z2                                             

      X1SQ = X1 *X1                                                      

      RS1 = X1SQ - B2 *RYZ1                                              

      RS2 = X1SQ - B2 *RYZ2                                              

      IF (RS1 .GT. 0.0) RS1 = SQROOT (RS1)                                 

      IF (RS2 .GT. 0.0) RS2 = SQROOT(RS2)                                  

      IF (LAX .EQ. 1) GO TO 50                                           

      RJ = 2 *J - 1                                                      

      RJ1 = 4 *J - 3                                                     

      DELX = 1.0                                                         

      WEIGHT = PION2 *SIN (RJ *PION2) *CHORD (K)                         

      WT1 = PION3 *SIN (RJ1 *PION3) *CHORD (K)                           

 50   XU1 = XLOAD - WT1                                                  

      CT = XTE (K) - XLOAD                                               

      TESP = TNT (K)                                                     

      ESP = VSP (IR)                                                     

      VOSS = VST (IR)                                                    

      TOLZ = WEIGHT *DELX *1.0E-1                                        

C                                                                        

C...IF CONTROL, OR RECEIVING, POINT IS WITHIN A GIVEN NEAR FIELD         

C...RADIUS (RNF) OF SENDING ELEMENT, THEN COMPUTE AXIALWASH (U1) BY      

C...INTERDIGITATED VORTEX SPLITTING.                                     

C                                                                        

      UVEL = 0.0                                                         

      IDIT = 0                                                           

      RNF = 4.0 *WEIGHT *DELX                                            

      IF (SX (IR) .EQ. SX (IRR)) GO TO 90                                

      IF (RS1 .LE. 0.0) GO TO 90                                         

      IF (RS1 .GT. RNF) GO TO 90                                         

      RJM = J - 1                                                        

      COSM = COS (2.0 *PION2 *RJM)                                       

      DO 80 L = 1, 8                                                     

      IF (LAX .EQ. 0) GO TO 60                                           

      RVL = 4 *L - 3                                                     

      XDIF = RVL *DELX /32.0                                             

      WFR = 0.1250                                                       

      GO TO 70                                                           

 60   RVL = 16 *(J - 1) + 2 *L - 1                                       

      XDIF = 0.5 *(COSM - COS (PION4 *RVL)) *CHORD (K)                   

      WFR = PION4 *SIN (PION4 *RVL)                                      

 70   XINT = XCNTL - XU1 - XDIF                                          

      CALL UXVEL (XINT, Y1, Z1, VOSS, ESP, B2, TOLZ, UDV)                

      UVEL = UVEL + UDV *WFR                                             

 80   CONTINUE                                                           

      DCW = 1.0                                                          

      IF (LAX .EQ. 0)  DCW = CHORD (K) /WEIGHT                           

      UVEL = UVEL * DCW                                                  

      IDIT = 1                                                           

C                                                                        

C...SUBROUTINE WASH COMPUTES THE VELOCITIES INDUCED BY A GENERALIZED     

C...HORSESHOE VORTEX OF UNIT INTENSITY.                                  

C                                                                        

 90   CALL WASH (X1,Y1,Z1,VOSS,ESP,B2,U1,V1,W1,AA,AM,TESP,CT,MM)         

      IF (IDIT .EQ. 1) U1 = UVEL                                         

C                                                                        

C...IF CONFIGURATION IS IN GROUND EFFECT (HAG % 0.) THEN COMPUTE THE     

C...VELOCITIES INDUCED BY THE HORSESHOE IMAGE MIRRORED ABOUT THE         

C...GROUND PLANE.                                                        

C                                                                        

      IF (HAG .EQ. 0.0) GO TO 100                                        

      XIM = XIMO + X (IR) *CO2A + ZZ (IR) *SI2A                          

      ZIM = ZIMO + X (IR) *SI2A - ZZ (IR) *CO2A                          

      X1I = XCNTL - XIM                                                  

      ZSI = ZCNTL - ZIM - X1I *TAN2A                                     

      Y1I = YS *CDL - ZSI *SDL                                           

      Z1I = ZSI *CDL + YS *SDL                                           

      CALL WASH (X1I,Y1I,Z1I,VOSS,ESP,B2,U1I,V1I,W1I,AA,AM,TESP,CT,MM)   

      U1 = U1 - U1I                                                      

      V1 = V1 - V1I *COSIM - W1I *SINIM                                  

      W1 = W1 + V1I *SINIM - W1I *COSIM                                  

 100  IF (LATRAL .EQ. 1) GO TO 160                                       

C                                                                        

C...IF CONFIGURATION AND FLIGHT CONDITION ARE SYMMETRICAL THEN           

C...COMPUTE INFLUENCE OF HORSESHOE VORTEX IMAGE MIRRORED ABOUT           

C...CENTER PLANE, I.E., X-Z PLANE.                                       

C                                                                        

      UVEL = 0.0                                                         

      IDIT = 0                                                           

      IF (RS2 .LE. 0.0) GO TO 140                                        

      IF (RS2 .GT. RNF) GO TO 140                                        

      RJM = J - 1                                                        

      COSM = COS (2.0 *PION2 *RJM)                                       

      DO 130 L = 1, 8                                                    

      IF (LAX .EQ. 0) GO TO 110                                          

      RVL = 4 *L - 3                                                     

      XDIF = RVL *DELX /32.0                                             

      WFR = 0.1250                                                       

      GO TO 120                                                          

 110  RVL = 16 *(J - 1) + 2 *L - 1                                       

      XDIF = 0.5 *(COSM - COS (PION4 *RVL)) *CHORD (K)                   

      WFR = PION4 *SIN (PION4 *RVL)                                      

 120  XINT = XCNTL - XU1 - XDIF                                          

      CALL UXVEL (XINT, Y2, Z2, VOSS, -ESP, B2, TOLZ, UDV)               

      UVEL = UVEL + UDV *WFR                                             

 130  CONTINUE                                                           

      DCW = 1.0                                                          

      IF (LAX .EQ. 0) DCW = CHORD (K) /WEIGHT                            

      UVEL = UVEL *DCW                                                   

      IDIT = 1                                                           

C                                                                        

 140  CALL WASH (X1,Y2,Z2,VOSS, - ESP,B2,U2,V2,W2,AA,AM, -TESP,CT,MM)    

      IF (IDIT .EQ. 1) U2 = UVEL                                         

C                                                                        

      IF  (HAG  .EQ. 0.0) GO TO 150                                      

C                                                                        

C...IF CONFIGURATION AND FLIGHT CONDITION ARE SYMMETRICAL, AND           

C...CONFIGURATION IS IN GROUND EFFECT, THEN COMPUTE INFLUENCE OF         

C...DOUBLE-MIRRORED HORSESHOE IMAGE (ONCE ABOUT CENTER PLANE, AND        

C...ANOTHER ABOUT GROUND PLANE).                                         

C                                                                        

      Y2I  = YP *CDL  + ZSI *SDL                                         

      Z2I  = ZSI *CDL  - YP *SDL                                         

      CALL WASH(X1I,Y2I,Z2I,VOSS,- ESP,B2,U2I,V2I,W2I,AA,AM,-TESP,CT,MM) 

      U2 = U2 - U2I                                                      

      V2 = V2 - V2I *COSIM + W2I *SINIM                                  

      W2 = W2 - V2I *SINIM - W2I *COSIM                                  

C                                                                        

 150  EW (IR) = (W1 *COS1 + W2 *COS2 - V1 *SIN1 - V2 *SIN2) *WEIGHT      

      EU (IR) = (U1 + U2) *WEIGHT                                        

      GO TO 170                                                          

C                                                                        

 160  EW (IR) = (W1 *COS1 - V1 *SIN1) *WEIGHT                            

      EU (IR) = U1 *WEIGHT                                               

 170  IF (JJ1 .EQ. 1) GO TO 210                                          

C                                                                        

 180  ENORM = EW (IR) *COSINE + B2 *EU(IR) *SINE                         

      ETAN = EW (IR) *SINE + EU (IR) *COSINE                             

      EW (IR) = ENORM                                                    

      EU (IR) = ETAN                                                     

C                                                                        

      IF  (IR  .NE. IRR) GO TO 190                                       

      EW (IR) = EW (IR) + WWAVE                                          

 190  CONTINUE                                                           

      IF  (FLAG .EQ. 0) GO TO 210                                        

      IF (INVERS .EQ. 1) GO TO 210                                       

C                                                                        

C...IF CONTROL POINT BELONGS TO A SONIC HORSESHOE VORTEX, AND THE        

C...SENDING ELEMENT IS SUCH HORSESHOE, THEN MODIFY THE NORMALWASH        

C...COEFFICIENTS IN SUCH A WAY THAT THE STRENGTH OF THE SONIC VORTEX     

C...WILL BE THE AVERAGE OF THE STRENGTHS OF THE HORSESHOES IMMEDIATELY   

C...IN FRONT OF AND BEHIND IT.                                           

C                                                                        

      RCC = 0.                                                           

      IF (K .NE. K1) GO TO 200                                           

      IF (IABS (J - J1) .GT. 1) GO TO 200                                

      RCC = - 1.0                                                        

      IF (J .EQ. J1) RCC = 2.0                                           

 200  EW (IR) = RCC                                                      

 210  CONTINUE                                                           

C                                                                        

C                                                                        

      IF  (JJ1  .GT. 1) GO TO 220                                        

      WRITE  (9) EW                                                      

      GO TO 230                                                          

 220  WRITE (1) EW                                                       

      WRITE (2) EU                                                       

      IRR = IRR + 1                                                      

 230  CONTINUE                                                           

C                                                                        

C                                                                        

C                                                                        

      REWIND 1                                                           

      REWIND 2                                                           

      REWIND 9                                                           

C                                                                        

C                                                                        

      RETURN                                                             

      END                                                                

CONTROL*VRLX.PRESS                                              9/15/76  

C...                                                                     

      SUBROUTINE PRESS (ITOTAL, EU)                                      

C                                                                        

C                                                                        

C...PURPOSE    TO COMPUTE PRESSURE LOAD COEFFICIENTS (CPLOWER            

C...           CPUPPER), OR SURFACE PRESSURE COEFFICIENTS, FROM THE      

C...           VALUES OF THE INDUCED VELOCITIES AND CIRCULATION          

C...           STRENGTHS.                                                

C...                                                                     

C...INPUT      CALLING SEQUENCE@                                         

C...           ITOTAL = TOTAL NUMBER OF HORSESHOE VORTICES.              

C...           EU = AXIALWASH INFLUENCE COEFFICIENT MATRIX (RETRIEVED    

C...                ROW BY ROW FROM UNIT 2).                             

C...           COMMON@                                                   

C...           B2, CX, DL, SX, JTS, PSI, TNL, TNT, ALFA, YAWQ, CHORD,    

C...           GAMMA, ONSET, RNMAX, SLOPE, WSPAN.                        

C...                                                                     

C...OUTPUT     CALLING SEQUENCE@                                         

C...           NONE.                                                     

C...           COMMON@                                                   

C...           DCP.                                                      

C...                                                                     

C...SUBROUTINES                                                          

C...CALLED     NONE.                                                     

C...                                                                     

C...DISCUSSION THIS SUBROUTINE COMPUTES THE PRESSURE COEFFICIENT ARRAY   

C...           DCP. EACH ELEMENT OF DCP CORRESPONDS TO A GIVEN           

C...           HORSESHOE VORTEX OF THE LATTICE, AND IT IS ASSUMED TO     

C...           ACT AT THE HORSESHOE CENTROID, I.E., THE MI=              

C...           THE TRANSVERSE, OR SKEWED, LEG. AN ELEMENT OF THE DCP     

C...           ARRAY IS EITHER A LOAD COEFFICIENT (IF THE SURFACE        

C...           IS ASSUMED WETTED ON BOTH FACES, I.E., JTS = ITS = 1),    

C...           OR A SURFACE PRESSURE COEFFICIENT (IF THE SURFACE IS      

C...           ASSUMMED WETTED ON ONE SIDE ONLY, I.E., JTS = ITS = 0).   

C...           IN THE COMPUTATION OF LOAD COEFFICIENTS, THE CIRCULA      

C...           TION STRENGTHS, THE FREE STREAM VELOCITY COMPONENTS,      

C...           AND THE ONSET FLOW DUE TO ANY ANGULAR ROTATION OF THE     

C...           CONFIGURATION ARE TAKEN INTO ACCOUNT? THE EFFECT OF       

C...           THE INDUCED AXIALWASH IS IGNORED (SECOND ORDER ERROR).    

C...           IN THE COMPUTATION OF SURFACE PRESSURE COEFFICIENTS,      

C,,,           THE AXIALWASH IS ALSO TAKEN INTO ACCOUNT. IF NPP = 1,     

C...           THE "AXIALWASH" IS NO LONGER A TRUE AXIALWASH (X-AXIS     

C...           VELOCITY COMPONENT), RATHER IT REPRESENTS THE VELOCITY    

C...           COMPONENT TANGENTIAL TO THE SURFACE BUT WITH THE SIDE     

C...           WASH LEFT OUT. SURFACE PRESSURE COEFFICIENTS ARE LIMI     

C...           TED BY THE ISENTROPIC VALUES CORRESPONDING TO STAGNA      

C...           TION AND 70 PERCENT OF VACUUM FOR THE GIVEN FREE-STREAM   

C...           MACH NUMBER.                                              

C...                                                                     

C...                                                                     

C                                                                        

      COMMON LAX, LAY, IQ, IH, LATRAL, PSI, PITCHQ, ROLLQ, YAWQ, HAG,    

     * FLOATX, FLOATY, INVERS                                            

      COMMON /SET2 /DCP (12000), SLOPE (12000), VSP (12000)                 

      COMMON /SET3 /CX (12000), SX (12000), RFLAG (12000), IDES (12000)      

      COMMON /SET7 /RNCV (90), RNMAX (1000), ITS (90), JTS (1000)        

      COMMON /SET10 /CHORD (1000), DL (1000), VSS (1000), TNL (1000),    

     * TNT (1000), XTE (1000), IPAN (1000)                               

      COMMON /SET11 /MACH (16), ALPHA (16), ALFA, VINF, NMACH, NALPHA   

      COMMON /SET13 /BIG, ITER, ITRMAX, EPS , WSPAN, RLM                 

      COMMON /SET15 /B2, BETA, CBAR, XBAR, ZBAR                          

      COMMON /SET16 /GAMMA  (12000) , ONSET  (12000)                       

      INTEGER CX, SX                                                     

C                                                                        

      DIMENSION EU (ITOTAL)                                              

C                                                                        

      REWIND 2                                                           

C                                                                        

      PI = 3.14159                                                       

      DTR = 0.01745329                                                   

C                                                                        

C...COMPUTE ISENTROPIC FLOW PARAMETERS AND CUTOFF VALUES FOR             

C...SURFACE PRESSURE COEFFICIENTS (CPSTAG AND CPVAC).                    

C                                                                        

      CPSTAG = 1.0                                                       

      XM1 = 1.0                                                          

      XM2 = 0.0                                                          

      XM3 = 1.0                                                          

      XM4 = 1.0                                                          

      XM5 = 0.0                                                          

      CPVAC = - 142.86                                                   

      IF (B2 .LT. -.98) GO TO 10                                         

C                                                                        

      CPSTAG = ((1.2 + .2 *B2) **3.5 - 1.) /(.7*(1.+B2))                 

      CPVAC = - 1.0 /(1.0 + B2)                                          

      XM1 = 1.4286 /(1.0 + B2)                                           

      XM2 = 1.0                                                          

      XM3 = 0.2 *(1.0 + B2)                                              

      XM4 = 3.5                                                          

      XM5 = 1.0                                                          

C                                                                        

 10   CONTINUE                                                           

C                                                                        

C                                                                        

C...COMPUTE FREE-STREAM AND ONSET FLOW PARAMETERS.                       

C                                                                        

      YAW = DTR *YAWQ *2.0 /WSPAN                                        

      COSALF = 1.0 /SQROOT (1. + ALFA **2)                                 

      SINPSI = SIN (DTR *PSI)                                            

      COPSI = COS (DTR *PSI)                                             

      FORAXL = COSALF *COPSI                                             

      FORLAT = COSALF *SINPSI *2.0                                       

      FLAX = LAX                                                         

C                                                                        

      DO 90 IR = 1, ITOTAL                                               

      KC = CX (IR)                                                       

      KS = SX (IR)                                                       

      RC = KC                                                            

      RS = RC                                                            

      PION = PI /RNMAX (KS)                                              

      MAX = RNMAX (KS)                                                   

      DCPSID = 0.0                                                       

      IF (PSI .EQ. 0.0) GO TO 40                                         

C                                                                        

C...COMPUTE EFFECT OF SIDESLIP.                                          

C                                                                        

      XIA = 0.5 *(1. - COS ((RC - 1.) *PION)) *(1. - FLAX)               

      XIA = XIA + (RC - 1.0) /RNMAX (KS) *FLAX                           

      XIB = 0.5 * (1. - COS (RC *PION)) *(1. - FLAX)                     

      XIB = XIB + RC /RNMAX (KS) *FLAX                                   

      TANA = TNL (KS) *(1. - XIA) + TNT (KS) *XIA                        

      TANB = TNL (KS) *(1. - XIB) + TNT (KS) *XIB                        

      KTOP = KC - 1                                                      

      GANT = 0.0                                                         

      IF (KTOP .EQ. 0) GO TO 30                                          

      DO 20 KK = 1, KTOP                                                 

      KIR = IR - KC + KK                                                 

      RKK = KK                                                           

      GFX = .5 *PION *SIN ((RKK - .5) *PION) *(1. - FLAX)                

      GFX = GFX + FLAX /CHORD (KS)                                       

      GANT = GANT + GFX *GAMMA (KIR)                                     

 20   CONTINUE                                                           

 30   GLAT = GANT *(TANA - TANB)                                         

      GFX = .5 *PION *SIN ((RC - .5) *PION) *(1. - FLAX)                 

      GFX = GFX + FLAX /CHORD (KS)                                       

      GLAT = GLAT - GFX *GAMMA (IR) *TANB                                

      DCPSID = FORLAT *COS (DTR *DL (KS)) *GLAT /(XIB - XIA)             

 40   FACTOR = FORAXL + ONSET (IR)                                       

C                                                                        

C...COMPUTE LOAD COEFFICIENT.                                            

C                                                                        

      GNET = GAMMA (IR) *FACTOR                                          

      IF (LAX .EQ. 1) GNET = GNET *RNMAX (SX (IR)) /CHORD (SX (IR))      

      DCP (IR) = 2.0 *GNET + DCPSID                                      

C                                                                        

      READ (2) EU                                                        

      IF (JTS (SX (IR)) .EQ. 0) GO TO 90                                 

C                                                                        

C                                                                        

C...COMPUTATION OF SURFACE PRESSURE COEFFICIENT.                         

C                                                                        

C                                                                        

C...COMPUTE TOTAL INDUCED AXIALWASH AT CONTROL POINT RELATED TO          

C...HORSESHOE VORTEX UNDER CONSIDERATION (UB).                           

C                                                                        

      UB = 0.0                                                           

      DO 50 IRR = 1, ITOTAL                                              

      UBF = EU (IRR)                                                     

      UB = UB + UBF *GAMMA (IRR)                                         

 50   CONTINUE                                                           

C                                                                        

      F2 = UB                                                            

C                                                                        

      FS2 = SLOPE (IR)                                                   

C                                                                        

      IF (KC  .EQ. 1) GO TO 80                                           

C                                                                        

C...COMPUTE AXIALWASH AT VORTEX CENTROID (LOAD POINT) BY INTERPOLATING   
C...(EXTRAPOLATING FOR THE FIRST CHORDWISE ELEMENT) BETWEEN CONTROL      
C...POINTS.                                                              

C                                                                        

      IF  (LAX  .EQ. 1) GO TO 60                                         

      XX = .5 *(1.0 - COS ((RC  - 0.5) *PION))                           

      X1 = .5 *(1.0 - COS ((RC - 1.0) *PION))                            

      X2 = .5 *(1.0 - COS (RC *PION))                                    

      GO TO 70                                                           

 60   XX = (RC - 0.75) /RNMAX (KS)                                       

      X1 = (RC - 1.25) /RNMAX (KS)                                       

      X2 = (RC + 0.75) /RNMAX (KS)                                       

 70   UB = (XX - X2) /(X1 - X2) *F1 + (XX - X1)/ (X2 - X1) *F2           

C                                                                        

C...COMPUTE AXIALWASH DUE TO THE DISTRIBUTED VORTICITY WHICH HAS BEEN    

C...CONCENTRATED IN TRANSVERSE LEG OF THE HORSESHOE UNDER CONSIDERA      

C...TION (UG). THIS COMPONENT HAS NOT BEEN INCLUDED IN UB.               

C                                                                        

      UG = 0.25 *FLOAT (JTS (KS)) *DCP (IR)                              

C                                                                        

C...ADD UG TO FREE-STREAM X-VELOCITY COMPONENT, ACCOUNT FOR SURFACE      

C...INCLINATION IN ORDER TO OBTAIN TRUE TANGENTIAL COMPONENT, AND ADD    

C...TO UB TO COMPUTE TOTAL TANGENTIAL VELOCITY (VELOX). THIS IS ONLY     

C...AN APPROXIMATION BECAUSE SIDEWASH CONTRIBUTION IS NOT INCLUDED.      

C                                                                        

      FTAN = (XX - X2) /(X1 - X2) *FS1 + (XX - X1) /(X2 - X1) *FS2       

      FSQ = 1.0 /SQROOT (1.0 + FTAN **2)                                   

      VELOX = UB + (UG + COSALF) *FSQ                                    

C                                                                        

C...COMPUTE SURFACE PRESSURE COEFFICIENT USING ISENTROPIC FLOW           

C...FLOW FORMULAS, AND APPLY ESTABLISHED PHYSICAL LIMITS (CPSTAG AND     

C...CPVAC) TO IT.                                                        

C                                                                        

      RADVEX = XM2 + XM3 *(1.0 - VELOX *VELOX)                           

      DCP (IR) = CPVAC                                                   

      IF (RADVEX .GT. 0.0) DCP (IR) = XM1 *(RADVEX **XM4 - XM5)          

      IF (B2 .LT. -.98) DCP (IR) = RADVEX                                

C                                                                        

      IF (KC .GT. 2) GO TO 80                                            

C                                                                        

C                                                                        

C...CARRY OUT COMPUTATIONS RELATED TO FIRST CHORDWISE ELEMENT.           
C...EXTRAPOLATE USING FIRST AND SECOND CHORDWISE CONTROL POINTS.         

C                                                                        

      XX = .5 * (1.0 - COS (0.5 *PION))                                  

      IF (LAX .EQ. 1) XX = 0.25 /RNMAX (KS)                              

      UB = (XX - X2) /(X1 - X2) *F1 + (XX - X1) /(X2 - X1) *F2           

      FTAN = (XX-X2) /(X1-X2) *FS1 + (XX-X1) /(X2-X1) *FS2               

      UG = 0.25 *FLOAT (JTS (KS)) *DCP (IR - KC + 1)                     

      FSQ = 1.0 /SQROOT (1.0 + FTAN **2)                                   

      VELOX = UB + (UG + COSALF) *FSQ                                    

      RADVEX = XM2 + XM3 *(1.0 - VELOX *VELOX)                           

      DCP (IR - KC + 1) = CPVAC                                          

      IF (RADVEX .GT. 0.) DCP (IR - KC + 1) = XM1 *(RADVEX **XM4 - XM5)  

      IF (B2 .LT. -.98)  DCP (IR - KC + 1) = RADVEX                      

C                                                                        

      IF (DCP (IR - KC + 1) .GT. CPSTAG) DCP (IR - KC + 1) = CPSTAG      

      IF (DCP (IR - KC + 1) .LT. CPVAC ) DCP (IR - KC + 1) = CPVAC       

C                                                                        

C...END OF COMPUTATIONS PARTICULAR TO FIRST CHORDISE ELEMENT ONLY.       

C                                                                        

 80   F1 = F2                                                            

      FS1 = FS2                                                          

      IF (KC .EQ. 1) GO TO 90                                            

      IF (DCP (IR) .GT. CPSTAG) DCP (IR) = CPSTAG                        

      IF (DCP (IR) .LT. CPVAC) DCP (IR) = CPVAC                          

C                                                                        

C                                                                        

C...END OF SURFACE PRESSURE COEFFICIENT COMPUTATION                      

C                                                                        

C                                                                        

 90   CONTINUE                                                           

C                                                                        

      REWIND 2                                                           

      RETURN                                                             

      END                                                                

CONTROL*VRLX.PRINT                                              9/17/76  

C...                                                                     

      SUBROUTINE PRINT (ITOTAL, EW, EWX, EWY)                            

C...                                                                     

C...PURPOSE    TO PRINT PROGRAM DATA.                                    

C                                                                        

C...INPUT      CALLING SEQUENCE@                                         

C...           ITOTAL = TOTAL NUMBER OF HORSESHOE VORTICES.              

C...           EW, EWX, EWY = STORAGE ARRAYS SET ASIDE FOR CALLING       

C...                          SUBROUTINE MAP.                            

C...           COMMON@                                                   

C...           CD, CL, CM, CM, CX, CY, DL, IH, IQ, YY, ZC, ZZ,           

C...           BIG, CDC, CNC, CRM, CYM, DCP, EPS, HAG, JTS, LAX,         

C...           NXS, PDL, PSI, RLM, SPC, CBAR, CMTC, CSUC, HEAD,          

C...           IPAN, ITER, LIFT, MACH, NPAN, NVOR, RNCV, SREF,           

C...           SURF, VINF, XBAR, XSUC, YAWQ, ZBAR, AINC1, AINC2,         

C...           ALPHA, CDTOT, CHORD, CLTOT, CMTOT, CRTOT, CYTOT,          

C...           DNDX1, DNDX2, GAMMA, ISOLV, LESWP, PSPAN, RNMAX,          

C...           ROLLQ, SLOPE, SYNTH, TAPER, TITLE, WSPAN, XAPEX,          

C...           YAPEX, ZAPEX, CSTART, FLOATX, FLOATY, INVERS,             

C...           IQUANT, ITRMAX, LATRAL, MOMENT, PITCHQ.                   

C...                                                                     

C...OUTPUT     CALLING SEQUENCE@                                         

C...           NONE.                                                     

C...           COMMON@                                                   

C...           NONE.                                                     

C...                                                                     

C...SUBROUTINES                                                          

C...CALLED     ZNORM, MAP.                                               

C...                                                                     

C...DISCUSSION THE DATA PRINTED OUT BY THIS SUBROUTINE ARE ARRANGED      

C...           IN THREE GROUPS, AS FOLLOWS@                              

C...           (1) INPUT DATA? THESE ARE DATA WHICH ARE TAKEN FROM       

C...               THE INPUT DECK AND HAVE BEEN CONVERTED IN A FORMAT    

C...               SUITABLE FOR USE BY THE PROGRAM.                      

C...           (2) PANEL AND TOTAL CONFIGURATION FORCE AND MOMENT        

C...               COEFFICIENT DATA.                                     

C...           (3) DATA WHICH ARE RELATED EITHER TO CHORDWISE STRIPS     

C...               OR TO INDIVIDUAL HORSESHOE VORTICES.                  

C...           THESE THREE DATA GROUPS ARE PRINTED SEQUENTIALLY.         

C...           IF A FLOW FIELD SURVEY HAS BEEN REQUESTED, THE CORRES     

C...           PONDING DATA ARE PRINTED OUT THROUGH SUBROUTINE MAP.      

C...                                                                     

C                                                                        

      DIMENSION EW (12000), EWX (6001), EWY (6001), EU (6001)             

      REAL MACH, NVOR, LIFT, MOMENT, LESWP                               

      INTEGER TITLE, CX, SX                                              

      COMMON LAX, LAY, IQ, IH, LATRAL, PSI, PITCHQ, ROLLQ, YAWQ, HAG,    

     *FLOATX, FLOATY, INVERS, ISOLV                                      

      COMMON /SET1 /X (12000), Y (1000), Z (1000), ZC (60)                  

      COMMON /SET2 /DCP (12000), SLOPE (12000), VSP (12000)                 

      COMMON /SET3 /CX (12000), SX (12000), RFLAG (12000), IDES (12000)      

      COMMON /SET4 /DNDX1 (400), DNDX2 (400), AINC1 (90), AINC2 (90)     

      COMMON /SET5 /XAPEX (60), YAPEX (60), ZAPEX (60), PDL (60),        

     * LESWP (60), SYNTH (60), IQUANT (60), CSTART (60), TAPER (60),     

     * PSPAN (60), NVOR (60)                                             

      COMMON /SET6 /TITLE (90), HEAD (200), ALOC (12000)                  

      COMMON /SET7 /RNCV (90), RNMAX (1000), ITS (90), JTS (1000)          

      COMMON /SET8 /LIFT (60), DRAG (60), MOMENT (60), CL (60),          

     * CD (60), CM (60), FN (60), CN (60), FY (60), CY (60),             

     * RM (60), CRM (60), YM (60), CYM (60), XSUC (60), SURF (60)        

      COMMON /SET9 /CDC (1000), CNC (1000)                                 

      COMMON /SET10 /CHORD (1000), DL (1000), VSS (1000), TNL (1000),        

     * TNT (1000), XTE (1000), IPAN (1000)                                  

      COMMON /SET11 /MACH (16), ALPHA (16), ALFA, VINF, NMACH, NALPHA 

      COMMON /SET12 /CLTOT, CDTOT, CMTOT, SREF, CYTOT, CRTOT, CNTOT      

      COMMON /SET13 /BIG, ITER, ITRMAX, EPS , WSPAN, RLM                 

      COMMON /SET14 /NPAN, NT, SMAX , NPANAS                             

      COMMON /SET15 /B2, BETA, CBAR, XBAR, ZBAR                          

      COMMON /SET16 /GAMMA (12000), ONSET (12000)                          

      COMMON /SET17 /CSUC (1000), CMTC (1000), SPC (60)                    

      COMMON /SET18 /NXS, NYS, NZS, YNOT, DELTAY, ZNOT, DELTAZ, XS (90)  

      COMMON /SET19 /SLE1 (90), SLE2 (90), SLE (1000), ZETA (1000)         

      COMMON /SET20 /ZLE1 (90), ZLE2 (90), PHIMED (1000), RCS (1000),      

     * NPP (90), INTRAC (90), YY (12000), ZZ(12000), VST(12000)             

C                                                                        

      PI = 3.14159                                                       

      DTR = 0.01745329                                                   

C                                                                        

C                                                                        

      IF (IQ .EQ. 1 .AND. IH .EQ. 1) GO TO 10                            

      WRITE (7, 350) TITLE                                               

      GO TO 110                                                          

C                                                                        

C...PRINTOUT FIRST DATA GROUP, I.E., INPUT DATA REARRANGED IN A FORMAT   
C...SUITABLE FOR USE BY THE PROGRAM.                                     

C                                                                        

 10   WRITE (7, 20) TITLE                                                

 20   FORMAT (//,20A4,'PANEL GEOMETRY',//)

      WRITE (7, 30)                                                      

 30   FORMAT  (' I  XAPEX(I)  YAPEX(I)  ZAPEX(I)    PDL(I)  ',
     * 'LESWP(I) CSTART(I)  TAPER(I)  PSPAN(I)  NVOR(I)  RNCV(I)',
     * '   SPC(I)')                                             

      DO 50 I = 1, NPAN                                                  
       WRITE (7, 40) I, XAPEX(I), YAPEX(I), ZAPEX(I), PDL(I), LESWP(I), 
     * CSTART(I), TAPER(I), PSPAN(I), NVOR(I), RNCV(I), SPC(I)           

 40   FORMAT (I2, 8F10.4, 2F8.0, F10.2) 

 50   CONTINUE                                                           

      KED1 = 1                                                           

      DO 100 I = 1, NPAN                                                 

      IF (SYNTH (I) .LT. 0.5) WRITE (7, 60) I                            
 60   FORMAT  (/,'INCIDENCE AND CAMBER SLOPE INPUT FOR PANEL ',I4) 

      IF  (SYNTH (I)  .GT. 0.5 ) WRITE  (7, 70 ) I                    
 70   FORMAT  (/,'PRESSURE DISTRIBUTION INPUT FOR PANEL ', I4) 

      MAX = RNCV (I)                                                     

      KED2 = KED1 + MAX - 1                                              

      WRITE (7,*) '    AINC1      AINC2'
      WRITE (7, 80) AINC1 (I), AINC2 (I)                                 

 80   FORMAT (2F10.4) 

      WRITE (7,*) 'DNDX1'
      WRITE (7, 90) (DNDX1 (J), J = KED1, KED2)                          

 90   FORMAT (10F10.4) 

      WRITE (7,*) 'DNDX2'
      WRITE (7, 90) (DNDX2 (J), J = KED1, KED2)                          

      KED1 = KED1 + MAX                                                  

 100  CONTINUE                                                           

C                                                                        

C...PRINTOUT PANEL AND TOTAL CONFIGURATION DATA (SECOND DATA GROUP).     

C                                                                        

      WRITE (7, 350) TITLE                                               

 110  WRITE (7, 120) MACH (IQ), ALPHA (IH), PSI, PITCHQ, ROLLQ, YAWQ     

 120  FORMAT ('MACH =', F7.3 //'ALPHA =', F7.3,' DEG.'/,
     * 'PSI =',F7.3,' DEG.'//'PITCH RATE =', F7.2, 
     * ' DEG/SEC' / 'ROLL RATE  =',F7.2,' DEG/SEC'  / ,
     * 'YAW RATE   =', F7.2, ' DEG/SEC' ///)


      IF (INVERS  .EQ. 0) WRITE (7,130)                                  
      IF (INVERS  .EQ. 1) WRITE (7,140)                                  

 130  FORMAT ('ANALYSIS (DIRECT)  CASE   (INVERS = 0)')        
 140  FORMAT ('DESIGN   (INVERSE) CASE   (INVERS = 1)'///) 

      WRITE (7, 150) XBAR, ZBAR, VINF                                    

 150  FORMAT ('MOMENT AND ROTATION CENTER  @   XBAR = ', E12.5, 
     * 5X, 'ZBAR = ', E12.5, '  ***** VINF = ', E12.5)                

      IF (HAG .EQ. 0.) WRITE (7, 160)                                    

 160  FORMAT ('CONFIGURATION IS OUT OF GROUND EFFECT')

      IF (HAG .GT. 0.) WRITE (7, 170) HAG                                

 170  FORMAT('HEIGHT OF MOMENT REFERENCE CENTER ABOVE GROUND  @ HAG = ',
     *  E10.4)                                                

      WRITE  (7, 180 ) FLOATX, FLOATY                                    

 180  FORMAT ('VORTEX WAKE FLOATATION PARAMETERS @  FLOATX =', F5.2, 5X,
     *         ' FLOATY =',F5.2)
     
      WRITE (7, 190)                                                     

 190  FORMAT (//) 

      WRITE (7, 200)                                                     

 200  FORMAT ('CN REFERENCED TO SURF. CL,CY,CD,CT,CS REFERENCED TO SREF'
     * ' CM REFERENCED TO SREF*CBAR. CRM,CYM REFERENCED TO SREF*WSPAN'/)
     
      WRITE  (7, 210 )                                                   

 210  FORMAT ('   I   ','SURF/SREF',7X,'CN(I)', 7X,'CL(I)',
     * 7X, 'CY(I)', 7X, 'CD(I)', 7X, 'CT(I)', 7X, 'CS(I)', 10X, 
     * 'CM(I)', 7X, 'CRM(I)', 7X, 'CYM(I)') 

 220  FORMAT (I4, E12.4, 6F12.5, 2X, 3E13.4)          

 230  FORMAT ('**', I2, E12.4, 6F12.5, 2X, 3E13.4)    

      I = 1                                                              

      IX = 0                                                             

      ICYCLE = 1                                                         

 240  IX = IX + 1                                                        

      CS = XSUC (IX) *SQROOT (1.0 + (TAN (DTR *LESWP (I))) **2)            

      F1 = SURF (IX) /SREF                                               

      F2 = CN (IX)                                                       

      F3 = CL (IX) *F1                                                   

      F4 = CY (IX) *F1                                                   

      F5 = CD (IX) *F1                                                   

      F6 = XSUC (IX) *F1                                                 

      F7 = CS *F1                                                        

      F8 = CM (IX) *F1 /CBAR                                             

      F9 = CRM (IX) *F1 /WSPAN                                           

      F10 = CYM (IX) *F1 /WSPAN                                          

      IF (ICYCLE - 1) 250, 250, 260                                      

 250  WRITE (7, 220) I, F1, F2, F3, F4, F5, F6, F7, F8, F9, F10          

      GO TO 270                                                          

 260  WRITE (7, 230) I, F1, F2, F3, F4, F5, F6, F7, F8, F9, F10          

 270  IF (ICYCLE .EQ. 2) GO TO 290                                       

      I = I + 1                                                          

      IF (I - NPAN) 240, 240, 280                                        

 280  IF  (LATRAL  .EQ. 0 ) GO TO 300                                    

      ICYCLE = 2                                                         

      I = 0                                                              

 290  I = I + 1                                                          

      IF (I .GT. NPAN) GO TO 300                                         

      IF (IQUANT (I) .EQ. 1) GO TO 290                                   

      GO TO 240                                                          

 300  WRITE (7, 310)                                                     

 310  FORMAT(/,6X, 'SREF', 9X, 'WSPAN', 10X, 'CBAR', 13X, 'CLTOT',9X, 
     * 'CDTOT', 9X,'CYTOT', 5X, 'CMTOT', 9X,'CRMTOT', 8X, 'CYMTOT')

 320  FORMAT (1H , 3E14.5, 3F14.5, 3E14.5 //)                            

      CMTOT = CMTOT /CBAR                                                

      CRTOT = CRTOT /WSPAN                                               

      CNTOT = CNTOT /WSPAN                                               

C    TRANSFORM  WIND AXES TO STABILITY AXES - REV. 4/2004 TT
C       FURTHER REVISED MAY 19,2004 - TT & RJS
C
C    ORIGINAL   SIGN CONVENTION IS NOT A CONVENTIONAL RIGHT-HAND SYSTEM
C        +X OUT TAIL
C        +Y OUT PILOTS RIGHT
C        +Z UP
C      
C    AIRCRAFT CUSTOMARY STABILITY AXIS IS
C        +X OUT NOSE
C        +Y OUT PILOTS RIGHT
C        +Z DOWN
C
C    TO TRANSFORM   COORDINATE SYSTEM TO AIRCRAFT STABILITY AXIS
C      NEED TO INVERT THE SIGN OF CYM AND CRM
C
C  NEW CODE 5/19/04 - TT & RJS
      CRTOT = -1. * CRTOT
      CNTOT = -1. * CNTOT


C
      PSIRAD= PSI / 57.2958
        
      CLSTAB = CLTOT
      CDSTAB = CDTOT
      CYSTAB = CYTOT
      
C     CDSTAB = CDTOT * COS(PSIRAD) - CYTOT*SIN(PSIRAD)
C      CYSTAB = CYTOT * COS(PSIRAD) + CDTOT*SIN(PSIRAD)

      CMSTAB = CMTOT 
C * COS(PSIRAD) - (WSPAN/CBAR)*CRTOT*SIN(PSIRAD)
      CRSTAB = CRTOT
C * COS(PSIRAD) + (CBAR/WSPAN)*CMTOT*SIN(PSIRAD)
      CNSTAB = CNTOT 

C      OUTPUT - MAR 2004, TT
      WRITE (6, 321) MACH(IQ),ALPHA(IH),PSI,PITCHQ,ROLLQ,YAWQ,
     &               HAG,SREF,CBAR,WSPAN,XBAR,ZBAR,
     &               CLSTAB,CDSTAB,CYSTAB,CMSTAB,CRSTAB,CNSTAB
                    
 321  FORMAT ( 6(F8.4,', '), ' ,', 6(F12.4,', '), 6(', ',F12.5))


      WRITE (7, 320) SREF, WSPAN, CBAR, CLTOT, CDTOT, CYTOT, CMTOT, 
     * CRTOT, CNTOT                                                   


      IF (CLTOT .EQ. 0.) GO TO 340                                       

      CDCL = CDTOT /(CLTOT **2)                                          

      E = (SREF *CLTOT **2) /(WSPAN **2 *PI *CDTOT)                      

      WRITE (7, 330) CDCL, E                                             

 330  FORMAT ('   CD/CL**2 =', F7.4, 4X, 'E =', F7.4) 

C                                                                        

C                                                                        

C...PRINTOUT DATA PERTAINING TO THE CHORDWISE LATTICE STRIPS AND         
C...TO THE INDIVIDUAL HORSESHOE VORTICES (AERODYNAMIC LOAD DISTRIBUTION  
C...DATA, THIRD DATA GROUP).                                             

C...                                                                     

C...INDEX LINE IS AN OUTPUT LINE COUNTER TO DETERMINE PAGE SWITCH        
C...CONTROL.                                                             

C...                                                                     

 340  LINE = 1                                                           

      DO 460 I = 1, ITOTAL                                               

      IF (LINE .EQ. 1) WRITE (7, 350) TITLE                              

 350  FORMAT (20A4) 

      IF (LINE .EQ. 1) WRITE (7, 360) MACH (IQ), ALPHA (IH), PSI,        
     * PITCHQ, ROLLQ, YAWQ                                               

 360  FORMAT (' MACH =', F7.3, 4X, 'ALPHA =', F7.3, 'DG', 4X,
     * 'PSI =', F7.3, ' DG', 4X, 'PITCH RATE =', F6.2, 'D/S', 4X, 
     * 'ROLL RATE =',F6.2, 'D/S', 4X, 'YAW RATE =', F6.2, 'D/S')

      IF (LINE .EQ. 1) LINE = 3                                          

      IF (LINE .EQ. 3 .AND. INVERS .EQ. 0) WRITE (7, 420)                

      IF (LINE .EQ. 3 .AND. INVERS .EQ. 1) WRITE (7, 430)                

      IF (LINE .EQ. 3) LINE = 7                                          

      IS = SX (I)                                                        

      IC = CX (I)                                                        

      ILEX  = INVERS *IC                                                 

C                                                                        

C...IF DESIGN PROCESS HAS BEEN INVOKED (INVERS = 1) THEN CALL            
C...SUBROUTINE ZNORM TO GENERATE THE CAMBERLINE THAT CORRESPONDS TO      
C...THE COMPUTED SLOPE DISTRIBUTION.                                     

C                                                                        

      IF (ILEX .EQ. 1) CALL ZNORM (I, IS, RNMAX (IS))                    

      R1V = IC                                                           

      R1 = .5 * (1. - COS ((R1V - .5) *PI /RNMAX (IS)))                  

      IF (LAX .EQ. 1) R1 = (R1V - 0.75) /RNMAX (IS)                      

      R2 = X (I)                                                         

      R3 = YY (I)                                                        

      R4 = ZZ (I)                                                        

      R5 = CHORD (IS)                                                    

      R6 = SLOPE (I)                                                     

      R7 = DCP (I)                                                       

      R8  = CNC  (IS)                                                    

      R9 = R8 /R5                                                        

      R10 = DL (IS)                                                      

      R11 = CMTC (IS) /R5                                                

      R12 = GAMMA (I)                                                    

      IF (INVERS .EQ. 1) R12 = ZC (IC)                                   

      R13 = CSUC  (IS) *R5                                               

      R14 = CDC (IS)                                                     

      IF (IC .NE. 1) GO TO 400                                           

C                                                                        

      IF (IS .EQ. 1) GO TO 370                                           

      IF (IPAN (IS) .EQ. IPAN (IS - 1)) GO TO 390                        

 370  IM1 = (IPAN (IS) - 1) *10 + 1                                      

      IM2 = IM1 + 9                                                      

      WRITE (7, 380) IPAN (IS), (HEAD (JJ), JJ = IM1, IM2)               

      LINE = LINE + 2                                                    

 380  FORMAT (30X, 'PANEL NO.', 2X, I2, 5X, 10A4)   


 390  WRITE (7, 440) IS, IC, R1, R2, R3, R4,R5,R6,JTS(IS),R7, 
     * R8, R9, R10 , R11, R12, R13, R14                                  

      LINE = LINE + 1                                                    

      GO TO 410                                                          

 400  WRITE (7, 450) IS, IC, R1,R2,R3,R4,R5,R6,JTS(IS),R7,R12 

 410  LINE = LINE + 1                                                    

C      IF (LINE .GT. 57) LINE = 1                                         

 420  FORMAT (2X, 'S', 2X, 'C', 2X, 'X/C', 6X, 'X', 10X, 'Y', 
     * 10X, 'Z', 5X,'CHORD',3X,'SLOPE',2X,'ITS', 5X, 'DCP', 6X, 
     * 'CNC', 5X, 'CN', 6X, 'DL', 6X, 'CMT', 8X, 'GAMMA', 6X, 'CTC',
     * 6X, 'CDC'/) 

 430  FORMAT (2X, 'S', 2X, 'C', 2X, 'X/C', 6X, 'X', 6X, 'Y',       
     * 8X, 'Z', 5X,'CHORD',3X,'SLOPE',2X,'ITS', 5X, 'DCP', 6X,
     * 'CNC', 5X, 'CN', 6X, 'DL', 6X, 'CMT', 8X, 'ZC/C', 6X, 'CTC',
     * 6X, 'CDC',/)                                              

 440  FORMAT (2I3, F7.4, 3F10.3, 1X,F8.3,1X, F7.4, I3, 1X, F9.3,  
     * F10.3, 1X, F7.3, F8.2, F10.4, E12.4, 2F9.5 )                    

 450  FORMAT (2I3, F7.4, 3F10.3, 1X,F8.3,1X, F7.4, I3, 1X, F9.3,  
     * 35X, E12.4)                                                      

 460  CONTINUE                                                           

      IF (ISOLV .EQ. 1) GO TO 480                                        

C                                                                        

C...PRINTOUT RELAXATION SOLUTION PARAMETERS.                             

C                                                                        

      WRITE (7, 470) ITRMAX, EPS, ITER, BIG , RLM                        

 470  FORMAT (' ITRMAX =', I3/' EPS =', F10.5/' ITER =',I3/
     & ' BIG =', F10.5/' CONVERGENCE FACTOR =', F10.5)  

C                                                                        

C...IF FLOW FIELD SURVEY HAS BEEN REQUESTED (NXS % 0) THEN CALL          
C...SUBROUTINE MAP TO COMPUTE AND PRINT THE FLOW QUANTITIES AT           
C...THE NODAL POINTS OF THE SURVEY GRID.                                 

C                                                                        

 480  IF  (NXS  .GT. 0) CALL MAP  (EW, EWX, EWY, ITOTAL)                 

 490  WRITE (7, 500)                                                     

 500  FORMAT ('END OF CASE')

      RETURN                                                             

      END                                                                

CONTROL*VRLX.SURVEY                                             9/17/76  

C...                                                                     

      SUBROUTINE SURVEY (EW, EWX, EWY, ITOTAL)                           

C...                                                                     

C...PURPOSE    TO GENERATE THREE AERODYNAMIC INFLUENCE COEFFICIENT       

C...           MATRICES@ (1) THE UPWASH AT THE FLOW FIELD SURVEY         

C...           POINTS (EW / UNIT 3)? (2) THE AXIALWASH AT THE FLOW       

C...           FIELD SURVEY POINTS (EWX / UNIT 4)? AND (3) THE           

C...           SIDEWASH AT THE FLOW FIELD SURVEY POINTS (EWY / UNIT 7).  

C...           THESE MATRICES REPRESENT THE INDUCED VELOCITY FIELD       

C...           DUE TO THE HORSESHOE VORTICES OF THE LATTICE. THIS FLOW   

C...           FIELD IS MEASURED AT THE NODAL POINTS OF A SPECIFIED      

C...           3-D GRID.                                                 

C...                                                                     

C...INPUT      CALLING SEQUENCE@                                         

C...           ITOTAL = TOTAL NUMBER OF HORSESHOE VORTICES.              

C...           COMMON@                                                   

C...           X, B2, CX, DL, NT, SX, XS, YY, ZZ, HAG, LAX, NXS,         

C...           NYS, NZS, PSI, TNT, VSP, VST, XTE, ALFA, YNOT, XBAR,      

C...           ZBAR, ZNOT, CHORD, RNMAX, DELTAY, DELTAZ, FLOATX,         

C...           FLOATY, LATRAL.                                           

C...                                                                     

C...OUTPUT     CALLING SEQUENCE@                                         

C...           EW = UPWASH MATRIX (STORED ROW BY ROW IN UNIT 3)          

C...           EWX = AXIALWASH MATRIX (STORED ROW BY ROW IN UNIT 4)      

C...           EWY = SIDEWASH MATRIX (STORED ROW BY ROW IN UNIT 7)       

C...           COMMON@                                                   

C...           NONE.                                                     

C...                                                                     

C...SUBROUTINES                                                          

C...CALLED     WASH, UXVEL.                                              

C...                                                                     

C...DISCUSSION THE ELEMENTS OF THE INFLUENCE COEFFICIENT MATRICES ARE    

C...           GENERATED BY COMPUTING THE VELOCITY INDUCED AT A FLOW     

C...           FIELD SURVEY POINT BY THE (K, J) HORSESHOE VORTEX OF      

C...           UNIT STRENGTH. IF THE FLOW FIELD SURVEY POINT I=          

C...           WITHIN A GIVEN NEAR FIELD RADIUS OF THE INDUCING          

C...           HORSESHOE VORTEX THEN THE AXIALWASH CONTRIBUTION IS       

C...           COMPUTED BY INTERDIGITATED VORTEX SPLITTING. THE FLOW     

C...           FIELD SURVEY POINTS ARE THE NODAL POINTS OF A 3-D GRID    

C...           DEFINED BY A SET OF THREE ORTHOGONAL PLANES. THESE        

C...           PLANES ARE SPECIFIED BY THE INPUT VALUES OF XS, YNOT,     

C...           DELTAY, ZNOT, AND DELTAZ.                                 

C...                                                                     

C...                                                                     

C...                                                                     

      DIMENSION EW (ITOTAL)                                              

      DIMENSION EWX (ITOTAL)                                             

      DIMENSION EWY (ITOTAL)                                             

      COMMON LAX, LAY, IQ, IH, LATRAL, PSI, PITCHQ, ROLLQ, YAWQ, HAG,    

     * FLOATX, FLOATY                                                    

      COMMON /SET1 /X (12000), Y (1000), Z (1000), ZC (60)                  

      COMMON /SET2 /DCP (12000), SLOPE (12000), VSP (12000)                 

      COMMON /SET3 /CX (12000), SX (12000), RFLAG (12000), IDES (12000)      

      COMMON /SET7 /RNCV (90), RNMAX (1000), ITS (90), JTS (1000)          

      COMMON /SET10 /CHORD (1000), DL (1000), VSS (1000), TNL (1000),        

     * TNT (1000), XTE (1000), IPAN (1000)                                  

      COMMON /SET11 /MACH (16), ALPHA (16), ALFA, VINF, NMACH, NALPHA      

      COMMON /SET14 /NPAN, NT, SMAX , NPANAS                             

      COMMON /SET15 /B2, BETA, CBAR, XBAR, ZBAR                          

      COMMON /SET18 /NXS, NYS, NZS, YNOT, DELTAY, ZNOT, DELTAZ, XS (90)  

      COMMON /SET20 /ZLE1 (90), ZLE2 (90), PHIMED (1000), RCS (1000),      

     * NPP (90), INTRAC (90), YY (12000), ZZ(12000), VST(12000)             

      INTEGER CX, SX                                                     

C                                                                        

      PI = 3.14159                                                       

      DTR = 0.01745329                                                   

C                                                                        

C                                                                        

      REWIND 3                                                           

      REWIND 4                                                           

      REWIND 7                                                           

C                                                                        

C                                                                        

      FLAX = LAX                                                         

C                                                                        

C...COMPUTE GEOMETRIC PARAMETERS RELATED TO WAKE FLOATATION.             

C                                                                        

      FAL = FLOATX *ALFA                                                 

      FBL = FLOATY *PSI * DTR                                            

      MM = 0                                                             

      IF (FAL .NE. 0.0  .OR. FBL .NE. 0.0) MM = 1                        

C                                                                        

C...COMPUTE GEOMETRIC PARAMETERS RELATED TO GROUND EFFECT.               

C                                                                        

      SI2A = SIN (2.0 *ALFA)                                             

      CO2A = COS (2.0 *ALFA)                                             

      HIM = HAG - ZBAR *COS (ALFA) + XBAR *SIN (ALFA)                    

      XIMO = 2.0 *HIM *SIN (ALFA)                                        

      ZIMO = - 2.0 *HIM *COS (ALFA)                                      

      TAN2A = SI2A /CO2A                                                 

C                                                                        

C...THERE ARE TWO MAJOR NESTED DO-LOOP SYSTEMS THAT GENERATE THE         

C...COEFFICIENTS OF THE AERODYNAMIC INFLUENCE MATRICES@ (1) LABEL 150    

C...SYSTEM, AND (2) LABEL 140 SYSTEM. LABEL 140 LOOPS ARE INTERNAL TO    

C...LABEL 150 LOOPS. THE LATTER ARE RELATED TO THE FLOW FIELD SURVEY     

C...GRID POINTS, AND THE FORMER TO THE HORSESHOE VORTEX LATTICE. THE     

C...VORTEX LATTICE IS COVERED STREAMWISE STRIP BY STREAMWISE STRIP.      

C...THE SAME CODE LOGIC USED IN SUBROUTINE MATRIX IS APPLIED HERE.       

C                                                                        

      DO 150 I = 1, NXS                                                  

C                                                                        

C...LOCATE CROSS-FLOW PLANE.                                             

C                                                                        

      XCNTL = XS (I)                                                     

      DO 150 J1 = 1, NZS                                                 

C.                                                                       

C...LOCATE WATERLINE PLANE.                                              

C                                                                        

      RJ1 = J1                                                           

      ZK1 = ZNOT + DELTAZ *(RJ1 - 1.)                                    

      DO 150 K1 = 1, NYS                                                 

C                                                                        

C...COMPUTE GRID POINT BUTT LINE.                                        

C                                                                        

      RK1 = K1                                                           

      YK1 = YNOT + DELTAY *(RK1  - 1.)                                   

C                                                                        

C...COMPUTE HORSESHOE VORTEX INDUCTION WORKING STREAMWISE, STRIP BY      

C...STRIP, I.E., THE OUTER 60-LOOP RELATES TO A CHORDWISE STRIP, AND     

C...THE INNER 60-LOOP RELATES TO A HORSESHOE WITHIN THE STRIP (FROM      

C...LEADING EDGE TO TRAILING EDGE).                                      

C                                                                        

      IR = 0                                                             

      DO 140 K = 1, NT                                                   

C                                                                        

C...COMPUTE PARAMETERS COMMON TO A GIVEN STRIP.                          

C                                                                        

      PION2 = PI *.5 /RNMAX (K)                                          

      PION3 = 0.5 *PION2                                                 

      PION4 = PION2 /8.0                                                 

      DELX = CHORD (K) /RNMAX (K)                                        

      WEIGHT = 1.0                                                       

      WT1 = 0.25 *DELX                                                   

      CDL = COS (DTR* DL (K))                                            

      SDL = SIN (DTR * DL (K))                                           

      COS1 = COS (DTR * DL (K))                                          

      COS2 = COS1                                                        

      SIN1 = SIN (- DTR *DL (K))                                         

      SIN2 = - SIN1                                                      

      COSIM = COS (2.0 *DTR *DL (K))                                     

      SINIM = SIN (2.0 *DTR *DL (K))                                     

      MAX2 = RNMAX (K)                                                   

C                                                                        

      AA = FAL *CDL - FBL *SDL                                           

      AM = FBL *CDL + FAL *SDL                                           

C                                                                        

 10   DO 140 J = 1, MAX2                                                 

      IR = IR + 1                                                        

      XLOAD  = X (IR)                                                    

      X1 = XCNTL - XLOAD                                                 

      YP = YK1 + YY(IR)                                                  

      YS = YK1 - YY (IR)                                                 

      ZS = ZK1 - ZZ (IR)                                                 

      Y1 = YS *CDL + ZS *SDL                                             

      Z1 = ZS *CDL - YS *SDL                                             

      Y2 = YP *CDL - ZS *SDL                                             

      Z2 = ZS *CDL + YP *SDL                                             

      RYZ1 = Y1 *Y1 + Z1 *Z1                                             

      RYZ2 = Y2 *Y2 + Z2 *Z2                                             

      X1SQ = X1 *X1                                                      

      RS1 = X1SQ - B2 *RYZ1                                              

      RS2 = X1SQ - B2 *RYZ2                                              

      IF (RS1 .GT. 0.0) RS1 = SQROOT (RS1)                                 

      IF (RS2 .GT. 0.0) RS2 = SQROOT(RS2)                                  

      IF (LAX .EQ. 1) GO TO 20                                           

      RJ = 2 *J - 1                                                      

      RJ1 = 4 *J - 3                                                     

      DELX = 1.0                                                         

      WEIGHT = PION2 *SIN (RJ *PION2) *CHORD (K)                         

      WT1 = PION3 *SIN (RJ1 *PION3) *CHORD (K)                           

 20   XU1 = XLOAD - WT1                                                  

      CT = XTE (K) - XLOAD                                               

      TESP = TNT (K)                                                     

      ESP = VSP (IR)                                                     

      VOSS = VST (IR)                                                    

      TOLZ = WEIGHT *DELX *1.0E-1                                        

C                                                                        

C...IF FIELD POINT IS WITHIN A GIVEN NEAR FIELD RADIUS (RNF) OF          

C...HORSESHOE THEN COMPUTE AXIALWASH (U1) BY INTERDIGITATED VORTEX       

C...SPLITTING.                                                           

C                                                                        

      UVEL = 0.0                                                         

      IDIT = 0                                                           

      RNF = 4.0 *WEIGHT *DELX                                            

      IF (RS1 .LE. 0.0) GO TO 60                                         

      IF (RS1 .GT. RNF) GO TO 60                                         

      RJM = J - 1                                                        

      COSM = COS (2.0 *PION2 *RJM)                                       

      DO 50 L = 1, 8                                                     

      IF (LAX .EQ. 0) GO TO 30                                           

      RVL = 4 *L - 3                                                     

      XDIF = RVL *DELX /32.0                                             

      WFR = 0.1250                                                       

      GO TO 40                                                           

 30   RVL = 16 *(J - 1) + 2 *L - 1                                       

      XDIF = 0.5 *(COSM - COS (PION4 *RVL)) *CHORD (K)                   

      WFR = PION4 *SIN (PION4 *RVL)                                      

 40   XINT = XCNTL - XU1 - XDIF                                          

      CALL UXVEL (XINT, Y1, Z1, VOSS, ESP, B2, TOLZ, UDV)                

      UVEL = UVEL + UDV *WFR                                             

 50   CONTINUE                                                           

      DCW = 1.0                                                          

      IF (LAX .EQ. 0)  DCW = CHORD (K) /WEIGHT                           

      UVEL = UVEL * DCW                                                  

      IDIT = 1                                                           

C                                                                        

C...SUBROUTINE WASH COMPUTES THE VELOCITY COMPONENTS INDUCED BY A        
C...GENERALIZED HORSESHOE VORTEX OF UNIT STRNGTH.                        

C                                                                        

 60   CALL WASH (X1,Y1,Z1,VOSS,ESP,B2,U1,V1,W1,AA,AM,TESP,CT,MM)         

      IF (IDIT .EQ. 1) U1 = UVEL                                         

C                                                                        

C...IF CONFIGURATION IS IN GROUND EFFECT (HAG . 0.) THEN COMPUTE THE     
C...INDUCTION DUE TO IMAGE OF HORSESHOE MIRRORED ABOUT GROUND PLANE.     

C                                                                        

      IF (HAG .EQ. 0.0) GO TO 70                                         

      XIM = XIMO + X (IR) *CO2A + ZZ (IR) *SI2A                          

      ZIM = ZIMO + X (IR) *SI2A - ZZ (IR) *CO2A                          

      X1I = XCNTL - XIM                                                  

      ZSI = ZK1 - ZIM - X1I *TAN2A                                       

      Y1I = YS *CDL - ZSI *SDL                                           

      Z1I = ZSI *CDL + YS *SDL                                           

      CALL WASH (X1I,Y1I,Z1I,VOSS,ESP,B2,U1I,V1I,W1I,AA,AM,TESP,CT,MM)   

      U1 = U1 - U1I                                                      

      V1 = V1 - V1I *COSIM - W1I *SINIM                                  

      W1 = W1 + V1I *SINIM - W1I *COSIM                                  

 70   IF (LATRAL .EQ. 1) GO TO 130                                       

C                                                                        

C...IF CONFIGURATION AND FLIGHT CONDITION ARE SYMMETRICAL THEN           
C...COMPUTE INFLUENCE OF IMAGE OF HORSESHOE MIRRORED ABOUT PLANE OF      
C...SYMMETRY, I.E., X-Z PLANE.                                           

C                                                                        

C                                                                        

      UVEL = 0.0                                                         

      IDIT = 0                                                           

      IF (RS2 .LE. 0.0) GO TO 110                                        

      IF (RS2 .GT. RNF) GO TO 110                                        

      RJM = J - 1                                                        

      COSM = COS (2.0 *PION2 *RJM)                                       

      DO 100 L = 1, 8                                                    

      IF (LAX .EQ. 0) GO TO 80                                           

      RVL = 4 *L - 3                                                     

      XDIF = RVL *DELX /32.0                                             

      WFR = 0.1250                                                       

      GO TO 90                                                           

 80   RVL = 16 *(J - 1) + 2 *L - 1                                       

      XDIF = 0.5 *(COSM - COS (PION4 *RVL)) *CHORD (K)                   

      WFR = PION4 *SIN (PION4 *RVL)                                      

 90   XINT = XCNTL - XU1 - XDIF                                          

      CALL UXVEL (XINT, Y2, Z2, VOSS, -ESP, B2, TOLZ, UDV)               

      UVEL = UVEL + UDV *WFR                                             

 100  CONTINUE                                                           

      DCW = 1.0                                                          

      IF (LAX .EQ. 0) DCW = CHORD (K) /WEIGHT                            

      UVEL = UVEL *DCW                                                   

      IDIT = 1                                                           

C                                                                        

 110  CALL WASH (X1,Y2,Z2,VOSS, - ESP,B2,U2,V2,W2,AA,AM, -TESP,CT,MM)    

      IF (IDIT .EQ. 1) U2 = UVEL                                         

C                                                                        

C...IF CONFIGURATION AND FLIGHT CONDITION ARE SYMMETRICAL, AND           
C...CONFIGURATION IS IN GROUND EFFECT, THEN COMPUTE INFLUENCE OF         
C...IMAGE OF HORSESHOE MIRRORED ABOUT CENTER PLANE (X-Z PLANE) AND       
C...MIRRORED ONCE MORE ABOUT GROUND PLANE.                               

C                                                                        

      IF (HAG  .EQ. 0.0) GO TO 120                                       

      Y2I = YP *CDL + ZSI *SDL                                           

      Z2I = ZSI *CDL - YP *SDL                                           

      CALL WASH(X1I,Y2I,Z2I,VOSS,-ESP,B2,U2I,V2I,W2I,AA,AM,-TESP,CT,MM)  

      U2 = U2 - U2I                                                      

      V2 = V2 - V2I *COSIM + W2I *SINIM                                  

      W2 = W2 - V2I *SINIM - W2I *COSIM                                  

C                                                                        

 120  EW (IR) = (W1 *COS1 + W2 *COS2 - V1 *SIN1 - V2 *SIN2) *WEIGHT      

      EWY (IR) = (V1 *COS1 + V2 *COS2 - W1 *SIN1 - W2 *SIN2) *WEIGHT     

      EWX (IR) = (U1 + U2) *WEIGHT                                       

      GO TO 140                                                          

C                                                                        

 130  EW (IR) = (W1 *COS1 - V1 *SIN1) *WEIGHT                            

      EWY (IR) = (V1 *COS1 - W2 *SIN2) *WEIGHT                           

      EWX (IR) = U1 *WEIGHT                                              

 140  CONTINUE                                                           

C                                                                        

C                                                                        

      WRITE (3) EW                                                       

      WRITE (4) EWX                                                     

      WRITE (7) EWY                                                      

C                                                                        

C                                                                        

 150  CONTINUE                                                           

C                                                                        

C                                                                        

      REWIND 3                                                           

      REWIND 4                                                           

      REWIND 7                                                           

C                                                                        

C                                                                        

      RETURN                                                             

      END                                                                

CONTROL*VRLX.UXVEL                                              9/14/76  

C...                                                                     

      SUBROUTINE UXVEL (X, Y, Z, S, T, B2, TOLZ, U)                      

C...                                                                     

C...PURPOSE    TO COMPUTE THE AXIALWASH INDUCED BY A SKEWED              

C...           RECTILINEAR VORTEX SEGMENT OF UNIT CIRCULATION.           

C...                                                                     

C...INPUT      CALLING SEQUENCE@                                         

C...           X, Y, Z = ORTHOGONAL CARTESIAN COORDINATES OF             

C...                     RECEIVING POINT MEASURED IN A REFERENCE FRAME   

C...                     CENTERED AT THE MIDPOINT OF VORTEX SEGMENT?     

C...                     THE X-AXIS IS PARALLEL TO THE X-AXIS OF THE     

C...                     MASTER (CONFIGURATION) COORDINATE SYSTEM, THE   

C...                     Y-AXIS IS NORMAL TO THE X-AXIS BUT LIES IN      

C...                     THE PLANE DETERMINED BY THE X-AXIS AND THE      

C...                     VORTEX SEGMENT, AND THE Z-AXIS IS NORMAL TO     

C...                     SUCH PLANE.                                     

C...           S = SEMISPAN OF VORTEX SEGMENT.                           

C...           T = TANGENT OF SWEEP ANGLE OF VORTEX SEGMENT.             

C...           B2 = COMPRESSIBILITY FACTOR (= MACH **2 - 1.0).           

C...           TOLZ = NUMERICAL TOLERANCE CONSTANT.                      

C...           COMMON@                                                   

C...           NONE.                                                     

C...                                                                     

C...OUTPUT     CALLING SEQUENCE@                                         

C...           U = X-AXIS VELOCITY COMPONENT (AXIALWASH) INDUCED BY      

C...               SKEWED VORTEX SEHMENT OF UNIT INTENSITY.              

C...           COMMON@                                                   

C...           NONE.                                                     

C...                                                                     

C...SUBROUTINES                                                          

C...CALLED     NONE.                                                     

C...                                                                     

C...DISCUSSION THIS SUBROUTINE IS CALLED WHEN THE AXIALWASH IS           

C...           COMPUTED IN ACCORDANCE WITH VORTEX SPLITTING SCHEME.      

C...           ONLY THE AXIALWASH IS COMPUTED, AND ONLY THE TRANS        

C...           VERSE SEGMENT OF THE HORSESHOE IS TAKEN INTO ACCOUNT.     

C...           THE SAME COMMENTS PRESENTED IN SUBROUTINE WASH            

C...           REGARDING THE NUMERICAL SINGULARITY IN THE VICINITY       

C...           OF THE CHARACTERISTIC SURFACES (MACH CONES) ARE           

C...           ALSO APPLICABLE HERE. SUBROUTINE UXVEL IS A DIRECT        

C...           COPY OF PARTS OF SUBROUTINE WASH.                         

C...                                                                     

C...                                                                     

C                                                                        

      CUTOFF = 0.80                                                      

      X1 = X + T*S                                                       

      Y1 = Y + S                                                         

      X2 = X - T*S                                                       

      Y2  = Y  - S                                                       

      XTY = X - T *Y                                                     

      U = 0.                                                             

      TOL = TOLZ                                                         

      TOLSQ  = TOL *TOL                                                  

      ZSQ  = Z *Z                                                        

      BZQ  = B2 *ZSQ                                                     

      IF (ABS (BZQ) .LT. TOLSQ) GO TO 90                                 

      YSQ1 = Y1 *Y1                                                      

      YSQ2 = Y2 *Y2                                                      

      RTV1 = YSQ1 + ZSQ                                                  

      RTV2 = YSQ2 + ZSQ                                                  

      RO1 = B2 *RTV1                                                     

      RO2 = B2 *RTV2                                                     

      RAD1 = 0.0                                                         

      RAD2 = 0.0                                                         

      XSQ1 = X1 *X1                                                      

      XSQ2 = X2 *X2                                                      

      IF (B2) 10, 40, 40                                                 

C                                                                        

C                                                                        

C...SUBSONIC FLOW COMPUTATION.                                           

C                                                                        

C                                                                        

 10   CPI = 12.56636                                                     

      ARG = XSQ1 - RO1                                                   
      RAD1 = SQROOT (ARG)                                       
    
      ARG = XSQ2 - RO2                                                   
      RAD2 = SQROOT (ARG)                                                  

      FB1 = 0.0                                                          

      FB2 = 0.0                                                          

      XBSQ = XTY *XTY                                                    

      TBZ = (T *T - B2) *ZSQ                                             

      DENOM = XBSQ + TBZ                                                 

      IF (ABS (DENOM) .LT. TOLSQ) DENOM = TOLSQ                          

      FB1 = (T *X1 - B2 *Y1) /RAD1                                       

 20   FB2 = (T *X2 - B2 *Y2) /RAD2                                       

 30   QB = (FB1 - FB2) /DENOM                                            

      ZETAPI = Z /CPI                                                    

      U = ZETAPI *QB                                                     

      GO TO 90                                                           

C                                                                        

C                                                                        

C...SUPERSONIC FLOW COMPUTATION.                                         

C                                                                        

C                                                                        

 40   CPI = 6.28318                                                      

      IF (X1 .LT. TOL) GO TO 50                                          

      ARG = XSQ1 - RO1                                                   

      IF (ARG .GT. 0.0) RAD1 = SQROOT (ARG)                                

 50   IF (X2 .LT. TOL) GO TO 60                                          

      ARG = XSQ2 - RO2                                                   

      IF (ARG .GT. 0.0) RAD2 = SQROOT (ARG)                                

 60   ZETAPI = Z /CPI                                                    

      FB1 = 0.0                                                          

      FB2 = 0.0                                                          

      XBSQ = XTY *XTY                                                    

      TBZ = (T *T - B2) *ZSQ                                             

      DENOM = XBSQ + TBZ                                                 

      SIGN = 1.0                                                         

      IF (DENOM .LT. 0.0) SIGN = - 1.0                                   

      IF (ABS (DENOM) .LT. TOLSQ) DENOM = SIGN *TOLSQ                    

      IF (X1 .LT. TOL) GO TO 70                                          

      IF (RAD1 .EQ. 0.0) GO TO 70                                        

      REPS = CUTOFF *XSQ1                                                

      FRAD = RAD1                                                        

      IF (RO1 .GT. REPS) GO TO 70                                        

      FB1 = (T *X1 - B2 *Y1) /FRAD                                       

 70   IF (X2 .LT. TOL) GO TO 80                                          

      IF (RAD2 .EQ. 0.0) GO TO 80                                        

      REPS = CUTOFF *XSQ2                                                

      FRAD = RAD2                                                        

      IF (RO2 .GT. REPS) GO TO 80                                        

      FB2 = (T *X2 - B2 *Y2) /FRAD                                       

 80   QB = (FB1 - FB2) /DENOM                                            

      U = ZETAPI *QB                                                     

C                                                                        

C                                                                        

 90   RETURN                                                             

      END                                                                

CONTROL*VRLX.VECTOR                                             9/14/76  

C...                                                                     

      SUBROUTINE VECTOR (ITOTAL, NX1, AV, EW, VOR1, VORK, VORL) 


C ENHANCED TO FORTRAN-90 BY T. TAKAHASHI, 6/26/2002
C   IT STILL USES SCRATCH FILES, THOUGH! SORRY!

C...PURPOSE    TO SOLVE THE LINEAR SYSTEM OF BOUNDARY CONDITION          
C...           EQUATIONS BY PURCELL"S VECTOR ORTHOGONALIZATION           
C...           METHOD.                                                   

C...                                                                     

C...INPUT      CALLING SEQUENCE@                                         

C...           ITOTAL = TOTAL NUMBER OF HORSESHOE VORTICES.              
C...           NX1 = ITOTAL + 1  .                                       
C...           EW = ROW OF NORMALWASH INFLUENCE COEFFICIENT MATRIX.      

C...           COMMON@                                                   
C...           ALOC.                                                     

C...                                                                     

C...OUTPUT     CALLING SEQUENCE@                                         
C...           VOR1 = AUXILIARY COMPUTATIONAL ROW VECTOR.                
C...           VORK = EXTENDED SOLUTION ROW VECTOR.                      
C...           VORL = AUXILIARY COMPUTATIONAL ROW VECTOR.                

C...           COMMON@                                                   
C...           GAMMA.                                                    

C...                                                                     

C...SUBROUTINES                                                          

C...CALLED     NONE.                                                     

C...                                                                     

C...DISCUSSION THE BOUNDARY CONDITION EQUATIONS ARE SOLVED DIRECTLY      
C...           BY A VECTOR ORTHOGONALIZATION PROCEDURE (PURCELL"S        
C...           VECTOR METHOD). SETS OF LINEARLY INDEPENDENT VECTORS      
C...           ARE CONSTRUCTED WHICH ARE SUCCESIVELY ORTHOGONAL TO       
C...           EACH ROW. WHEN ALL ROWS HAVE BEEN CONSIDERED THERE IS     
C...           ONE VECTOR WHICH IS NORMAL (ORTHOGONAL) TO ALL ROWS       
C...           AND CONTAINS THE SOLUTION VECTOR. NO MATRIX INVERSION     
C...           IS INVOLVED AND ONLY ONE ROW OF THE COEFFICIENT MATRIX    
C...           IS REQUIRED AT A TIME, AND ONCE OPERATED ON CAN BE        
C...           OVERWRITTEN. IN ADDITION, TWO AUXILIARY ROW VECTORS       
C...           ARE NEEDED FOR TEMPORARY STORAGE OF INTERMEDIATE VECTOR   
C...           VECTOR DATA.                                              

C...                                                                     

C...                                                                     

      COMMON /SET6 /TITLE (90), HEAD (200), ALOC (12000)                
      COMMON /SET16 /GAMMA  (12000) , ONSET  (12000)                     

C                                                                        

      DIMENSION AV (NX1), VOR1 (NX1), VORK (NX1), VORL (NX1)           
      DIMENSION EW (ITOTAL)                                            

C ***************** SOLUTION BY VECTOR METHOD ***********************    


      REWIND 1                                                         


C...UNITS 11 AND 12 ARE TEMPORARY DATA STORAGE. DATA STORED IN THESE     
C...UNITS ARE NOT USED ANYWHERE ELSE IN THE PROGRAM.                     


      REWIND 11                                                        
      REWIND 12                                                        

C                                                                        
C...ALL VECTORS ARE EXTENDED, I.E., THEY HAVE A DIMENSION EQUAL TO       
C...THE NUMBER OF UNKNOWNS PLUS ONE.                                     
C                                                                        
C     NX1 = ITOTAL + 1                                                   
C                                                                        
C...DEFINE INITIAL SET OF VECTORS WITH "DIAGONAL" ELEMENTS EQUAL TO      
C...UNITY, AND ALL OTHER ELEMENTS ZEROED OUT.                            
C                                                                        

      DO K = 1, NX1  
       DO J = 1, NX1 
        VORK (J) = 0.0                                                 
        IF (J .EQ. K) VORK (J) = 1.0                                   
       END DO
      WRITE (11) VORK                                                  
      END DO

C...COMPUTE SUCCESSIVE SETS OF INTERMEDIATE VECTORS. THE JTH SET         
C...CONTAINS (NX1 - J) VECTORS WHICH ARE NORMAL (ORTHOGONAL) TO THE      
C...FIRST J VECTORS. CONSEQUENTLY THE LAST SET (J = ITOTAL) IS ORTHO     
C...GONAL TO ALL THE VECTORS AND IT CONTAINS THE SOLUTION OF THE         
C...LINEAR SYSTEM (THE FIRST ITOTAL OF THE NX1 ELEMENTS, I.E., ALL       
C...THE ELEMENTS BUT THE LAST ONE ARE THE VALUES OF THE UNKNOWNS).       


      REWIND 11                                  

      IN = 11                                    

      DO JJ = 1, ITOTAL 

       IM = 23 - IN                                                    
 
       READ (1) EW                                                     

       READ (IN) VOR1                            

       DO I = 1, NX1   
        IF (I .LT. NX1) AV (I) = EW (I)          
        IF (I .EQ. NX1) AV (I) = - ALOC (JJ)                           
       END DO

       RDEN = 0.0                                                      

       DO I = 1, NX1    
        RDEN = RDEN + AV (I) *VOR1 (I)                
       END DO

       NTOP = NX1 - JJ                                                 

       DO KK = 1, NTOP    

        READ (IN) VORL                                                 

        RNUM = 0.0                                                     

        DO I = 1, NX1   
         RNUM = RNUM + AV (I) *VORL (I) 
        END DO

        CJK = - RNUM /RDEN                                             

        DO I = 1, NX1                                            
         VORK (I) = CJK *VOR1 (I) + VORL (I)                     
        END DO

        WRITE (IM) VORK   
      
       END DO

      REWIND 11                                                        

      REWIND 12                                                        

      IN = IM                                                          

      END DO


C     VORK  IS  THE  EXTENDED  SOLUTION  ROW  VECTOR                     

C  **************** END OF SOLUTION BY VECTOR METHOD *****************   

 90   DO IR = 1, ITOTAL   
       GAMMA (IR) = VORK (IR)                                          
      END DO

      REWIND 1                                                          

      RETURN                                                            

      END                                                               

CONTROL*VRLX.WASH                                               9/14/76  

C...                                                                     

      SUBROUTINE WASH (X, Y, Z, S, T, B2, U, V, W, AA, AM, TE, CT, MM)  

C...                                                                     

C...PURPOSE    TO COMPUTE THE THREE VELOCITY COMPONENTS INDUCED AT A     
C...           GIVEN POINT BY A GENERALIZED HORSESHOE VORTEX OF UNIT     
C...           STRENGTH.                                                 

C                                                                        

C...INPUT      CALLING SEQUENCE@                                         

C...           X, Y, Z = ORTHOGONAL CARTESIAN COORDINATES OF             
C...                     RECEIVING (FIELD OR CONTROL) POINT MEASURED     
C...                     IN A REFERENCE FRAME CENTERED AT THE MIDPOINT   
C...                     OF THE TRANSVERSE VORTEX SEGMENT (HORSESHOE     
C...                     VORTEX CENTROID)? THE X-AXIS IS PARALLEL TO     
C...                     THE X-AXIS OF THE MASTER (CONFIGURATION)        
C...                     COORDINATE SYSTEM, THE Y-AXIS IS NORMAL TO      
C...                     THE X-AXIS BUT LIES IN THE PLANE DETERMINED     
C...                     BY THE X-AXIS ITSELF AND THE TRANSVERSE LEG     
C...                     OF THE HORSESHOE, AND THE Z-AXIS IS NORMAL      
C...                     TO SUCH PLANE.                                  
C...           S = HORSESHOE VORTEX SEMISPAN.                            
C...           T = TANGENT OF SWEEP ANGLE OF TRANSVERSE LEG, POSITIVE    
C...               FOR SWEEPBACK.                                        
C...           B2 = COMPRESSIBILITY FACTOR (= MACH **2 - 1.0).           
C...           AA, AM = DIRECTION ANGLES (ANGLES OF FLOATATION) OF       
C...                    FREE (WAKE) TRAILING LEGS.                       
C...           TE = TANGENT OF TRAILING EDGE SWEEP ANGLE.                
C...           CT = AVERAGE LENGTH OF BOUND TRAILING LEGS OF HORSESHOE   
C...                (DISTANCE BETWEEN VORTEX CENTROID AND TRAILING       
C...                EDGE MEASURED ALONG X-AXIS).                         
C...           MM = FLOATING WAKE COMPUTATION FLAG.                      
C...           COMMON@                                                   
C...           NONE.                                                     

C...                                                                     

C...OUTPUT     CALLING SEQUENCE@                                         
C...           U, V, W = ORTHOGONAL VELOCITY COMPONENTS INDUCED BY       
C...                     GENERALIZED HORSESHOE VORTEX OF UNIT            
C...                     CIRCULATION INTENSITY.                          
C...                                                                     
C...SUBROUTINES                                                          
C...CALLED     NONE.                                                     
C...                                                                     
C...DISCUSSION THE [GENERALIZED[ HORSESHOE VORTEX ELEMENT CONSISTS OF    
C...           FIVE LEGS OR SEGMENTS, OF WHICH THREE ARE [BOUND[ AND     
C...           TWO ARE [FREE[ OR [FLOATING[. THE BOUND LEGS ARE THE      
C...           SKEWED, OR SWEPT, TRANSVERSE SEGMENT AND THE TWO          
C...           TRAILING, OR CHORDWISE, FILAMENTS EXTENDING FROM THE      
C...           ENDS OF THE TRANSVERSE LEG TO THE TRAILING EDGE. THE      
C...           FLOATING TRAILING LEGS ARE THE SEMI-INFINITE LINES        
C...           WHICH START AT THE TRAILING EDGE AND CONTINUE TO          
C...           DOWNSTREAM INFINITY ACCORDING TO A PRESCRIBED DIRECTION   
C...           DETERMINED BY THE FLOATATION ANGLES AA AND AM. THESE      
C...           FLOATING TRAILING LEGS CONSTITUTE THE CONTINUATION        
C...           IN THE WAKE OF THE BOUND TRAILING SEGMENTS.               
C...           AT SUPERSONIC MACH NUMBERS THE VELOCITY INDUCED BY A      
C...           DISCRETE HORSESHOE VORTEX BECOMES VERY LARGE IN THE       
C...           VICINITY OF THE MACH AFTCONES GENERATED BY THE SKEWED     
C...           LEG OF THE HORSESHOE. AT THE CHARACTERISTIC ENVELOPE      
C...           ITSELF, THE INDUCED VELOCITY VANISHES DUE TO THE FINITE   
C...           PART CONCEPT. THIS SINGULAR BEHAVIOR OCCURS ONLY FOR      
C...           FIELD POINTS OFF THE PLANE OF THE HORSESHOE. TO AVOID     
C...           THIS NUMERICAL SINGULARITY THE CHARACTERISTIC SURFACES    
C...           (MACH CONES) ARE TAKEN TO BE GIVEN BY                     
C...           (X - X1) **2 = B2 *((Y - Y1) **2 + (Z -Z1) **2) /CUTOFF   
C...           WHERE CUTOFF IS A NUMERICAL CONSTANT WHOSE VALUE IS       
C...           LESS THAN, BUT CLOSE TO, 1.0 .                            
C...                                                                     
C...                                                                     
C...                                                                     

      CUTOFF = 0.80                                                     

C                                                                        

C...COMPUTE COORDINATES OF RECEIVING POINT WITH RESPECT TO               

C...END POINTS OF SKEWED LEG.                                            

C                                                                        

      X1 = X + T *S                                                     

      Y1 = Y + S                                                        

      X2 = X - T *S                                                     

      Y2 = Y - S                                                        

C                                                                        

C...CALCULATE AXIAL DISTANCE BETWEEN PROJECTION OF RECEIVING POINT       

C...ONTO HORSESHOE PLANE AND EXTENSION OF SKEWED LEG.                    

C                                                                        

      XTY = X - T *Y                                                     

C                                                                        

C...ZERO-OUT PERTURBATION VELOCITY COMPONENTS.                           

C                                                                        

      U = 0.                                                             

      V = 0.                                                             

      W = 0.                                                             

C                                                                        

C...SET VALUES OF NUMERICAL TOLERANCE CONSTANTS.                         

C                                                                        

      TOL = S /500.0                                                    

      TOLSQ = TOL *TOL                                                  

      TOLSQ2 = 2500.0 *TOLSQ                                            

      ZSQ = Z *Z                                                        

      BZQ = B2 *ZSQ                                                     

      YSQ1 = Y1 *Y1                                                     

      YSQ2 = Y2 *Y2                                                     

      RTV1 = YSQ1 + ZSQ                                                 

      RTV2 = YSQ2 + ZSQ                                                 

      RO1  = B2 *RTV1                                                   

      RO2  = B2 *RTV2                                                   

      RAD1 = 0.0                                                        

      RAD2 = 0.0                                                        

      XSQ1 = X1 *X1                                                     

      XSQ2 = X2 *X2                                                     

      IF (B2) 10, 50, 50                                                

C                                                                       

C                                                                       

C...COMPUTATION FOR SUBSONIC HORSESHOE VORTEX.                          

C                                                                       

C                                                                       

 10   CPI = 12.56636                                                    

      ARG = XSQ1 - RO1                                                  

      RAD1 = SQROOT (ARG)                                                 

      ARG = XSQ2 - RO2                                                  

      RAD2 = SQROOT (ARG)                                                 

      FB1 = 0.0                                                         

      FB2 = 0.0                                                         

      FT1 = 0.0                                                         

      FT2 = 0.0                                                         

      XBSQ = XTY *XTY                                                   

      TBZ = (T *T - B2) *ZSQ                                            

      DENOM = XBSQ + TBZ                                                

      IF (ABS (DENOM) .LT. TOLSQ) DENOM = TOLSQ                         

      FB1 = (T *X1 - B2 *Y1) /RAD1                                      

      RTV = RTV1                                                        

      IF (RTV .LT. TOLSQ) GO TO 20                                      

      FT1 = (X1 + RAD1) /(RAD1 *RTV)                                    

 20   FB2 = (T *X2 - B2 *Y2) /RAD2                                      

      RTV = RTV2                                                        

      IF (RTV .LT. TOLSQ) GO TO 30                                      

      FT2 = (X2 + RAD2) /(RAD2 *RTV)                                    

 30   QB = (FB1 - FB2) /DENOM                                           

      ZETAPI = Z /CPI                                                   

      IF (ZSQ .LT. TOLSQ) GO TO 40                                      

      U = ZETAPI *QB                                                    

      V = ZETAPI * (FT1 - FT2 - QB *T)                                  

 40   W = - (QB *XTY + FT1 *Y1 - FT2 *Y2) /CPI                          

      GO TO 110                                                         

C                                                                       

C                                                                       

C...COMPUTATION FOR SUPERSONIC HORSESHOE VORTEX.                        

C                                                                       

C                                                                       

 50   CPI = 6.28318                                                     

      IF (X1 .LT. TOL) GO TO 60                                         

      ARG = XSQ1 - RO1                                                  

      IF (ARG .GT. 0.0) RAD1 = SQROOT (ARG)                               

 60   IF (X2 .LT. TOL) GO TO 70                                         

      ARG = XSQ2 - RO2                                                  

      IF (ARG .GT. 0.0) RAD2 = SQROOT (ARG)                               

 70   ZETAPI = Z /CPI                                                   

      IF (ZSQ .LT. TOLSQ2) GO TO 100                                    

      FB1 = 0.0                                                         

      FB2 = 0.0                                                         

      FT1 = 0.0                                                         

      FT2 = 0.0                                                         

      XBSQ = XTY *XTY                                                   

      TBZ = (T *T - B2) *ZSQ                                            

      DENOM = XBSQ + TBZ                                                

      SIGN = 1.0                                                        

      IF (DENOM .LT. 0.0) SIGN = - 1.0                                  

      IF (ABS (DENOM) .LT. TOLSQ) DENOM = SIGN *TOLSQ                   

      IF (X1 .LT. TOL) GO TO 80                                         

      IF (RAD1 .EQ. 0.0) GO TO 80                                       

      REPS = CUTOFF *XSQ1                                               

      FRAD = RAD1                                                       

      IF (RO1 .GT. REPS) GO TO 80                                       

      FB1 = (T *X1 - B2 *Y1) /FRAD                                      

      RTV = RTV1                                                        

      IF (RTV .LT. TOLSQ) GO TO 80                                      

      FT1 = X1 /(FRAD *RTV)                                             

 80   IF (X2 .LT. TOL) GO TO 90                                         

      IF (RAD2 .EQ. 0.0) GO TO 90                                       

      REPS = CUTOFF *XSQ2                                               

      FRAD = RAD2                                                       

      IF (RO2 .GT. REPS) GO TO 90                                       

      FB2 = (T *X2 - B2 *Y2) /FRAD                                      

      RTV = RTV2                                                        

      IF (RTV .LT. TOLSQ) GO TO 90                                      

      FT2 = X2 /(FRAD *RTV)                                             

 90   QB = (FB1 - FB2) /DENOM                                           

      U = ZETAPI *QB                                                    

      V = ZETAPI *(FT1 - FT2 - QB *T)                                   

      W = - (QB *XTY + FT1 *Y1 - FT2 *Y2) /CPI                          

      GO TO 110                                                         

C                                                                       

C...COMPUTATION FOR SUPERSONIC HORSESHOE VORTEX WHEN RECEIVING POINT    

C...IS IN THE PLANE OF THE HORSESHOE.                                   

C                                                                       

 100  F1 = 0.                                                           

      F2 = 0.                                                           

      IF (ABS (Y1) .GT. TOL) F1 = RAD1 /Y1                              

      IF (ABS (Y2) .GT. TOL) F2 = RAD2 /Y2                              

      IF (ABS (XTY) .GT. TOL) W = (- F1 + F2) /XTY /CPI                 

 110  IF (MM .EQ. 0) GO TO 200                                          

C                                                                       

C                                                                       

C...IF THE FREE TRAILING LEGS DO NOT CONTINUE TO DOWNSTREAM INFINITY    

C...PARALLEL TO X-AXIS, I.E., WAKE FLOATATION FLAG MM IS NOT ZERO,      

C...THEN THE EFFECT OF WAKE FLOATATION ANGLES IS COMPUTED BY FIRST      

C...SUBTRACTING THE VELOCITY INDUCED BY THE SEMI-INFINITE SEGMENTS      

C...PARALLEL TO THE X-AXIS AND EMANATING FROM THE TRAILING EDGE, AND    

C...LATER ADDING THE INFLUENCE INDUCED BY THE SEMI-INFINITE PAIR        

C...ORIGINATING AT THE SAME POINTS BUT TRAILING TO DOWNSTREAM INFINITY  

C...PARALLEL TO THE DIRECTION DEFINED BY THE FLOATATION ANGLES AA AND   

C...AM.                                                                 

C                                                                       

C                                                                       

      XMP = X - CT                                                      

      X1 = XMP + TE *S                                                  

      X2 = XMP - TE *S                                                  

      ZZ = Z - XMP *AA                                                  

      DELU = 0.0                                                        

      DELV = 0.0                                                        

      DELW = 0.0                                                        

      ZSQ = ZZ *ZZ                                                      

      BZQ = B2 *ZSQ                                                     

      RO1 = B2 *YSQ1 + BZQ                                              

      RO2 = B2 *YSQ2 + BZQ                                              

      RAD1 = 0.0                                                        

      RAD2 = 0.0                                                        

      XSQ1 = X1 *X1                                                     

      XSQ2 = X2 *X2                                                     

      XMY1 = AM *X1 - Y1                                                

      XMY2 = AM *X2 - Y2                                                

      IF (B2) 120, 130, 130                                             

 120  ARG = XSQ1 - RO1                                                  

      RAD1 = SQROOT (ARG)                                                 

      ARG = XSQ2 - RO2                                                  

      RAD2 = SQROOT (ARG)                                                 

      GO TO 150                                                         

 130  IF (X1 .LT. TOL) GO TO 140                                        

      ARG = XSQ1 - RO1                                                  

      IF (ARG .GT. 0.0) RAD1 = SQROOT (ARG)                               

 140  IF (X2 .LT. TOL) GO TO 150                                        

      ARG = XSQ2 - RO2                                                  

      IF (ARG .GT. 0.0) RAD2 = SQROOT (ARG)                               

 150  GG1 = 0.0                                                         

      GG2 = 0.0                                                         

      R1 = SQROOT ((1. - CUTOFF) *XSQ1)                                   

      R2 = SQROOT ((1. - CUTOFF) *XSQ2)                                   

      DR1 = 0.0                                                         

      DR2 = 0.0                                                         

      IF (RAD1 .GT. R1) DR1 = 1.0 /RAD1                                 

      IF (RAD2 .GT. R2) DR2 = 1.0 /RAD2                                 

      BAM = 1.0 - B2 *AM *AM                                            

      BMZ = BAM *ZSQ                                                    

      DG1 = XMY1 *XMY1 + BMZ                                            

      DG2 = XMY2 *XMY2 + BMZ                                            

      GN1 = X1 - B2 *AM *Y1                                             

      GN2 = X2 - B2 *AM *Y2                                             

      IF (ABS (DG1) .LT. TOLSQ) DG1 = TOLSQ                             

      IF (ABS (DG2) .LT. TOLSQ) DG2 = TOLSQ                             

      GINF = 0.0                                                        

      IF (B2 .LT. 0.0) GINF = - SQROOT (BAM)                              

      GG1 = (GN1*DR1 - GINF) /DG1                                       

      GG2 = (GN2 *DR2 - GINF) /DG2                                      

      FZETA1 = 0.0                                                      

      FZETA2 = 0.0                                                      

      ETA1 = 0.0                                                        

      ETA2 = 0.0                                                        

      IF (RTV1 .LT. TOLSQ) GO TO 160                                    

      FZETA1 = ZETAPI /RTV1                                             

      ETA1 = Y1 /CPI /RTV1                                              

 160  IF (RTV2 .LT. TOLSQ) GO TO 170                                    

      FZETA2 = ZETAPI /RTV2                                             

      ETA2 = Y2 /CPI /RTV2                                              

 170  IF (B2 .GE. 0.0) GO TO 180                                        

      DELV = DELV - FZETA1 + FZETA2                                     

      DELW = DELW + ETA1 - ETA2                                         

 180  DELV = DELV - DR1 *X1 *FZETA1 + DR2 *X2 *FZETA2                   

      DELW = DELW + DR1 *X1 *ETA1 - DR2 *X2 *ETA2                       

 190  DELU = DELU + (GG2 - GG1) *AM *ZZ /CPI                            

      DELV = DELV - (GG2 - GG1) *ZZ /CPI                                

      DELW = DELW + (GG1 *XMY1 - GG2 *XMY2) /CPI                        

      U = U + DELU                                                      

      V = V + DELV                                                      

      W = W + DELW                                                      

 200  RETURN                                                            

      END                                                               

CONTROL*VRLX.ZNORM                                              9/14/76 

C...                                                                    

      SUBROUTINE ZNORM (I, IS, RTOP)                                    

C...                                                                    

C...PURPOSE    TO INTEGRATE THE CHORDWISE SLOPE DISTRIBUTION IN ORDER   
C...           TO OBTAIN THE SURFACE CAMBER (OR WARP) ORDINATES.        

C                                                                       

C...INPUT      CALLING SEQUENCE@                                        
C...           I = ELEMENT INDEX (TOTAL COUNT).                         
C...           IS = STRIP INDEX (SPANWISE COUNT).                       
C...           RNMAX = NUMBER OF HORSESHOE VORTICES IN A GIVEN STRIP    
C...                   (CHORDWISE ROW).                                 

C...           COMMON@                                                  
C...           LAX, SLE, SLOPE.                                         

C                                                                       

C...OUTPUT     CALLING SEQUENCE@                                        
C...           NONE.                                                    

C...           COMMON@                                                  
C...           ZC.                                                      

C...                                                                    

C...SUBROUTINES                                                         
C...CALLED     NONE.                                                    

C...                                                                    

C...DISCUSSION THIS SUBROUTINE COMPUTES THE CAMBER NORMAL ORDINATES     
C...           BY TRAPEZOIDAL INTEGRATION OF THE SURFACE SLOPE DIS      
C...           TRIBUTION ALONG THE CHORD. THIS SUBROUTINE IS ONLY       
C...           CALLED (BY SUBROUTINE PRINT) WHEN THE DESIGN PROCESS     
C...           IS INVOKED (INVERS = 1). IN SUCH A CASE, THE LOAD DIS    
C...           TRIBUTION HAS BEEN INPUT, AND THE SURFACE WARP NEEDED    
C...           TO ACHIEVE IT IS THE DESIRED OUTPUT. THE CAMBERLINE IS   
C...           DEFINED AS BEING ZERO AT THE LEADING EDGE AND IS         
C...           EXPRESSED AS DECIMAL FRACTION OF THE LOCAL CHORD         
C...           LENGTH. THE COMPUTED CAMBERLINE REPRESENTS THE TOTAL      
C...           SURFACE WARP, I.E., IT INCLUDES CAMBER AND TWIST.         
C...           SUBROUTINE ZNORM IS CALLED ONCE PER EACH CHORDWISE        
C...           STRIP OR ROW OF HORSESHOE VORTICES.                       

C                                                                        

C                                                                        

C                                                                        

      COMMON LAX                                                        

      COMMON /SET1 /X (12000), Y (1000), Z (1000), ZC (60)                 

      COMMON /SET2 /DCP (12000), SLOPE (12000), VSP (12000)                

      COMMON /SET19 /SLE1 (90), SLE2 (90), SLE (1000), ZETA (1000)        

C                                                                       

C                                                                       

C                                                                       

      FEQL = LAX                                                        

      FCOS = 1.0 - FEQL                                                 

      PION = (3.14159 *FCOS + FEQL) /RTOP                               

      F1 = .75 *FCOS + .8333 *FEQL                                      

      F2 = .25 *FCOS + .1667 *FEQL                                      

C                                                                       

      TSTART = F1 *SLE (IS) + F2 *SLOPE (I)                             

C                                                                       

      DEL1 = .25 *PION                                                  

      DELX = DEL1 * (SIN (DEL1 *FCOS) + FEQL)                           

      ZOR = TSTART *DELX                                                

      DEL = PION *.5                                                    

      LTOP = RTOP                                                       

C                                                                       

      DO 30 L = 1, LTOP                                                 

      IL = I + L - 1                                                    

      RL = L                                                            

      IF (LAX .EQ. 1) GO TO 10                                          

      DELXI = SIN (PION * (RL - 1.0))                                   

      GO TO 20                                                          

 10   DELXI = 2.0                                                       

 20   ZC (L) = ZOR + DEL *DELXI *SLOPE (IL)                             

      ZOR = ZC (L)                                                      

 30   CONTINUE                                                          

C                                                                       

C                                                                       

      RETURN                                                            

      END                                                               
      
      SUBROUTINE CCTOSS

C     INPUT SUBROUTINE COMMENT CARD TOSSER
CLVB  MOD TO REFLECT EDET CCTOSS 6/18/2017
      CHARACTER*80 X

      OPEN(UNIT=99, FILE='VORLAX.SCR', ACTION='WRITE')

 10   READ(8,100,END=20) X
      
      IF (X(1:1).NE.'*') THEN
       WRITE(99,*) X(1:80)
      END IF

      GO TO 10
 20   CLOSE(UNIT=99)
 100  FORMAT(A80)
      RETURN
      END
    
      FUNCTION SQROOT(X)
    
      IF (X.LT.0) THEN
       WRITE(7,*) 'SQRT OF NEGATIVE NUMBER?  SQROOT(',X,')'
       SQROOT=0.
      ELSE
       SQROOT=X**(0.5)
      END IF


      RETURN
      END

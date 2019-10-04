      SUBROUTINE W3FT207(ALOLA,APOLA,INTERP)
C$$$  SUBROUTINE DOCUMENTATION BLOCK  ***
C
C SUBROUTINE: W3FT207   CONVERT (361,91) GRID TO (49,35) N. HEMI. GRID
C   AUTHOR:  JONES,R.E.        ORG:  W342         DATE: 93-10-19
C
C ABSTRACT:  CONVERT A NORTHERN HEMISPHERE 1.0 DEGREE LAT.,LON. 361 BY
C   91 GRID TO A POLAR STEREOGRAPHIC 49 BY 35 GRID. THE POLAR
C   STEREOGRAPHIC MAP PROJECTION IS TRUE AT 60 DEG. N. , THE MESH
C   LENGTH IS 95.25 KM. AND THE ORIENTION IS 150 DEG. W.
C   AWIPS GRID 207  REGIONAL - ALASKA.
C
C PROGRAM HISTORY LOG:
C   93-10-19  R.E.JONES  
C
C USAGE:  CALL W3FT207(ALOLA,APOLA,INTERP)
C
C   INPUT ARGUMENTS:  ALOLA  - 361*91 GRID 1.0 DEG. LAT,LON GRID N. HEMI.
C                              32851 POINT GRID. 360 * 181 ONE DEGREE
C                              GRIB GRID 3 WAS FLIPPED, GREENWISH ADDED
C                              TO RIGHT SIDE AND CUT TO 361 * 91. 
C                     INTERP - 1 LINEAR INTERPOLATION , NE.1 BIQUADRATIC
C
C   INPUT FILES:  NONE
C
C   OUTPUT ARGUMENTS: APOLA - 49*35 GRID OF NORTHERN HEMISPHERE.
C                             1715 POINT GRID IS AWIPS GRID TYPE 207
C
C   OUTPUT FILES: ERROR MESSAGE TO FORTRAN OUTPUT FILE
C
C   WARNINGS:
C
C   1. W1 AND W2 ARE USED TO STORE SETS OF CONSTANTS WHICH ARE
C   REUSABLE FOR REPEATED CALLS TO THE SUBROUTINE.
C
C   2. WIND COMPONENTS ARE NOT ROTATED TO THE 49*35 GRID ORIENTATION
C   AFTER INTERPOLATION. YOU MAY USE W3FC08 TO DO THIS.
C
C   RETURN CONDITIONS: NORMAL SUBROUTINE EXIT
C
C   SUBPROGRAMS CALLED:
C     UNIQUE :  NONE
C
C     LIBRARY:  ASIN , ATAN2
C
C ATTRIBUTES:
C   LANGUAGE: CRAY CFT77 FORTRAN
C   MACHINE:  CRAY C916/128, Y-MP8/864, Y-MP EL92/256
C
C$$$
C
       PARAMETER   (NPTS=1715,II=49,JJ=35)
       PARAMETER   (ORIENT=150.0,IPOLE=25,JPOLE=51)
       PARAMETER   (XMESH=95.250)
C
       REAL        R2(NPTS),      WLON(NPTS)
       REAL        XLAT(NPTS),    XI(II,JJ),   XJ(II,JJ)
       REAL        XII(NPTS),     XJJ(NPTS),   ANGLE(NPTS)
       REAL        ALOLA(361,91), APOLA(NPTS), ERAS(NPTS,4)
       REAL        W1(NPTS),      W2(NPTS)
       REAL        XDELI(NPTS),   XDELJ(NPTS)
       REAL        XI2TM(NPTS),   XJ2TM(NPTS)
C
       INTEGER     IV(NPTS),      JV(NPTS),    JY(NPTS,4)
       INTEGER     IM1(NPTS),     IP1(NPTS),   IP2(NPTS)
C
       LOGICAL     LIN
C
       SAVE
C
       EQUIVALENCE (XI(1,1),XII(1)),(XJ(1,1),XJJ(1))
C
       DATA  DEGPRD/57.2957795/
       DATA  EARTHR/6371.2/
       DATA  INTRPO/99/
       DATA  ISWT  /0/
C
      LIN = .FALSE.
      IF (INTERP.EQ.1) LIN = .TRUE.
C
      IF  (ISWT.EQ.1)  GO TO  900
C
        DEG    = 1.0
        GI2    = (1.86603 * EARTHR) / XMESH
        GI2    = GI2 * GI2
C
C     NEXT 32 LINES OF CODE PUTS SUBROUTINE W3FB05 IN LINE
C
      DO 100 J = 1,JJ
         XJ1 = J - JPOLE
         DO 100 I = 1,II
             XI(I,J) = I - IPOLE
             XJ(I,J) = XJ1
 100     CONTINUE
C
      DO 200 KK = 1,NPTS
        R2(KK)   = XJJ(KK) * XJJ(KK) + XII(KK) * XII(KK)
        XLAT(KK) = DEGPRD *
     &      ASIN((GI2 - R2(KK)) / (GI2 + R2(KK)))
 200  CONTINUE
C
      DO 300 KK = 1,NPTS
        ANGLE(KK) = DEGPRD * ATAN2(XJJ(KK),XII(KK))
 300  CONTINUE
C
      DO 400 KK = 1,NPTS
        IF (ANGLE(KK).LT.0.0) ANGLE(KK) = ANGLE(KK) + 360.0
 400  CONTINUE
C
      DO 500 KK = 1,NPTS
        WLON(KK) = 270.0 + ORIENT - ANGLE(KK)
 500  CONTINUE
C
      DO 600 KK = 1,NPTS
        IF (WLON(KK).LT.0.0)   WLON(KK) = WLON(KK) + 360.0
 600  CONTINUE
C
      DO 700 KK = 1,NPTS
        IF (WLON(KK).GE.360.0) WLON(KK) = WLON(KK) - 360.0
 700  CONTINUE
C
      DO 800 KK = 1,NPTS
        W1(KK)  = (360.0 - WLON(KK)) / DEG + 1.0
        W2(KK)  = XLAT(KK) / DEG + 1.0
 800  CONTINUE
C
      ISWT   = 1
      INTRPO = INTERP
      GO TO 1000
C
C     AFTER THE 1ST CALL TO W3FT207 TEST INTERP, IF IT HAS
C     CHANGED RECOMPUTE SOME CONSTANTS
C
  900 CONTINUE
        IF (INTERP.EQ.INTRPO) GO TO 2100
        INTRPO = INTERP
C
 1000 CONTINUE
        DO 1100 K = 1,NPTS
          IV(K)    = W1(K)
          JV(K)    = W2(K)
          XDELI(K) = W1(K) - IV(K)
          XDELJ(K) = W2(K) - JV(K)
          IP1(K)   = IV(K) + 1
          JY(K,3)  = JV(K) + 1
          JY(K,2)  = JV(K)
 1100   CONTINUE
C
      IF (LIN) GO TO 1400
C
      DO 1200 K = 1,NPTS
        IP2(K)   = IV(K) + 2
        IM1(K)   = IV(K) - 1
        JY(K,1)  = JV(K) - 1
        JY(K,4)  = JV(K) + 2
        XI2TM(K) = XDELI(K) * (XDELI(K) - 1.0) * .25
        XJ2TM(K) = XDELJ(K) * (XDELJ(K) - 1.0) * .25
 1200 CONTINUE
C
      DO 1300 KK = 1,NPTS
         IF (IV(KK).EQ.1) THEN
           IP2(KK) = 3
           IM1(KK) = 360
         ELSE IF (IV(KK).EQ.360) THEN
           IP2(KK) = 2
           IM1(KK) = 359
         ENDIF
 1300 CONTINUE
C
 1400 CONTINUE
C
      IF (LIN) GO TO 1700
C
      DO 1500 KK = 1,NPTS
        IF (JV(KK).LT.2.OR.JV(KK).GT.89) XJ2TM(KK) = 0.0
 1500 CONTINUE
C
      DO 1600 KK = 1,NPTS
        IF (IP2(KK).LT.1)   IP2(KK) = 1
        IF (IM1(KK).LT.1)   IM1(KK) = 1
        IF (IP2(KK).GT.361) IP2(KK) = 361
        IF (IM1(KK).GT.361) IM1(KK) = 361
 1600 CONTINUE
C
 1700 CONTINUE
      DO 1800 KK = 1,NPTS
        IF (IV(KK).LT.1)    IV(KK)  = 1
        IF (IP1(KK).LT.1)   IP1(KK) = 1
        IF (IV(KK).GT.361)  IV(KK)  = 361
        IF (IP1(KK).GT.361) IP1(KK) = 361
 1800 CONTINUE
C
C     LINEAR INTERPOLATION
C
      DO 1900 KK = 1,NPTS
        IF (JY(KK,2).LT.1)  JY(KK,2) = 1
        IF (JY(KK,2).GT.91) JY(KK,2) = 91
        IF (JY(KK,3).LT.1)  JY(KK,3) = 1
        IF (JY(KK,3).GT.91) JY(KK,3) = 91
 1900 CONTINUE
C
      IF (.NOT.LIN) THEN
      DO 2000 KK = 1,NPTS
        IF (JY(KK,1).LT.1)  JY(KK,1) = 1
        IF (JY(KK,1).GT.91) JY(KK,1) = 91
        IF (JY(KK,4).LT.1)  JY(KK,4) = 1
        IF (JY(KK,4).GT.91) JY(KK,4) = 91
 2000 CONTINUE
      ENDIF
C
 2100 CONTINUE
      IF (LIN) THEN
C
C     LINEAR INTERPOLATION
C
      DO 2200 KK = 1,NPTS
        ERAS(KK,2) = (ALOLA(IP1(KK),JY(KK,2))-ALOLA(IV(KK),JY(KK,2)))
     &             * XDELI(KK) + ALOLA(IV(KK),JY(KK,2))
        ERAS(KK,3) = (ALOLA(IP1(KK),JY(KK,3))-ALOLA(IV(KK),JY(KK,3)))
     &             * XDELI(KK) + ALOLA(IV(KK),JY(KK,3))
 2200 CONTINUE
C
      DO 2300 KK = 1,NPTS
        APOLA(KK) = ERAS(KK,2) + (ERAS(KK,3) - ERAS(KK,2))
     &            * XDELJ(KK)
 2300 CONTINUE
C
      ELSE
C
C     QUADRATIC INTERPOLATION
C
      DO 2400 KK = 1,NPTS
        ERAS(KK,1)=(ALOLA(IP1(KK),JY(KK,1))-ALOLA(IV(KK),JY(KK,1)))
     &            * XDELI(KK) + ALOLA(IV(KK),JY(KK,1)) +
     &            ( ALOLA(IM1(KK),JY(KK,1)) - ALOLA(IV(KK),JY(KK,1))
     &            - ALOLA(IP1(KK),JY(KK,1))+ALOLA(IP2(KK),JY(KK,1)))
     &            * XI2TM(KK)
        ERAS(KK,2)=(ALOLA(IP1(KK),JY(KK,2))-ALOLA(IV(KK),JY(KK,2)))
     &            * XDELI(KK) + ALOLA(IV(KK),JY(KK,2)) +
     &            ( ALOLA(IM1(KK),JY(KK,2)) - ALOLA(IV(KK),JY(KK,2))
     &            - ALOLA(IP1(KK),JY(KK,2))+ALOLA(IP2(KK),JY(KK,2)))
     &            * XI2TM(KK)
        ERAS(KK,3)=(ALOLA(IP1(KK),JY(KK,3))-ALOLA(IV(KK),JY(KK,3)))
     &            * XDELI(KK) + ALOLA(IV(KK),JY(KK,3)) +
     &            ( ALOLA(IM1(KK),JY(KK,3)) - ALOLA(IV(KK),JY(KK,3))
     &            - ALOLA(IP1(KK),JY(KK,3))+ALOLA(IP2(KK),JY(KK,3)))
     &            * XI2TM(KK)
        ERAS(KK,4)=(ALOLA(IP1(KK),JY(KK,4))-ALOLA(IV(KK),JY(KK,4)))
     &            * XDELI(KK) + ALOLA(IV(KK),JY(KK,4)) +
     &            ( ALOLA(IM1(KK),JY(KK,4)) - ALOLA(IV(KK),JY(KK,4))
     &            - ALOLA(IP1(KK),JY(KK,4))+ALOLA(IP2(KK),JY(KK,4)))
     &            * XI2TM(KK)
 2400      CONTINUE
C
       DO 2500 KK = 1,NPTS
         APOLA(KK) = ERAS(KK,2) + (ERAS(KK,3) - ERAS(KK,2))
     &             * XDELJ(KK)  + (ERAS(KK,1) - ERAS(KK,2)
     &             - ERAS(KK,3) + ERAS(KK,4)) * XJ2TM(KK)
 2500  CONTINUE
C
      ENDIF
C
      RETURN
      END

!!  Copyright(C) Stichting Deltares, 2012.
!!
!!  This program is free software: you can redistribute it and/or modify
!!  it under the terms of the GNU General Public License version 3,
!!  as published by the Free Software Foundation.
!!
!!  This program is distributed in the hope that it will be useful,
!!  but WITHOUT ANY WARRANTY; without even the implied warranty of
!!  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
!!  GNU General Public License for more details.
!!
!!  You should have received a copy of the GNU General Public License
!!  along with this program. If not, see <http://www.gnu.org/licenses/>.
!!
!!  contact: delft3d.support@deltares.nl
!!  Stichting Deltares
!!  P.O. Box 177
!!  2600 MH Delft, The Netherlands
!!
!!  All indications and logos of, and references to registered trademarks
!!  of Stichting Deltares remain the property of Stichting Deltares. All
!!  rights reserved.

      SUBROUTINE SETGRD ( NOGRID, NOTOT , NOTOTG, GRDREF, SYSGRD,
     +                    PROSYS, GRPATH, IPGRID)
C
C     Deltares     SECTOR WATERRESOURCES AND ENVIRONMENT
C
C     CREATED             : Oct 1998 by Jan van Beek
C
C     FUNCTION            : sets most aggregated grid possible for a process
C                           taken into acount the grid for each substance.
C
C     LOGICAL UNITNUMBERS : -
C
C     SUBROUTINES CALLED  :
C
C     PARAMETERS          :
C
C     NAME    KIND     LENGTH     FUNCT.  DESCRIPTION
C     ----    -----    ------     ------- -----------
C     NOGRID  INTEGER       1     INPUT   Number of grids
C     NOTOT   INTEGER       1     INPUT   Number of substances
C     NOTOTG  INTEGER       1     INPUT   Number of substances for this grid
C     GRDREF  INTEGER    NOGRID   INPUT   Reference grid number
C     SYSGRD  INTEGER    NOTOT    INPUT   Grid number substance
C     PROSYS  INTEGER    NOTOTG   INPUT   Substance numbers for this process
C     GRPATH  INTEGER    NOGRID   LOCAL   Reference path to base grid
C     IPGRID  INTEGER       1     OUTPUT  Grid number set for this process
C
C     Declaration of arguments
C
      use timers       !   performance timers

      INTEGER             NOGRID, NOTOT , NOTOTG, IPGRID
      INTEGER             GRDREF(NOGRID), SYSGRD(NOTOT) ,
     +                    PROSYS(NOTOTG), GRPATH(NOGRID)
C
C     Local declarations
C
      INTEGER             NPATH , IPATH , IGRID
      integer(4) :: ithndl = 0
      if (timon) call timstrt( "setgrd", ithndl )
C
C     Check number of substances for this grid
C
      IF ( NOTOTG .LT. 1 ) THEN
         IPGRID = -1
         goto 9999
      ENDIF
C
C     Get first valid substance
C
      ISYS1 = 0
      DO ISYS = 1 , NOTOTG
         IF ( PROSYS(ISYS) .GT. 0 ) THEN
            ISYS1 = ISYS
            GOTO 5
         ENDIF
      ENDDO
    5 CONTINUE
      IF ( ISYS1 .LT. 1 ) THEN
         IPGRID = -1
         goto 9999
      ENDIF
C
C     Count length of path for first substance
C
      IPGRID = SYSGRD(PROSYS(ISYS1))
      IGRID  = IPGRID
      NPATH  = 1
   10 CONTINUE
      IF ( IGRID .NE. 1 )  THEN
         IGRID  = GRDREF(IGRID)
         IF ( IGRID .LE. 0 ) THEN

C           not defined on reference grid
            IPGRID = -2
            goto 9999

         ENDIF
         NPATH = NPATH + 1
         IF ( NPATH .GT. NOGRID ) THEN
C
C           Base grid not found in reference
C
            IPGRID = -2
            goto 9999
         ENDIF
         GOTO 10
      ENDIF
C
C     Set path for first substance
C
      GRPATH(NPATH) = SYSGRD(PROSYS(ISYS1))
      DO IPATH = NPATH - 1 , 1 , -1
         GRPATH(IPATH) = GRDREF(GRPATH(IPATH+1))
      ENDDO
C
C     For next substances check where the reference comes together
C
      DO IGSYS = ISYS1+1 , NOTOTG
         IF ( PROSYS(IGSYS) .GT. 0 ) THEN
            IGRID = SYSGRD(PROSYS(IGSYS))
            NCHECK = 1
   40       CONTINUE
C
C              Check path previously found
C
               DO IPATH = NPATH , 1 , -1
                  IF ( GRPATH(IPATH) .EQ. IGRID ) THEN
                     IPGRID = IGRID
                     NPATH  = IPATH
                     GOTO 50
                  ENDIF
               ENDDO
               NCHECK = NCHECK + 1
               IF ( NCHECK .GT. NOGRID ) THEN
                  IPGRID = -2
                  goto 9999
               ENDIF
               IGRID = GRDREF(IGRID)
               GOTO 40
   50       CONTINUE
C
         ENDIF
      ENDDO
C
 9999 if (timon) call timstop( ithndl )
      RETURN
      END
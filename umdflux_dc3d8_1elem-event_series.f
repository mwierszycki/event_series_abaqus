      SUBROUTINE UMDFLUX( 
     *     jFlags, amplitude, noel, nElemNodes, iElemNodes, 
     *     mcrd, coordNodes, uNodes, kstep, kinc, time, dt, jlTyp,
     *     temp, npredef, predef, nsvars, svars, sol, dsol,
     *     nIntp, volElm, volInt, 
     *     nHeatEvents, flux, dfluxdT, csiStart, csiEnd)

      include 'aba_param.inc'
      include 'aba_evs_param.inc'

      integer, dimension(2) :: jFlags
      integer, dimension(nElemNodes) :: iElemNodes
      real(kind=8), dimension(mcrd,nElemNodes) :: coordNodes
      real(kind=8), dimension(mcrd,nElemNodes) :: uNodes
      real(kind=8), dimension(nIntp) :: volInt
      real(kind=8), dimension(2) :: time
      real(kind=8), dimension(2) :: dt 
      real(kind=8), dimension(2,nElemNodes) :: temp
      real(kind=8), dimension(2,npredef,nElemNodes) :: predef    
      real(kind=8), dimension(nsvars,2) :: svars
      real(kind=8), dimension(nElemNodes) :: sol
      real(kind=8), dimension(nElemNodes) :: dsol
      real(kind=8), dimension(nHeatEvents) :: flux
      real(kind=8), dimension(nHeatEvents) :: dfluxdT
      real(kind=8), dimension(3,nHeatEvents) :: csiStart
      real(kind=8), dimension(3,nHeatEvents) :: csiEnd
      
      integer, parameter :: numFields = 1 
      integer, parameter :: nFieldSize = 1 
      integer, parameter :: maxSegments = 5 
      character (len=80) :: evsName
      character (len=80) :: cProps(n_evsC_size)

      integer, dimension(n_evsI_size) :: iProps
      real(kind=8), dimension(n_evsR_size) :: rProps

      real(kind=8), dimension(3) :: xCenter
      integer :: maxEvents
      integer :: numSegments
      real(kind=8), dimension (:), allocatable :: evsTime
      real(kind=8), dimension (:,:), allocatable :: evsCoord
      real(kind=8), dimension (:,:), allocatable :: evsField

      real(kind=8), dimension (:,:), allocatable :: evsPathTime
      real(kind=8), dimension (:,:,:), allocatable :: evsPathCoord
      real(kind=8), dimension (:,:,:), allocatable :: evsPathField

C     Query properties of a slice of the event series data
      evsName = 'EVENT_SERIES_1'
      call getEventSeriesSliceProperties(evsName, iProps, rProps,
     1 cProps)

C     Number of events
      maxEvents = iProps(i_evsI_numEvents)

      allocate(evsTime(maxEvents))
      allocate(evsCoord(3,maxEvents))
      allocate(evsField(numFields,maxEvents))

      allocate(evsPathTime(2,maxSegments))
      allocate(evsPathCoord(3,2,maxEvents))
      allocate(evsPathField(nFieldSize,2,maxEvents))

C     Get all events in the slice
      call getEventSeriesSliceLG(evsName, numEvents, evsTime, evsCoord,
     1 evsField)

C     Coordinates of the center point
      xCenter(1) = 0.15
      xCenter(2) = 0.15
      xCenter(3) = 0.0

C     Distance to the center point
      radius = 0.16

C     Get the list of path segments of the slice events that are within the
C     provided distance (radius) to a center point (xCenter)
      call getEventSeriesSliceLGLocationPath(evsName, xCenter, radius,
     1 nFieldSize, numSegments, evsPathTime, evsPathCoord, evsPathField)
      
      print *, '-------------------------'
      print *, 'Time:',time(1)
      print *, 'Nb of events in slice:',numEvents
      print *, 'Events time:',evsTime
      print *, 'Events fields:',evsField
      if ( numSegments > 0 ) then
        print *, 'nb of path segments:',numSegments
        print *, 'Start and end time of event segments:'
        print *, evsPathTime
        print *, 'Coordinates at the start and end of locations of event
     1            segments:'
        print *, evsPathCoord 
        print *, 'Start and end field values of event segments:' 
        print *, evsPathField 
      end if

C     It's UMDFLUX - nHeatEvents, flux, dfluxdT, csiStart, csiEnd have
C     to be defined 
      nHeatEvents=1
      flux(1)=1.0
      dfluxdT(1)=0.0
      csiStart(1,1)=0.0
      csiStart(2,1)=0.0
      csiStart(3,1)=0.0

      csiEnd(1,1)=0.0
      csiEnd(2,1)=0.0
      csiEnd(3,1)=0.0

      deallocate(evsTime)
      deallocate(evsCoord)
      deallocate(evsField)

      return
      END


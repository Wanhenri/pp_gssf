program advance_cymdh

! Compile in linux:
! pgf90 -Mfreeform -o advance_cymdh ~/bin/advance_cymdh.f90 -byteswapio
!

   implicit none

   interface
      integer function iargc()
      end function iargc
   end interface

   integer :: ccyy, mm, dd, hh, dh

   integer :: nargum, i, n, sign

   character(len=80), dimension(2) :: argum

   character(len=10) :: ccyymmddhh

   nargum=iargc()

   if(nargum /= 2) then
      write(unit=*, fmt='(a)') &
           'Usage: advance_cymdh ccyymmddhh dh'
      stop 'try again.'
   endif

   do i=1,nargum
      do n=1,80
         argum(i)(n:n)=' '
      enddo
      call getarg(i,argum(i))
   enddo

   ccyymmddhh = trim(argum(1))

   read(ccyymmddhh(1:10), fmt='(i4, 3i2)')  ccyy, mm, dd, hh

   sign = 1

   dh = 0

   do n=1,len_trim(argum(2))
      if(argum(2)(n:n) == '-') then
         sign = -1
         cycle
      else
         read(argum(2)(n:n), fmt='(i1)') i
         dh=10*dh + i
      end if
   enddo

   dh = sign * dh

!  write(unit=*, fmt='(i4, 4i4)')  ccyy, mm, dd, hh, dh

   hh = hh + dh

   do while (hh < 0) 
      hh = hh + 24
      call change_date ( ccyy, mm, dd, -1 )
   end do

   do while (hh > 23) 
      hh = hh - 24
      call change_date ( ccyy, mm, dd, 1 )
   end do

   write(ccyymmddhh(1:10), fmt='(i4, 3i2.2)')  ccyy, mm, dd, hh
   write(unit=*, fmt='(a)') ccyymmddhh

contains

   subroutine change_date( ccyy, mm, dd, delta )

      implicit none

      integer, intent(inout) :: ccyy, mm, dd
      integer, intent(in)    :: delta

      integer, dimension(12) :: mmday

      mmday = (/31,28,31,30,31,30,31,31,30,31,30,31/)

      mmday(2) = 28

      if (mod(ccyy,4) == 0) then
         mmday(2) = 29

         if ( mod(ccyy,100) == 0) then
            mmday(2) = 28
         endif

         if(mod(ccyy,400) == 0) then
            mmday(2) = 29
         end if
      endif

      dd = dd + delta

      if(dd == 0) then
         mm = mm - 1

         if(mm == 0) then
            mm = 12
            ccyy = ccyy - 1
         endif

         dd = mmday(mm)
      elseif ( dd .gt. mmday(mm) ) then
         dd = 1
         mm = mm + 1
         if(mm > 12 ) then
            mm = 1
            ccyy = ccyy + 1
         end if
      end if
   end subroutine change_date

end program advance_cymdh

#include '../include/inc_field.h'
#include '../include/inc_ts_guess.h'
#include '../include/inc_grid_boundary.h'
#include '../include/inc_grid_size.h'

program main
    implicit none
    double precision:: px, pz
    double precision:: x0, z0, px_inf, pz_inf, L
    double complex:: ts, Mp
    integer:: n_near_core, ierr
    double complex, allocatable:: ts_guess(:)
    double complex, external:: spe
    integer:: n_ts, i
    integer, parameter:: tag = 0
    double precision:: err_spe

    px = 0.4d0; pz = 1d0

    print*, 'E0', E0;
    print*, 'OM', OM;
    print*, 'NC', NC;
    print*, 'XI', XI;
    print*, 'PH', PH;

    call pulse_plot()
    call set_p0( px, pz )

    allocate( ts_guess( LMS_MAX_COUNT ) )
    call local_minima_x( LMS_RE_LOWER, LMS_RE_UPPER, LMS_IM_LOWER, &
          LMS_IM_UPPER, SPE, n_ts, ts_guess )

    ! display estimated saddle points
    write(*,'(a,i3,2x,a)'), 'n_ts:', n_ts, repeat(' -', 30)
    do i = 1, n_ts
        write(*,'(a,i3,a,2(f15.8,x))'), 'ets[', i, '] = ', ts_guess(i)
    end do
    write(*,'(a)'), repeat(' -', 37)

    ! start propagation with designated ts
    call propagate_with_single_p0( px, pz, ts_guess(4), ts, Mp, x0, z0, px_inf, pz_inf, L, &
          n_near_core, err_spe, ierr, tag )


    print*, 'p0_x, p0_z', px, pz
    print*, 'ts', ts
    print*, 'Mp', Mp
    print*, "x0, z0", x0, z0
    print*,  px_inf, pz_inf, ierr
    print*, "n_near_core", n_near_core

    deallocate( ts_guess )
end program main

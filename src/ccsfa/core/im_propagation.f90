#include '../include/inc_atom.h'
#include '../include/inc_misc.h'
#ifdef MISC_PLOT
#include '../include/inc_plot_im_integrand.h'
#endif

!#define IM_PROP_PRNT_DATA

#define CRF_STEP_LENGTH 0.1d0


! in this file, saddle_point equation should be defined


module mod_p0
    implicit none;
    double precision:: p0_x;
    double precision:: p0_z;
end module mod_p0


subroutine set_p0( p0_x_, p0_z_ )
    use mod_p0
    
    implicit none
    double precision, intent(in):: p0_x_, p0_z_

    p0_x = p0_x_;
    p0_z = p0_z_;
    
    return;
end subroutine set_p0



double complex function solve_ts_from_p0( ts0 ) result(ts)
    use mod_p0;

    implicit none;

    double complex, intent(in):: ts0;
    double complex, external:: SPE
    double complex:: z0
    double precision:: hs
    integer:: flag
    double complex, external:: find_root
    integer:: ierr

#ifdef IM_PROP_PRNT_DATA
    double complex, external:: im_traj_x, im_traj_z, im_traj_vx, im_traj_vz
#endif

    flag = 0; ! used for further extension

    ts = find_root( ts0, SPE, CRF_STEP_LENGTH, flag, ierr );
    if( ierr > 0 ) then
        print*, 'root not found!'
        return;
    end if

#ifdef IM_PROP_PRNT_DATA
    print*, 'ts:', ts
    print*, 'x(ts):', im_traj_x( ts, ts );
    print*, 'z(ts):', im_traj_z( ts, ts );
    print*, 'vx(ts):', im_traj_vx( ts );
    print*, 'vz(ts):', im_traj_vz( ts );
#endif

end function solve_ts_from_p0




double complex function SPE( t )
    use mod_p0;

    implicit none;
    double complex, intent(in):: t;
    double precision, parameter:: Ip = IONIZATION_IP;
    double complex, external:: pulse_A_x, pulse_A_z;

    
    SPE = ( p0_x + pulse_A_x(t) )**2 + ( p0_z + pulse_A_z(t) )**2 + 2d0 * Ip;

    return;
end function SPE






double complex function action_W_im_num( ts )
    
    implicit none;
    double complex, intent(in):: ts;
    double complex, external:: v2_integrand, cedint;
    double complex:: t0;
    double precision, parameter:: Ip = IONIZATION_IP
    integer:: i
    double complex:: t


    t0 = dcmplx( dreal(ts), 0d0 );
    if ( dimag(ts)+1d-6 <= 0d0 ) stop 'error: Im[t] < 0';

#ifdef IM_PLOT_INTEGRAND
     open(IM_PLOT_FILE_ID, file=IM_PLOT_FILE_NAME)
     do i = 1, IM_PLOT_N_PTS
         t = dcmplx( dreal(ts), ( dimag(ts) + IM_PLOT_OFFSET ) / (IM_PLOT_N_PTS-1) * (i - 1) );
         write(IM_PLOT_FILE_ID, '(3(e15.8,2x))'), dimag(t), v2_integrand( t ) + Ip;
     end do
     close(IM_PLOT_FILE_ID)
#endif ! IM_PLOT_INTEGRAND

    action_W_im_num = cedint( v2_integrand, 1000, ts, t0 );
    action_W_im_num = action_W_im_num + ( t0 - ts ) * Ip
    
    return;
end function action_W_im_num




double complex function action_DDW( ts )
    
    implicit none
    double complex, intent(in):: ts
    double complex:: vzs, vxs, azs, axs
    double complex, external:: pulse_E_z, pulse_E_x, im_traj_vz, im_traj_vx

    vzs = im_traj_vz( ts );
    vxs = im_traj_vx( ts );
    azs = - pulse_E_z( ts );
    axs = - pulse_E_x( ts );
    action_DDW = vzs * azs + vxs * axs;
    
    return;
end function action_DDW


double complex function v2_integrand( t )

    implicit none
    double complex, intent(in):: t
    double complex, external:: im_traj_x, im_traj_z, im_traj_vx, im_traj_vz
    double complex:: vz, vx, v2
    
    vz = im_traj_vz( t );
    vx = im_traj_vx( t );
    v2 = vz * vz + vx * vx;

    v2_integrand = 0.5d0 * v2
    
    return;
end function v2_integrand


















double complex function im_traj_x( t, ts )
    use mod_p0

    implicit none;
    double complex, intent(in):: t, ts
    double complex, external:: alpha_x

    im_traj_x = alpha_x( t ) + p0_x * t - &
          dreal( alpha_x( ts ) + p0_x * ts );

    return;
end function im_traj_x


double complex function im_traj_z( t, ts )
    use mod_p0

    implicit none;
    double complex, intent(in):: t, ts;
    double complex, external:: alpha_z;

    im_traj_z = alpha_z( t ) + p0_z * t - &
          dreal( alpha_z( ts ) + p0_z * ts );

    return;
end function im_traj_z


double complex function im_traj_vx( t )
    use mod_p0;

    implicit none;
    double complex, intent(in):: t;
    double complex, external:: pulse_A_x;

    im_traj_vx = p0_x + pulse_A_x( t );

    return;
end function im_traj_vx


double complex function im_traj_vz( t )
    use mod_p0;

    implicit none;
    double complex, intent(in):: t;
    double complex, external:: pulse_A_z;

    im_traj_vz = p0_z + pulse_A_z( t );

    return;
end function im_traj_vz







double complex function action_W_im( ts )
    use mod_p0
    use mod_pulse, only: om, E0, nc, xi, Pi
    
    implicit none;
    double complex, intent(in):: ts;
    double complex, external:: v2_integrand, cedint;
    double complex:: t0;
    double precision, parameter:: Ip = IONIZATION_IP
    double precision:: p0x, p0z
    integer:: i
    double complex:: t

    t0 = dcmplx( dreal(ts), 0d0 );
    p0x = p0_x;
    p0z = p0_z;
    if ( dimag(ts)+1d-6 <= 0d0 ) stop 'error: Im[t] < 0';


#ifdef IM_PLOT_INTEGRAND
     open(IM_PLOT_FILE_ID, file=IM_PLOT_FILE_NAME)
     do i = 1, IM_PLOT_N_PTS
         t = dcmplx( dreal(ts), ( dimag(ts) + IM_PLOT_OFFSET ) / (IM_PLOT_N_PTS-1) * (i - 1) );
         write(IM_PLOT_FILE_ID, '(3(e15.8,2x))'), dimag(t), v2_integrand( t ) + Ip;
     end do
     close(IM_PLOT_FILE_ID)
#endif ! IM_PLOT_INTEGRAND

    action_W_im = Ip*t0 - Ip*ts + (64*om**3*p0x**2*t0 - 320*nc**2*om**3*p0x**2*t0 &
          + 256*nc**4*om**3*p0x**2*t0 - 64*om**3*p0x**2*ts + 320*nc**2*om**3*p0x**2*ts &
          - 256*nc**4*om**3*p0x**2*ts + 12*E0**2*om*t0*xi**2 - 60*E0**2*nc**2*om*t0*xi**2 &
          + 48*E0**2*nc**4*om*t0*xi**2 + 64*om**3*p0x**2*t0*xi**2 - 320*nc**2*om**3*p0x**2*t0*xi**2 &
          + 256*nc**4*om**3*p0x**2*t0*xi**2 - 12*E0**2*om*ts*xi**2 + 60*E0**2*nc**2*om*ts*xi**2 &
          - 48*E0**2*nc**4*om*ts*xi**2 - 64*om**3*p0x**2*ts*xi**2 + 320*nc**2*om**3*p0x**2*ts*xi**2 &
          - 256*nc**4*om**3*p0x**2*ts*xi**2 + 32*E0*nc*(-1 - nc + 4*nc**2 + 4*nc**3)*om*p0x*xi*dsqrt(1 &
          + xi**2)*cdcos(((-1 + nc)*(Pi - 2*om*t0))/(2.*nc)) - 32*E0*nc*(-1 - nc + 4*nc**2 &
          + 4*nc**3)*om*p0x*xi*dsqrt(1 + xi**2)*cdcos(((-1 + nc)*(Pi - 2*om*ts))/(2.*nc)) - &
          64*E0*(1 - 5*nc**2 + 4*nc**4)*om*p0x*xi*dsqrt(1 + xi**2)*cdsin(om*t0) + &
          6*E0**2*xi**2*cdsin(2*om*t0) - 30*E0**2*nc**2*xi**2*cdsin(2*om*t0) + &
          24*E0**2*nc**4*xi**2*cdsin(2*om*t0) + 16*E0**2*nc*xi**2*cdsin((Pi - 2*om*t0)/(2.*nc)) &
          - 80*E0**2*nc**3*xi**2*cdsin((Pi - 2*om*t0)/(2.*nc)) + 64*E0**2*nc**5*xi**2*cdsin((Pi &
          - 2*om*t0)/(2.*nc)) - 2*E0**2*nc*xi**2*cdsin((Pi - 2*om*t0)/nc) + &
          10*E0**2*nc**3*xi**2*cdsin((Pi - 2*om*t0)/nc) - 8*E0**2*nc**5*xi**2*cdsin((Pi - 2*om*t0)/nc) &
          - E0**2*nc*xi**2*cdsin((Pi + 2*(-1 + nc)*om*t0)/nc) - E0**2*nc**2*xi**2*cdsin((Pi + 2*(-1 &
          + nc)*om*t0)/nc) +  4*E0**2*nc**3*xi**2*cdsin((Pi + 2*(-1 + nc)*om*t0)/nc) + &
          4*E0**2*nc**4*xi**2*cdsin((Pi + 2*(-1 + nc)*om*t0)/nc) + 8*E0**2*nc*xi**2*cdsin((Pi - 2*om*t0 &
          + 4*nc*om*t0)/(2.*nc)) + 16*E0**2*nc**2*xi**2*cdsin((Pi - 2*om*t0 + 4*nc*om*t0)/(2.*nc)) &
          - 8*E0**2*nc**3*xi**2*cdsin((Pi - 2*om*t0 + 4*nc*om*t0)/(2.*nc)) - &
          16*E0**2*nc**4*xi**2*cdsin((Pi - 2*om*t0 + 4*nc*om*t0)/(2.*nc)) - 32*E0*nc*om*p0x*xi*dsqrt(1 &
          + xi**2)*cdsin((Pi - 2*(1 + nc)*om*t0)/(2.*nc)) + 32*E0*nc**2*om*p0x*xi*dsqrt(1 + &
          xi**2)*cdsin((Pi - 2*(1 + nc)*om*t0)/(2.*nc)) + 128*E0*nc**3*om*p0x*xi*dsqrt(1 + &
          xi**2)*cdsin((Pi - 2*(1 + nc)*om*t0)/(2.*nc)) - 128*E0*nc**4*om*p0x*xi*dsqrt(1 + &
          xi**2)*cdsin((Pi - 2*(1 + nc)*om*t0)/(2.*nc)) - E0**2*nc*xi**2*cdsin((Pi - 2*(1 + &
          nc)*om*t0)/nc) + E0**2*nc**2*xi**2*cdsin((Pi - 2*(1 + nc)*om*t0)/nc) + &
          4*E0**2*nc**3*xi**2*cdsin((Pi - 2*(1 + nc)*om*t0)/nc) - 4*E0**2*nc**4*xi**2*cdsin((Pi - &
          2*(1 + nc)*om*t0)/nc) + 8*E0**2*nc*xi**2*cdsin((Pi - 2*(1 + 2*nc)*om*t0)/(2.*nc)) - &
          16*E0**2*nc**2*xi**2*cdsin((Pi - 2*(1 + 2*nc)*om*t0)/(2.*nc)) - &
          8*E0**2*nc**3*xi**2*cdsin((Pi - 2*(1 + 2*nc)*om*t0)/(2.*nc)) + &
          16*E0**2*nc**4*xi**2*cdsin((Pi - 2*(1 + 2*nc)*om*t0)/(2.*nc)) + 64*E0*(1 - 5*nc**2 + &
          4*nc**4)*om*p0x*xi*dsqrt(1 + xi**2)*cdsin(om*ts) - 6*E0**2*xi**2*cdsin(2*om*ts) + &
          30*E0**2*nc**2*xi**2*cdsin(2*om*ts) - 24*E0**2*nc**4*xi**2*cdsin(2*om*ts) + &
          2*(6*E0**2*om*t0 - 30*E0**2*nc**2*om*t0 + 24*E0**2*nc**4*om*t0 + 32*om**3*p0z**2*t0 - &
          160*nc**2*om**3*p0z**2*t0 + 128*nc**4*om**3*p0z**2*t0 - 6*E0**2*om*ts + 30*E0**2*nc**2*om*ts &
          - 24*E0**2*nc**4*om*ts - 32*om**3*p0z**2*ts + 160*nc**2*om**3*p0z**2*ts - &
          128*nc**4*om**3*p0z**2*ts + 32*om**3*p0z**2*t0*xi**2 - 160*nc**2*om**3*p0z**2*t0*xi**2 + &
          128*nc**4*om**3*p0z**2*t0*xi**2 - 32*om**3*p0z**2*ts*xi**2 + 160*nc**2*om**3*p0z**2*ts*xi**2 - &
          128*nc**4*om**3*p0z**2*ts*xi**2 - 32*E0*(-1 + 4*nc**2)*om*p0z*dsqrt(1 + xi**2)*cdcos(om*t0)*(1 - &
          nc**2 + nc**2*cdcos((om*t0)/nc)) + 32*E0*(-1 + 4*nc**2)*om*p0z*dsqrt(1 + xi**2)*cdcos(om*ts)*(1 - &
          nc**2 + nc**2*cdcos((om*ts)/nc)) + E0**2*(16*nc**2*(-1 + nc**2)*cdcos((om*t0)/nc) - &
          (-1 + 4*nc**2)*(-3 + 3*nc**2 + nc**2*cdcos((2*om*t0)/nc)))*cdsin(2*om*t0) - &
          8*E0**2*nc*cdsin((om*t0)/nc) + 40*E0**2*nc**3*cdsin((om*t0)/nc) - &
          32*E0**2*nc**5*cdsin((om*t0)/nc) + 2*E0**2*nc*cdcos(om*t0)**2*(4 - 4*nc**2 + (-1 + &
          4*nc**2)*cdcos((om*t0)/nc))*cdsin((om*t0)/nc) + 32*E0*nc*om*p0z*dsqrt(1 + &
          xi**2)*cdsin(om*t0)*cdsin((om*t0)/nc) - 128*E0*nc**3*om*p0z*dsqrt(1 + &
          xi**2)*cdsin(om*t0)*cdsin((om*t0)/nc) - 8*E0**2*nc*cdsin(om*t0)**2*cdsin((om*t0)/nc) + &
          8*E0**2*nc**3*cdsin(om*t0)**2*cdsin((om*t0)/nc) + E0**2*nc*cdsin((2*om*t0)/nc) - &
          5*E0**2*nc**3*cdsin((2*om*t0)/nc) + 4*E0**2*nc**5*cdsin((2*om*t0)/nc) + &
          E0**2*nc*cdsin(om*t0)**2*cdsin((2*om*t0)/nc) - 4*E0**2*nc**3*cdsin(om*t0)**2*cdsin((2*om*t0)/nc) &
          - E0**2*(16*nc**2*(-1 + nc**2)*cdcos((om*ts)/nc) - (-1 + 4*nc**2)*(-3 + 3*nc**2 + &
          nc**2*cdcos((2*om*ts)/nc)))*cdsin(2*om*ts) + 8*E0**2*nc*cdsin((om*ts)/nc) - &
          40*E0**2*nc**3*cdsin((om*ts)/nc) + 32*E0**2*nc**5*cdsin((om*ts)/nc) - &
          2*E0**2*nc*cdcos(om*ts)**2*(4 - 4*nc**2 + (-1 + 4*nc**2)*cdcos((om*ts)/nc))*cdsin((om*ts)/nc) - &
          32*E0*nc*om*p0z*dsqrt(1 + xi**2)*cdsin(om*ts)*cdsin((om*ts)/nc) + 128*E0*nc**3*om*p0z*dsqrt(1 &
          + xi**2)*cdsin(om*ts)*cdsin((om*ts)/nc) + 8*E0**2*nc*cdsin(om*ts)**2*cdsin((om*ts)/nc) &
          - 8*E0**2*nc**3*cdsin(om*ts)**2*cdsin((om*ts)/nc) - E0**2*nc*cdsin((2*om*ts)/nc) + &
          5*E0**2*nc**3*cdsin((2*om*ts)/nc) - 4*E0**2*nc**5*cdsin((2*om*ts)/nc) - &
          E0**2*nc*cdsin(om*ts)**2*cdsin((2*om*ts)/nc) + 4*E0**2*nc**3*cdsin(om*ts)**2*cdsin((2*om*ts)/nc)) &
          - 16*E0**2*nc*xi**2*cdsin((Pi - 2*om*ts)/(2.*nc)) + 80*E0**2*nc**3*xi**2*cdsin((Pi - &
          2*om*ts)/(2.*nc)) - 64*E0**2*nc**5*xi**2*cdsin((Pi - 2*om*ts)/(2.*nc)) + &
          2*E0**2*nc*xi**2*cdsin((Pi - 2*om*ts)/nc) - 10*E0**2*nc**3*xi**2*cdsin((Pi - 2*om*ts)/nc) + &
          8*E0**2*nc**5*xi**2*cdsin((Pi - 2*om*ts)/nc) + E0**2*nc*xi**2*cdsin((Pi + 2*(-1 + nc)*om*ts)/nc) &
          + E0**2*nc**2*xi**2*cdsin((Pi + 2*(-1 + nc)*om*ts)/nc) - 4*E0**2*nc**3*xi**2*cdsin((Pi + 2*(-1 &
          + nc)*om*ts)/nc) - 4*E0**2*nc**4*xi**2*cdsin((Pi + 2*(-1 + nc)*om*ts)/nc) - &
          8*E0**2*nc*xi**2*cdsin((Pi - 2*om*ts + 4*nc*om*ts)/(2.*nc)) - 16*E0**2*nc**2*xi**2*cdsin((Pi - &
          2*om*ts + 4*nc*om*ts)/(2.*nc)) + 8*E0**2*nc**3*xi**2*cdsin((Pi - 2*om*ts + 4*nc*om*ts)/(2.*nc)) &
          + 16*E0**2*nc**4*xi**2*cdsin((Pi - 2*om*ts + 4*nc*om*ts)/(2.*nc)) + 32*E0*nc*om*p0x*xi*dsqrt(1 + &
          xi**2)*cdsin((Pi - 2*(1 + nc)*om*ts)/(2.*nc)) - 32*E0*nc**2*om*p0x*xi*dsqrt(1 + xi**2)*cdsin((Pi &
          - 2*(1 + nc)*om*ts)/(2.*nc)) - 128*E0*nc**3*om*p0x*xi*dsqrt(1 + xi**2)*cdsin((Pi - 2*(1 + &
          nc)*om*ts)/(2.*nc)) + 128*E0*nc**4*om*p0x*xi*dsqrt(1 + xi**2)*cdsin((Pi - 2*(1 + &
          nc)*om*ts)/(2.*nc)) + E0**2*nc*xi**2*cdsin((Pi - 2*(1 + nc)*om*ts)/nc) - &
          E0**2*nc**2*xi**2*cdsin((Pi - 2*(1 + nc)*om*ts)/nc) - 4*E0**2*nc**3*xi**2*cdsin((Pi - &
          2*(1 + nc)*om*ts)/nc) + 4*E0**2*nc**4*xi**2*cdsin((Pi - 2*(1 + nc)*om*ts)/nc) - &
          8*E0**2*nc*xi**2*cdsin((Pi - 2*(1 + 2*nc)*om*ts)/(2.*nc)) + 16*E0**2*nc**2*xi**2*cdsin((Pi &
          - 2*(1 + 2*nc)*om*ts)/(2.*nc)) + 8*E0**2*nc**3*xi**2*cdsin((Pi - 2*(1 + 2*nc)*om*ts)/(2.*nc)) &
          - 16*E0**2*nc**4*xi**2*cdsin((Pi - 2*(1 + 2*nc)*om*ts)/(2.*nc)))/(128.*(1 - 5*nc**2 + &
          4*nc**4)*om**3*(1 + xi**2))
    
    return;
end function action_W_im

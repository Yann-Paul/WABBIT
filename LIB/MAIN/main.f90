! ********************************
! 2D AMR prototype
! --------------------------------
!
! main program, time loop
!
! name: main.f90
! date: 01.08.2016
! author: msr
! version: 0.1
!
! ********************************

program main

    use module_params
    use module_blocks

    implicit none

    ! time loop variables
    real(kind=rk) 	    :: time
    integer(kind=ik)	:: iteration
    ! cpu time variables
    real(kind=rk)       :: t0, t1

    time        = 0.0_rk
    iteration   = 0

    ! initializing data
    call init_data()

    ! cpu time start
    call cpu_time(t0)

    ! create block tree
    call matrix_to_block_tree()
    call active_blocks_list()
    call block_check()

    ! update neighbor relations
    call update_neighbors()

    ! save start field to disk
    call save_data(iteration, time)

    ! main time loop
    do while ( time < params%time_max )

        iteration = iteration + 1

        ! adapt the mesh
        call adapt_mesh()

        ! advance in time
        call time_step(time)

        ! write data to disk
        if (modulo(iteration, params%write_freq) == 0) then
          call save_data(iteration, time)
        endif

        ! output on screen
        write(*,'("iteration=",i5,3x," time=",f10.6,3x," N_active=",i7)') iteration, &
        time, size(blocks_params%active_list, dim=1)
        write(*,'(80("-"))')

    end do

    ! save end field to disk
    call save_data(iteration, time)

    ! cpu time calculation and writing
    call cpu_time(t1)
    write(*,'(a,f10.6)') "cpu-time = ", t1-t0

end program main

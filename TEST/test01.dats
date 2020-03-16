(**
 ** Project: jack-ats2
 ** Author : Mark Bellaire
 ** Year   : 2020
 ** License: MIT
 **)

#include "share/atspre_staload.hats"
#include "./../mylibies.hats"

staload "libats/libc/SATS/unistd.sats"

fn process(
   pf : !JACK_PROCESS | 
   nframes :  jack_nframes_t 
 , arg     : !ptr 
 ) : int = 0 

 
implement main0 () = 
  println!("Hello [test01]") where {

    var status : jack_status_t?
    
    val client 
      = jack_client_open_exn("test01", JackNullOption, status )

    var state = the_null_ptr    

    prval () = jack_client_own( client, state )
   
    val x = jack_set_process_callback( client, process, state )
    
    val port 
      = jack_port_register_exn( client, "out", JACK_DEFAULT_MIDI_TYPE, JackPortIsOutput, 0UL )

    val _ = sleep( 10 )

    val (pf | x) = jack_client_close( client )

    prval () = jack_owned_elim_lval( pf | state )

  }




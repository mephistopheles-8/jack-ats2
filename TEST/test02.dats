(**
 ** Project: jack-ats2
 ** Author : Mark Bellaire
 ** Year   : 2020
 ** License: MIT
 **)

#include "share/atspre_staload.hats"
#include "./../mylibies.hats"

staload "libats/libc/SATS/unistd.sats"
staload "libats/libc/SATS/math.sats"
staload _ = "libats/libc/DATS/math.dats"


#define jack_sample_t jack_default_audio_sample_t
symintr jacksamp
overload size with jack_nframes_size
overload jacksamp with double_jack_sample

#define BUFSZ 1024

typedef dsp_state(buf:addr) = @{
      time      = [n:nat | n < BUFSZ] int n
    , waveform  = ptr buf
    , port      = jack_port_t
    , sr        = size_t
  }

datavtype dsp(buf:addr) =
  | DSP of (dsp_state(buf))
    
var buf = @[jack_sample_t][BUFSZ]() 
val () = array_initize<jack_sample_t>( buf, i2sz(BUFSZ)) where {
  implement 
  array_initize$init<jack_sample_t>( i, x ) 
      = x := jacksamp(sin(2.0*M_PI*g0int2float(sz2i(i))/g0int2float(BUFSZ)))
} 

extern
praxi getbuf( !ptr buf ) 
  : (array_v(jack_sample_t,buf,BUFSZ), (array_v(jack_sample_t,buf,BUFSZ)) -<lin,prf> void)

implement main0 () = 
  println!("Hello [test02]") where {

    var status : jack_status_t?

    val client 
      = jack_client_open_exn("test01", JackNullOption, status )
    
    val port 
      = jack_port_register_exn( client, "out", JACK_DEFAULT_AUDIO_TYPE, JackPortIsOutput, 0UL )

    var state : dsp(buf) = DSP(@{
      time     = 0
    , waveform = addr@buf
    , port     = port
    , sr       = size( jack_get_sample_rate( client ) ) 
    })

    prval () = jack_client_own( client, state )
   
    val x 
      = jack_set_process_callback{dsp(buf)}(
          client , lam(PROC | nframes, arg) => 0 where {
              val @DSP(state) = arg 
              val ( pf, pff | p ) 
                = jack_port_get_buffer( state.port, nframes )
              
              val _ = array_foreach_env<jack_sample_t><dsp_state(buf)>( !p, size(nframes), state )
                    where {
                      implement
                      array_foreach$fwork<jack_sample_t><dsp_state(buf)>( x, env )
                        = let
                             val wavep = env.waveform
                             prval ( pf, pff ) = getbuf( wavep )
                             val () = x := array_get_at( !wavep, env.time )
                             val inc = i2sz(440)*i2sz(BUFSZ)/env.sr
                             val () = env.time := $UNSAFE.cast{intBtwe(0,BUFSZ-1)}( (env.time + sz2i(inc)) mod BUFSZ ) 
                             prval () = pff( pf )
                           in
                          end
                    } 
              prval () = pff(pf)
              prval () = fold@arg
        }, state )
  
    val _ = jack_activate( client ) 
 
    val _ = sleep( 10 )

    val _ = jack_deactivate( client ) 
 
    val (pf | x) = jack_client_close_exn( client )

    prval () = jack_owned_elim_lval( pf | state )
    val ~DSP(_) = state

  }




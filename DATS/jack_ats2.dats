(**
 ** Project: jack-ats2
 ** Author : Mark Bellaire
 ** Year   : 2020
 ** License: MIT
 **)

#include "share/atspre_staload.hats"
#include "./../HATS/project.hats"

staload "./../SATS/jack.sats"
staload "./../SATS/jack_ats2.sats"

implement {}
jack_client_open_opt( name, opts, status, client ) 
 = let
     val (pfc | cp) 
       = jack_client_open(cstring(name), opts, status )
    in if cp > the_null_ptr 
       then let
           prval Some_v(pfc) = pfc
          val () =  client := jack_client_encode( pfc | cp )
           prval () = opt_some( client )
         in true
        end
      else let
           prval None_v() = pfc
           prval () = opt_none( client )
        in false
       end
   end

implement {}
jack_client_open_option( name, opts, status) 
 = let
     val (pfc | cp) 
       = jack_client_open(cstring(name), opts, status )
    in if cp > the_null_ptr 
       then let
           prval Some_v(pfc) = pfc
         in Some_vt( jack_client_encode( pfc | cp ) )
        end
      else let
           prval None_v() = pfc
        in None_vt()
       end
   end

implement {}
jack_client_open_exn( name, opts, status) 
  = client where { 

    val (pfc | cp) 
      = jack_client_open(cstring(name), opts, status )

    val () 
      = assert_errmsg( cp > the_null_ptr, "Could not open JACK client")

    prval Some_v(pfc) = pfc
    
    val client = jack_client_encode( pfc | cp )

  } 

implement {}
jack_port_register_exn{cl}(client, name, ptype, pflags, flags)
   = client_port where {

      val (pfp | pp)  
        = jack_port_register( client, cstring(name), cstring(ptype), pflags, flags )

      val () 
        = assert_errmsg( pp > the_null_ptr, "Could not open JACK MIDI port")

      prval Some_v(pfp) = pfp
      
      val client_port = jack_port_encode( pfp | pp )

    }

implement {}
jack_port_register_opt{cl}( client, name, ptype, pflags, flags, port )
 = let
     val (pfp | pp)  
       = jack_port_register( client, cstring(name), cstring(ptype), pflags, flags )
    in if pp > the_null_ptr 
       then let
           prval Some_v(pfp) = pfp
           val () = port :=  jack_port_encode( pfp | pp )
           prval () = opt_some( port )
         in true
        end
      else let
           prval None_v() = pfp
           prval () = opt_none( port )
        in false
       end
   end

implement {}
jack_port_register_option{cl}(client, name, ptype, pflags, flags) 
 = let
     val (pfp | pp)  
       = jack_port_register( client, cstring(name), cstring(ptype), pflags, flags )
    in if pp > the_null_ptr 
       then let
           prval Some_v(pfp) = pfp
         in Some_vt( jack_port_encode( pfp | pp ) )
        end
      else let
           prval None_v() = pfp
        in None_vt()
       end
   end

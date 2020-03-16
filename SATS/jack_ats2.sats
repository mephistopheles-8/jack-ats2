(**
 ** Project: jack-ats2
 ** Author : Mark Bellaire
 ** Year   : 2020
 ** License: MIT
 **)

#include "./../HATS/project.hats"
staload "./../SATS/jack.sats"

fun {} jack_client_open_opt( 
    name: string
  , opts: jack_options_t
  , status: &jack_status_t? >> jack_status_t
  , client: &jack_client_t? >> opt(jack_client_t,b) 
  ) : #[b:bool] bool b 

fun {} jack_client_open_option( 
    name: string
  , opts: jack_options_t
  , status: &jack_status_t? >> jack_status_t
  ) : Option_vt(jack_client_t) 

fun {} jack_client_open_exn( 
    name: string
  , opts: jack_options_t
  , status: &jack_status_t? >> jack_status_t 
  ) : [cl:agz] jack_client_t(cl) 

fun {} jack_port_register_exn{cl:agz}(
    client: !jack_client_t(cl)
  , name: string
  , ptype: string
  , pflags: enum_JackPortFlags
  , flags: ulint
  ): [l:agz] jack_port_t(cl,l) 

fun {} jack_port_register_opt{cl:agz}( 
    client: !jack_client_t(cl)
  , name: string
  , ptype: string
  , pflags: enum_JackPortFlags
  , flags: ulint
  , port: &jack_port_t? >> opt(jack_port_t(cl),b) 
  ) : #[b:bool] bool b 

fun {} jack_port_register_option{cl:agz}( 
    client: !jack_client_t(cl)
  , name: string
  , ptype: string
  , pflags: enum_JackPortFlags
  , flags: ulint
  ) : [b:bool] Option_vt(jack_port_t(cl)) 

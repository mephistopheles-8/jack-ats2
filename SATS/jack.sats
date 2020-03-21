(**
 ** Project: jack-ats2
 ** Author : Mark Bellaire
 ** Year   : 2020
 ** License: MIT
 **)
%{#
#ifndef _JACK_ATS2_JACK_SATS
#define _JACK_ATS2_JACK_SATS

#include "jack/jack.h"

#define _jack_ats2_lor(x,y) ((x) | (y))
#define _jack_ats2_lhas(x,y) (((x) & (y)) != 0)
#define _jack_ats2_eq(x,y) ((x) == (y))
#define _jack_ats2_neq(x,y) ((x) != (y))

#endif
%}
(**  **)
local
typedef cstring = $extype"atstype_string"
in

castfn cstring_string( cstring ) : string
castfn string_cstring( string ) : cstring
overload string with cstring_string
overload cstring with string_cstring


macdef JACK_LIB_EXPORT = $extval(ulint,"JACK_LIB_EXPORT")
macdef JACK_OPTIONAL_WEAK_EXPORT = $extval(ulint,"JACK_OPTIONAL_WEAK_EXPORT")
macdef JACK_POSITION_MASK = $extval(ulint,"JACK_POSITION_MASK")
macdef JACK_DEFAULT_MIDI_TYPE = $extval(string,"JACK_DEFAULT_MIDI_TYPE")
macdef JACK_WEAK_EXPORT = $extval(ulint,"JACK_WEAK_EXPORT")
macdef JACK_MAX_FRAMES = $extval(ulint,"JACK_MAX_FRAMES")
macdef JACK_LOAD_INIT_LIMIT = $extval(ulint,"JACK_LOAD_INIT_LIMIT")
macdef JACK_DEFAULT_AUDIO_TYPE = $extval(string,"JACK_DEFAULT_AUDIO_TYPE")
macdef JACK_OPTIONAL_WEAK_DEPRECATED_EXPORT = $extval(ulint,"JACK_OPTIONAL_WEAK_DEPRECATED_EXPORT")

(**
 ** [Modeling Ownership]
 ** 
 ** JACK uses callbacks in a realtime thread.
 ** It's only safe to free shared resources 
 ** when the client is deactivated.
 **
 ** To pass state to a callback, you need to first 
 ** cast it to jack_owned.  The cast must be explicit,
 ** because the state may be used in multiple callbacks
 ** for the same client.
 ** 
 ** To eliminate jack_owned safely, you need proof
 ** that the client has been closed.
 **
 ** [Process Restrictions]
 ** 
 ** Some functions can only be used from the process calback.
 ** They will require the view JACK_PROCESS 
 **) 

absprop jack_client_closed(l:addr)
absview jack_process_stopped(l:addr)

absvtype jack_owned(l:addr,a:vtype) = a

castfn jack_owned_elim_rval{a:vtype}{l:addr}( jack_client_closed(l) | jack_owned(l,a) ) : a 
praxi jack_owned_elim_lval{a:vtype}{l:addr}( jack_client_closed(l) | !jack_owned(l,a) >> a ) : void 

absview JACK_PROCESS

typedef jack_native_thread_t = $extype"jack_native_thread_t"

typedef jack_uuid_t = $extype"jack_uuid_t"

typedef jack_shmsize_t = $extype"jack_shmsize_t"

abst@ype jack_nframes_t(n:int) = $extype"jack_nframes_t"

typedef jack_nframes_t = [n:nat] jack_nframes_t(n)

castfn jack_nframes_int{n:nat}( jack_nframes_t(n) ) : int n
castfn jack_nframes_size{n:nat}( jack_nframes_t(n) ) : size_t n

typedef jack_time_t = $extype"jack_time_t"

typedef jack_intclient_t = $extype"jack_intclient_t"

(** Really, ports are managed by the client.  You can unregister but you
    Don't really need to.  You cannot use the port after the client is freed. **)
absview jack_port_v(cl:addr,l:addr)
abstype jack_port_t(cl:addr,l:addr) = cPtr0( $extype"jack_port_t" )
vtypedef jack_port_t(cl:addr) = [l:addr | l > null] jack_port_t(cl,l)
vtypedef jack_port_t = [cl,l:agz] jack_port_t(cl,l)

castfn jack_port_encode{cl,l:addr}( jack_port_v(cl,l) | ptr l ) : jack_port_t(cl,l)
castfn jack_port_decode{cl,l:addr}( jack_port_t(cl,l) ) : ( jack_port_v(cl,l) | ptr l ) 

praxi jack_port_elim{cl,l:addr}{a:vtype}( jack_client_closed(cl) | jack_port_t(cl,l) ) : void 


absview jack_client_v(l:addr)
absvtype jack_client_t(l:addr) = cPtr0( $extype"jack_client_t" )
vtypedef jack_client_t = [l:agz] jack_client_t(l)

castfn jack_client_encode{l:addr}( jack_client_v(l) | ptr l ) : jack_client_t(l)
castfn jack_client_decode( jack_client_t ) : [l:addr] ( jack_client_v(l) | ptr l ) 

castfn jack_client_v_own_rval{l:addr}{a:vtype}( !jack_client_v(l) |  a ) : jack_owned(l,a)
praxi jack_client_v_own_lval{l:addr}{a:vtype}( !jack_client_v(l) |  !a >> jack_owned(l,a) ) : void
praxi jack_client_t_own_lval{l:addr}{a:vtype}( !jack_client_t(l) , !a >> jack_owned(l,a) ) : void

symintr jack_client_own
overload jack_client_own with jack_client_v_own_rval
overload jack_client_own with jack_client_v_own_lval
overload jack_client_own with jack_client_t_own_lval


typedef jack_port_id_t = $extype"jack_port_id_t"

typedef jack_port_type_id_t = $extype"jack_port_type_id_t"

abst@ype enum_JackOptions = $extype"enum JackOptions"

macdef JackNullOption = $extval(enum_JackOptions,"JackNullOption")
macdef JackNoStartServer = $extval(enum_JackOptions,"JackNoStartServer")
macdef JackUseExactName = $extval(enum_JackOptions,"JackUseExactName")
macdef JackServerName = $extval(enum_JackOptions,"JackServerName")
macdef JackLoadName = $extval(enum_JackOptions,"JackLoadName")
macdef JackLoadInit = $extval(enum_JackOptions,"JackLoadInit")
macdef JackSessionID = $extval(enum_JackOptions,"JackSessionID")

fn enum_JackOptions_lor( enum_JackOptions, enum_JackOptions ) :<> enum_JackOptions = "mac#_jack_ats2_lor"
overload lor with enum_JackOptions_lor

typedef jack_options_t = enum_JackOptions


abst@ype enum_JackStatus = $extype"enum JackStatus"

macdef JackFailure = $extval(enum_JackStatus,"JackFailure")
macdef JackInvalidOption = $extval(enum_JackStatus,"JackInvalidOption")
macdef JackNameNotUnique = $extval(enum_JackStatus,"JackNameNotUnique")
macdef JackServerStarted = $extval(enum_JackStatus,"JackServerStarted")
macdef JackServerFailed = $extval(enum_JackStatus,"JackServerFailed")
macdef JackServerError = $extval(enum_JackStatus,"JackServerError")
macdef JackNoSuchClient = $extval(enum_JackStatus,"JackNoSuchClient")
macdef JackLoadFailure = $extval(enum_JackStatus,"JackLoadFailure")
macdef JackInitFailure = $extval(enum_JackStatus,"JackInitFailure")
macdef JackShmFailure = $extval(enum_JackStatus,"JackShmFailure")
macdef JackVersionError = $extval(enum_JackStatus,"JackVersionError")
macdef JackBackendError = $extval(enum_JackStatus,"JackBackendError")
macdef JackClientZombie = $extval(enum_JackStatus,"JackClientZombie")

typedef jack_status_t = enum_JackStatus

fn jack_status_eq( jack_status_t, jack_status_t ) :<> bool = "mac#_jack_ats2_eq"
fn jack_status_neq( jack_status_t, jack_status_t ) :<> bool = "mac#_jack_ats2_neq"
overload = with jack_status_eq
overload != with jack_status_neq

abst@ype enum_JackLatencyCallbackMode = $extype"enum JackLatencyCallbackMode"

macdef JackCaptureLatency = $extval(enum_JackLatencyCallbackMode,"JackCaptureLatency")
macdef JackPlaybackLatency = $extval(enum_JackLatencyCallbackMode,"JackPlaybackLatency")

abst@ype jack_latency_callback_mode_t = $extype"jack_latency_callback_mode_t"


typedef JackLatencyCallback(a:vtype) = (jack_latency_callback_mode_t, !a) -> void

typedef struct__jack_latency_range = $extype_struct"struct _jack_latency_range" of {
   min = jack_nframes_t
 , max = jack_nframes_t
}

typedef jack_latency_range_t = $extype"jack_latency_range_t"

typedef JackProcessCallback(a:vtype) = (!JACK_PROCESS | jack_nframes_t, !a) -> int

typedef JackThreadCallback(a:vtype) = (a) -> a

typedef JackThreadInitCallback(a:vtype) = (!a) -> void

typedef JackGraphOrderCallback(a:vtype) = (!a) -> int

typedef JackXRunCallback(a:vtype) = (!a) -> int

typedef JackBufferSizeCallback(a:vtype) = (jack_nframes_t, !a) -> int

typedef JackSampleRateCallback(a:vtype) = (jack_nframes_t, !a) -> int

typedef JackPortRegistrationCallback(a:vtype) = (jack_port_id_t, int, !a) -> void

typedef JackClientRegistrationCallback(a:vtype) = (cstring, int, !a) -> void

typedef JackPortConnectCallback(a:vtype) = (jack_port_id_t, jack_port_id_t, int, !a) -> void

typedef JackPortRenameCallback(a:vtype) = (jack_port_id_t, cstring, cstring, !a) -> void

typedef JackFreewheelCallback(a:vtype) = (int, !a) -> void

typedef JackShutdownCallback(a:vtype) = (!a) -> void

typedef JackInfoShutdownCallback(a:vtype) = (jack_status_t, cstring, !a) -> void

typedef jack_default_audio_sample_t = $extype"jack_default_audio_sample_t"

castfn jack_sample_float ( jack_default_audio_sample_t ) : float
castfn jack_sample_double ( jack_default_audio_sample_t ) : double
castfn float_jack_sample( float ) : jack_default_audio_sample_t
castfn double_jack_sample ( double ) : jack_default_audio_sample_t


abst@ype enum_JackPortFlags = $extype"enum JackPortFlags"

macdef JackPortIsInput = $extval(enum_JackPortFlags,"JackPortIsInput")
macdef JackPortIsOutput = $extval(enum_JackPortFlags,"JackPortIsOutput")
macdef JackPortIsPhysical = $extval(enum_JackPortFlags,"JackPortIsPhysical")
macdef JackPortCanMonitor = $extval(enum_JackPortFlags,"JackPortCanMonitor")
macdef JackPortIsTerminal = $extval(enum_JackPortFlags,"JackPortIsTerminal")

abst@ype jack_transport_state_t = $extype"jack_transport_state_t"

macdef JackTransportStopped = $extval(jack_transport_state_t,"JackTransportStopped")
macdef JackTransportRolling = $extval(jack_transport_state_t,"JackTransportRolling")
macdef JackTransportLooping = $extval(jack_transport_state_t,"JackTransportLooping")
macdef JackTransportStarting = $extval(jack_transport_state_t,"JackTransportStarting")
macdef JackTransportNetStarting = $extval(jack_transport_state_t,"JackTransportNetStarting")

typedef jack_unique_t = $extype"jack_unique_t"

abst@ype jack_position_bits_t = $extype"jack_position_bits_t"

macdef JackPositionBBT = $extval(jack_position_bits_t,"JackPositionBBT")
macdef JackPositionTimecode = $extval(jack_position_bits_t,"JackPositionTimecode")
macdef JackBBTFrameOffset = $extval(jack_position_bits_t,"JackBBTFrameOffset")
macdef JackAudioVideoRatio = $extval(jack_position_bits_t,"JackAudioVideoRatio")
macdef JackVideoFrameOffset = $extval(jack_position_bits_t,"JackVideoFrameOffset")

typedef struct__jack_position = $extype_struct"struct _jack_position" of {
   unique_1 = jack_unique_t
 , usecs = jack_time_t
 , frame_rate = jack_nframes_t
 , frame = jack_nframes_t
 , valid = jack_position_bits_t
 , bar = int32
 , beat = int32
 , tick = int32
 , bar_start_tick = double
 , beats_per_bar = float
 , beat_type = float
 , ticks_per_beat = double
 , beats_per_minute = double
 , frame_time = double
 , next_time = double
 , bbt_offset = jack_nframes_t
 , audio_frames_per_video_frame = float
 , video_offset = jack_nframes_t
 , padding = int32
 , unique_2 = jack_unique_t
}

typedef jack_position_t = struct__jack_position

typedef JackSyncCallback(a:vtype) = (jack_transport_state_t, cPtr0(jack_position_t), !a) -> int

typedef JackTimebaseCallback(a:vtype) = (jack_transport_state_t, jack_nframes_t, cPtr0(jack_position_t), int, !a) -> void

abst@ype jack_transport_bits_t = $extype"jack_transport_bits_t"

macdef JackTransportState = $extval(jack_transport_bits_t,"JackTransportState")
macdef JackTransportPosition = $extval(jack_transport_bits_t,"JackTransportPosition")
macdef JackTransportLoop = $extval(jack_transport_bits_t,"JackTransportLoop")
macdef JackTransportSMPTE = $extval(jack_transport_bits_t,"JackTransportSMPTE")
macdef JackTransportBBT = $extval(jack_transport_bits_t,"JackTransportBBT")

typedef jack_transport_info_t = $extype_struct"jack_transport_info_t" of {
   frame_rate = jack_nframes_t
 , usecs = jack_time_t
 , valid = jack_transport_bits_t
 , transport_state = jack_transport_state_t
 , frame = jack_nframes_t
 , loop_start = jack_nframes_t
 , loop_end = jack_nframes_t
 , smpte_offset = lint
 , smpte_frame_rate = float
 , bar = int
 , beat = int
 , tick = int
 , bar_start_tick = double
 , beats_per_bar = float
 , beat_type = float
 , ticks_per_beat = double
 , beats_per_minute = double
}

fun jack_release_timebase(!jack_client_t) : int = "mac#"

fun jack_set_sync_callback{a:vtype}{l:addr}(!jack_client_t(l), JackSyncCallback(a), !jack_owned(l,a)) : int = "mac#"

fun jack_set_sync_timeout(!jack_client_t, jack_time_t) : int = "mac#"

fun jack_set_timebase_callback{a:vtype}{l:addr}(!jack_client_t(l), int, JackTimebaseCallback(a), !jack_owned(l,a)) : int = "mac#"

fun jack_transport_locate(!jack_client_t, jack_nframes_t) : int = "mac#"

fun jack_transport_query(!jack_client_t, &jack_position_t? >> jack_position_t ) : jack_transport_state_t = "mac#"

fun jack_get_current_transport_frame(!jack_client_t) : jack_nframes_t = "mac#"

fun jack_transport_reposition(!jack_client_t, &jack_position_t) : int = "mac#"

fun jack_transport_start(!jack_client_t) : void = "mac#"

fun jack_transport_stop(!jack_client_t) : void = "mac#"

fun jack_get_transport_info(!jack_client_t, &jack_transport_info_t? >> jack_transport_info_t) : void = "mac#"

fun jack_set_transport_info(!jack_client_t, &jack_transport_info_t) : void = "mac#"

fun jack_get_version(&int? >> int, &int? >> int, &int? >> int, &int? >> int) : void = "mac#"

fun jack_get_version_string() : cstring = "mac#"

fun jack_client_open(cstring, jack_options_t, &jack_status_t? >> jack_status_t) 
  : [l:addr] (option_v(jack_client_v(l),l > null) | ptr l) = "mac#"

(*
fun jack_client_new(cstring) : jack_client_t = "mac#"
*)

fun jack_client_close{l:addr}( !jack_client_t(l) >> opt(jack_client_t(l),n != 0)) 
  : #[n:int] (option_v(jack_client_closed(l),n == 0) | int n) = "mac#"

fun jack_client_name_size() : int = "mac#"

fun jack_get_client_name(!jack_client_t) : cstring = "mac#"

fun jack_get_uuid_for_client_name(!jack_client_t, cstring) : cstring = "mac#"

fun jack_get_client_name_by_uuid(!jack_client_t, cstring) : cstring = "mac#"

fun jack_internal_client_new(cstring, cstring, cstring) : int = "mac#"

fun jack_internal_client_close(cstring) : void = "mac#"

fun jack_activate(!jack_client_t) : int = "mac#"

fun jack_deactivate(!jack_client_t) : int = "mac#"

fun jack_get_client_pid(cstring) : int = "mac#"

fun jack_client_thread_id(!jack_client_t) : jack_native_thread_t = "mac#"

fun jack_is_realtime(!jack_client_t) : int = "mac#"

fun jack_thread_wait(!jack_client_t, int) : jack_nframes_t = "mac#"

fun jack_cycle_wait(!jack_client_t) : jack_nframes_t = "mac#"

fun jack_cycle_signal(!jack_client_t, int) : void = "mac#"

fun jack_set_process_thread{a:vtype}{l:addr}(!jack_client_t(l), JackThreadCallback(a), !jack_owned(l,a)) : int = "mac#"

fun jack_set_thread_init_callback{a:vtype}{l:addr}(!jack_client_t(l), JackThreadInitCallback(a), !jack_owned(l,a)) : int = "mac#"

fun jack_on_shutdown{a:vtype}{l:addr}(!jack_client_t(l), JackShutdownCallback(a), !jack_owned(l,a)) : void = "mac#"

fun jack_on_info_shutdown{a:vtype}{l:addr}(!jack_client_t(l), JackInfoShutdownCallback(a), !jack_owned(l,a)) : void = "mac#"

fun jack_set_process_callback{a:vtype}{l:addr}(!jack_client_t(l), JackProcessCallback(a), !jack_owned(l,a)) : int = "mac#"

fun jack_set_freewheel_callback{a:vtype}{l:addr}(!jack_client_t(l), JackFreewheelCallback(a), !jack_owned(l,a)) : int = "mac#"

fun jack_set_buffer_size_callback{a:vtype}{l:addr}(!jack_client_t(l), JackBufferSizeCallback(a), !jack_owned(l,a)) : int = "mac#"

fun jack_set_sample_rate_callback{a:vtype}{l:addr}(!jack_client_t(l), JackSampleRateCallback(a), !jack_owned(l,a)) : int = "mac#"

fun jack_set_client_registration_callback{a:vtype}{l:addr}(!jack_client_t(l), JackClientRegistrationCallback(a), !jack_owned(l,a)) : int = "mac#"

fun jack_set_port_registration_callback{a:vtype}{l:addr}(!jack_client_t(l), JackPortRegistrationCallback(a), !jack_owned(l,a)) : int = "mac#"

fun jack_set_port_connect_callback{a:vtype}{l:addr}(!jack_client_t(l), JackPortConnectCallback(a), !jack_owned(l,a)) : int = "mac#"

fun jack_set_port_rename_callback{a:vtype}{l:addr}(!jack_client_t(l), JackPortRenameCallback(a), !jack_owned(l,a)) : int = "mac#"

fun jack_set_graph_order_callback{a:vtype}{l:addr}(!jack_client_t(l), JackGraphOrderCallback(a), !jack_owned(l,a)) : int = "mac#"

fun jack_set_xrun_callback{a:vtype}{l:addr}(!jack_client_t(l), JackXRunCallback(a), !jack_owned(l,a)) : int = "mac#"

fun jack_set_latency_callback{a:vtype}{l:addr}(!jack_client_t(l), JackLatencyCallback(a), !jack_owned(l,a)) : int = "mac#"

fun jack_set_freewheel(!jack_client_t, int) : int = "mac#"

fun jack_set_buffer_size(!jack_client_t, jack_nframes_t) : int = "mac#"

fun jack_get_sample_rate(!jack_client_t) : jack_nframes_t = "mac#"

fun jack_get_buffer_size(!jack_client_t) : jack_nframes_t = "mac#"

fun jack_engine_takeover_timebase(!jack_client_t) : int = "mac#"

fun jack_cpu_load(!jack_client_t) : float = "mac#"

fun jack_port_register{cl:addr}(!jack_client_t(cl), cstring, cstring, enum_JackPortFlags, ulint) 
  : [l:addr] (option_v(jack_port_v(cl,l),l > null) | ptr l) = "mac#"

fun jack_port_unregister(!jack_client_t, jack_port_t) : int = "mac#"

fun jack_port_get_buffer{n:nat}(!jack_port_t, jack_nframes_t(n)) 
  : [l:agz] ( array(jack_default_audio_sample_t,n) @ l, (array(jack_default_audio_sample_t,n) @ l) -<lin,prf> void | ptr l ) = "mac#"

fun jack_port_uuid(!jack_port_t) : jack_uuid_t = "mac#"

fun jack_port_name(!jack_port_t) : cstring = "mac#"

fun jack_port_short_name(!jack_port_t) : cstring = "mac#"

fun jack_port_flags(!jack_port_t) : int = "mac#"

fun jack_port_type(!jack_port_t) : cstring = "mac#"

fun jack_port_type_id(!jack_port_t) : jack_port_type_id_t = "mac#"

fun jack_port_is_mine(!jack_client_t, !jack_port_t) : int = "mac#"

fun jack_port_connected(!jack_port_t) : int = "mac#"

fun jack_port_connected_to(!jack_port_t, cstring) : int = "mac#"

fun jack_port_get_connections(!jack_port_t) : cPtr0(cstring) = "mac#"

fun jack_port_get_all_connections(!jack_client_t, !jack_port_t) : cPtr0(cstring) = "mac#"

fun jack_port_tie(!jack_port_t, !jack_port_t) : int = "mac#"

fun jack_port_untie(!jack_port_t) : int = "mac#"

fun jack_port_set_name(!jack_port_t, cstring) : int = "mac#"

fun jack_port_rename(!jack_client_t, !jack_port_t, cstring) : int = "mac#"

fun jack_port_set_alias(!jack_port_t, cstring) : int = "mac#"

fun jack_port_unset_alias(!jack_port_t, cstring) : int = "mac#"

fun jack_port_get_aliases(!jack_port_t, cPtr0(cstring)) : int = "mac#"

fun jack_port_request_monitor(!jack_port_t, int) : int = "mac#"

fun jack_port_request_monitor_by_name(!jack_client_t, cstring, int) : int = "mac#"

fun jack_port_ensure_monitor(!jack_port_t, int) : int = "mac#"

fun jack_port_monitoring_input(!jack_port_t) : int = "mac#"

fun jack_connect(!jack_client_t, cstring, cstring) : int = "mac#"

fun jack_disconnect(!jack_client_t, cstring, cstring) : int = "mac#"

fun jack_port_disconnect(!jack_client_t, !jack_port_t) : int = "mac#"

fun jack_port_name_size() : int = "mac#"

fun jack_port_type_size() : int = "mac#"

fun jack_port_type_get_buffer_size(!jack_client_t, cstring) : size_t = "mac#"

fun jack_port_set_latency(!jack_port_t, jack_nframes_t) : void = "mac#"

fun jack_port_get_latency_range(!jack_port_t, jack_latency_callback_mode_t, cPtr0(jack_latency_range_t)) : void = "mac#"

fun jack_port_set_latency_range(!jack_port_t, jack_latency_callback_mode_t, cPtr0(jack_latency_range_t)) : void = "mac#"

fun jack_recompute_total_latencies(!jack_client_t) : int = "mac#"

fun jack_port_get_latency(!jack_port_t) : jack_nframes_t = "mac#"

fun jack_port_get_total_latency(!jack_client_t, !jack_port_t) : jack_nframes_t = "mac#"

fun jack_recompute_total_latency(!jack_client_t, !jack_port_t) : int = "mac#"

fun jack_get_ports(!jack_client_t, cstring, cstring, ulint) : cPtr0(cstring) = "mac#"

fun jack_port_by_name(!jack_client_t, cstring) : jack_port_t = "mac#"

fun jack_port_by_id(!jack_client_t, jack_port_id_t) : jack_port_t = "mac#"

fun jack_frames_since_cycle_start(!jack_client_t) : jack_nframes_t = "mac#"

fun jack_frame_time(!jack_client_t) : jack_nframes_t = "mac#"

fun jack_last_frame_time(!JACK_PROCESS | !jack_client_t) : jack_nframes_t = "mac#"

fun jack_get_cycle_times(!JACK_PROCESS | !jack_client_t, &jack_nframes_t? >> jack_nframes_t, &jack_time_t? >> jack_time_t, &jack_time_t? >> jack_time_t, &float? >> float) : int = "mac#"

fun jack_frames_to_time(!jack_client_t, jack_nframes_t) : jack_time_t = "mac#"

fun jack_time_to_frames(!jack_client_t, jack_time_t) : jack_nframes_t = "mac#"

fun jack_get_time() : jack_time_t = "mac#"

fun jack_set_error_function((cstring) -> void) : void = "mac#"

fun jack_set_info_function((cstring) -> void) : void = "mac#"

fun jack_free(ptr) : void = "mac#"

end // [local]

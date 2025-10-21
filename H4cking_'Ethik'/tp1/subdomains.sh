#!/bin/bash

# Este script automatiza la enumeración de directorios
# usando gobuster para una lista de dominios y una wordlist.

# Asegúrate de que gobuster esté instalado y en tu PATH.

# -------------------- CONFIGURACIÓN --------------------
DOMAINS_FILE="domains.txt"
WORDLIST_FILE=""
OUTPUT_FILE=""

# -------------------- MANEJO DE ARGUMENTOS --------------------
while getopts "w:o:" opt; do
  case $opt in
    w)
      WORDLIST_FILE="$OPTARG"
      ;;
    o)
      OUTPUT_FILE="$OPTARG"
      ;;
    \?)
      echo "Uso: $0 -w <wordlist> -o <archivo_salida>"
      exit 1
      ;;
  esac
done

# -------------------- VALIDACIÓN --------------------
if [ -z "$WORDLIST_FILE" ]; then
    echo "Error: Se requiere una wordlist. Usa la opción -w."
    echo "Uso: $0 -w <wordlist> -o <archivo_salida>"
    exit 1
fi

if [ -z "$OUTPUT_FILE" ]; then
    echo "Error: Se requiere un archivo de salida. Usa la opción -o."
    echo "Uso: $0 -w <wordlist> -o <archivo_salida>"
    exit 1
fi

if [ ! -f "$DOMAINS_FILE" ]; then
    echo "Error: El archivo de dominios '$DOMAINS_FILE' no existe."
    exit 1
fi

if [ ! -f "$WORDLIST_FILE" ]; then
    echo "Error: El archivo de wordlist '$WORDLIST_FILE' no existe."
    exit 1
fi

if ! command -v gobuster &> /dev/null; then
    echo "Error: gobuster no está instalado o no está en el PATH."
    echo "Por favor, instálalo e inténtalo de nuevo."
    exit 1
fi

# Limpia el archivo de salida si existe, o crea uno nuevo
> "$OUTPUT_FILE"

# -------------------- EJECUCIÓN --------------------
echo "Iniciando la enumeración de directorios con gobuster..."
echo "Los resultados se guardarán en '$OUTPUT_FILE'."
echo "------------------------------------------------------"

# Leer cada línea (dominio) del archivo de dominios
while IFS= read -r domain; do
    # Eliminar espacios en blanco alrededor del dominio
    domain=$(echo "$domain" | xargs)

    if [ -z "$domain" ]; then
        continue
    fi

    # Imprimir el dominio que se está escaneando
    echo "Escaneando: $domain"

    # Construir la URL completa, asumiendo HTTP o HTTPS (se puede mejorar)
    url="$domain"

    # Ejecutar el comando gobuster y redirigir la salida al archivo
    # La opción -q (quiet) evita que gobuster imprima la barra de progreso
    gobuster dir -u "$url" -w "$WORDLIST_FILE" -t 50000 -q --status-codes-blacklist 404,403,301 >> "$OUTPUT_FILE"

    # Imprimir un separador para mayor claridad en el archivo de salida
    echo "------------------------------------------------------" >> "$OUTPUT_FILE"

done < "$DOMAINS_FILE"

echo "Enumeración de directorios completada."
echo "Resultados finales en '$OUTPUT_FILE'."

# Opcional: Mostrar el contenido del archivo de salida al final
echo
echo "----------- Contenido de '$OUTPUT_FILE' -----------"
cat "$OUTPUT_FILE"
echo "------------------------------------------------------"

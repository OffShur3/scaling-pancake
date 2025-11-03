#!/bin/bash

# --- CONFIGURACIÓN ---
SAL='2123293dsj2hu2nikhiljdsd'
HASH_OBJETIVO='b5e5346559c8256158b7b24773d4e6ad888383df8873950d2b3a26aff19b1819'
WORDLIST="$1"
# ---------------------

echo "Iniciando crackeo de hash..."

if [ ! -f "$WORDLIST" ]; then
    echo "Error: El archivo de lista de palabras '$WORDLIST' no se encontró."
    exit 1
fi

while IFS= read -r password; do
    # Primer SHA-256 de la contraseña
    hash_pass_1=$(echo -n "$password" | sha256sum | awk '{print $1}')

    # Segundo SHA-256 de (SAL + Primer Hash)
    hash_final=$(echo -n "$SAL$hash_pass_1" | openssl dgst -sha256 | awk '{print $NF}')

    # Comparación
    if [ "$hash_final" = "$HASH_OBJETIVO" ]; then
        echo "🎉 Contraseña encontrada: $password"
        exit 0
    fi
done < "$WORDLIST"

echo "Contraseña no encontrada en la lista de palabras."
exit 1

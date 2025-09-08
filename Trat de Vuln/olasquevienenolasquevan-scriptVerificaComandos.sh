echo "==============================================="
echo "👤 Usuario actual:"
whoami
id
echo "==============================================="

echo "📁 Home directory: $HOME"
echo "💻 Hostname: $(hostname)"
echo "==============================================="

echo "🔧 Comandos que puedo ejecutar con sudo (sin password):"
sudo -l 2>/dev/null
echo "==============================================="

echo "🔍 Archivos con SUID (Set-User-ID):"
find / -perm -4000 -type f 2>/dev/null
echo "==============================================="

echo "🔍 Archivos con SGID (Set-Group-ID):"
find / -perm -2000 -type f 2>/dev/null
echo "==============================================="

echo "🧵 Procesos corriendo como root:"
ps -U root -u root u 2>/dev/null
echo "==============================================="

echo "🧪 Carpetas en \$PATH:"
IFS=':' read -ra DIRS <<< "$PATH"
for dir in "${DIRS[@]}"; do
    ls -ld "$dir" 2>/dev/null
done
echo "==============================================="

echo "🧨 Binarios comunes con SUID:"
for bin in /usr/bin/find /usr/bin/nmap /usr/bin/python /usr/bin/perl /usr/bin/bash /usr/bin/vim /usr/bin/less; do
    if [ -u "$bin" ]; then
        echo "[+]: $bin tiene SUID"
    fi
done
echo "==============================================="

echo "🧻 Archivos con permisos de escritura para todos:"
find / -type f -perm -o+w -exec ls -l {} \; 2>/dev/null | head -n 20
echo "==============================================="

echo "📦 Archivos .conf y scripts modificables por este usuario:"
find / -type f \( -name "*.conf" -o -name "*.sh" -o -name "*.py" -o -name "*.pl" \) -user $(whoami) 2>/dev/null | head -n 20
echo "==============================================="

echo "🎯 Servicios sudo posibles (GTFOBins):"
for cmd in nmap vim less more nano find bash perl python tar zip awk; do
    if sudo -l 2>/dev/null | grep -q "$cmd"; then
        echo "[!] Podés escalar con $cmd — buscá en https://gtfobins.github.io/gtfobins/$cmd/"
    fi
done
echo "==============================================="

echo "🧾 Listo. Analizá bien la salida para buscar caminos de escalada 🔍"

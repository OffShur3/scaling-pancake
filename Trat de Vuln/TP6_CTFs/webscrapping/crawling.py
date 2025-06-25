import requests
import os

# Dominio base del sitio
base_url = 'https://www.diosdelared.com/retos/escuela'

# Rutas/directorios comunes que podrían tener el contenido
paths = [
    'math_exam/',
    'exam/',
    'math/',
    'secret/',
    'algo/',
    'algorithm/',
    'test/',
    'flag.txt',
    'secret.txt',
    'algorithm.js',
]

os.makedirs('scrap', exist_ok=True)

for path in paths:
    url = f"{base_url}/{path}"
    try:
        r = requests.get(url)
        if r.status_code == 200:
            filename = f"scrap/Result_{path.replace('/', '_')}.txt"
            with open(filename, 'w', encoding='utf-8') as f:
                f.write(r.text)
            print(f"[+] Encontrado contenido en {url}, guardado en {filename}")
        else:
            print(f"[-] No encontrado o error en {url} (status {r.status_code})")
    except Exception as e:
        print(f"[!] Error accediendo a {url}: {e}")

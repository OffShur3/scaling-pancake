import requests
from bs4 import BeautifulSoup
from urllib.parse import urljoin
import time
import os
import random

INPUT_FILE = "domains.txt"
CONSOLIDATED_FILE = "links.txt"

# Lista de User-Agents realistas
USER_AGENTS = [
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.107 Safari/537.36',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36',
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:89.0) Gecko/20100101 Firefox/89.0',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15',
    'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.107 Safari/537.36'
]

def get_random_headers():
    """Genera encabezados aleatorios para cada solicitud"""
    return {
        'User-Agent': random.choice(USER_AGENTS),
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.5',
        'Accept-Encoding': 'gzip, deflate',
        'Connection': 'keep-alive',
        'Upgrade-Insecure-Requests': '1',
        'Cache-Control': 'max-age=0'
    }

def extract_links(base_url):
    print(f"Buscando enlaces en {base_url}...")
    
    try:
        # Usa encabezados aleatorios y realistas
        headers = get_random_headers()
        
        # Añade timeout y permite redirecciones
        session = requests.Session()
        session.headers.update(headers)
        
        response = session.get(base_url, timeout=15, allow_redirects=True)
        response.raise_for_status()
        
        # Verifica que sea contenido HTML
        if 'text/html' not in response.headers.get('Content-Type', ''):
            print(f"La URL {base_url} no devuelve HTML (Content-Type: {response.headers.get('Content-Type')})")
            return set()
        
        soup = BeautifulSoup(response.text, 'html.parser')
        
        links = set()
        for a in soup.find_all('a'):
            href = a.get('href')
            if href:
                try:
                    absolute_url = urljoin(base_url, href)
                    # Filtra URLs no válidas o javascript:
                    if absolute_url.startswith(('http://', 'https://')):
                        links.add(absolute_url)
                        print(f" -> {absolute_url}")
                except Exception as e:
                    print(f"Error al procesar enlace {href}: {e}")
                    continue
        
        return links
        
    except requests.exceptions.HTTPError as e:
        if e.response.status_code == 403:
            print(f"Acceso prohibido (403) para {base_url}. El sitio puede estar protegido por Cloudflare/WAF.")
        elif e.response.status_code == 429:
            print(f"Demasiadas solicitudes (429) para {base_url}. Esperando antes de continuar...")
        else:
            print(f"Error HTTP {e.response.status_code} al acceder a {base_url}: {e}")
        return set()
        
    except requests.exceptions.RequestException as e:
        print(f"Error de conexión con {base_url}: {e}")
        return set()
        
    except Exception as e:
        print(f"Error inesperado con {base_url}: {e}")
        return set()

def main():
    if not os.path.exists(INPUT_FILE):
        print(f"Error: El archivo '{INPUT_FILE}' no fue encontrado. Asegúrate de que exista.")
        return

    all_unique_links = set()
    
    with open(INPUT_FILE, 'r') as f_in:
        domains = [line.strip() for line in f_in if line.strip()]
    
    print(f"Se encontraron {len(domains)} dominios para procesar.")
    
    for i, domain in enumerate(domains, 1):
        print(f"\n=============== Procesando URL {i}/{len(domains)}: {domain} ===============\n")
        links = extract_links(domain)
        all_unique_links.update(links)
        
        # Pequeña pausa aleatoria entre solicitudes para evitar bloqueos
        time.sleep(random.uniform(1, 3))

    # Escribir resultados
    with open(CONSOLIDATED_FILE, 'w', encoding='utf-8') as f_consolidated:
        f_consolidated.write("=============== Contenido total de enlaces únicos ===============\n\n")
        for link in sorted(all_unique_links):
            f_consolidated.write(f"{link}\n")
    
    print(f"\nProceso completado. Se encontraron {len(all_unique_links)} enlaces únicos.")
    print(f"Resultados guardados en '{CONSOLIDATED_FILE}'")

if __name__ == "__main__":
    main()

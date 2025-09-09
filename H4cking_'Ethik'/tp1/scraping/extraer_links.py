import requests
from bs4 import BeautifulSoup
from urllib.parse import urljoin
import os
import re

# Archivo de entrada predefinido
INPUT_FILE = "domains.txt"
# Archivo de salida consolidado
CONSOLIDATED_FILE = "links.txt"

def extract_links(base_url):
    """Función para extraer enlaces de una URL y convertirlos a absolutos."""
    print(f"Buscando enlaces en {base_url}...")
    try:
        response = requests.get(base_url, timeout=10)
        response.raise_for_status()
        soup = BeautifulSoup(response.text, 'html.parser')
        links = soup.find_all('a')
        
        extracted_data = []
        for link in links:
            link_url = link.get('href')
            if link_url:
                absolute_url = urljoin(base_url, link_url)
                extracted_data.append(f"{absolute_url}\n")
                # Imprime el link en la consola
                print(f" -> {absolute_url}")
        
        return extracted_data
    
    except requests.exceptions.RequestException as e:
        print(f"Error al acceder a la URL {base_url}: {e}\n")
        return [f"Error al acceder a la URL {base_url}: {e}\n"]
    except Exception as e:
        print(f"Ocurrió un error inesperado con la URL {base_url}: {e}\n")
        return [f"Ocurrió un error inesperado con la URL {base_url}: {e}\n"]

def main():
    """Función principal para el procesamiento sin argumentos."""
    try:
        # Verifica si el archivo de entrada existe
        if not os.path.exists(INPUT_FILE):
            print(f"Error: El archivo '{INPUT_FILE}' no fue encontrado. Asegúrate de que exista.")
            return

        with open(INPUT_FILE, 'r') as f_in:
            domains = f_in.readlines()

        # Abre el archivo consolidado en modo de escritura para empezar de cero
        with open(CONSOLIDATED_FILE, 'w') as f_consolidated:
            f_consolidated.write(f"=============== Contenido total de enlaces ===============\n\n")

            for domain in domains:
                url = "https://"+domain.strip()
                if not url:
                    continue
                
                print(f"\n=============== Procesando URL: {url} ===============\n")
                
                # Genera el nombre del archivo individual
                filename = re.sub(r'https?://(www\.)?', '', url)
                filename = re.sub(r'[^a-zA-Z0-9\.]', '_', filename)
                individual_file = f"{filename}.txt"
                
                data = extract_links(url)
                
                # Escribe en el archivo individual
                with open(individual_file, 'w') as f_individual:
                    f_individual.write(f"=============== Enlaces de {url} ===============\n\n")
                    for line in data:
                        f_individual.write(line)
                
                print(f"\nProceso completado para {url}. Resultados guardados en {individual_file} y {CONSOLIDATED_FILE}.\n")
                
                # Escribe en el archivo consolidado
                # f_consolidated.write(f"=============== Enlaces de {url} ===============\n\n")
                for line in data:
                    f_consolidated.write(line)
                f_consolidated.write("\n\n")
        
        print(f"Proceso total completado. Se crearon archivos individuales y el archivo consolidado '{CONSOLIDATED_FILE}'.")
    
    except Exception as e:
        print(f"Ocurrió un error: {e}")

if __name__ == "__main__":
    main()

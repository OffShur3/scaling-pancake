import os
import re
import requests

def nombre_archivo_desde_url(url, extension=".html"):
    # Ejemplo: https://edu.ddlr.org => edu.ddlr.org.html
    nombre = url.replace('https://', '').replace('http://', '').replace('/', '.')
    return nombre + extension

def descargar_html(url, carpeta='scrap'):
    if not os.path.exists(carpeta):
        os.makedirs(carpeta)
    nombre_archivo = nombre_archivo_desde_url(url)
    ruta = os.path.join(carpeta, nombre_archivo)
    
    print(f"Descargando {url} ...")
    try:
        r = requests.get(url)
        r.raise_for_status()
        with open(ruta, 'w', encoding='utf-8') as f:
            f.write(r.text)
        print(f"Guardado en {ruta}")
        return ruta
    except Exception as e:
        print(f"Error al descargar {url}: {e}")
        return None

def cargar_palabras_clave(archivo='palabrasClave.txt'):
    with open(archivo, 'r', encoding='utf-8') as f:
        palabras = [linea.strip() for linea in f if linea.strip()]
    return palabras

def buscar_palabras_en_archivo(ruta_html, palabras_clave, chars_antes=50, chars_despues=50):
    resultados = []
    with open(ruta_html, 'r', encoding='utf-8') as f:
        contenido = f.read().lower()
        for palabra in palabras_clave:
            palabra_lower = palabra.lower()
            for match in re.finditer(re.escape(palabra_lower), contenido):
                start = max(match.start() - chars_antes, 0)
                end = min(match.end() + chars_despues, len(contenido))
                contexto = contenido[start:end]
                resultados.append(f"Palabra: '{palabra}' | Contexto: ...{contexto}...\n")
    return resultados

def main():
    carpeta = 'scrap'
    if not os.path.exists(carpeta):
        os.makedirs(carpeta)
    
    with open('webs.txt', 'r', encoding='utf-8') as f:
        urls = [linea.strip() for linea in f if linea.strip()]
    
    palabras_clave = cargar_palabras_clave()
    
    for url in urls:
        ruta_html = descargar_html(url, carpeta)
        if ruta_html:
            resultados = buscar_palabras_en_archivo(ruta_html, palabras_clave)
            if resultados:
                nombre_resultados = nombre_archivo_desde_url(url, extension=".txt").replace(".html", "")
                ruta_resultados = os.path.join(carpeta+"/Results", f"Results_{nombre_resultados}.txt")
                with open(ruta_resultados, 'w', encoding='utf-8') as f:
                    f.writelines(resultados)
                print(f"Resultados guardados en {carpeta+'/Results'}")
            else:
                print(f"No se encontraron coincidencias en {url}")

if __name__ == "__main__":
    main()

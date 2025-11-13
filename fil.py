def filtrar_numeros_serie1(resultados, prefijos_validos, umbral_confianza_impreso=0.95):
    """
    Filtra los números de serie y los clasifica como 'IMPRESO' o 'MANUSCRITO'
    basándose en la puntuación de confianza del OCR.

    Args:
        resultados (list): Salida cruda de PaddleOCR.
        umbral_confianza_impreso (float): Umbral para considerar un texto como IMPRESO.

    Returns:
        dict: Un diccionario donde la clave es el número de serie detectado
              y el valor es su clasificación ('IMPRESO' o 'MANUSCRITO').
    """
    encontrados = {}  # Usaremos un diccionario para guardar la clasificación

    # Check if resultados is not empty and has at least one element before accessing resultados[0]
    if not resultados or not resultados[0]:
        return encontrados

    # PaddleOCR devuelve una lista de bloques, y cada bloque es una lista de detecciones.
    # Recorremos el resultado de la rotación (resultados[0])
    for block in resultados[0]:  # El resultado de predict() es [ [detecciones], ... ]
        # El formato es: [[x1, y1, x2, y2], (texto, confianza)]
        if isinstance(block, list) and len(block) == 2 and isinstance(block[1], tuple):
            txt, conf = block[1]
            t = txt.strip().upper()

            for prefijo in prefijos_validos:
                if prefijo in t:
                    inicio = t.find(prefijo)
                    numero_serie_candidato = t[inicio:]

                    # Aplicar la lógica de filtrado existente
                    if len(numero_serie_candidato) >= 6 and numero_serie_candidato.isalnum():

                        # --- CLASIFICACIÓN POR CONFIANZA ---
                        clasificacion = "IMPRESO (Pegatina)" if conf >= umbral_confianza_impreso else "MANUSCRITO"

                        # Guardamos el número de serie y su clasificación
                        encontrados[numero_serie_candidato] = clasificacion
                        break

    return encontrados

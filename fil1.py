def filtrar_numeros_serie(resultados): #backup viejo
    """
    Filtra los números de serie de los resultados del OCR.
    La lógica se basa en buscar prefijos válidos dentro de la cadena de texto
    y extraer la parte del texto que comienza con ese prefijo.

    Args:
        resultados (list): Una lista de resultados de OCR, donde cada elemento es un diccionario
                         con una clave 'rec_texts' que contiene una lista de strings.

    Returns:
        list: Una lista de strings únicos que son números de serie válidos.
    """
    encontrados = set()

    # Check if resultados is not empty and has at least one element before accessing resultados[0]
    if not resultados or not resultados[0]:
        return encontrados

    for bloque in resultados:
        for txt in bloque.get('rec_texts', []):
            t = txt.strip().upper()

            for prefijo in prefijos_validos:
                if prefijo in t:
                    inicio = t.find(prefijo)

                    numero_serie_candidato = t[inicio:]

                    if len(numero_serie_candidato) >= 6 and numero_serie_candidato.isalnum():
                        encontrados.add(numero_serie_candidato)
                        break

    return list(encontrados)

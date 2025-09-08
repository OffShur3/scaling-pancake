# # Análisis de tecnologías
# echo """whatweb diosdelared.com
# whatweb diosdelared.com:8080
# whatweb diosdelared.com:8443
# whatweb diosdelared.com:8880
# """
var="""$(whatweb diosdelared.com && \
whatweb diosdelared.com:8080  && \
whatweb diosdelared.com:8443 && \
whatweb diosdelared.com:8880)""" && informarEnd "$var"
# # 3. Análisis web básico
#
# echo """curl -I http://diosdelared.com
# curl -I http://diosdelared.com:8080
# """
curl -I http://diosdelared.com
curl -I http://diosdelared.com:8080
#
# # 1. Identificación exacta de servicios
# echo "nmap -sV -sC -p 80,443,2052,2053,2082,2083,2086,2087,2095,8080,8443,8880 diosdelared.com
# "
# nmap -sV -sC -p 80,443,2052,2053,2082,2083,2086,2087,2095,8080,8443,8880 diosdelared.com
#
# # 2. Banner grabbing de puertos misteriosos
# echo """
# for port in 2052 2053 2082 2083 2086 2087 2095; do
#     echo '=== Puerto $port ==='
#     nc -nv diosdelared.com $port -w 3
#     echo ''
# done
# """
# for port in 2052 2053 2082 2083 2086 2087 2095; do
#     echo "=== Puerto $port ==="
#     nc -nv diosdelared.com $port -w 3
#     echo ""
# done
#
#

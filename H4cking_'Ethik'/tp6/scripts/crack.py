import hashlib

salt = ''
hashx=''
wl = 'rockyou.txt'

def hash_password(password):
    pass_hash = hashlib.sha256(password.encode()).hexdigest()
    salted_hash = hashlib.sha256(salt.encode() + pass_hash.encode()).hexdigest()
    return salted_hash

def crack_hash():
    with open(wl, 'r', encoding='latin1') as file:

        for line in file:
            password = line.strip()
            if hash_password(password) == hashx:
                print(f'Contraseña encontrada: {password}')
                return password
    print('Contraseña no encontrada')
    return None

# Ejecutar el crackeo
crack_hash()

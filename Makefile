INSTALL=install -c -o root -g bin -m 555
DESTDIR=/usr/local/bin
COMMANDS=koha_batch_items_mod

.SUFFIXES: .pl

all:
	@echo "Usage: make [install|deinstall]"

.pl:
	${INSTALL} $< ${DESTDIR}/$@

install: ${COMMANDS}

deinstall:
	rm ${COMMANDS:%=${DESTDIR}/%}

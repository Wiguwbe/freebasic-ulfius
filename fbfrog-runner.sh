#!/bin/sh

set -e

FBF=${1}
OUTDIR=${2}

test -z "${FBF}" || test -z "${OUTDIR}" && { echo "missing arguments"; exit 1; }

alias fbf="${FBF} -o ${OUTDIR} -target linux-x86_64"

# get microhttpd version
MHD_VERSION=$(grep -Po1 '(?<=^#define MHD_VERSION )0x[0-9a-fA-F]+' /usr/include/microhttpd.h)

echo "MHD_VERSION = ${MHD_VERSION}"

# ulfius
fbf /opt/ulfius/include/ulfius.h \
	-include /opt/ulfius/include/ulfius.h \
	-addinclude "crt/netinet/in.bi" \
	-define MHD_VERSION ${MHD_VERSION} \
#	-removeinclude "pthread.h" \
#	-addinclude "crt/pthread.bi"

# orcania
fbf /usr/include/orcania.h -include /usr/include/orcania-cfg.h

# yder
fbf /usr/include/yder.h -include /usr/include/yder-cfg.h

# jansson, enum collides with function names
${FBF} jansson.fbfrog -o ${OUTDIR}

# microhttpd, rename includes
fbf /usr/include/microhttpd.h \
	-rename_ fd_setsize \
	-removeproc MHD_get_fdset
#	-removeinclude "unistd.h" \
#	-removeinclude "sys/time.h" \
#	-addinclude "crt/unistd.bi" \
#	-addinclude "crt/sys/time.bi" \

# opaque types
for suffix in UpgradeResponseHandle PostProcessor Response Connection Daemon
do
	sed -i "/extern \"C\"/a type MHD_${suffix} as Any" ${OUTDIR}/microhttpd.bi
done

# all cool
unalias fbf

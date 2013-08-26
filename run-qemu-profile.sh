#!/bin/sh
#
# This software is delivered under the terms of the MIT License
#
# Copyright (C) STMicroelectronics Ltd. 2013
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#

#
# Main script for run-qemu-profile utility.
#
# Dependencies:
# - QEMU with tcg oprofile plugin
#   (for instance https://github.com/cedric-vincent/QEMU),
# - objdump,
# - perl5.
#
# Usage: run-qemu-profile.sh program args...
#

set -e

[ "$DEBUG" = "" ] || set -x

error() { echo "$0: error: $1" >&2; exit 1; }

cleanup() {
    trap - EXIT INT TERM QUIT
    [ ! -f "${DUMPFILE}" ] || rm -f ${DUMPFILE}
    [ ! -f "${PROFILE}" ] || rm -f ${PROFILE}
    rm -f ${PROFILE}.*
}

# We match only samples from the main executable (first arg)
EXE=$1
[ "$EXE" != "" ] || error "missing program to execute. Usage: `basename $0` program args..."
[ -x "$EXE" ] || error "program to execute not found or not executable. Usage: `basename $0` program args..."

uname=`uname -m`
case ${uname} in
    i[3456]86) uname=i386
	;;
    arm*) uname=arm
	;;
    sh*) uname=sh4
	;;
esac

PERL=${PERL-perl}
QEMU=${QEMU-qemu-${uname}}
QEMU_ARGS="${QEMU_ARGS}"
OBJDUMP=${OBJDUMP-objdump}
DUMPFILE=`basename ${EXE}`.dump
PROFILE=oprofile.out

has_qemu=`${QEMU} -h 2>/dev/null | wc -l`
[ "$has_qemu" != 0 ] || error "QEMU not found or not executable: $QEMU. Download from https://github.com/cedric-vincent/QEMU."

has_plugin=`${QEMU} -h 2>/dev/null | grep tcg-plugin | wc -l`
[ "$has_plugin" != 0 ] || error "QEMU is not plugin enabled: $QEMU. Download from https://github.com/cedric-vincent/QEMU."

trap "cleanup" EXIT INT TERM QUIT

${OBJDUMP} -d ${EXE} >${EXE}.dump || error "can't run objdump correctly: ${OBJDUMP} -d ${EXE}"

rm -f ${PROFILE}.*
env TPI_OUTPUT=${PROFILE} ${QEMU} -singlestep -tcg-plugin oprofile ${QEMU_ARGS} ${1+"$@"} || true
mv ${PROFILE}.* ${PROFILE}

${PERL} `dirname $0`/merge-profile.pl ${PROFILE} ${DUMPFILE}


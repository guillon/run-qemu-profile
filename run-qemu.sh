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
# Simple wrapper script for running qemu on native command
#
# Usage: run-qemu.sh program args...
#

set -e

[ "$DEBUG" = "" ] || set -x

uname=`uname -m`
case ${uname} in
    i[3456]86) uname=i386
	;;
    arm*) uname=arm
	;;
    sh*) uname=sh4
	;;
esac

QEMU=${QEMU-qemu-$uname}
QEMU_ARGS="${QEMU_ARGS}"

${QEMU} ${QEMU_ARGS} ${1+"$@"}

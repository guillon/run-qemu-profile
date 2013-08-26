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
# Test Makefile for run-qemu-profile.sh
#

CC=gcc
CFLAGS=-O2 -Wall
LDFLAGS=$(CFLAGS)
LIBS=
RUN_QEMU=./run-qemu.sh
RUN_PROFILE=./run-qemu-profile.sh
INSTALL=install
PREFIX=/usr/local

EXE_loop=loop.exe
OBJS_loop=loop.o

EXES=$(EXE_loop)
OBJS=$(OBJ_loop)

.phony: all clean distclean run run-qemu run-profile install

all: $(EXES)

clean:
	rm -f *.exe *.o

distclean: clean
	rm -f *~

run: $(EXE_loop)
	./$(EXE_loop)

run-qemu: $(EXE_loop)
	$(RUN_QEMU) ./$(EXE_loop)

run-profile: $(EXE_loop)
	$(RUN_PROFILE) ./$(EXE_loop)

install:
	$(INSTALL) -d -m 755 $(PREFIX)/bin
	$(INSTALL) -m 755 run-qemu.sh $(PREFIX)/bin
	$(INSTALL) -m 755 run-qemu-profile.sh $(PREFIX)/bin
	$(INSTALL) -m 755 merge-profile.pl $(PREFIX)/bin

#
# Build Rules
#
$(EXE_loop): $(OBJS_loop)
	$(CC) -o $@ $(LDFLAGS) $(OBJS_loop) $(LIBS)

$(OBJS): %.o: %.c
	$(CC) -c -o $@ $(CFLAGS) $<

$(OBJS) $(EXES): GNUmakefile

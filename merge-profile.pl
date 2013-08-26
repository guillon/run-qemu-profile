#!/usr/bin/env perl
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
# Internal script for merging output of oprofile
# with a disassembly dump.
#
# Usage: merge-profile.pl oprofile.out program.dump
#
# The program.dump file must be generated for instance with:
#  objdump -d program.exe >program.dump
#
# The oprofile output may be generated for insance with:
#  env TPI_OUTPUT=oprofile.out qemu-<arch> -tcg-plugin oprofile program.exe args...
#

use strict;

defined($ARGV[0]) or die "missing profile file argument";
defined($ARGV[1]) or die "missing objdump file argument";

open(PROFILE, $ARGV[0]) or die "can't open profile file: $ARGV[0]: $!";
open(DUMP, $ARGV[1]) or die "can't open objdump file: $ARGV[1]: $!";

my $state = 0;
my $image;
my $symbol;
my $symbol_addr;
my %image_samples;

while(<PROFILE>) {
    if (/^vma/) {
	$state += 1;
	next;
    }
    next if $state == 0;
    if (/^(\S+) (\S+)/) {
	my @fields = split;
	($symbol_addr, $image, $symbol) = (hex("0x".$fields[0]), $fields[-2], $fields[-1]);
	$image_samples{$image} = {} if !defined($image_samples{$image});
	$image_samples{$image}->{$symbol_addr} = { 'symbol' => $symbol,
						   'samples' => [] };
	next;
    }
    if (defined($image)) {
	if (/^  (\S+) (\S+)/) {
	    my ($addr, $samples) = (hex("0x".$1), int($2));
	    my $offset = $addr - $symbol_addr;
	    # Skip too large distances
	    if ($offset <= 100000) {
		$image_samples{$image}->{$symbol_addr}->{samples}->[$offset] = $samples;
	    }
	}
    }
}
close(PROFILE);

my $state = 0;
my $dump_image;
my $dump_symaddr;
my $dump_symbol;
while(<DUMP>) {
    if ($state == 0 && /^([^:]+):\s+file format/) {
	$state = 1;
	$dump_image = $1;
	$dump_image =~ s|.*/||;
    } elsif ($state == 1 && /^(\S+) <([^>]+)>/) {
	($dump_symaddr, $dump_symbol) = (hex("0x".$1), $2);
	if (defined($image_samples{$dump_image}) &&
	    defined($image_samples{$dump_image}->{$dump_symaddr})) {
	    $state = 2;
	}
    } elsif ($state == 2 && /\s+([^:]+)[:]/) {
	my $addr = hex("0x" . $1);
	my $offset = $addr - $dump_symaddr;
	my $samples = $image_samples{$dump_image}->{$dump_symaddr}->{samples}->[$offset];
	if (defined($samples)) {
	    printf(" %10u ##%s", $samples, $_);
	} else {
	    printf("            ##%s", $_);
	}
	next;
    } elsif ($state > 0 && /^$/) {
	$state = 1;
    }
    printf("%s", $_);
}
close(DUMP);

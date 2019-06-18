# ============================================================================
# Name        : Makefile
# Author      : Rand Huso
# Version     :
# Copyright   : No copyright
# Description : Makefile for Hello MPI World in Fortran
# ============================================================================

.PHONY: all clean

all: src/PolymorphicFortran.f90
	mpif90 -O2 -g -o bin/PolymorphicFortran \
		src/PolymorphicFortran.f90

clean:
	rm -f bin/PolymorphicFortran *.mod

PATSHOMEQ="$(PATSHOME)"
PATSCONTRIBQ="$(PATSCONTRIB)"

RMF=rm -f

PATSCC=$(PATSHOMEQ)/bin/patscc

PATSFLAGS=-DATS_MEMALLOC_LIBC
CFLAGS=-O2
LFLAGS=-lm -ljack

all:: test01
test01: test01.dats ; $(PATSCC) $(PATSFLAGS) $(CFLAGS)  -o $@ $< $(LFLAGS) 
cleanall:: ; $(RMF) test01

all:: test02
test02: test02.dats ; $(PATSCC) $(PATSFLAGS) $(CFLAGS)  -o $@ $< $(LFLAGS) 
cleanall:: ; $(RMF) test02

cleanall:: ; $(RMF) *_*ats.c

clean:: cleanall

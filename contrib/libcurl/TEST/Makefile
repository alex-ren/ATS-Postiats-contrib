#
# A simple Makefile
#

######

PATSHOMEQ="$(PATSHOME)"
PATSHOMERELOCQ="$(PATSHOMERELOC)"

######

PATSCC=$(PATSHOMEQ)/bin/patscc

######

all::
regress::
cleanall::

######

all:: test00
test00: test00.dats ; \
  $(PATSCC) -I$(PATSHOMERELOCQ)/contrib -o $@  $< testlib.dats -lcurl
#
# regress:: test00 ; ./$<
#
cleanall:: ; $(RMF) test00

######

all:: test01
test01: test01.dats ; \
  $(PATSCC) -DATS_MEMALLOC_LIBC -I$(PATSHOMERELOCQ)/contrib -o $@  $< testlib.dats -lcurl
#
# regress:: test01 ; ./$<
#
cleanall:: ; $(RMF) test01

######

RMF=rm -f

######

clean:: ; $(RMF) *~
clean:: ; $(RMF) *_?ats.c
clean:: ; $(RMF) *_?ats.o

cleanall:: clean

###### end of [Makefile] ######

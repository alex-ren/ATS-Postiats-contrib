SUBDIRS := contrib document projects

all regress:
	@for i in $(SUBDIRS); do \
		$(MAKE) -C $$i $@; \
	done

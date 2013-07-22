export LD_LIBRARY_PATH := $(shell pwd)
export GI_TYPELIB_PATH := $(shell pwd)

c-source:
	valac \
		-H magento.h \
		-C \
		--vapi=Magento.vapi \
		--library=libmagento \
		--pkg gee-1.0 --pkg libsoup-2.4 --pkg gee-1.0 \
		API.vala Config.vala DBus.vala XMLRPC.vala Wrapper.vala 


libmagento.so:
	valac \
		--enable-experimental    \
		-X -fPIC -X -shared      \
		--library=libmagento    \
		--gir=Magento-0.1.gir \
		-o libmagento.so        \
		--pkg gee-1.0 --pkg libsoup-2.4 --pkg gee-1.0 \
		API.vala Config.vala DBus.vala XMLRPC.vala Wrapper.vala 

Magento-0.1.typelib: libmagento.so
	cd vala; \
	g-ir-compiler \
		--shared-library=libmagento.so \
		--output=Magento-0.1.typelib \
		Magento-0.1.gir

clean:
	rm -f *.c *.h *.vapi *.typelib *.gir *.so
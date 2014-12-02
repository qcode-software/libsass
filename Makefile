NAME=libsass
DPKG_NAME=$(NAME)-$(VERSION)
RELEASE=0
TMP_DIR=/tmp/$(NAME)
BUILD_DIR=$(TMP_DIR)/lib
MAINTAINER=hackers@qcode.co.uk
REMOTE_USER=debian.qcode.co.uk
REMOTE_HOST=debian.qcode.co.uk
REMOTE_DIR=debian.qcode.co.uk

SOURCES = \
	ast.cpp \
	base64vlq.cpp \
	bind.cpp \
	constants.cpp \
	context.cpp \
	contextualize.cpp \
	copy_c_str.cpp \
	error_handling.cpp \
	eval.cpp \
	expand.cpp \
	extend.cpp \
	file.cpp \
	functions.cpp \
	inspect.cpp \
	node.cpp \
	json.cpp \
	output_compressed.cpp \
	output_nested.cpp \
	parser.cpp \
	prelexer.cpp \
	remove_placeholders.cpp \
	sass.cpp \
	sass_util.cpp \
	sass_values.cpp \
	sass_context.cpp \
	sass_functions.cpp \
	sass_interface.cpp \
	sass2scss.cpp \
	source_map.cpp \
	to_c.cpp \
	to_string.cpp \
	units.cpp \
	utf8_string.cpp \
	util.cpp

CSOURCES = cencode.c

OBJECTS = $(SOURCES:.cpp=.o)
COBJECTS = $(CSOURCES:.c=.o)

all: build package clean

%.o: %.c
	g++ -Wall -fPIC -O2 -c -o $@ $<

%.o: %.cpp
	g++ -std=c++0x -Wall -fPIC -O2 -c -o $@ $<

%: %.o 
	g++ -std=c++0x -Wall -fPIC -O2 -o $@ $+ -fPIC

build: $(COBJECTS) $(OBJECTS)
	cd $(TMP_DIR) && mkdir -p lib
	cd $(TMP_DIR) && g++ -shared -fPIC -o lib/libsass.so $(COBJECTS) $(OBJECTS)

package: check-version
	# Copy files to pristine temporary directory
	rm -rf $(TMP_DIR)
	mkdir $(TMP_DIR)
	curl --fail -K ~/.curlrc_github -L -o v$(VERSION).tar.gz https://api.github.com/repos/qcode-software/$(NAME)/tarball/v$(VERSION)
	tar --strip-components=1 -xzvf v$(VERSION).tar.gz -C $(TMP_DIR)

	fakeroot checkinstall -D --deldoc --backup=no --install=no --pkgname=$(DPKG_NAME) --pkgversion=$(VERSION) --pkgrelease=$(RELEASE) --pkglicense="PUBLIC" -A all -y --maintainer $(MAINTAINER) --reset-uids=yes --replaces none --conflicts none make install

install: build
	cd $(TMP_DIR) && install -pm0755 lib/libsass.so /usr/local/lib/libsass.so

upload: check-version
	scp $(DPKG_NAME)_$(VERSION)-$(RELEASE)_all.deb "$(REMOTE_USER)@$(REMOTE_HOST):$(REMOTE_DIR)/debs"	
	ssh $(REMOTE_USER)@$(REMOTE_HOST) reprepro -b $(REMOTE_DIR) includedeb squeeze $(REMOTE_DIR)/debs/$(DPKG_NAME)_$(VERSION)-$(RELEASE)_all.deb
	ssh $(REMOTE_USER)@$(REMOTE_HOST) reprepro -b $(REMOTE_DIR) includedeb wheezy $(REMOTE_DIR)/debs/$(DPKG_NAME)_$(VERSION)-$(RELEASE)_all.deb

clean:
	rm -f $(DPKG_NAME)*_all.deb v$(VERSION).tar.gz

.PHONY: all 

check-version:
ifndef VERSION
    $(error VERSION is undefined. Usage make VERSION=x.x.x)
endif
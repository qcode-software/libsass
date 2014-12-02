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
	$(TMP_DIR)/ast.cpp \
	$(TMP_DIR)/base64vlq.cpp \
	$(TMP_DIR)/bind.cpp \
	$(TMP_DIR)/constants.cpp \
	$(TMP_DIR)/context.cpp \
	$(TMP_DIR)/contextualize.cpp \
	$(TMP_DIR)/copy_c_str.cpp \
	$(TMP_DIR)/error_handling.cpp \
	$(TMP_DIR)/eval.cpp \
	$(TMP_DIR)/expand.cpp \
	$(TMP_DIR)/extend.cpp \
	$(TMP_DIR)/file.cpp \
	$(TMP_DIR)/functions.cpp \
	$(TMP_DIR)/inspect.cpp \
	$(TMP_DIR)/node.cpp \
	$(TMP_DIR)/json.cpp \
	$(TMP_DIR)/output_compressed.cpp \
	$(TMP_DIR)/output_nested.cpp \
	$(TMP_DIR)/parser.cpp \
	$(TMP_DIR)/prelexer.cpp \
	$(TMP_DIR)/remove_placeholders.cpp \
	$(TMP_DIR)/sass.cpp \
	$(TMP_DIR)/sass_util.cpp \
	$(TMP_DIR)/sass_values.cpp \
	$(TMP_DIR)/sass_context.cpp \
	$(TMP_DIR)/sass_functions.cpp \
	$(TMP_DIR)/sass_interface.cpp \
	$(TMP_DIR)/sass2scss.cpp \
	$(TMP_DIR)/source_map.cpp \
	$(TMP_DIR)/to_c.cpp \
	$(TMP_DIR)/to_string.cpp \
	$(TMP_DIR)/units.cpp \
	$(TMP_DIR)/utf8_string.cpp \
	$(TMP_DIR)/util.cpp

CSOURCES = $(TMP_DIR)/cencode.c

OBJECTS = $(SOURCES:.cpp=.o)
COBJECTS = $(CSOURCES:.c=.o)

all: package upload clean

%.o: %.c
	g++ -Wall -fPIC -O2 -c -o $@ $<

%.o: %.cpp
	g++ -std=c++0x -Wall -fPIC -O2 -c -o $@ $<

%: %.o 
	g++ -std=c++0x -Wall -fPIC -O2 -o $@ $+ -fPIC

$(TMP_DIR)/lib/libsass.so: $(COBJECTS) $(OBJECTS)
	mkdir -p cd $(TMP_DIR)/lib
	g++ -shared -fPIC -o $(TMP_DIR)/lib/libsass.so $(COBJECTS) $(OBJECTS)

package: check-version
	# Copy files to pristine temporary directory
	rm -rf $(TMP_DIR)
	mkdir $(TMP_DIR)
	curl --fail -K ~/.curlrc_github -L -o v$(VERSION).tar.gz https://api.github.com/repos/qcode-software/$(NAME)/tarball/v$(VERSION)
	tar --strip-components=1 -xzvf v$(VERSION).tar.gz -C $(TMP_DIR)

	fakeroot checkinstall -D --deldoc --backup=no --install=no --pkgname=$(DPKG_NAME) --pkgversion=$(VERSION) --pkgrelease=$(RELEASE) --pkglicense="PUBLIC" -A all -y --maintainer $(MAINTAINER) --reset-uids=yes --replaces none --conflicts none make install

install: $(TMP_DIR)/lib/libsass.so
	install -pm0755 $(TMP_DIR)/lib/libsass.so /usr/local/lib/libsass.so

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
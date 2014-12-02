CC       ?= cc
CXX      ?= g++
RM       ?= rm -f
MKDIR    ?= mkdir -p
CFLAGS   = -Wall -fPIC -O2 $(EXTRA_CFLAGS)
CXXFLAGS = -std=c++0x -Wall -fPIC -O2 $(EXTRA_CXXFLAGS)
LDFLAGS  = -fPIC $(EXTRA_LDFLAGS)

ifneq (,$(findstring /cygdrive/,$(PATH)))
	UNAME := Cygwin
else
ifneq (,$(findstring WINDOWS,$(PATH)))
	UNAME := Windows
else
	UNAME := $(shell uname -s)
endif
endif

ifeq ($(UNAME),Darwin)
	CFLAGS += -stdlib=libc++
	CXXFLAGS += -stdlib=libc++
endif

ifeq (,$(PREFIX))
	ifeq (,$(TRAVIS_BUILD_DIR))
		PREFIX = /usr/local
	else
		PREFIX = $(TRAVIS_BUILD_DIR)
	endif
endif

SASS_SASSC_PATH ?= sassc
SASS_SPEC_PATH ?= sass-spec
SASS_SPEC_SPEC_DIR ?= spec
SASSC_BIN = $(SASS_SASSC_PATH)/bin/sassc
RUBY_BIN = ruby

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

DEBUG_LVL ?= NONE

NAME=libsass
DPKG_NAME=$(NAME)-$(VERSION)
RELEASE=0
TMP_DIR=/tmp/$(NAME)
MAINTAINER=hackers@qcode.co.uk
REMOTE_USER=debian.qcode.co.uk
REMOTE_HOST=debian.qcode.co.uk
REMOTE_DIR=debian.qcode.co.uk

ifneq ($(BUILD), shared)
	BUILD = static
endif

all: $(BUILD) package upload clean

debug: $(BUILD)

debug-static: LDFLAGS := -g
debug-static: CFLAGS := -g -DDEBUG -DDEBUG_LVL="$(DEBUG_LVL)" $(filter-out -O2,$(CFLAGS))
debug-static: CXXFLAGS := -g -DDEBUG -DDEBUG_LVL="$(DEBUG_LVL)" $(filter-out -O2,$(CXXFLAGS))
debug-static: static

debug-shared: LDFLAGS := -g
debug-shared: CFLAGS := -g -DDEBUG -DDEBUG_LVL="$(DEBUG_LVL)" $(filter-out -O2,$(CFLAGS))
debug-shared: CXXFLAGS := -g -DDEBUG -DDEBUG_LVL="$(DEBUG_LVL)" $(filter-out -O2,$(CXXFLAGS))
debug-shared: shared

static: lib/libsass.a
shared: lib/libsass.so

lib/libsass.a: $(COBJECTS) $(OBJECTS)
	$(MKDIR) lib
	$(AR) rvs $@ $(COBJECTS) $(OBJECTS)

lib/libsass.so: $(COBJECTS) $(OBJECTS)
	$(MKDIR) lib
	$(CXX) -shared $(LDFLAGS) -o $@ $(COBJECTS) $(OBJECTS)

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

%: %.o static
	$(CXX) $(CXXFLAGS) -o $@ $+ $(LDFLAGS)

install: install-$(BUILD)

install-static: lib/libsass.a
	$(MKDIR) $(DESTDIR)$(PREFIX)\/lib/
	install -pm0755 $< $(DESTDIR)$(PREFIX)/$<

install-shared: lib/libsass.so
	$(MKDIR) $(DESTDIR)$(PREFIX)\/lib/
	install -pm0755 $< $(DESTDIR)$(PREFIX)/$<

$(SASSC_BIN): $(BUILD)
	cd $(SASS_SASSC_PATH) && $(MAKE)

test: $(SASSC_BIN)
	$(RUBY_BIN) $(SASS_SPEC_PATH)/sass-spec.rb -c $(SASSC_BIN) -s $(LOG_FLAGS) $(SASS_SPEC_PATH)/$(SASS_SPEC_SPEC_DIR)

test_build: $(SASSC_BIN)
	$(RUBY_BIN) $(SASS_SPEC_PATH)/sass-spec.rb -c $(SASSC_BIN) -s --ignore-todo $(LOG_FLAGS) $(SASS_SPEC_PATH)/$(SASS_SPEC_SPEC_DIR)

test_issues: $(SASSC_BIN)
	$(RUBY_BIN) $(SASS_SPEC_PATH)/sass-spec.rb -c $(SASSC_BIN) $(LOG_FLAGS) $(SASS_SPEC_PATH)/spec/issues

clean:
	$(RM) $(COBJECTS) $(OBJECTS) lib/*.a lib/*.la lib/*.so $(DPKG_NAME)*_all.deb

package: check-version
	fakeroot checkinstall -D --deldoc --backup=no --install=no --pkgname=$(DPKG_NAME) --pkgversion=$(VERSION) --pkgrelease=$(RELEASE) --pkglicense="PUBLIC" -A all -y --maintainer $(MAINTAINER) --reset-uids=yes --replaces none --conflicts none make install

upload: check-version
	scp $(DPKG_NAME)_$(VERSION)-$(RELEASE)_all.deb "$(REMOTE_USER)@$(REMOTE_HOST):$(REMOTE_DIR)/debs"	
	ssh $(REMOTE_USER)@$(REMOTE_HOST) reprepro -b $(REMOTE_DIR) includedeb squeeze $(REMOTE_DIR)/debs/$(DPKG_NAME)_$(VERSION)-$(RELEASE)_all.deb
	ssh $(REMOTE_USER)@$(REMOTE_HOST) reprepro -b $(REMOTE_DIR) includedeb wheezy $(REMOTE_DIR)/debs/$(DPKG_NAME)_$(VERSION)-$(RELEASE)_all.deb

.PHONY: all debug debug-static debug-shared static shared install install-static install-shared clean check-version package upload

check-version:
ifndef VERSION
    $(error VERSION is undefined. Usage make VERSION=x.x.x)
endif
############################################################
# OPSI package Makefile (VIVALDI)
# Version: 3.0.1
# Jens Boettge <boettge@mpi-halle.mpg.de>
# 2024-03-07 11:33:34 +0100
############################################################

.PHONY: header clean mpimsp mpimsp_test o4i o4i_test dfn dfn_test all_test all_prod all help download pdf install
.DEFAULT_GOAL := help

### defaults:
DEFAULT_SPEC = spec.json
DEFAULT_ALLINC = false
DEFAULT_KEEPFILES = false

ifeq ($(ORGNAME),O4I)
	override DEFAULT_ALLINC = true
endif

### to keep the changelog inside the control set CHANGELOG_TGT to an empty string
### otherwise the given filename will be used:
CHANGELOG_TGT = changelog.txt
# CHANGELOG_TGT =

PWD = ${CURDIR}
BUILD_DIR = BUILD
DL_DIR = $(PWD)/DOWNLOAD
PACKAGE_DIR = PACKAGES
SRC_DIR = SRC

OPSI_BUILDER := $(shell which opsi-makepackage)
ifeq ($(OPSI_BUILDER),)
	override OPSI_BUILDER := $(shell which opsi-makeproductfile)
	ifeq ($(OPSI_BUILDER),)
		$(error Error: opsi-make(package|productfile) not found!)
	endif
endif

OPSI_VERSION = $(shell $(OPSI_BUILDER) -V | cut -f 1 -d " ")
$(info * OPSI_BUILDER = $(OPSI_BUILDER) $(OPSI_VERSION))
O_MAJOR = $(shell echo $(OPSI_VERSION) | cut -f1 -d.)
O_MINOR = $(shell echo $(OPSI_VERSION) | cut -f2 -d.)
O_REVNR = $(shell echo $(OPSI_VERSION) | cut -f3 -d.)
O_VERCL = $(shell echo $$(($(O_MAJOR) * 100 + $(O_MINOR))))
# $(info * VERCL = $(O_VERCL))

### more defaults, depending on OPSI version:
ifeq ($(shell test "$(O_VERCL)" -ge "403"; echo $$?),0)
    $(info * OPSI >=4.3)
	DEFAULT_ARCHIVEFORMAT = tar
	ARCHIVE_TYPES :="[tar]"
	DEFAULT_COMPRESSION = gz
	COMPRESSION_TYPES :="[gz] [gzip] [bz2] [bzip2] [zstd]"
else
    $(info * OPSI <4.3)
	DEFAULT_ARCHIVEFORMAT = cpio
	ARCHIVE_TYPES :="[cpio] [tar]"
	DEFAULT_COMPRESSION = gzip
	COMPRESSION_TYPES :="[gzip] [zstd]"
endif

MUSTACHE = ./SRC/TOOLS/mustache.32
BUILD_JSON = $(BUILD_DIR)/build.json
CONTROL_IN = $(SRC_DIR)/OPSI/control.in
CONTROL = $(BUILD_DIR)/OPSI/control
DOWNLOAD_SH_IN = ./SRC/CLIENT_DATA/product_downloader.sh.in
DOWNLOAD_SH = $(PWD)/product_downloader.sh
OPSI_FILES := control preinst postinst
FILES_IN := $(basename $(shell (cd $(SRC_DIR)/CLIENT_DATA; ls *.in 2>/dev/null)))
FILES_OPSI_IN := $(basename $(shell (cd $(SRC_DIR)/OPSI; ls *.in 2>/dev/null)))
TODAY := $(shell date +"%Y-%m-%d")
TMP_FILE := $(shell mktemp -u)

### spec file:
SPEC ?= $(DEFAULT_SPEC)
ifeq ($(shell test -f $(SPEC) && echo OK),OK)
    $(info * spec file found: $(SPEC))
else
    $(error Error: spec file NOT found: $(SPEC))
endif

SW_NAME := $(shell grep '"O_SOFTWARE"' $(SPEC)        | sed -e 's/^.*\s*:\s*\"\(.*\)\".*$$/\1/' )
SW_VER := $(shell grep '"O_SOFTWARE_VER"' $(SPEC)     | sed -e 's/^.*\s*:\s*\"\(.*\)\".*$$/\1/' )
PKG_BUILD := $(shell grep '"O_PKG_VER"' $(SPEC)       | sed -e 's/^.*\s*:\s*\"\(.*\)\".*$$/\1/' )

FILES_MASK := *.$(SW_VER).*exe
FILES_EXPECTED = 2

MD5SUM_FILE := $(SW_NAME).md5sums

### Only download packages?
# ifeq ($(MAKECMDGOALS),download)
ifneq ($(filter download all_%,$(MAKECMDGOALS)),)
	ONLY_DOWNLOAD=true
else
	ONLY_DOWNLOAD=false
endif

### build "batteries included' package?
ALLINC ?= $(DEFAULT_ALLINC)
ALLINC_SEL := "[true] [false]"
AFX := $(firstword $(ALLINC))
AFY := $(shell echo $(AFX) | tr A-Z a-z)
AFZ := $(findstring [$(AFY)],$(ALLINC_SEL))
ifeq (,$(AFZ))
	ALLINCLUSIVE := false
else
	ALLINCLUSIVE := $(AFY)
endif

ifeq ($(ALLINCLUSIVE),true)
	CUSTOMNAME := ""
else
	CUSTOMNAME := "dl"
endif

### Keep all files in files/ directory?
KEEPFILES ?= $(DEFAULT_KEEPFILES)
KEEPFILES_SEL := "[true] [false]"
KFX := $(firstword $(KEEPFILES))
override KFX := $(shell echo $(KFX) | tr A-Z a-z)
override KFX := $(findstring [$(KFX)],$(KEEPFILES_SEL))
ifeq (,$(KFX))
	override KEEPFILES := false
else
	override KEEPFILES := $(shell echo $(KFX) | tr -d '[]')
endif

### Used archive format for OPSI package
ARCHIVE_FORMAT ?= $(DEFAULT_ARCHIVEFORMAT)
AFX := $(firstword $(ARCHIVE_FORMAT))
AFY := $(shell echo $(AFX) | tr A-Z a-z)

ifeq (,$(findstring [$(AFY)],$(ARCHIVE_TYPES)))
	BUILD_FORMAT := $(DEFAULT_ARCHIVEFORMAT)
else
	BUILD_FORMAT := $(AFY)
endif

### Used compression for OPSI package
COMPRESSION ?= $(DEFAULT_COMPRESSION)
AFX := $(firstword $(COMPRESSION))
AFY := $(shell echo $(AFX) | tr A-Z a-z)

ifeq (,$(findstring [$(AFY)],$(COMPRESSION_TYPES)))
	BUILD_COMPRESSION := $(DEFAULT_COMPRESSION)
else
	BUILD_COMPRESSION := $(AFY)
endif

### Customname
ifeq ($(CUSTOMNAME),"")
	PKGNAME := ${TESTPREFIX}$(ORGPREFIX)$(SW_NAME)_${SW_VER}-$(PKG_BUILD)$(CUSTOMNAME)
else
	PKGNAME := ${TESTPREFIX}$(ORGPREFIX)$(SW_NAME)_${SW_VER}-$(PKG_BUILD)~$(CUSTOMNAME)
endif



leave_err:
	exit 1

var_test:
	@echo "=================================================================="
	@echo "* Software Name         : [$(SW_NAME)]"
	@echo "* Software Version      : [$(SW_VER)]"
	@echo "* Package Build         : [$(PKG_BUILD)]"
	@echo "* SPEC file             : [$(SPEC)]"
	@echo "* Batteries included    : [$(ALLINC)] --> [$(ALLINCLUSIVE)]"
	@echo "* Custom Name           : [$(CUSTOMNAME)]"
	@echo "* OPSI Archive Types    : [$(ARCHIVE_TYPES)]"
	@echo "* OPSI Archive Format   : [$(ARCHIVE_FORMAT)] --> $(BUILD_FORMAT)"
	@echo "* OPSI Compression Types: [$(COMPRESSION_TYPES)]"
	@echo "* OPSI Compression      : [$(COMPRESSION)] --> $(BUILD_COMPRESSION)"
	@echo "* Templates OPSI        : [$(FILES_OPSI_IN)]"
	@echo "* Templates CLIENT_DATA : [$(FILES_IN)]"
	@echo "* Files Mask            : [$(FILES_MASK)]"
	@echo "* Keep files            : [$(KEEPFILES)]"
	@echo "* Changelog target      : [$(CHANGELOG_TGT)]"
	@echo "* OPSI Builder Version  : [$(OPSI_VERSION)]"
	@echo "=================================================================="
	@echo "* Installer files in $(DL_DIR):"
	@for F in `ls -1 $(DL_DIR)/$(FILES_MASK) | sed -re 's/.*\/(.*)$$/\1/' `; do echo "    $$F"; done
	@ $(eval NUM_FILES := $(shell ls -l $(DL_DIR)/$(FILES_MASK) 2>/dev/null | wc -l))
	@echo "* $(NUM_FILES) files found"
	@echo "=================================================================="


header:
	@echo "=================================================================="
	@echo "                      Building OPSI package(s)"
	@echo "=================================================================="

fix_rights: header
	@echo "---------- setting rights for PACKAGES folder --------------------"
	chgrp -R opsiadmin $(PACKAGE_DIR)
	chmod g+rx $(PACKAGE_DIR)
	chmod g+r $(PACKAGE_DIR)/*

mpimsp: header
	@echo "---------- building MPIMSP package -------------------------------"
	@make 	TESTPREFIX=""	 			\
			ORGNAME="MPIMSP" 			\
			ORGPREFIX=""     			\
			STAGE="release"  			\
	build

mpimsp_test: header
	@echo "---------- building MPIMSP testing package -----------------------"
	@make 	TESTPREFIX="0_"	 			\
			ORGNAME="MPIMSP" 			\
			ORGPREFIX=""     			\
			STAGE="testing"  			\
	build

o4i: header
	@echo "---------- building O4I package ----------------------------------"
	@make 	TESTPREFIX=""    			\
			ORGNAME="O4I"    			\
			ORGPREFIX="o4i_" 			\
			STAGE="release"  			\
	build

o4i_test: header
	@echo "---------- building O4I testing package --------------------------"
	@make 	TESTPREFIX="test_"  		\
			ORGNAME="O4I"    			\
			ORGPREFIX="o4i_" 			\
			STAGE="testing"  			\
	build

o4i_test_0: header
	@echo "---------- building O4I testing package --------------------------"
	@make 	TESTPREFIX="0_"  			\
			ORGNAME="O4I"    			\
			ORGPREFIX="o4i_" 			\
			STAGE="testing"  			\
	build

o4i_test_noprefix: header
	@echo "---------- building O4I testing package --------------------------"
	@make 	TESTPREFIX=""    			\
			ORGNAME="O4I"    			\
			ORGPREFIX="o4i_" 			\
			STAGE="testing"  			\
	build


dfn: header
	@echo "---------- building DFN package ----------------------------------"
	@make 	TESTPREFIX=""    			\
			ORGNAME="DFN"    			\
			ORGPREFIX="dfn_" 			\
			STAGE="release"  			\
	build

dfn_test: header
	@echo "---------- building DFN testing package --------------------------"
	@make 	TESTPREFIX="test_"  		\
			ORGNAME="DFN"    			\
			ORGPREFIX="dfn_" 			\
			STAGE="testing"  			\
	build

dfn_test_0: header
	@echo "---------- building DFN testing package --------------------------"
	@make 	TESTPREFIX="0_"  			\
			ORGNAME="DFN"    			\
			ORGPREFIX="dfn_" 			\
			STAGE="testing"  			\
	build

dfn_test_noprefix: header
	@echo "---------- building DFN testing package --------------------------"
	@make 	TESTPREFIX=""    			\
			ORGNAME="DFN"    			\
			ORGPREFIX="dfn_" 			\
			STAGE="testing"  			\
	build


clean_packages: header
	@echo "---------- cleaning packages, checksums and zsync ----------------"
	@rm -f $(PACKAGE_DIR)/*.md5 $(PACKAGE_DIR)/*.opsi $(PACKAGE_DIR)/*.zsync


clean: header
	@echo "---------- cleaning  build directory -----------------------------"
	@rm -rf $(BUILD_DIR)


realclean: header clean
	@echo "---------- cleaning  download directory --------------------------"
	@rm -rf $(DL_DIR)


help: header
	@echo "Valid targets: "
	@echo "	mpimsp                - build package for mpimsp"
	@echo "	mpimsp_test           - build testing package for mpimsp"
	@echo "	o4i                   - build package for O4I"
	@echo "	o4i_test              - build testing package for O4I"
	@echo "	o4i_test_0            - build package for O4I with prefix 0_"
	@echo "	o4i_test_noprefix     - build package for O4I without testing prefix"
	@echo "	dfn                   - build 'dfn' package for O4I"
	@echo "	dfn_test              - build 'dfn' testing package for O4I"
	@echo "	dfn_test_0            - build 'dfn' testing package for O4I with prefix 0_"
	@echo "	dfn_test_noprefix     - build 'dfn' testing package for O4I without testing prefix"
	@echo "	all_prod              - build: mpimsp o4i dfn"
	@echo "	all_test              - build: mpimsp_test o4i_test dfn"
	@echo ""
	@echo "	install               - install available current packages on depot server"
	@echo "	download              - download installation archive(s) from vendor"
	@echo "	pdf                   - create PDF from readme.md (req. pandoc)"
	@echo "	fix_rights            - fix rights for package directory"
	@echo "	clean                 - delete build directory"
	@echo "	clean_packages        - delete all packages previously built"
	@echo "	realclean             - delete build directory and download directory"
	@echo ""
	@echo "Options:"
	@echo "	SPEC=<filename>                       (default: $(DEFAULT_SPEC))"
	@echo "			Use the given alternative spec file."
	@echo "	ALLINC=[true|false]                   (default: $(DEFAULT_ALLINC))"
	@echo "			Include software in OPSI package?"
	@echo "	KEEPFILES=[true|false]                (default: $(DEFAULT_KEEPFILES))"
	@echo "			Keep really all previous files from 'files' directory?"
	@echo "			If false only files matching this package version are kept."
	@if [ $(O_VERCL) -ge 403 ]; then \
	 echo "	ARCHIVE_FORMAT=[tar]                  (default: $(DEFAULT_ARCHIVEFORMAT))"; \
	 echo "	COMPRESSION=[gz|gzip|zstd|bz2|bzip2]  (default: $(DEFAULT_COMPRESSION))"; \
	else \
	 echo "	ARCHIVE_FORMAT=[cpio|tar]             (default: $(DEFAULT_ARCHIVEFORMAT))"; \
	 echo "	COMPRESSION=[gzip|zstd]               (default: $(DEFAULT_COMPRESSION))"; \
	fi
	@echo ""


pdf:
	@# requirements for ths script (under Debian/Ubuntu):
	@#    pandoc
	@#    texlive-xetex
	@#    texlive-latex-base
	@#    texlive-fonts-recommended
	@#    texlive-latex-recommended
	@if [ -f "readme.md" ]; then \
		if [ ! -e readme.pdf -o readme.pdf -ot readme.md ]; then \
			echo "* Converting readme.md to readme.pdf"; \
			cat readme.md | sed -re 's/^.*<!-- \b(START|END)\b PANDOC_PDF .*$$//' \
			              | sed -re 's/^(<!-- START GIT_MARKDOWN .*-->)/\1<!--/'  \
			              | sed -re 's/^(<!-- END GIT_MARKDOWN .*-->)/-->\1/'     \
			              > $(BUILD_DIR)/readme_tmp.md && \
			pandoc "$(BUILD_DIR)/readme_tmp.md" \
				--pdf-engine=xelatex \
				-f markdown \
				-H SRC/DOCU/readme.sty \
				-V linkcolor:blue \
				-V geometry:a4paper \
				-V geometry:margin=30mm \
				-V mainfont="DejaVu Serif" \
				-V monofont="DejaVu Sans Mono" \
				-o "readme.pdf"; \
			rm -f $(BUILD_DIR)/readme_tmp.md; \
		else \
			echo "* readme.pdf seems to be up to date"; \
		fi \
	else \
		echo "* Error: readme.md is missing!"; \
	fi


build_dirs:
	@echo "* Creating/checking directories"
	@if [ ! -d "$(BUILD_DIR)" ]; then mkdir -p "$(BUILD_DIR)"; fi
	@if [ ! -d "$(BUILD_DIR)/OPSI" ]; then mkdir -p "$(BUILD_DIR)/OPSI"; fi
	@if [ ! -d "$(BUILD_DIR)/CLIENT_DATA" ]; then mkdir -p "$(BUILD_DIR)/CLIENT_DATA"; fi
	@if [ ! -d "$(PACKAGE_DIR)" ]; then mkdir -p "$(PACKAGE_DIR)"; fi


build_md5:
	@echo "* Creating md5sum file for installation archives ($(MD5SUM_FILE))"
	if [ -f "$(BUILD_DIR)/CLIENT_DATA/$(MD5SUM_FILE)" ]; then \
		rm -f $(BUILD_DIR)/CLIENT_DATA/$(MD5SUM_FILE); \
	fi
	@grep -i "$(SW_NAME).$(SW_VER)." $(DL_DIR)/$(MD5SUM_FILE)>> $(BUILD_DIR)/CLIENT_DATA/$(MD5SUM_FILE)


copy_from_src:	build_dirs build_md5
	@echo "* Copying files"
	@cp -upL $(SRC_DIR)/CLIENT_DATA/LICENSE   $(BUILD_DIR)/CLIENT_DATA/
	@cp -upL $(SRC_DIR)/CLIENT_DATA/readme.md $(BUILD_DIR)/CLIENT_DATA/
	@cp -upr $(SRC_DIR)/CLIENT_DATA/bin       $(BUILD_DIR)/CLIENT_DATA/
	@cp -upr $(SRC_DIR)/CLIENT_DATA/*.opsiscript  $(BUILD_DIR)/CLIENT_DATA/
	@cp -upr $(SRC_DIR)/CLIENT_DATA/*.opsiinc     $(BUILD_DIR)/CLIENT_DATA/
	@cp -upr $(SRC_DIR)/CLIENT_DATA/*.opsifunc    $(BUILD_DIR)/CLIENT_DATA/

	@# if [ -f  "readme.pdf" ] ; then cp -upL readme.pdf   $(BUILD_DIR)/CLIENT_DATA/; fi
	@# if [ -f  "changelog" ]  ; then cp -upL changelog    $(BUILD_DIR)/CLIENT_DATA/changelog.txt; fi

	@$(eval NUM_FILES := $(shell ls -l $(DL_DIR)/$(FILES_MASK) 2>/dev/null | wc -l))
	@if [ "$(ALLINCLUSIVE)" = "true" ]; then \
		echo "  * building batteries included package"; \
		if [ ! -d "$(BUILD_DIR)/CLIENT_DATA/files" ]; then \
			echo "    * creating directory $(BUILD_DIR)/CLIENT_DATA/files"; \
			mkdir -p "$(BUILD_DIR)/CLIENT_DATA/files"; \
		else \
			echo "    * cleanup directory"; \
			rm -f $(BUILD_DIR)/CLIENT_DATA/files/*; \
		fi; \
		echo "    * including install packages"; \
		echo "      * files found   : $(NUM_FILES)"; \
		echo "      * files expected: $(FILES_EXPECTED)"; \
		[ "$(NUM_FILES)" -lt "$(FILES_EXPECTED)" ] && exit 1; \
		for F in `ls $(DL_DIR)/$(FILES_MASK)`; do echo "      + $$F"; ln $$F $(BUILD_DIR)/CLIENT_DATA/files/; done; \
		ls -l $(BUILD_DIR)/CLIENT_DATA/files/ ;\
	else \
		echo "    * removing $(BUILD_DIR)/CLIENT_DATA/files"; \
		rm -rf $(BUILD_DIR)/CLIENT_DATA/files ; \
	fi
	@if [ -d "$(SRC_DIR)/CLIENT_DATA/custom" ]; then  cp -upr $(SRC_DIR)/CLIENT_DATA/custom     $(BUILD_DIR)/CLIENT_DATA/ ; fi
	@if [ -d "$(SRC_DIR)/CLIENT_DATA/files" ] ; then  cp -upr $(SRC_DIR)/CLIENT_DATA/files      $(BUILD_DIR)/CLIENT_DATA/ ; fi
	@if [ -d "$(SRC_DIR)/CLIENT_DATA/images" ]; then  \
		mkdir -p "$(BUILD_DIR)/CLIENT_DATA/images"; \
		cp -up $(SRC_DIR)/CLIENT_DATA/images/*.png  $(BUILD_DIR)/CLIENT_DATA/images/; \
	fi
	@if [ -f  "$(SRC_DIR)/OPSI/control" ];  then cp -up $(SRC_DIR)/OPSI/control   $(BUILD_DIR)/OPSI/; fi
	@if [ -f  "$(SRC_DIR)/OPSI/preinst" ];  then cp -up $(SRC_DIR)/OPSI/preinst   $(BUILD_DIR)/OPSI/; fi
	@if [ -f  "$(SRC_DIR)/OPSI/postinst" ]; then cp -up $(SRC_DIR)/OPSI/postinst  $(BUILD_DIR)/OPSI/; fi


build_json:
	@if [ ! -f "$(SPEC)" ]; then echo "*Error* spec file not found: \"$(SPEC)\""; exit 1; fi
	@if [ ! -d "$(BUILD_DIR)" ]; then mkdir -p "$(BUILD_DIR)"; fi
	@$(if $(filter $(STAGE),testing), $(eval TESTING :="true"), $(eval TESTING := "false"))
	@echo "* Creating $(BUILD_JSON)"
	@rm -f $(BUILD_JSON)
	@echo "{\n\
              \"M_TODAY\"      : \"$(TODAY)\",\n\
              \"M_STAGE\"      : \"$(STAGE)\",\n\
              \"M_ORGNAME\"    : \"$(ORGNAME)\",\n\
              \"M_ORGPREFIX\"  : \"$(ORGPREFIX)\",\n\
              \"M_TESTPREFIX\" : \"$(TESTPREFIX)\",\n\
              \"M_ALLINC\"     : \"$(ALLINCLUSIVE)\",\n\
              \"M_KEEPFILES\"  : \"$(KEEPFILES)\",\n\
              \"M_TESTING\"    : \"$(TESTING)\"\n}"      > $(TMP_FILE)
	@cat  $(TMP_FILE)
	@$(MUSTACHE) $(TMP_FILE) $(SPEC)	 > $(BUILD_JSON)
	@rm -f $(TMP_FILE)


download: build_json
	@echo "[DBG] Vars: [ALLINC=$(ALLINCLUSIVE)]  [ONLY_DOWNLOAD=$(ONLY_DOWNLOAD)]"
	@$(eval NUM_FOUND := $(shell ls -l $(DL_DIR)/$(FILES_MASK) 2>/dev/null | wc -l))
	@echo "[DBG] $(SW_NAME) installer packages found: $(NUM_FOUND), expected: $(FILES_EXPECTED)"
	@if [ "$(ALLINCLUSIVE)" = "true" -o  $(ONLY_DOWNLOAD) = "true" -o $(NUM_FOUND) -ne $(FILES_EXPECTED) ]; then \
		rm -f $(DOWNLOAD_SH) ;\
		$(MUSTACHE) $(BUILD_JSON) $(DOWNLOAD_SH_IN) > $(DOWNLOAD_SH) ;\
		chmod +x $(DOWNLOAD_SH) ;\
		if [ ! -d "$(DL_DIR)" ]; then mkdir -p "$(DL_DIR)"; fi ;\
		DEST_DIR=$(DL_DIR) $(DOWNLOAD_SH) ;\
	fi


build: download pdf clean copy_from_src
	@make build_json

	for F in $(FILES_OPSI_IN); do \
		echo "* Creating OPSI/$$F"; \
		rm -f $(BUILD_DIR)/OPSI/$$F; \
		$(MUSTACHE) $(BUILD_JSON) $(SRC_DIR)/OPSI/$$F.in > $(BUILD_DIR)/OPSI/$$F; \
	done

	for E in readme.txt readme.md readme.pdf changelog.txt changelog.md changelog.pdf; do \
		if [ -e $$E ]; then \
			echo "Copying additional file: $$E"; \
			cp -fupL $$E $(BUILD_DIR)/CLIENT_DATA/; \
			cp -fupL $$E $(BUILD_DIR)/OPSI/; \
		fi; \
	done

	if [ -e $(BUILD_DIR)/OPSI/control -a -e changelog ]; then \
		if [ -n "$(CHANGELOG_TGT)" ]; then \
			echo "* Using separate CHANGELOG file."; \
			echo "The logs were moved to $(CHANGELOG_TGT)" >> $(BUILD_DIR)/OPSI/control; \
			cp -f changelog $(BUILD_DIR)/OPSI/$(CHANGELOG_TGT); \
			cp -f changelog $(BUILD_DIR)/CLIENT_DATA/$(CHANGELOG_TGT); \
		else \
			echo "* Including changelogs in CONTROL file."; \
			cat changelog >> $(BUILD_DIR)/OPSI/control; \
		fi; \
	fi

	for F in $(FILES_IN); do \
		echo "* Creating CLIENT_DATA/$$F"; \
		rm -f $(BUILD_DIR)/CLIENT_DATA/$$F; \
		${MUSTACHE} $(BUILD_JSON) $(SRC_DIR)/CLIENT_DATA/$$F.in > $(BUILD_DIR)/CLIENT_DATA/$$F; \
	done
	@if [ "$(ALLINCLUSIVE)" = "true" ]; then \
		rm -f $(BUILD_DIR)/CLIENT_DATA/product_downloader.sh; \
	fi
	find $(BUILD_DIR)/CLIENT_DATA -type f -name "*.sh" -exec chmod +x {} \;
	@#chmod +x $(BUILD_DIR)/CLIENT_DATA/*.sh; \

	@echo "* OPSI Archive Format: $(BUILD_FORMAT)"
	@echo "* Building OPSI package"
	if [ -z $(CUSTOMNAME) ]; then \
		cd "$(CURDIR)/$(PACKAGE_DIR)" && $(OPSI_BUILDER) -F $(BUILD_FORMAT) -k -m $(CURDIR)/$(BUILD_DIR); \
	else \
		cd $(CURDIR)/$(BUILD_DIR) && \
		for D in OPSI CLIENT_DATA SERVER_DATA; do \
			if [ -d "$$D" ] ; then mv $$D $$D.$(CUSTOMNAME); fi; \
		done && \
		cd "$(CURDIR)/$(PACKAGE_DIR)" && $(OPSI_BUILDER) -F $(BUILD_FORMAT) -k -m $(CURDIR)/$(BUILD_DIR) -c $(CUSTOMNAME); \
	fi; \
	cd $(CURDIR)
	@echo "======================================================================"
	@echo "Package built: $(PACKAGE_DIR)/$(PKGNAME).opsi"
	@echo "======================================================================"


all_test:  header download mpimsp_test o4i_test dfn_test dfn_test_0

all_prod:  header download mpimsp o4i dfn

all: header download mpimsp o4i dfn

install:
	@$(eval PACKAGES_FOUND := $(shell ls -1 $(PACKAGE_DIR)/*.opsi | grep -E "$(SW_NAME)_$(SW_VER)-$(PKG_BUILD)(~dl){0,1}.opsi$$"))
	@$(eval PKG_NUM := $(shell echo $(PACKAGES_FOUND) | wc -w))
	@#echo "[$(PACKAGES_FOUND)]"
	@echo "Number of installable packages found: $(PKG_NUM)"
	@if [ $(PKG_NUM) -gt 0 ]; then \
		for F in $(PACKAGES_FOUND); do \
			echo -n "* Installing: $$F" ;\
			opsi-package-manager -q -p package -i $$F ;\
			echo "\t[$$?]" ;\
		done ;\
	fi

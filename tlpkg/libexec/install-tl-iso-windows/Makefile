### -*-Makefile-*- to build install-tl-iso-windows.exe
##
## Copyright (C) 2026 Vincent Goulet
##
## This file is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published
## by the Free Software Foundation, either version 2 of the License,
## or (at your option) any later version.
## 
## 'make innosetup' builds the InnoSetup script from the '.in' file.
##
## 'make mirrors' builds a .csv version of the CTAN mirror list
## (automatically run by 'make innosetup' as a dependency).
##
## 'make exe' builds the installer with InnoSetup.
##
## 'make all' is equivalent to 'make innosetup exe'

## Variables to set
TLVERSION = 2026

## Files
INNOSCRIPT = install-tl-iso-windows.iss
LAUNCHER = start-installer.ps1
MIRRORLIST = ctan-mirrors.csv

## Toolset
INNOSETUP = c:/progra~1/innose~1/iscc.exe
RM = rm -r

all: innoscript exe

${MIRRORLIST}: mirrors

${INNOSCRIPT}: innoscript

.PHONY: mirrors
mirrors:
	@printf "%s\n" "----- Building the CTAN mirrors list..."
	curl -L "https://mirror.ctan.org/CTAN.sites" 2>/dev/null | \
	awk '/^ +[a-z](.[a-z]+)+ \(.*\) *$$/ { \
	         split($$0, a, "[()]"); \
	         gsub(/^[ \t]+|[ \t]+$$/, "", a[1]); \
	         gsub(/^[ \t]+|[ \t]+$$/, "", a[2]); \
	         if (a[2] ~ Netherlands) sub("The ", "", a[2]); \
	         do { getline url } while (url !~ /https:\/\//); \
	         sub(/^[ \t]*URL:[ \t]+|[ \t]+$$/, "", url); \
	         print a[2] "," a[1] "," url \
	     }' | LC_ALL=C sort > ${MIRRORLIST}

.PHONY: innoscript
innoscript: ${MIRRORLIST}
	@printf "%s\n" "----- Building the Inno script..."
	awk 'BEGIN { FS = "," } \
	     /@version@/ { sub("@version@", "${TLVERSION}") } \
	     /@innoscript@/ { sub("@innoscript@", "${INNOSCRIPT:.iss=}") } \
	     /@launcher@/ { sub("@launcher@", "${LAUNCHER}") } \
	     { \
	         print; \
	         if (/MirrorPage\.Add/) { \
	             while (getline < "${MIRRORLIST}") \
	                 print "  MirrorPage.Add(\047" $$1 " (" $$2 ")\047);"; \
	             close("ctan-mirrors.csv") \
	         } \
	         else if (/0: Url :=/) { \
	             print; \
	             while (getline < "${MIRRORLIST}") \
	                 print "      " ++i ": Url := \047" $$3 "\047;" \
	         } \
	     }' ${INNOSCRIPT:.iss=.in} > ${INNOSCRIPT}
	@printf "\n%s\n" "done"

.PHONY: exe
exe: ${INNOSCRIPT}
	@printf "%s\n" "----- Building the setup wizard..."
	cmd //c "${INNOSETUP} ${INNOSCRIPT}"
	@printf "\n%s\n" "done"

.PHONY: clean
clean:
	${RM} ${INNOSCRIPT} ${MIRRORLIST}

### -*-Makefile-*- to build TeX Live ISO Installer Launcher
##
## Copyright (C) 2026 Vincent Goulet
##
## TeX Live ISO Installer Launcher is free software; you can
## redistribute it and/or modify it under the terms of the GNU General
## Public License as published by the Free Software Foundation; either
## version 3, or (at your option) any later version.
##
## Author: Vincent Goulet
##
## This file is part of TeX Live ISO Installer Launcher
## https://gitlab.com/vigou3/texlive-iso-installer-launcher

## ISO Installer Launcher and TeX Live versions
VERSION = 0.1
TLVERSION = 2026

## Files
INNOSCRIPT = install-tl-windows-iso.iss
LAUNCHER = start-installer.ps1
MIRRORLIST = ctan-mirrors.csv
NEWS = NEWS

## CTAN mirror and URL to ISO file
CTANURL = https://ctan.mirror.globo.tech
ISOURL = ${CTANURL}/systems/texlive/Images/${ISOFILE}

## Toolset
INNOSETUP = c:/progra~1/innose~1/iscc.exe
CP = cp -p
RM = rm -r

## GitLab repository stuff and authentication
REPOSURL := https://gitlab.com/vigou3/texlive-iso-installer-launcher
REPOSNAME := $(shell basename ${REPOSURL})
APIURL := https://gitlab.com/api/v4/projects/vigou3%2F${REPOSNAME}
OAUTHTOKEN := $(shell cat ~/.gitlab/token)

## Automatic variable
TAGNAME := v${VERSION}

all: innoscript exe

release: check-status create-release upload create-link

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
	     }' | sort > ${MIRRORLIST}

.PHONY: innoscript
innoscript: ${MIRRORLIST}
	@printf "%s\n" "----- Building the Inno script..."
	awk 'BEGIN { FS = "," } \
	     { gsub("@version@", ${TLVERSION}); print } \
	     /MirrorPage\.Add/ { \
	         while (getline < "ctan-mirrors.csv") \
	             print "  MirrorPage.Add(\047" $$1 " (" $$2 ")\047);"; \
	         close("ctan-mirrors.csv") \
	     } \
	     /0: Url :=/ { \
	         while (getline < "ctan-mirrors.csv") \
	             print "      " ++i ": Url := \047" $$3 "\047;" \
	     }' ${INNOSCRIPT:.iss=.in} > ${INNOSCRIPT}
	@printf "\n%s\n" "done"

.PHONY: exe
exe: ${INNOSCRIPT}
	@printf "%s\n" "----- Building the setup wizard..."
	cmd //c "${INNOSETUP} ${INNOSCRIPT}"
	@printf "\n%s\n" "done"

.PHONY: get-texlive
get-texlive:
	@printf "%s\n" "----- Fetching TeX Live ISO..."
	if [ -f ${ISOFILE} ]; then ${RM} ${ISOFILE}; fi
	curl -OfL --retry 2 "${ISOURL}"
	@printf "\n%s\n" "done"

.PHONY: check-status
check-status:
	@{ \
	    printf "%s" "----- Checking status of working directory... "; \
	    branch=$$(git branch --list | grep ^* | cut -d " " -f 2-); \
	    if [ "$${branch}" != "master"  ] && [ "$${branch}" != "main" ]; \
	    then \
	        printf "\n%s\n" "not on branch master or main"; exit 2; \
	    fi; \
	    if [ -n "$$(git status --porcelain | grep -v '^??')" ]; \
	    then \
	        printf "\n%s\n" "uncommitted changes in repository; not creating release"; exit 2; \
	    fi; \
	    if [ -n "$$(git log origin/master..HEAD | head -n1)" ]; \
	    then \
	        printf "\n%s\n" "unpushed commits in repository; pushing to origin"; \
	        git push; \
	    else \
	        printf "%s\n" "ok"; \
	    fi; \
	}

.PHONY: create-release
create-release:
	@{ \
	    printf "%s" "----- Checking if a release already exists... "; \
	    http_code=$$(curl -I ${APIURL}/releases/${TAGNAME} 2>/dev/null \
	                     | head -n1 | cut -d " " -f2) ; \
	    if [ "$${http_code}" = "200" ]; \
	    then \
	        printf "%s\n" "yes"; \
	        printf "%s\n" "using the existing release"; \
	    else \
	        printf "%s\n" "no"; \
	        printf "%s" "Creating release on GitLab... "; \
	        name=$$(awk '/^# / { sub(/# +VERSION +/, "", $$0); print $$0; exit }' ${NEWS}); \
	        desc=$$(awk ' \
	                      /^$$/ { next } \
	                      (state == 0) && /^# / { state = 1; next } \
	                      (state == 1) && /^# / { exit } \
	                      (state == 1) { print } \
	                    ' ${NEWS}); \
	        curl --request POST \
	             --header "PRIVATE-TOKEN: ${OAUTHTOKEN}" \
	             --output /dev/null --silent \
	             "${APIURL}/repository/tags?tag_name=${TAGNAME}&ref=master" && \
	        curl --request POST \
	             --header "PRIVATE-TOKEN: ${OAUTHTOKEN}" \
	             --data tag_name="${TAGNAME}" \
	             --data name="TeX Live ISO Installer Launcher $${name}" \
	             --data description="$${desc}" \
	             --output /dev/null --silent \
	             ${APIURL}/releases; \
	        printf "%s\n" "done"; \
	    fi; \
	}

.PHONY: upload
upload:
	@printf "%s\n" "----- Uploading package to registry..."
	curl --upload-file "${INNOSCRIPT:iss=.exe}" \
	     --header "PRIVATE-TOKEN: ${OAUTHTOKEN}" \
	     --silent \
	     "${APIURL}/packages/generic/TeX-Live-ISO-Installer-Launcher/${VERSION}/${INNOSCRIPT:iss=.exe}"

.PHONY: create-link
create-link: create-release
	@printf "%s\n" "----- Adding package link to the release... "; \
	$(eval pkg_id=$(shell curl --header "PRIVATE-TOKEN: ${OAUTHTOKEN}" \
	                           --silent \
	                           "${APIURL}/packages" \
	                      | grep -o -E '\{[^{]*"version":"${VERSION}"[^}]*}' \
	                      | grep -o '"id":[0-9]*' | cut -d: -f 2))
	$(eval file_id=$(shell curl --header "PRIVATE-TOKEN: ${OAUTHTOKEN}" \
	                            --silent \
	                            "${APIURL}/packages/${pkg_id}/package_files" \
	                       | grep -o -E '\{[^{]*"file_name":"${INNOSCRIPT:.iss=.exe}"[^}]*}' \
	                       | grep -o '"id":[0-9]*' | cut -d: -f 2))
	@printf "%s: %s\n" "package file id" "${file_id}"
	curl --request POST \
	     --header "PRIVATE-TOKEN: ${OAUTHTOKEN}" \
	     --data name="${INNOSCRIPT:.iss=.exe}" \
	     --data url="${REPOSURL:/=}/-/package_files/${file_id}/download" \
	     --data link_type="package" \
	     --output /dev/null --silent \
	     "${APIURL}/releases/${TAGNAME}/assets/links"

.PHONY: clean
clean:
	${RM} ${ISOFILE} ${INNOSCRIPT}

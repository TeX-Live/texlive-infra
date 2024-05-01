# $Id$
# Public domain.

test_tlmgr_html = /tmp/tlmgr.html
htmldir = /home/httpd/html/texlive/doc

test-tlmgr-html:
	pod2html --cachedir=/tmp tlmgr.pl >$(test_tlmgr_html)
	diff $(htmldir)/tlmgr.html $(test_tlmgr_html)
	
install-tlmgr-doc:
	mv $(test_tlmgr_html) $(htmldir)/tlmgr.html

# testing.
uhelp:
	./updmap.pl --help
fhelp:
	./fmtutil.pl --help
test-mktexfmt:
	./mktexfmt -n ptex.fmt
	rm -rf $(HOME)/.texlive2021/texmf-var/web2c/ptex/

# remake fmtutil/updmap doc from --help; see Master/tlpkg/doc/releng.txt.
# assume $W is a TL build tree.
INSTALL_DATA = cp -p
man2html = groff -mandoc -Thtml
#
man1 = ../../doc/man/man1
#
install-updmap-doc:
	$(MAKE) -C $(W)/texk/texlive/tl_support xupdmap.1
	$(INSTALL_DATA) /tmp/xupdmap.1 $(man1)/updmap.1
	$(man2html) $(man1)/updmap.1 >$(htmldir)/updmap.html
	$(MAKE) -C $(man1)/..

install-fmtutil-doc:
	$(MAKE) -C $(W)/texk/texlive/tl_support xfmtutil.1
	$(INSTALL_DATA) /tmp/xfmtutil.1 $(man1)/fmtutil.1
	$(man2html) $(man1)/fmtutil.1 >$(htmldir)/fmtutil.html
#	$(MAKE) -C $(man1)/..

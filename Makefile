
all:

clean:
	rm -rf build *.egg-info */__pycache__ tests/*.pyc
	rm -rf debian/python-* debian/files debian/*.log
	rm -rf debian/*.substvars debian/*.debhelper debian/*-stamp
	rm -rf .pybuild MANIFEST

deb:
	debuild -us -uc -b

xclean: clean
	rm -rf .tox dist

VERSION = $(shell python3 setup.py --version)
RXVERSION = $(shell python3 setup.py --version | sed 's/\./[.]/g')
TAG = v$(VERSION)

checkver:
	@echo "Checking version"
	@grep -q '## Skytools $(RXVERSION)\b' NEWS.md \
	|| { echo "Version '$(VERSION)' not in NEWS.md"; exit 1; }
	@head debian/changelog | grep -q '[(]$(RXVERSION)-' debian/changelog \
	|| { echo "Version '$(VERSION)' not in debian/changelog"; exit 1; }
	@echo "Checking git repo"
	@git diff --stat --exit-code || { echo "ERROR: Unclean repo"; exit 1; }

release: checkver
	git tag $(TAG)
	git push github $(TAG):$(TAG)

TGZ = dist/skytools-$(VERSION).tar.gz
URL = https://github.com/pgq/python-skytools/releases/download/v$(VERSION)/skytools-$(VERSION).tar.gz

upload:
	mkdir -p dist && rm -f dist/*
	cd dist && wget -q $(URL)
	tar tvf $(TGZ)
	twine upload dist/*.gz


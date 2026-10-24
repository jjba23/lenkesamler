#
# spec file for package lenkesamler
#
# Copyright (c) 2026 SUSE LLC and contributors
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/
#

# Scheme sources plus a bash launcher: there is no compiled binary to
# debug, so the empty -debugsource package is skipped.
%global debug_package %{nil}

Name:           lenkesamler
Version:        0.0.5
Release:        0
Summary:        Bookmark manager, sync tool and archiver in Guile Scheme
License:        AGPL-3.0-or-later
URL:            https://codeberg.org/jjba23/lenkesamler
Source0:        %{name}-%{version}.tar.gz
BuildRequires:  pkgconfig(guile-3.0)
BuildRequires:  guile-json
BuildRequires:  guile-lib
BuildRequires:  veritas
Requires:       guile
Requires:       bash
Requires:       coreutils
Requires:       guile-json
Requires:       guile-lib

# NOTE: guile-lib is not packaged in openSUSE yet.  Build it first
# (from a devel project if needed) before this package.
# veritas is produced by the same packaging batch; build it first.

%description
Lenkesamler keeps bookmarks in one Scheme file and writes them out in the
formats other tools read: the file a browser imports, Markdown, Org, CSV,
JSON, XBEL or a plain terminal listing. It can check the links it holds and
import an existing bookmark file.

%prep
%autosetup -n %{name}-%{version}

# The launcher is a bash script; point it at the interpreter path
# openSUSE packages are expected to use instead of /usr/bin/env.
sed -i '1s|^#!%{_bindir}/env \(.*\)$|#!%{_bindir}/\1|' scripts/lenkesamler

%build
# Nothing to build: the program is Scheme sources plus a launcher, and
# the sources are byte-compiled during %install so that they land in
# the interpreter's compiled-module directory.

%install
# Both directories are asked of Guile's pkg-config file rather than
# assumed, so the modules land where this distribution's Guile looks
# for them.
SITE_DIR="%{buildroot}$(pkg-config --variable=sitedir guile-3.0)"
CCACHE_DIR="%{buildroot}$(pkg-config --variable=siteccachedir guile-3.0)"

mkdir -p "$SITE_DIR/lenkesamler" "$CCACHE_DIR/lenkesamler"
cp -r src/lenkesamler/. "$SITE_DIR/lenkesamler/"

# Byte-compile every module so that loading it does not compile it
# again on first use.
find "$SITE_DIR/lenkesamler" -name '*.scm' | while read -r scm_file; do
  rel_path="${scm_file#$SITE_DIR/}"
  go_file="$CCACHE_DIR/${rel_path%.scm}.go"
  mkdir -p "$(dirname "$go_file")"
  guild compile -L "$SITE_DIR" -o "$go_file" "$scm_file"
done

install -D -m 0755 scripts/lenkesamler %{buildroot}%{_bindir}/lenkesamler

# Upstream reads resources and the log helper from the generic
# share/resources and share/scripts; several of these packages
# would clash there, so both move under share/lenkesamler/.
sed -i 's|share/resources|share/lenkesamler/resources|g; s|share/scripts|share/lenkesamler/scripts|g' %{buildroot}%{_bindir}/lenkesamler

install -d "%{buildroot}%{_datadir}/lenkesamler/resources"
cp -r resources/. "%{buildroot}%{_datadir}/lenkesamler/resources/"
install -D -m 0644 scripts/log.bash "%{buildroot}%{_datadir}/lenkesamler/scripts/log.bash"

%check
mkdir -p reports/spec
VERITAS_TEST_TYPE=unit VERITAS_RUN_BENCHMARKS=false guile -L ./src -L ./test -c '((@ (veritas runner) run-tests))'

%files
%license COPYING
%doc README.org NEWS.org
%{_bindir}/lenkesamler
%dir %{_datadir}/guile
%dir %{_datadir}/guile/site
%dir %{_datadir}/guile/site/3.0
%{_datadir}/guile/site/3.0/lenkesamler
%dir %{_libdir}/guile
%dir %{_libdir}/guile/3.0
%dir %{_libdir}/guile/3.0/site-ccache
%{_libdir}/guile/3.0/site-ccache/lenkesamler
%dir %{_datadir}/lenkesamler
%{_datadir}/lenkesamler/resources
%dir %{_datadir}/lenkesamler/scripts
%{_datadir}/lenkesamler/scripts/log.bash

%changelog

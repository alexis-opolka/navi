### This is the specfile for the nightly version of navi.
### As its name suggests, it is intended to be built in a recurent manner
### with the goal of making tests easier on Fedora.

%global _navi_description An interactive cheatsheet tool for the command-line.
%global _navi_license Apache-2.0
%global _navi_release_type rc1
%global _navi_source_package_name navi

### --------------------------------------------------------------------------------------------------
###                                         Package metadata
### --------------------------------------------------------------------------------------------------



Name:           navi
Version:        2.25.0
Release:        2.25.0%{?dist}
Summary:        %{_navi_description}
License:        %{_navi_license}

URL:            https://github.com/denisidoro/navi
Source:         https://github.com/alexis-opolka/navi/archive/refs/tags/v%{version}-%{_navi_release_type}.tar.gz

BuildRequires:  cargo-rpm-macros >= 24
BuildRequires: rust-srpm-macros
Requires:       fzf

### --------------------------------------------------------------------------------------------------
###                                     Package steps / informations
### --------------------------------------------------------------------------------------------------

%generate_buildrequires
%cargo_generate_buildrequires

%description
%{_navi_description}

%prep
%autosetup -n %{_navi_source_package_name}-%{version}-%{_navi_release_type} -p1
#/usr/lib/rpm/rpmuncompress -x /builddir/build/SOURCES/v%{version}-%{_navi_release_type}.tar.gz
#mv %{_navi_source_package_name}-%{version}-%{_navi_release_type}/* ./
%cargo_prep

%build
%cargo_build

%install
%cargo_install

%files -n %{name}
%{_bindir}/navi-nightly

%doc docs/README ChangeLog

%changelog
%autochangelog

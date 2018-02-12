#!/bin/bash
# Tested on CentOS 7
# This script contains versions specific to the moment in time it was created
# and is intended to be mainly used as an example of what the build steps might
# look like. The patch for the nginx spec file has the version of the auth module
# hard coded to v1.0.0

set -euxo pipefail

# Update everything to current.
sudo yum update -y

# Install necessary builddeps.
sudo yum install git wget pcre-devel zlib-devel libcurl-devel jansson-devel openssl-devel redhat-rpm-config rpm-build gperftools-devel GeoIP-devel gd-devel perl-devel libxslt-devel perl-ExtUtils-Embed yum-utils -y
sudo yum groupinstall "Development Tools" -y

# Prepare local rpm build env.
mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
echo '%_topdir %(echo $HOME)/rpmbuild' > ~/.rpmmacros

# This spec file for libxjwt has been tested on CentOS 6, CentOS 7 and AWS-Linux 1.
wget https://raw.githubusercontent.com/ScaleFT/libxjwt/969f1390f555a85c25352361aaa1e174240aabe7/dist/rpm/libxjwt.spec

# Download the 1.0.2 source and build the libxjwt rpm using the spec file.
rpmbuild --undefine=_disable_source_fetch -bb ./libxjwt.spec

# Install the rpms we just built, we'll need them to build the module.
sudo rpm -i rpmbuild/RPMS/x86_64/libxjwt-1.0.2-1.el7.centos.x86_64.rpm rpmbuild/RPMS/x86_64/libxjwt-devel-1.0.2-1.el7.centos.x86_64.rpm

# Grab the nginx source rpm and extract it, so we can build our dynamic module against it's source.
yumdownloader --source nginx
rpm -ivh ./nginx-1.12.2-1.el7.src.rpm

# Grab the CentOS 7 specific patch for the stock nginx.spec file from the nginx rpm
wget https://raw.githubusercontent.com/ScaleFT/nginx_auth_accessfabric/ba41ac21ca4de1449dc698958f2cc7d76cd2c0a9/dist/rpm/centos7/nginx.spec.patch

# Apply the patch to the spec file
cd ~/rpmbuild/SPECS/
patch -p0 < ~/nginx.spec.patch

# Download the source for 1.0.0 of our module and build a rpm using the patched spec.
rpmbuild --undefine=_disable_source_fetch -ba nginx.spec

# Install the stock nginx rpm and the access fabric module we just built.
sudo yum install nginx -y
sudo rpm -i ~/rpmbuild/RPMS/x86_64/nginx-mod-http-auth-accessfabric-1.12.2-1.el7.centos.x86_64.rpm

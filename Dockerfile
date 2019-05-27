ARG ubuntu_version='16.04'
FROM ubuntu:${ubuntu_version}
ENV DEBIAN_FRONTEND noninteractive
ARG ubuntu_codename='xenial'
ENV smartmontools_dir='/root/smartmontools'

RUN sed -i "s@# \(deb-src http://archive.ubuntu.com/ubuntu/ ${ubuntu_codename} main restricted\)@\1@" /etc/apt/sources.list && \
    mkdir ${smartmontools_dir} && \
    cd ${smartmontools_dir} && \
    apt-get update && \
    apt-get install -y \
        dpkg-dev \
        devscripts \
        build-essential \
        fakeroot \
        debhelper \
        libssl-dev \
        libpcre3-dev \
        libsystemd-dev \
        zlib1g-dev \
        quilt \
        wget && \
    apt-get build-dep -y smartmontools && \
    apt-get source smartmontools || true && \
    apt-get clean && apt-get autoclean && \
    rm -rf /var/lib/apt/*

WORKDIR ${smartmontools_dir}
COPY ./debian_* /root/
ARG url_smartmontools_archive="https://kent.dl.sourceforge.net/project/smartmontools/smartmontools/7.0/smartmontools-7.0.tar.gz"
RUN wget ${url_smartmontools_archive} && \
    smartmontools_archive_name=`echo -n "${url_smartmontools_archive}" | sed 's@.*/\([^/]\+\)$@\1@'` && \
    deb_archive_name=`echo -n $(ls -1 | grep -E "smartmontools.*orig\.tar\.xz")` && \
    gzip -d ${smartmontools_archive_name} -c | tar -x && \
    archive_src_dir=`tar -tf ${smartmontools_archive_name} | cut -d/ -f1 | uniq | head -n1` && \
    deb_src_dir=`tar -tf ${deb_archive_name} | cut -d/ -f1 | uniq | head -n1 | sed 's/\.orig//'` && \
    cp -r ${deb_src_dir}/debian ${archive_src_dir}/ && \
    cp -fv /root/debian_control_${ubuntu_codename} ${archive_src_dir}/debian/control && \
    cp -fv /root/debian_changelog_${ubuntu_codename} ${archive_src_dir}/debian/changelog


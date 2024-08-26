ARG RHEL_VERSION
FROM rockylinux:${RHEL_VERSION}

ARG RHEL_VERSION
ARG PG_VERSION
ARG PG_BULKLOAD_VERSION

ENV PATH /usr/pgsql-${PG_VERSION}/bin:$PATH
ENV PGDATA /var/lib/pgsql/${PG_VERSION}/data


################################################################################
#
# Prerequisite
#
################################################################################

# Install packages for build
RUN dnf update -y
RUN dnf install -y \
        clang gcc git krb5-devel libselinux-devel libzstd-devel lz4-devel make \
        openssl-devel pam-devel readline-devel rpmdevtools zlib-devel

# Install PostgreSQL
RUN if [ "${RHEL_VERSION}" = "8" ]; then \
        dnf install -y --enablerepo=powertools perl-IPC-Run; \
    else \
        dnf install -y --enablerepo=crb perl-IPC-Run; \
    fi
RUN dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-${RHEL_VERSION}-x86_64/pgdg-redhat-repo-latest.noarch.rpm
RUN dnf -qy module disable postgresql
RUN dnf install -y postgresql${PG_VERSION}-server postgresql${PG_VERSION}-devel postgresql${PG_VERSION}-llvmjit


################################################################################
#
# Build RPMs
#
################################################################################

# Build by postgres user
USER postgres
WORKDIR /var/lib/pgsql/

RUN rpmdev-setuptree
RUN git clone https://github.com/ossc-db/pg_bulkload.git
WORKDIR /var/lib/pgsql/pg_bulkload
RUN    git archive --format=tar.gz --prefix=pg_bulkload-${PG_BULKLOAD_VERSION}/ --output=../rpmbuild/SOURCES/pg_bulkload-${PG_BULKLOAD_VERSION}.tar.gz VERSION${PG_BULKLOAD_VERSION//./_}
WORKDIR /var/lib/pgsql/
RUN cp -a pg_bulkload/SPECS/pg_bulkload-pg${PG_VERSION}.spec rpmbuild/SPECS
RUN rpmbuild -bb --define="dist .pg${PG_VERSION}.rhel${RHEL_VERSION}" rpmbuild/SPECS/pg_bulkload-pg${PG_VERSION}.spec


################################################################################
#
# Run regression tests
#
################################################################################

USER root
RUN cd /var/lib/pgsql/rpmbuild/RPMS/x86_64/ && rpm -ivh *

USER postgres
RUN initdb --no-locale -E UTF8
RUN pg_ctl -w start && \
    cd pg_bulkload && \
    make installcheck

#/bin/bash

BUILD_VERSION=0
RHEL_VERSION=("8" "9")
PG_VERSION=("13" "14" "15" "16")
PG_BULKLOAD_VERSION=3.1.21

for RHEL in "${RHEL_VERSION[@]}"; do
  for PG in "${PG_VERSION[@]}"; do
    echo "RHEL version: ${RHEL}, PostgreSQL version: ${PG}, pg_bulkload version: ${PG_BULKLOAD_VERSION}"
    docker build --build-arg RHEL_VERSION=${RHEL} --build-arg PG_VERSION=${PG} --build-arg PG_BULKLOAD_VERSION=${PG_BULKLOAD_VERSION} -t pg_bulkload:${PG}-${PG_BULKLOAD_VERSION}-${BUILD_VERSION}-el${RHEL} .
    container_id=$(docker create pg_bulkload:${PG}-${PG_BULKLOAD_VERSION}-${BUILD_VERSION}-el${RHEL})
    docker cp $container_id:/var/lib/pgsql/rpmbuild/RPMS/x86_64 ./RPMS-${RHEL}-pg${PG}
    docker rm $container_id
    docker rmi pg_bulkload:${PG}-${PG_BULKLOAD_VERSION}-${BUILD_VERSION}-el${RHEL}
  done
done

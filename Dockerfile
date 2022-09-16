FROM quay.io/fedora/fedora:36 AS builder

RUN dnf update -y && \
    dnf install -y wget elfutils-libelf-devel cmake ethtool iperf3 libstdc++ \
        libstdc++-devel bison flex ncurses-devel python3-netaddr python3-pip \
        gcc gcc-c++ make zlib-devel luajit luajit-devel clang clang-devel \
        llvm llvm-devel llvm-static openssl kernel-devel && \
    dnf clean all -y && rm -rf /var/cache/dnf

RUN mkdir /tmp/bcc_build_output && \
    wget -O /tmp/bcc.tar.gz https://github.com/iovisor/bcc/releases/download/v0.25.0/bcc-src-with-submodule.tar.gz && \
    tar --no-same-owner -zxvf /tmp/bcc.tar.gz -C /tmp && \
    make -C /tmp/bcc/libbpf-tools && \
    sh -c 'find /tmp/bcc/libbpf-tools/ -type f -perm 0755 -exec mv {} /tmp/bcc_build_output/ \;' && \
    sh -c 'find /tmp/bcc/libbpf-tools/ -type l -name *dist -o -name *lower -exec mv {} /tmp/bcc_build_output/ \;'


FROM quay.io/fedora/fedora:36

COPY --from=builder /tmp/bcc_build_output/* /usr/local/bin/
RUN  dnf install -y \
        iperf3 perf sysstat \
        lsof strace ltrace \
        elfutils pciutils \
        flamegraph flamegraph-stackcollapse.noarch flamegraph-stackcollapse-perf.noarch \
    && \
    dnf clean all -y

RUN curl -L -o /usr/local/bin/rt-trace-bcc.py \
	https://raw.githubusercontent.com/xzpeter/rt-trace-bpf/main/rt-trace-bcc.py
COPY entrypoint.sh /
RUN chmod 0755 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/sleep", "inf"]

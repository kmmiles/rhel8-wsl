FROM registry.redhat.io/ubi8/ubi:8.5-236.1647448331
ENV WSL_DISTRO_NAME rhel8
WORKDIR /provision

# reinstall all packages with update dnf.conf (install docs!)
COPY ./etc/dnf.conf /etc/dnf/dnf.conf
#COPY ./bin/reinstall-packages .
#RUN set -ex; \
#  /provision/reinstall-packages

RUN set -ex; \
  yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

# install base packages
RUN set -ex; \
  dnf upgrade -y && \
  dnf install -y \
    redhat-lsb-core \ 
    cracklib-dicts \
    passwd \
    sudo \
    git \
    podman \
    crun

# create a user (l/wsl p/wsl)
RUN set -ex; \
  useradd -m -s /bin/bash -G wheel "wsl" && \
  printf "wsl" | passwd --stdin "wsl" 

# fix `podman` error: newuidmap: write to uid_map failed: Operation not permitted
RUN set -ex; \
  chmod 4755 /usr/bin/newgidmap && \
  chmod 4755 /usr/bin/newuidmap

# create dumb `docker` wrapper for `podman`
RUN set -ex; \
  printf "#!/bin/sh\n" > /usr/bin/docker && \
  printf "exec /usr/bin/podman \"\$@\"\n" >> /usr/bin/docker && \
  chmod +x /usr/bin/docker

# copy configs
COPY ./etc/passwordless /etc/sudoers.d/passwordless
COPY ./etc/fstab /etc/fstab
COPY ./etc/wsl.conf /etc/wsl.conf

# cleanup
RUN set -ex; \
  dnf autoremove -y && \
  dnf clean all -y && \
  find /tmp -mindepth 1 -exec rm -rf {} \; && \
  find /var/tmp -mindepth 1 -exec rm -rf {} \; && \
  find /var/cache -type f -exec rm -rf {} \; && \
  find /var/log -type f | while read f; do /bin/echo -ne "" > $f; done

# create dumb file to signify box is provisioned
RUN set -ex; \
  date > /etc/is_provisioned

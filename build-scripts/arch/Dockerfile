FROM archlinux:latest

RUN set -ex \
    && pacman -Syu --noconfirm \
    && pacman -S --noconfirm \
               base-devel \
               git \
               wget \
    && pacman -Scc --noconfirm \
    && rm -rf /tmp/* /var/tmp/*

# Create a build user (makepkg cannot run as root)
RUN useradd -m -G wheel builder \
    && echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER builder
WORKDIR /home/builder

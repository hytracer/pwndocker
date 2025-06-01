FROM amd64/ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm-256color
ENV SHELL=/bin/bash
ENV LANG=C.UTF-8
ENV PIP_ROOT_USER_ACTION=ignore

# Install core system dependencies
RUN apt update -y && apt upgrade -y && apt install -y \
  strace gdb gdb-multiarch gcc gdbserver \
  libc6-dbg gcc-multilib g++-multilib curl wget make python3 \
  python3-pip vim binutils ruby ruby-dev netcat tmux \
  file less man jq lsof tree iproute2 iputils-ping iptables dnsutils \
  traceroute nmap socat p7zip-full git net-tools openssh-server \
  ltrace libssl-dev libffi-dev procps libpcre3-dev libdb-dev

# Uncomment this block to enable 32-bit binary debugging
# RUN dpkg --add-architecture i386 && apt update && apt install -y \
#   libc6:i386 libncurses5:i386 libstdc++6:i386

# Python tools for pwning and reversing
RUN python3 -m pip install --upgrade pip && \
  python3 -m pip install \
    pwntools \
    keystone-engine \
    capstone \
    unicorn \
    ropper \
    r2pipe \
    requests \
    ROPgadget

# Install radare2
RUN git clone https://github.com/radareorg/radare2 && \
  cd radare2 && ./sys/install.sh

# Install libc-database
RUN git clone https://github.com/niklasb/libc-database /opt/libc-database

# Install pwndbg
RUN git clone https://github.com/pwndbg/pwndbg /opt/pwndbg && \
    cd /opt/pwndbg && ./setup.sh

# Install GEF (do NOT enable by default)
RUN curl -fsSL https://gef.blah.cat/sh > /root/.gdbinit-gef.py

# Add usage comments in .gdbinit
RUN echo "# To launch gdb with your preferred plugin, use the shell aliases:" > /root/.gdbinit && \
    echo "#   gdb-pwndbg  # to launch gdb with pwndbg" >> /root/.gdbinit && \
    echo "#   gdb-gef     # to launch gdb with GEF" >> /root/.gdbinit

# Persistent aliases for convenience
RUN echo "alias gdb-pwndbg='gdb -x /opt/pwndbg/gdbinit.py'" >> /root/.bashrc && \
    echo "alias gdb-gef='gdb -x ~/.gdbinit-gef.py'" >> /root/.bashrc

# Basic editor config
RUN echo "set number\nsyntax on" >> ~/.vimrc && \
  echo "set -g mouse on" >> ~/.tmux.conf

# Copy files and set permissions
COPY startup.sh /
RUN chmod +x /startup.sh

# SSH server config
RUN echo "PermitRootLogin yes\nPasswordAuthentication yes\nPermitEmptyPasswords yes" >> /etc/ssh/sshd_config && \
  passwd -d root

WORKDIR /CTF

FROM ubuntu:22.04

ENV HOME=/home

WORKDIR /home/dotfiles

COPY . /home/dotfiles

RUN apt-get update && apt-get install -y sudo

RUN test -f /home/dotfiles/pop_os/install.sh && chmod +x /home/dotfiles/pop_os/install.sh

CMD ["/bin/bash"]

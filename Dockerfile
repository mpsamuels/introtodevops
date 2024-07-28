FROM amazonlinux:2023.0.20230322.0

RUN yum update &&\
        yum install -y wget-1.21.3 awscli-2-2.9.19 zip-3.0 &&\
        yum install -y git-2.39.2 tar-1.34 && \
        yum install -y yum-utils

RUN useradd -m -s /bin/bash linuxbrew && \
    echo 'linuxbrew ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers

RUN rm -rf /usr/local/Homebrew &&\
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

USER root
ENV PATH="/home/linuxbrew/.linuxbrew/bin:${PATH}"

RUN yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo &&\
        yum -y install terraform &&\
        brew install tflint &&\
        brew install tfenv

ENTRYPOINT ["bin/bash"]

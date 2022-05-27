# https://github.com/GoogleCloudPlatform/cloud-sdk-docker
FROM gcr.io/google.com/cloudsdktool/cloud-sdk:slim
LABEL maintainer="GCP Platform Team"

ENV USERNAME=developer
ENV USRDIR=/builder
ENV PATH ${USRDIR}/.local/bin:${PATH}

ARG CHECKOV_VERSION
ARG MARKDOWNLINK_VERSION
ARG MDL_VERSION
ARG PRECOMMIT_VERSION
ARG TF_DOCS_VERSION
ARG TFENV_VERSION
ARG TFSEC_VERSION
ARG TGENV_VERSION
ARG TERRAFORM_VERSION
ARG TERRAGRUNT_VERSION

ENV TFENV_AUTO_INSTALL=true
ENV TGENV_AUTO_INSTALL=true

# Common tools & other packages
RUN mkdir -p "${USRDIR}" && \
    apt-get update && \
    apt-get install -y --no-install-recommends apt-transport-https \
    build-essential \
    ca-certificates \
    curl \
    findutils \
    gawk \
    git \
    gnupg \
    jq \
    python3 \
    python3-dev \
    python3-pip \
    python3-testresources \
    ruby \
    ruby-all-dev \
    sudo \
    unzip \
    wget && \
    curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    curl https://www.npmjs.com/install.sh | sh && \
    apt-get clean

# pip3 stuff
RUN pip3 install --no-cache-dir --upgrade setuptools && \
    pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir checkov=="${CHECKOV_VERSION}" \
    dataclasses \
    gitpython \
    pre-commit=="${PRECOMMIT_VERSION}"

# npm and gem
RUN npm install markdown-link-check@"${MARKDOWNLINK_VERSION}" -g --no-save && \
    gem install chef-utils -v 16.6.14 && \
    gem install mdl -v "${MDL_VERSION}"

# tfenv
RUN git clone --depth 1 --branch ${TFENV_VERSION} https://github.com/tfutils/tfenv.git ${USRDIR}/.tfenv

# tgenv
RUN git clone --depth 1 --branch ${TGENV_VERSION} https://github.com/cunymatthieu/tgenv.git ${USRDIR}/.tgenv

ENV PATH ${USRDIR}/.tgenv/bin:${USRDIR}/.tfenv/bin:${PATH}

# tfenv and tgenv setup
RUN tfenv install ${TERRAFORM_VERSION} && \
    tgenv install ${TERRAGRUNT_VERSION} && \
    tfenv use ${TERRAFORM_VERSION} && \
    tgenv use ${TERRAGRUNT_VERSION}

# terraform-docs
RUN TF_DOCS_URL=$(curl -Ls https://api.github.com/repos/terraform-docs/terraform-docs/releases/tags/"${TF_DOCS_VERSION}" | \
    jq -r '.assets[] | select(.name == "terraform-docs-'"${TF_DOCS_VERSION}"'-linux-amd64.tar.gz") | .browser_download_url') && \
    wget -q "${TF_DOCS_URL}" -O /tmp/terraform-docs.tar.gz && \
    mkdir -p ${USRDIR}/.terraform-docs/bin/terraform-docs && \
    tar -C ${USRDIR}/.terraform-docs/bin/terraform-docs -xzf /tmp/terraform-docs.tar.gz && \
    rm /tmp/terraform-docs.tar.gz && \
    chmod +x ${USRDIR}/.terraform-docs/bin/terraform-docs
ENV PATH="${USRDIR}/.terraform-docs/bin/terraform-docs:${PATH}"

# tfsec
RUN TFSEC_URL=$(curl -Ls https://api.github.com/repos/tfsec/tfsec/releases/tags/"${TFSEC_VERSION}" | \
    jq -r '.assets[] | select(.name == "tfsec-linux-amd64") | .browser_download_url') && \
    mkdir -p ${USRDIR}/.tfsec/bin && \
    wget -q "${TFSEC_URL}" -O ${USRDIR}/.tfsec/bin/tfsec && \
    chmod +x ${USRDIR}/.tfsec/bin/tfsec
ENV PATH="${USRDIR}/.tfsec/bin:${PATH}"

# cleanup
RUN rm -rf /var/lib/apt/lists/*

RUN userdel -rf cloudsdk && \
    chown root:root /usr/local/bin/docker && \
    useradd -m -d /home/"${USERNAME}" -s /bin/bash -U "${USERNAME}" && \
    usermod -aG sudo "${USERNAME}" && \
    echo "${USERNAME}" ALL=\(root\) NOPASSWD:ALL >/etc/sudoers.d/"${USERNAME}" && \
    chmod 0440 /etc/sudoers.d/"${USERNAME}"

ENV LC_MESSAGES="C.UTF-8"
ENV LC_COLLATE="C.UTF-8"
ENV LC_CTYPE="C.UTF-8"
ENV LC_ALL="C.UTF-8"
ENV LANGUAGE="C.UTF-8"

USER developer

ENTRYPOINT ["/bin/bash"]

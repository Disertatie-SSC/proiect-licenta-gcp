FROM gcr.io/google.com/cloudsdktool/cloud-sdk:slim

ENV USRDIR=/usr/local
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y apt-transport-https \
    ca-certificates \
    software-properties-common \
    curl \
    unzip \
    wget \
    graphviz \
    procps \
    locales && \
    locale-gen en_US.UTF-8

# https://packages.debian.org/buster/git
ARG GIT_VERSION=1:2.20.1-2+deb10u3
RUN apt-get install --no-install-recommends -y git="${GIT_VERSION}"

# https://github.com/tfutils/tfenv
ARG TFENV_VERSION=v2.2.2
RUN git clone --depth 1 --branch ${TFENV_VERSION} https://github.com/tfutils/tfenv.git ${USRDIR}/.tfenv
ENV PATH="${USRDIR}/.tfenv/bin:${PATH}"

# https://github.com/cunymatthieu/tgenv
ARG TGENV_VERSION=v0.0.3
RUN git clone --depth 1 --branch ${TGENV_VERSION} https://github.com/cunymatthieu/tgenv.git ${USRDIR}/.tgenv
ENV PATH="${USRDIR}/.tgenv/bin:${PATH}"

# https://www.terraform.io/downloads.html
ARG TERRAFORM_VERSION=1.0.3
RUN tfenv install ${TERRAFORM_VERSION} && \
    tfenv use ${TERRAFORM_VERSION}

# https://terragrunt.gruntwork.io
# https://terragrunt.gruntwork.io/docs/getting-started/supported-terraform-versions
ARG TERRAGRUNT_VERSION=0.31.3
RUN tgenv install ${TERRAGRUNT_VERSION}

# https://www.python.org/downloads/
ARG PYTHON_VERSION=3.9.7
RUN wget https://www.python.org/ftp/python/"${PYTHON_VERSION}"/Python-"${PYTHON_VERSION}".tgz -O Python-"${PYTHON_VERSION}".tgz && \
    tar xzf Python-"${PYTHON_VERSION}".tgz && \
    rm -rf Python-"${PYTHON_VERSION}".tgz && \
    cd Python-"${PYTHON_VERSION}" && \
    ./configure --enable-optimizations && \
    make -j 2

SHELL ["/bin/bash", "-c", "-l"]

RUN echo 'alias python='/usr/bin/python3.7'' >> ~/.bashrc && \
    . ~/.bashrc

SHELL ["/bin/sh", "-c", "-l"]

# https://github.com/pypa/pip
ARG PIP_VERSION=18.1-5
RUN apt-get install --no-install-recommends -y python3-pip

RUN pip3 install --upgrade pip

COPY requirements.txt requirements.txt
RUN pip3 install --no-cache-dir -r requirements.txt && \
    rm -rf requirements.txt

# https://github.com/pre-commit/pre-commit
ARG PRECOMMIT_VERSION=2.14.1
RUN pip3 install --no-cache-dir pre-commit=="${PRECOMMIT_VERSION}"

RUN pip3 install pandas

# https://github.com/adrienverge/yamllint
ARG YAMLLINT_VERSION=1.26.3
RUN pip3 install --no-cache-dir yamllint=="${YAMLLINT_VERSION}"

# https://github.com/bridgecrewio/checkov
ARG CHECKOV_VERSION=2.0.393
RUN python3 -m pip install --no-cache-dir -U checkov=="${CHECKOV_VERSION}"

# https://github.com/editorconfig-checker/editorconfig-checker
ARG ECC_VERSION=2.3.5
RUN pip3 install --no-cache-dir editorconfig-checker=="${ECC_VERSION}"

# https://github.com/terraform-linters/tflint
ARG TFLINT_VERSION=v0.31.0
RUN wget -q https://github.com/terraform-linters/tflint/releases/download/"${TFLINT_VERSION}"/tflint_linux_amd64.zip -O /tmp/tflint.zip && \
    unzip /tmp/tflint.zip -d ${USRDIR} && \
    rm /tmp/tflint.zip && \
    chmod +x ${USRDIR}/tflint
ENV PATH="${USRDIR}:${PATH}"

# https://github.com/terraform-docs/terraform-docs
ARG TFDOCS_VERSION=v0.15.0
RUN wget -q https://github.com/terraform-docs/terraform-docs/releases/download/"${TFDOCS_VERSION}"/terraform-docs-"${TFDOCS_VERSION}"-linux-amd64.tar.gz -O /tmp/terraform-docs.tar.gz && \
    mkdir -p ${USRDIR}/.terraform-docs/bin/terraform-docs && \
    tar -C ${USRDIR}/.terraform-docs/bin/terraform-docs -xzf /tmp/terraform-docs.tar.gz && \
    rm /tmp/terraform-docs.tar.gz && \
    chmod +x ${USRDIR}/.terraform-docs/bin/terraform-docs
ENV PATH="${USRDIR}/.terraform-docs/bin/terraform-docs:${PATH}"

# https://github.com/aquasecurity/tfsec
ARG TFSEC_VERSION=v0.58.6
RUN mkdir -p ${USRDIR}/.tfsec/bin && \
    wget -q https://github.com/tfsec/tfsec/releases/download/"${TFSEC_VERSION}"/tfsec-linux-amd64 -O ${USRDIR}/.tfsec/bin/tfsec && \
    chmod +x ${USRDIR}/.tfsec/bin/tfsec
ENV PATH="${USRDIR}/.tfsec/bin:${PATH}"

# https://github.com/mvdan/sh
ARG SHFMT_VERSION=v3.3.1
RUN wget -q https://github.com/mvdan/sh/releases/download/"${SHFMT_VERSION}"/shfmt_"${SHFMT_VERSION}"_linux_amd64 -O ${USRDIR}/shfmt && \
    chmod +x ${USRDIR}/shfmt
ENV PATH="${USRDIR}/shfmt:${PATH}"

# https://answers.launchpad.net/debian/buster/+source/npm
ARG NPM_VERSION=5.8.0+ds6-4+deb10u2
RUN apt-get install --no-install-recommends -y npm="${NPM_VERSION}"

# https://github.com/tcort/markdown-link-check
ARG MARKDOWNLINK_VERSION=3.8.7
RUN npm install -g --no-save markdown-link-check@"${MARKDOWNLINK_VERSION}"

# https://github.com/conventional-changelog/commitlint
ARG COMMITLINT_VERSION=13.1.0
RUN npm install -g --no-save @commitlint/cli@"${COMMITLINT_VERSION}" && \
    npm init -y && \
    npm install --save-dev @commitlint/config-conventional@"${COMMITLINT_VERSION}"

SHELL ["/bin/bash", "-c", "-l"]

# https://github.com/rvm/rvm
ARG RVM_VERSION=1.29.12
RUN gpg --keyserver hkp://pgp.mit.edu --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB && \
    curl -sSL https://get.rvm.io | bash -s -- --version "${RVM_VERSION}" && \
    echo 'source "/usr/local/rvm/scripts/rvm"' >> ~/.bashrc

# https://www.ruby-lang.org/en/downloads
ARG RUBY_VERSION=2.7.4
RUN rvm install ruby-dev-"${RUBY_VERSION}"
ENV PATH="/usr/share/rvm/rubies/ruby-"${RUBY_VERSION}":${PATH}"

SHELL ["/bin/sh", "-c", "-l"]

# https://rubygems.org/gems/rails/versions
ARG RGEMS_VERSION=3.2.19
RUN apt-get install --no-install-recommends -y rubygems && \
    gem update --system "${RGEMS_VERSION}"

# https://rubygems.org/gems/chef-utils/versions
ARG CHEFU_VERSION=16.6.14
RUN gem install chef-utils -v "${CHEFU_VERSION}"

# https://rubygems.org/gems/mdl/versions
ARG MDL_VERSION=0.11.0
RUN gem install mdl -v "${MDL_VERSION}"

# https://nodejs.org/en/download/releases/
ARG NODE_VERSION=14.17.6
RUN npm cache clean -f && \
    npm install -g n && \
    n stable "${NODE_VERSION}"

RUN rm -rf /var/lib/apt/lists/* && \
    apt-get purge --auto-remove && \
    apt-get clean

ENTRYPOINT ["/bin/bash"]

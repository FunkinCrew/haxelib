VERSION 0.6
ARG UBUNTU_RELEASE=bionic
FROM mcr.microsoft.com/vscode/devcontainers/base:0-$UBUNTU_RELEASE
ARG DEVCONTAINER_IMAGE_NAME_DEFAULT=haxe/haxelib_devcontainer_workspace

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

devcontainer-base:
    ARG TARGETARCH

    # Avoid warnings by switching to noninteractive
    ENV DEBIAN_FRONTEND=noninteractive

    ARG INSTALL_ZSH="false"
    ARG UPGRADE_PACKAGES="true"
    ARG ENABLE_NONROOT_DOCKER="true"
    ARG USE_MOBY="true"
    COPY .devcontainer/library-scripts/*.sh /tmp/library-scripts/
    RUN apt-get update \
        && /bin/bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" "true" "true" \
        # Use Docker script from script library to set things up
        && /bin/bash /tmp/library-scripts/docker-debian.sh "${ENABLE_NONROOT_DOCKER}" "/var/run/docker-host.sock" "/var/run/docker.sock" "${USERNAME}" \
        # Clean up
        && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts/

    # https://github.com/docker-library/mysql/blob/master/5.7/Dockerfile.debian
    # apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys A4A9406876FCBD3C456770C88C718D3B5072E1F5 || \
    # apt-key adv --keyserver pgp.mit.edu --recv-keys A4A9406876FCBD3C456770C88C718D3B5072E1F5 || \
    # apt-key adv --keyserver keyserver.pgp.com --recv-keys A4A9406876FCBD3C456770C88C718D3B5072E1F5
    COPY .devcontainer/mysql-public-key /tmp/mysql-public-key
    RUN apt-key add /tmp/mysql-public-key

    # Configure apt and install packages
    RUN apt-get update \
        && apt-get install -y --no-install-recommends apt-utils dialog 2>&1 \
        && apt-get install -y \
            iproute2 \
            procps \
            sudo \
            bash-completion \
            build-essential \
            curl \
            wget \
            software-properties-common \
            direnv \
            tzdata \
            python3-pip \
        && add-apt-repository ppa:git-core/ppa \
        && apt-get install -y git \
        && curl -sL https://deb.nodesource.com/setup_14.x | bash - \
        && apt-get install -y nodejs=14.* \
        # the haxelib server code base is not Haxe 4 ready
        && add-apt-repository ppa:haxe/haxe3.4 \
        && add-apt-repository ppa:haxe/haxe4.2 \
        && apt-get install -y neko haxe=1:4.2.* \
        # Install mysql-client
        # https://github.com/docker-library/mysql/blob/master/5.7/Dockerfile.debian
        && echo 'deb http://repo.mysql.com/apt/ubuntu/ bionic mysql-5.7' > /etc/apt/sources.list.d/mysql.list \
        && apt-get update \
        && apt-get -y install mysql-client=5.7.* \
        # install kubectl
        && curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
        && echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list \
        && apt-get update \
        && apt-get -y install --no-install-recommends kubectl \
        # install helm
        && curl -fsSL https://baltocdn.com/helm/signing.asc | apt-key add - \
        && echo "deb https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list \
        && apt-get update \
        && apt-get -y install --no-install-recommends helm \
        #
        # Clean up
        && apt-get autoremove -y \
        && apt-get clean -y \
        && rm -rf /var/lib/apt/lists/*

    ENV YARN_CACHE_FOLDER=/yarn
    RUN mkdir -m 777 "$YARN_CACHE_FOLDER"
    RUN npm install -g yarn

    # Switch back to dialog for any ad-hoc use of apt-get
    ENV DEBIAN_FRONTEND=

    # Setting the ENTRYPOINT to docker-init.sh will configure non-root access 
    # to the Docker socket. The script will also execute CMD as needed.
    ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
    CMD [ "sleep", "infinity" ]

    RUN mkdir -m 777 "/workspace"
    WORKDIR /workspace

# Usage:
# RUN /aws/install
awscli:
    FROM +devcontainer-base
    RUN curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -o "/tmp/awscliv2.zip" \
        && unzip -qq /tmp/awscliv2.zip -d / \
        && rm /tmp/awscliv2.zip
    SAVE ARTIFACT /aws

# Usage:
# COPY +aws-iam-authenticator/aws-iam-authenticator /usr/local/bin/
aws-iam-authenticator:
    RUN curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/aws-iam-authenticator \
        && chmod +x ./aws-iam-authenticator \
        && mv ./aws-iam-authenticator /usr/local/bin/
    SAVE ARTIFACT /usr/local/bin/aws-iam-authenticator

# Usage:
# COPY +doctl/doctl /usr/local/bin/
doctl:
    ARG TARGETARCH
    ARG DOCTL_VERSION=1.66.0
    RUN curl -fsSL "https://github.com/digitalocean/doctl/releases/download/v${DOCTL_VERSION}/doctl-${DOCTL_VERSION}-linux-${TARGETARCH}.tar.gz" | tar xvz -C /usr/local/bin/
    SAVE ARTIFACT /usr/local/bin/doctl

# Usage:
# COPY +tfenv/tfenv /tfenv
# RUN ln -s /tfenv/bin/* /usr/local/bin
tfenv:
    FROM +devcontainer-base
    RUN git clone --depth 1 https://github.com/tfutils/tfenv.git /tfenv
    SAVE ARTIFACT /tfenv

# Usage:
# COPY +terraform-ls/terraform-ls /usr/local/bin/
terraform-ls:
    ARG --required TARGETARCH
    ARG TERRAFORM_LS_VERSION=0.25.1
    RUN curl -fsSL -o terraform-ls.zip https://github.com/hashicorp/terraform-ls/releases/download/v${TERRAFORM_LS_VERSION}/terraform-ls_${TERRAFORM_LS_VERSION}_linux_${TARGETARCH}.zip \
        && unzip -qq terraform-ls.zip \
        && mv ./terraform-ls /usr/local/bin/ \
        && rm terraform-ls.zip
    SAVE ARTIFACT /usr/local/bin/terraform-ls

terraform:
    FROM +tfenv
    RUN ln -s /tfenv/bin/* /usr/local/bin
    ARG --required TERRAFORM_VERSION
    RUN tfenv install "$TERRAFORM_VERSION"
    RUN tfenv use "$TERRAFORM_VERSION"

# Usage:
# COPY +tfk8s/tfk8s /usr/local/bin/
tfk8s:
    FROM golang:1.17
    RUN go install github.com/jrhouston/tfk8s@v0.1.7
    SAVE ARTIFACT /go/bin/tfk8s

# Usage:
# COPY +earthly/earthly /usr/local/bin/
# RUN earthly bootstrap --no-buildkit --with-autocomplete
earthly:
    FROM +devcontainer-base
    ARG --required TARGETARCH
    RUN curl -fsSL https://github.com/earthly/earthly/releases/download/v0.6.2/earthly-linux-${TARGETARCH} -o /usr/local/bin/earthly \
        && chmod +x /usr/local/bin/earthly
    SAVE ARTIFACT /usr/local/bin/earthly

haxelib-deps:
    FROM +devcontainer-base
    USER $USERNAME
    COPY --chown=$USER_UID:$USER_GID libs.hxml run.n .
    COPY --chown=$USER_UID:$USER_GID lib/record-macros lib/record-macros
    RUN mkdir -p haxelib_global
    RUN haxelib setup haxelib_global
    RUN haxe libs.hxml && rm haxelib_global/*.zip
    SAVE ARTIFACT haxelib_global

node-modules-prod:
    FROM +devcontainer-base
    USER $USERNAME
    COPY --chown=$USER_UID:$USER_GID package.json yarn.lock .
    RUN yarn --production
    SAVE ARTIFACT node_modules

node-modules-dev:
    FROM +node-modules-prod
    RUN yarn
    SAVE ARTIFACT node_modules

dts2hx-externs:
    FROM +node-modules-dev
    USER $USERNAME
    COPY --chown=$USER_UID:$USER_GID generate_extern.sh .
    RUN bash generate_extern.sh
    SAVE ARTIFACT lib/dts2hx-generated

devcontainer:
    FROM +devcontainer-base

    # AWS cli
    COPY +awscli/aws /aws
    RUN /aws/install

    COPY +aws-iam-authenticator/aws-iam-authenticator /usr/local/bin/

    # doctl
    COPY +doctl/doctl /usr/local/bin/

    # tfenv
    COPY +tfenv/tfenv /tfenv
    RUN ln -s /tfenv/bin/* /usr/local/bin/
    COPY --chown=$USER_UID:$USER_GID terraform/.terraform-version "/home/$USERNAME/"
    RUN tfenv install "$(cat /home/$USERNAME/.terraform-version)"
    RUN tfenv use "$(cat /home/$USERNAME/.terraform-version)"
    COPY +terraform-ls/terraform-ls /usr/local/bin/

    COPY +tfk8s/tfk8s /usr/local/bin/

    # Install earthly
    COPY +earthly/earthly /usr/local/bin/
    RUN earthly bootstrap --no-buildkit --with-autocomplete

    USER $USERNAME

    COPY --chown=$USER_UID:$USER_GID +node-modules-dev/node_modules node_modules
    VOLUME /workspace/node_modules
    COPY --chown=$USER_UID:$USER_GID +dts2hx-externs/dts2hx-generated lib/dts2hx-generated
    VOLUME /workspace/lib/dts2hx-generated
    COPY --chown=$USER_UID:$USER_GID +haxelib-deps/haxelib_global haxelib_global
    VOLUME /workspace/haxelib_global

    # Config direnv
    COPY --chown=$USER_UID:$USER_GID .devcontainer/direnv.toml /home/$USERNAME/.config/direnv/config.toml

    # Config bash
    RUN echo 'eval "$(direnv hook bash)"' >> ~/.bashrc \
        && echo 'complete -C terraform terraform' >> ~/.bashrc \
        && echo "complete -C '/usr/local/bin/aws_completer' aws" >> ~/.bashrc \
        && echo 'source <(helm completion bash)' >> ~/.bashrc \
        && echo 'source <(kubectl completion bash)' >> ~/.bashrc \
        && echo 'source <(doctl completion bash)' >> ~/.bashrc

    # Create kubeconfig for storing current-context,
    # such that the project kubeconfig_* files wouldn't be touched.
    RUN mkdir -p ~/.kube && install -m 600 /dev/null ~/.kube/config

    USER root

    ARG DEVCONTAINER_IMAGE_NAME="$DEVCONTAINER_IMAGE_NAME_DEFAULT"
    ARG DEVCONTAINER_IMAGE_TAG=latest
    SAVE IMAGE --push "$DEVCONTAINER_IMAGE_NAME:$DEVCONTAINER_IMAGE_TAG" "$DEVCONTAINER_IMAGE_NAME:latest"

devcontainer-rebuild:
    RUN --no-cache date +%Y%m%d%H%M%S | tee buildtime
    ARG DEVCONTAINER_IMAGE_NAME="$DEVCONTAINER_IMAGE_NAME_DEFAULT"
    BUILD \
        --platform=linux/amd64 \
        +devcontainer \
        --DEVCONTAINER_IMAGE_NAME="$DEVCONTAINER_IMAGE_NAME" \
        --DEVCONTAINER_IMAGE_TAG="$(cat buildtime)"
    BUILD +devcontainer-update-refs \
        --DEVCONTAINER_IMAGE_NAME="$DEVCONTAINER_IMAGE_NAME" \
        --DEVCONTAINER_IMAGE_TAG="$(cat buildtime)"

devcontainer-update-refs:
    ARG --required DEVCONTAINER_IMAGE_NAME
    ARG --required DEVCONTAINER_IMAGE_TAG
    BUILD +devcontainer-update-ref \
        --DEVCONTAINER_IMAGE_NAME="$DEVCONTAINER_IMAGE_NAME" \
        --DEVCONTAINER_IMAGE_TAG="$DEVCONTAINER_IMAGE_TAG" \
        --FILE='./.devcontainer/docker-compose.yml' \
        --FILE='./.github/workflows/ci-dev.yml' \
        --FILE='./.github/workflows/ci-prod.yml'

devcontainer-update-ref:
    ARG --required DEVCONTAINER_IMAGE_NAME
    ARG --required DEVCONTAINER_IMAGE_TAG
    ARG --required FILE
    COPY "$FILE" file.src
    RUN sed -e "s#$DEVCONTAINER_IMAGE_NAME:[a-z0-9]*#$DEVCONTAINER_IMAGE_NAME:$DEVCONTAINER_IMAGE_TAG#g" file.src > file.out
    SAVE ARTIFACT --keep-ts file.out $FILE AS LOCAL $FILE

do-kubeconfig:
    FROM +doctl
    ARG --required CLUSTER_ID
    RUN --mount=type=secret,id=+secrets/.envrc,target=.envrc \
        . ./.envrc \
        && KUBECONFIG="kubeconfig" doctl kubernetes cluster kubeconfig save "$CLUSTER_ID"
    SAVE ARTIFACT --keep-ts kubeconfig

haxelib-server:
    FROM ubuntu:$UBUNTU_RELEASE

    RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common \
        && add-apt-repository ppa:haxe/haxe3.4 -y \
        && apt-get update && apt-get upgrade -y \
        && DEBIAN_FRONTEND=noninteractive apt-get install -y \
            apache2 \
            neko-dev \
            haxe \
            curl \
            git \
            libcurl4-gnutls-dev \
        && curl -sL https://deb.nodesource.com/setup_14.x | bash - \
        && DEBIAN_FRONTEND=noninteractive apt-get install -y \
            nodejs \
        && rm -r /var/lib/apt/lists/*

    # apache httpd
    RUN rm -rf /var/www/html \
        && mkdir -p /var/lock/apache2 /var/run/apache2 /var/log/apache2 /var/www/html \
        && chown -R www-data:www-data /var/lock/apache2 /var/run/apache2 /var/log/apache2 /var/www/html \
        && a2enmod rewrite \
        && a2enmod proxy \
        && a2enmod proxy_http \
        && a2enmod headers \
        && a2dismod mpm_event \
        && a2enmod mpm_prefork \
        && mv /etc/apache2/apache2.conf /etc/apache2/apache2.conf.dist && rm /etc/apache2/conf-enabled/* /etc/apache2/sites-enabled/*
    COPY apache2.conf /etc/apache2/apache2.conf
    RUN { \
            echo 'LoadModule neko_module /usr/lib/x86_64-linux-gnu/neko/mod_neko2.ndll'; \
            echo 'LoadModule tora_module /usr/lib/x86_64-linux-gnu/neko/mod_tora2.ndll'; \
            echo 'AddHandler tora-handler .n'; \
        } > /etc/apache2/mods-enabled/tora.conf \
        && apachectl stop

    # haxelib
    ENV HAXELIB_PATH /src/haxelib_global
    RUN mkdir -p ${HAXELIB_PATH} && haxelib setup ${HAXELIB_PATH}
    WORKDIR /src
    COPY libs.hxml run.n /src/
    COPY lib/record-macros /src/lib/record-macros
    RUN haxe libs.hxml && rm ${HAXELIB_PATH}/*.zip
    RUN cp ${HAXELIB_PATH}/aws-sdk-neko/*/ndll/Linux64/aws.ndll /usr/lib/x86_64-linux-gnu/neko/aws.ndll;
    COPY server*.hxml /src/

    COPY www/package*.json /src/www/
    WORKDIR /src/www/
    RUN npm install --unsafe-perm

    COPY www /src/www/
    COPY src/legacyhaxelib/.htaccess /src/www/legacy/
    COPY src/legacyhaxelib/haxelib.css /src/www/legacy/
    COPY src/legacyhaxelib/website.mtt /src/www/legacy/
    COPY src /src/src/

    RUN rm -rf /var/www/html
    RUN ln -s /src/www /var/www/html
    RUN mkdir -p /var/www/html/files
    RUN mkdir -p /var/www/html/tmp

    WORKDIR /src

    RUN haxe server_legacy.hxml
    RUN haxe server_website.hxml
    RUN haxe server_tasks.hxml
    RUN haxe server_api.hxml

    EXPOSE 80
    VOLUME ["/var/www/html/files", "/var/www/html/tmp"]
    CMD apachectl restart && haxelib run tora

    ARG HAXELIB_SERVER_IMAGE_NAME=haxe/lib.haxe.org
    ARG HAXELIB_SERVER_IMAGE_TAG=latest
    SAVE IMAGE --push "$HAXELIB_SERVER_IMAGE_NAME:$HAXELIB_SERVER_IMAGE_TAG" "$HAXELIB_SERVER_IMAGE_NAME:latest"

copy-image:
    LOCALLY
    ARG --required SRC
    ARG --required DEST
    RUN docker pull "$SRC"
    RUN docker tag "$SRC" "$DEST"
    RUN docker push "$DEST"

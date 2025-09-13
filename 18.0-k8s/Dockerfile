FROM ubuntu:noble
LABEL maintainer="eYssen <info@eyssen.com>"

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]
ENV LANG=en_US.UTF-8
ARG TARGETARCH

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        bash \
        build-essential \
        ca-certificates \
        curl \
        dirmngr \
        figlet \
        fontconfig \
        fonts-dejavu-core \
        fonts-dejavu-extra \
        fonts-liberation \
        fonts-noto-cjk \
        fonts-noto-core \
        fonts-noto-mono \
        fonts-noto-ui-core \
        git \
        gnupg \
        iputils-ping \
        less \
        libcairo2-dev \
        libffi-dev \
        libfontconfig1 \
        libjpeg-dev \
        libldap2-dev \
        libpq-dev \
        libsasl2-dev \
        libssl-dev \
        libxext6 \
        libxml2-dev \
        libxrender1 \
        libxslt1-dev \
        libyaml-dev \
        lnav \
        locales \
        mc \
        node-less \
        nodejs \
        npm \
        pkg-config \
        postgresql-client \
        python3-cairo \
        python3-dev \
        python3-gi \
        python3-icu \
        python3-ldap \
        python3-magic \
        python3-num2words \
        python3-odf \
        python3-pdfminer \
        python3-phonenumbers \
        python3-pip \
        python3-qrcode \
        python3-renderpm \
        python3-setuptools \
        python3-slugify \
        python3-tk \
        python3-venv \
        python3-vobject \
        python3-watchdog \
        python3-xlrd \
        python3-xlwt \
        supervisor \
        tini \
        unzip \
        vim \
        wget \
        xfonts-75dpi \
        xfonts-base \
        xz-utils \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

RUN if [ -z "${TARGETARCH}" ]; then TARGETARCH="$(dpkg --print-architecture)"; fi; \
    WKHTMLTOPDF_ARCH="${TARGETARCH}"; \
    case "${TARGETARCH}" in \
      amd64)   WKHTMLTOPDF_ARCH=amd64;  WKHTMLTOPDF_SHA=967390a759707337b46d1c02452e2bb6b2dc6d59 ;; \
      arm64)   WKHTMLTOPDF_SHA=90f6e69896d51ef77339d3f3a20f8582bdf496cc ;; \
      ppc64le|ppc64el) WKHTMLTOPDF_ARCH=ppc64el; WKHTMLTOPDF_SHA=5312d7d34a25b321282929df82e3574319aed25c ;; \
    esac && \
    curl -fSL -o /tmp/wkhtmltox.deb \
      "https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.jammy_${WKHTMLTOPDF_ARCH}.deb" && \
    echo "${WKHTMLTOPDF_SHA}  /tmp/wkhtmltox.deb" | sha1sum -c - && \
    apt-get update && \
    apt-get install -y --no-install-recommends /tmp/wkhtmltox.deb && \
    rm -f /tmp/wkhtmltox.deb && \
    rm -rf /var/lib/apt/lists/*

RUN sed -i 's/^# *\(.*UTF-8\)/\1/' /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=en_US.UTF-8

RUN npm install -g rtlcss
RUN curl -fsSL https://code-server.dev/install.sh | sh

RUN useradd -u 101 -m -d /opt/odoo -s /bin/bash odoo || true && \
    mkdir -p /data/odoo/odoo /data/odoo/themes /data/odoo/eyssen /data/odoo/addons \
             /data/filestore /data/sessions /data/config \
             /data/log/odoo /data/log/supervisor \
             /data/codeserver/data /data/codeserver/config \
             /var/run/supervisor && \
    chown -R odoo:odoo /data /var/run/supervisor /opt/odoo && \
    rm -rf /var/log/odoo /var/lib/odoo && \
    ln -s /data/log/odoo /var/log/odoo && \
    ln -s /data /var/lib/odoo

RUN echo 'echo -e "\n$(figlet -w 100 -f slant eYssen Cloud)"' >> /opt/odoo/.bashrc && \
    echo 'CONTAINER_NAME=$(hostname)' >> /opt/odoo/.bashrc && \
    echo 'OS_NAME=$(grep ^PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d "\"")' >> /opt/odoo/.bashrc && \
    echo 'echo "You are connected to your Odoo instance: $CONTAINER_NAME running on $OS_NAME"' >> /opt/odoo/.bashrc && \
    echo "echo \"\"" >> /opt/odoo/.bashrc && \
    echo "echo \"Overview of useful commands:\"" >> /opt/odoo/.bashrc && \
    echo "echo \"\"" >> /opt/odoo/.bashrc && \
    echo "echo \"  \$ odoo-shell          Open an Odoo shell\"" >> /opt/odoo/.bashrc && \
    echo "echo \"  \$ odoo-db             Open an Odoo database shell\"" >> /opt/odoo/.bashrc && \
    echo "echo \"  \$ odoo-update         Update Odoo modules\"" >> /opt/odoo/.bashrc && \
    echo "echo \"  \$ odoo-restart        Restart Odoo services\"" >> /opt/odoo/.bashrc && \
    echo "echo \"  \$ odoo-stop           Stop Odoo services\"" >> /opt/odoo/.bashrc && \
    echo "echo \"  \$ odoo-start          Start Odoo services\"" >> /opt/odoo/.bashrc && \
    echo "echo \"  \$ odoo-status         Status Odoo services\"" >> /opt/odoo/.bashrc && \
    echo "echo \"  \$ odoo-log            Navigate in your instance's odoo.log file\"" >> /opt/odoo/.bashrc && \
    echo "echo \"\"" >> /opt/odoo/.bashrc

USER odoo
ENV HOME=/opt/odoo
WORKDIR /data/odoo

RUN python3 -m venv /opt/odoo/venv \
 && /opt/odoo/venv/bin/pip install --upgrade pip setuptools wheel
ENV PATH="/opt/odoo/venv/bin:${PATH}"

COPY --chown=odoo:odoo ./requirements.txt /tmp/requirements.txt
RUN /opt/odoo/venv/bin/pip install --no-cache-dir -r /tmp/requirements.txt \
 && rm -f /tmp/requirements.txt

RUN code-server --install-extension ms-python.python \
    && code-server --install-extension jigar-patel.OdooSnippets \
    && code-server --install-extension ckolkman.vscode-postgres

USER root
COPY coder/Odoo.odoo-0.2.4.vsix /tmp/Odoo.vsix
USER odoo
RUN code-server --install-extension /tmp/Odoo.vsix
USER root
RUN rm -f /tmp/Odoo.vsix

COPY conf/supervisord.conf /etc/supervisor/supervisord.conf
COPY bin/* /usr/local/bin/
RUN chmod +x /usr/local/bin/*

EXPOSE 8069 8072 8080

USER odoo
ENTRYPOINT ["/usr/bin/tini","--","/usr/local/bin/entrypoint.sh"]

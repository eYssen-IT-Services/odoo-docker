FROM ubuntu:noble
LABEL maintainer="eYssen IT Services <info@eyssen.hu>"

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

# Generate locale C.UTF-8 for postgres and general locale data
ENV LANG=en_US.UTF-8

# Retrieve the target architecture to install the correct wkhtmltopdf package
ARG TARGETARCH

# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
RUN apt-get update && \
    apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        git \
        ca-certificates \
        curl \
        dirmngr \
        fonts-dejavu-core \
        fonts-dejavu-extra \
        fonts-liberation \
        fonts-noto-cjk \
        fonts-noto-core \
        fonts-noto-ui-core \
        fonts-noto-mono \
        gnupg \
        libssl-dev \
        node-less \
        nodejs \
        npm \
        python3-icu \
        python3-magic \
        python3-num2words \
        python3-odf \
        python3-pdfminer \
        python3-pip \
        python3-phonenumbers \
        python3-pyldap \
        python3-qrcode \
        python3-renderpm \
        python3-setuptools \
        python3-slugify \
        python3-tk \
        python3-vobject \
        python3-watchdog \
        python3-xlrd \
        python3-xlwt \
        python3-venv \
        python3-dev \
        build-essential \
        libxml2-dev \
        libxslt1-dev \
        zlib1g-dev \
        libsasl2-dev \
        libldap2-dev \
        libpq-dev \
        libjpeg-dev \
        libffi-dev \
        libssl-dev \
        libyaml-dev \
        wget \
        unzip \
        postgresql-client \
        xz-utils \
        vim \
        mc \
        lnav \
        iputils-ping \
        supervisor \
        figlet \
        less \
        libcairo2-dev \
        python3-cairo \
        python3-gi \
        pkg-config && \
    if [ -z "${TARGETARCH}" ]; then \
        TARGETARCH="$(dpkg --print-architecture)"; \
    fi; \
    WKHTMLTOPDF_ARCH=${TARGETARCH} && \
    case ${TARGETARCH} in \
    "amd64") WKHTMLTOPDF_ARCH=amd64 && WKHTMLTOPDF_SHA=967390a759707337b46d1c02452e2bb6b2dc6d59  ;; \
    "arm64")  WKHTMLTOPDF_SHA=90f6e69896d51ef77339d3f3a20f8582bdf496cc  ;; \
    "ppc64le" | "ppc64el") WKHTMLTOPDF_ARCH=ppc64el && WKHTMLTOPDF_SHA=5312d7d34a25b321282929df82e3574319aed25c  ;; \
    esac \
    && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.jammy_${WKHTMLTOPDF_ARCH}.deb \
    && echo ${WKHTMLTOPDF_SHA} wkhtmltox.deb | sha1sum -c - \
    && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
    && apt-get install -y locales \
    && sed -i 's/^# *\(.*UTF-8\)/\1/' /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# Install rtlcss (on Debian buster)
RUN npm install -g rtlcss

# Install Coder (web-based VS Code)
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Create Odoo user
RUN useradd -m -d /opt/odoo -U -r -s /bin/bash odoo

# Create a virtual environment
RUN python3 -m venv /opt/odoo/venv && \
    /opt/odoo/venv/bin/pip install --upgrade pip

# Copy commands
COPY bin/* /usr/local/bin/
RUN chmod +x /usr/local/bin/*

# Installing Python dependencies in the virtual environment
COPY ./requirements.txt /tmp/
RUN /opt/odoo/venv/bin/pip install --no-cache-dir -r /tmp/requirements.txt
RUN rm /tmp/requirements.txt

# Create directories
RUN mkdir /etc/odoo \
&& mkdir /var/lib/odoo \
&& mkdir /var/log/odoo \
&& mkdir -p /opt/odoo/.config/code-server/User \
&& mkdir -p /opt/odoo/.local/share/code-server/User

# Set permissions
RUN chown -R odoo:odoo /etc/odoo \
&& chown -R odoo:odoo /opt/odoo \
&& chown -R odoo:odoo /var/lib/odoo \
&& chown -R odoo:odoo /var/log/odoo \
&& chown -R odoo:odoo /opt/odoo/.config

# Expose Odoo and Coder services
EXPOSE 8069 8071 8072 8080

# Install extension for VS Code
USER odoo
RUN code-server --install-extension ms-python.python
# COPY coder/Odoo.odoo-0.2.4.vsix /extensions/Odoo.odoo-0.2.4.vsix
# RUN code-server --install-extension /extensions/Odoo.odoo-0.2.4.vsix
RUN code-server --install-extension jigar-patel.OdooSnippets
# RUN code-server --install-extension mstuttgart.odoo-snippets
RUN code-server --install-extension ckolkman.vscode-postgres

# Create welcome message
RUN echo 'echo -e "\n$(figlet -w 100 -f slant eYssen ERP Cloud)"' >> /opt/odoo/.bashrc && \
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

# Configure supervisord
USER root
COPY conf/supervisord.conf /etc/supervisor/supervisord.conf

# Start supervisord
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
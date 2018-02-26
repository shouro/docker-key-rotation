FROM openjdk:jre-alpine

LABEL maintainer="Gluu Inc. <support@gluu.org>"

# ===============
# Alpine packages
# ===============
RUN apk update && apk add --no-cache \
    py-pip \
    swig \
    openssl \
    openssl-dev \
    python-dev \
    gcc \
    musl-dev

# =============
# oxAuth client
# =============
ENV OX_VERSION 3.1.2.Final
ENV OX_BUILD_DATE 2018-01-18
# JAR files required to generate OpenID Connect keys
RUN mkdir -p /opt/key-rotation/javalibs \
    && wget -q https://ox.gluu.org/maven/org/xdi/oxauth-client/${OX_VERSION}/oxauth-client-${OX_VERSION}-jar-with-dependencies.jar -O /opt/key-rotation/javalibs/keygen.jar

# ======
# Python
# ======
RUN pip install -U pip
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# ==========
# misc stuff
# ==========
WORKDIR /opt/key-rotation
RUN mkdir -p /etc/certs
VOLUME /etc/certs
ENV GLUU_KV_HOST localhost
ENV GLUU_KV_PORT 8500
ENV GLUU_LDAP_URL localhost:1636
ENV GLUU_KEY_ROTATION_INTERVAL 48
ENV GLUU_KEY_ROTATION_CHECK 3600

COPY entrypoint.py /opt/key-rotation/entrypoint.py
CMD ["python", "/opt/key-rotation/entrypoint.py"]

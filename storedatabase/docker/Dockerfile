FROM postgres:17-alpine

# ติดตั้ง locales
RUN apk add --no-cache musl-locales musl-locales-lang

# ตั้งค่า locale
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Copy initialization scripts
COPY init.sql /docker-entrypoint-initdb.d/

# Expose the PostgreSQL port
EXPOSE 5432
FROM hashicorp/terraform:1.13.3 AS terraform

FROM debian:13-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV TERRAFORM=terraform

COPY --from=terraform /bin/terraform /usr/local/bin/terraform

RUN apt-get update \
    && apt-get install -y --no-install-recommends ansible python3 ca-certificates make \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
COPY CI-CD-proj-final /workspace/CI-CD-proj-final
COPY 02-terraform /workspace/02-terraform
COPY 03-ansible /workspace/03-ansible

WORKDIR /workspace/CI-CD-proj-final

CMD ["make", "ci"]

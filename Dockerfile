FROM node:22-bookworm AS installer

ARG AWS_CLI_VERSION=2.21.0

COPY aws_public_key.asc .

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-$(arch)-${AWS_CLI_VERSION}.zip" -o "awscliv2.zip" \
  && curl "https://awscli.amazonaws.com/awscli-exe-linux-$(arch)-${AWS_CLI_VERSION}.zip.sig" -o "awscliv2.sig" \
  && gpg --import aws_public_key.asc \
  && gpg --verify awscliv2.sig awscliv2.zip \
  && unzip awscliv2.zip \
  # The --bin-dir is specified so that we can copy the
  # entire bin directory from the installer stage into
  # into /usr/local/bin of the final stage without
  # accidentally copying over any other executables that
  # may be present in /usr/local/bin of the installer stage.
  && ./aws/install --bin-dir /aws-cli-bin/

FROM node:22-bookworm

COPY --from=installer /usr/local/aws-cli/ /usr/local/aws-cli/
COPY --from=installer /aws-cli-bin/ /usr/local/bin/

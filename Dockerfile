FROM node:20-alpine

RUN apk add --no-cache \
    git openssh-client curl bash python3 py3-pip make g++ docker-cli jq

RUN npm install -g @sourcegraph/amp typescript eslint prettier jest

WORKDIR /workspace

RUN addgroup -g 1001 -S ampuser && \
    adduser -S ampuser -u 1001 -G ampuser && \
    mkdir -p /home/ampuser/.config/amp /home/ampuser/.ssh && \
    chown -R ampuser:ampuser /home/ampuser

COPY --chown=ampuser:ampuser config/amp-settings.json /home/ampuser/.config/amp/settings.json
COPY --chown=ampuser:ampuser scripts/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

USER ampuser

ENV HOME=/home/ampuser
ENV AMP_CONFIG_DIR=/home/ampuser/.config/amp
ENV PATH="/home/ampuser/.local/bin:$PATH"

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["amp"]

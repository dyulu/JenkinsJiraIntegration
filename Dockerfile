FROM jenkinsci/blueocean:latest

USER root
# change docker sock permissions after moutn
RUN if [ -e /var/run/docker.sock ]; then chown jenkins:jenkins /var/run/docker.sock

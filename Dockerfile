# Dockerfile to create a CentOS 7 Elasticsearch host.
FROM centos:7
MAINTAINER Gary Rogers <gary-rogers@uiowa.edu>

# Install necessary packages and update the system
RUN yum update -y && \
    yum install -y wget tar which java-1.8.0-openjdk java-1.8.0-openjdk-devel && \
    yum clean all

# Add an elasticsearch user that ES will run as
RUN useradd elasticsearch -c 'Elasticsearch User' -d /home/elasticsearch

# Set up directories for Elasticsearch binaries and data
RUN mkdir -p /local/elasticsearch && \
    chown elasticsearch:elasticsearch /local/elasticsearch && \
    mkdir -p /local/data && \
    chown elasticsearch:elasticsearch /local/data

# Switch to the ES user. None of the rest needs root access.
USER elasticsearch

# Set some ENV variables to cut down on the typos.
ENV ES_HOME /local/elasticsearch
ENV ES_CONFIG /local/elasticsearch/config/elasticsearch.yml

# Pull Elasticsearch down from ES.org, expand it and move it into place
RUN cd /tmp && \
    wget --quiet https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.3.4.tar.gz && \
    tar xfz elasticsearch-1.3.4.tar.gz && \
    rm -f elasticsearch-1.3.4.tar.gz && \
    mv /tmp/elasticsearch-1.3.4/* /local/elasticsearch

VOLUME ["/local/data"]

# Define the ES config to point our data to the volume
RUN mkdir -p $ES_HOME/config && \
    touch $ES_CONFIG && \
    printf "path:\n" >> $ES_CONFIG && \
    printf "  data: /local/data/data\n" >> $ES_CONFIG && \
    printf "  logs: /local/data/logs\n" >> $ES_CONFIG && \
    printf "  plugins: /local/data/plugins\n" >> $ES_CONFIG && \
    printf "  work: /local/data/work\n" >> $ES_CONFIG

# What we run by default
CMD $ES_HOME/bin/elasticsearch

# Ports to expose
# NOTE! ES doesn't have any authentication by default. It's probably a bad idea
# to EXPOSE these ports without some proxy, or outside of other Docker containers
EXPOSE 9200
EXPOSE 9300

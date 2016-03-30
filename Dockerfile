FROM ubuntu:14.04
MAINTAINER Jadson Lourenço <jadsonlourenco@gmail.com>
LABEL Description="Mongodb cron backup to Google Cloud Storage (GCE)"

RUN apt-get update && \
  apt-get install -y software-properties-common python-software-properties curl

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 && \
  echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list && \
  apt-get update && \
  apt-get install -y mongodb-org

RUN add-apt-repository ppa:fkrull/deadsnakes && \
  apt-get update && \
  apt-get install -y python3.5 mercurial && \
  apt-get install -y python-pip

RUN pip install -e hg+https://bitbucket.org/dbenamy/devcron#egg=devcron
RUN mkdir /cron && \
    echo "* * * * * /cron/sample.sh" > /cron/crontab && \
    echo "echo hello world" > /cron/sample.sh && \
    chmod a+x /cron/sample.sh

RUN curl -s -O https://storage.googleapis.com/pub/gsutil.tar.gz && \
  tar xfz gsutil.tar.gz -C $HOME && \
  chmod 777 /root/gsutil && chmod 777 /root/gsutil/* && \
  rm gsutil.tar.gz

ENV CRON_TIME "0 1 * * *"

COPY ./mongodb-backup.sh /
RUN chmod +x /mongodb-backup.sh

COPY ./entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

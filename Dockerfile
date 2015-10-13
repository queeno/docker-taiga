FROM python:3.4.3-onbuild
MAINTAINER Ivan Pedrazas "ipedrazas@gmail.com"

ENV DEBIAN_FRONTEND noninteractive

ADD taiga-back /taiga-back
ADD taiga-front-dist /taiga-front-dist

COPY assets/config/docker-settings.py /taiga-back/settings/local.py
COPY assets/config/locale.gen /etc/locale.gen

RUN echo "LANG=en_US.UTF-8" > /etc/default/locale
RUN echo "LC_TYPE=en_US.UTF-8" > /etc/default/locale
RUN echo "LC_MESSAGES=POSIX" >> /etc/default/locale
RUN echo "LANGUAGE=en" >> /etc/default/locale

RUN apt-get update && apt-get install -y locales
RUN locale-gen en_US.UTF-8 && dpkg-reconfigure locales

ENV LANG en_US.UTF-8
ENV LC_TYPE en_US.UTF-8
ENV API_NAME localhost

RUN locale -a

RUN (cd /taiga-back && python manage.py collectstatic --noinput)

VOLUME ["/taiga-front-dist","/taiga-back/static","/taiga-back/media"]

EXPOSE 8000

WORKDIR /taiga-back

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]

FROM debian:latest

RUN apt-get update && apt-get install -y wget curl telnet

RUN wget https://dl.influxdata.com/influxdb/releases/influxdb_1.1.1_amd64.deb \
  && dpkg -i influxdb_1.1.1_amd64.deb

RUN wget https://dl.influxdata.com/telegraf/releases/telegraf_1.1.2_amd64.deb \
  && dpkg -i telegraf_1.1.2_amd64.deb

RUN wget https://dl.influxdata.com/chronograf/releases/chronograf_1.1.0~beta6_amd64.deb \
  && dpkg -i chronograf_1.1.0~beta6_amd64.deb

RUN wget https://dl.influxdata.com/kapacitor/releases/kapacitor_1.1.1_amd64.deb \
  && dpkg -i kapacitor_1.1.1_amd64.deb

RUN influxd config > /etc/influxdb/influxdb.generated.conf

RUN apt-get update && apt-get install -y supervisor net-tools

# Configure supervisord
ADD ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD ./influxdb.conf /etc/influxdb/influxdb.conf
ADD ./telegraf.conf /opt/telegraf/telegraf.conf
ADD ./chronograf.toml /opt/chronograf/config.toml
RUN mkdir /opt/kapacitor/
ADD ./kapacitor.conf /opt/kapacitor/kapacitor.conf
RUN rm *.deb
RUN mkdir -p /data/chronograf && chown -R chronograf:chronograf /data/chronograf && chmod 777 /data/chronograf

VOLUME /data/influx/data
VOLUME /data/influx/meta
VOLUME /data/influx/wal
VOLUME /data/kapacitor
VOLUME /data/chronograf

EXPOSE  80
EXPOSE 8125/udp
EXPOSE 10000
EXPOSE 8083
EXPOSE 8086
EXPOSE 8088

CMD     ["/usr/bin/supervisord"]

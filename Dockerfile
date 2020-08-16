FROM google/dart:2.9.1

WORKDIR /app

ADD pubspec.* /app/
RUN pub get
ADD . /app
RUN pub get --offline

CMD []
ENTRYPOINT ["/usr/bin/dart", "src/main.dart"]

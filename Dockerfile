# Официальный sing-box linux-armv5, упакованный для контейнера MikroTik.
# В контексте сборки должен лежать бинарник sing-box из архива
# sing-box-<версия>-linux-armv5.tar.gz. Скрипт build.sh кладёт его сам.
FROM scratch
COPY sing-box /usr/local/bin/sing-box
ENTRYPOINT ["/usr/local/bin/sing-box"]

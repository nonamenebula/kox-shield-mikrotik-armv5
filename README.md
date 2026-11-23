# KOX Shield — образ sing-box для MikroTik ARM v5

Отдельный образ контейнера для роутеров, у которых процессор выполняет только **ARM v5** (`firmware-type: en7562`). Обычный образ `ghcr.io/sagernet/sing-box` на них сразу завершается с `Illegal instruction`.

Проверенная модель: **hEX Refresh, E50UG**. Тот же образ нужен любой плате, у которой команда ниже показывает `en7562`:

```routeros
/system routerboard print
```

Установщик для остальных роутеров: [kox-shield-mikrotik](https://github.com/nonamenebula/kox-shield-mikrotik). На процессоре `en7562` он сам берёт этот образ.

## Что внутри

| | |
|---|---|
| Программа | официальный [sing-box 1.11.9](https://github.com/SagerNet/sing-box/releases/tag/v1.11.9), сборка `linux-armv5` |
| Система образа | `linux/arm/v5` |
| Файл | статически собранный ELF ARM EABI5 |
| Запуск | `sing-box run -c /etc/sing-box/config.json` |

Формат конфига тот же, что у установщика с образом 1.11.7. Подписку заново собирать не нужно.

Готовый архив для роутера:

- выпуск GitHub: `sing-box-1.11.9-armv5.tar` в [Releases](https://github.com/nonamenebula/kox-shield-mikrotik-armv5/releases)
- зеркало, если с роутера GitHub не открывается: `https://kox.nonamenebula.ru/static/kox-mikrotik/sing-box-1.11.9-armv5.tar`

## Если контейнер уже ставился обычным образом

Папку `kox-mount` не удаляйте: в ней конфиг. Папку старого контейнера `kox-singbox` удалите. Если контейнер уже остановлен, ошибку первой команды можно пропустить.

```routeros
/container/stop [find where comment="kox-shield-singbox"]
:delay 3s
/container/remove [find where comment="kox-shield-singbox"]
```

```routeros
/tool fetch url="https://kox.nonamenebula.ru/static/kox-mikrotik/sing-box-1.11.9-armv5.tar" mode=https dst-path=kox-singbox-armv5.tar
/container/add file=kox-singbox-armv5.tar hostname=kox-singbox interface=docker-xray-vless-veth root-dir=kox-singbox logging=yes start-on-boot=yes mountlists=kox-singbox-cfg dns=172.18.20.5 cmd="run -c /etc/sing-box/config.json" comment="kox-shield-singbox"
/container/start [find where comment="kox-shield-singbox"]
```

Архив около 11 МБ, после распаковки каталог контейнера около 31 МБ. На hEX Refresh диск 128 МБ, перед загрузкой старый контейнер нужно убрать. Когда контейнер останется в состоянии running, файл `kox-singbox-armv5.tar` можно удалить.

## Проверка образа

На машине с эмуляцией `linux/arm/v5` проверено:

- `sing-box version` печатает `1.11.9` и завершается без `Illegal instruction`;
- `sing-box check` принимает конфиг того же вида, что собирает установщик: TUN `172.19.0.1/30`, Hysteria2, `auto_route`;
- `sing-box run` поднимает интерфейс `tun0`.

Дальше на обычном компьютере нет фильтра RouterOS, поэтому правила маршрутизации внутри контейнера там не проверяются. Рабочий туннель до сервера KOX подтверждается уже на роутере: контейнер остаётся `running`, в логе нет `Illegal instruction`.

## Сборка заново

Нужны Docker Buildx и официальный архив `linux-armv5`. Бинарник в git не хранится.

```sh
sh build.sh 1.11.9
```

На выходе файл `sing-box-1.11.9-armv5.tar`.

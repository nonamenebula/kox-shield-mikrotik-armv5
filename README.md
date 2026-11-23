# KOX Shield — MikroTik с процессором ARM v5

Образ sing-box для роутеров, у которых `/system routerboard print` показывает `firmware-type: en7562`. Обычный образ `ghcr.io/sagernet/sing-box:v1.11.7` на них сразу завершается с `Illegal instruction`.

Проверенная модель: **hEX Refresh (E50UG)**. Тот же образ нужен любой плате с `en7562`.

Это не отдельная программа. Маршруты и команды живут в основном проекте: **[kox-shield-mikrotik](https://github.com/nonamenebula/kox-shield-mikrotik)**. Здесь только образ контейнера и то, чем первый запуск на ARM v5 отличается.

Подойдёт подписка KOX или своя ссылка. Ограничения нет: можно поставить серверы KOX, свою подписку, свой Hysteria2 (`hy2://` или `hysteria2://`) или свой VLESS.

## Первый запуск

Установщик **2.9** сам скачивает этот образ, если видит процессор `en7562`. Образ руками собирать не нужно.

1. Подготовьте роутер: пакет `container` и выключенный FastTrack. Шаги: [подготовка RouterOS](https://github.com/nonamenebula/kox-shield-mikrotik#шаг-1-подготовьте-routeros) и [FastTrack](https://github.com/nonamenebula/kox-shield-mikrotik#шаг-2-отключите-fasttrack).
2. Запустите установщик. Адрес личного кабинета у каждого свой, его присылает бот, поэтому здесь его нет.
   - Подписка KOX. Бот [@kox_nonamenebula_bot](https://t.me/kox_nonamenebula_bot) присылает готовую команду лично, в ней уже ваша ссылка. Её и вставляйте.
   - Своя ссылка. Варианты в [шаге установки](https://github.com/nonamenebula/kox-shield-mikrotik#шаг-3-запустите-установщик): своя подписка, Hysteria2 или VLESS.

Если команду для подписки KOX собираете сами, подставьте свой токен:

```routeros
:global koxSubUrl "https://kox.nonamenebula.ru/c/YOUR_TOKEN"
/tool fetch url=https://raw.githubusercontent.com/nonamenebula/kox-shield-mikrotik/main/install.rsc
/import file-name=install.rsc
```

Дождитесь окончания. В логе установщика должна быть строка про процессор `en7562` и образ sing-box 1.11.9, не `ghcr.io/sagernet/sing-box:v1.11.7`.

3. Проверьте, что контейнер запущен:

```routeros
/container/print
/log/print where topics~"container"
```

Статус `running`, в логе нет `Illegal instruction`. Дальше — [проверка туннеля](https://github.com/nonamenebula/kox-shield-mikrotik#шаг-4-проверка): ping через таблицу `r_to_vpn` и список `to_vpn`.

На диске hEX Refresh 128 МБ. Архив образа около 11 МБ, после распаковки каталог контейнера около 31 МБ. Когда контейнер остался `running`, файл `kox-singbox-armv5.tar` можно удалить.

## Дальше: серверы, списки, включение

Смена локации, категории сайтов и включение туннеля описаны в основной инструкции. Образ для этого повторно ставить не нужно.

| Что сделать | Куда смотреть |
|---|---|
| Своя ссылка вместо подписки KOX | [Шаг установки](https://github.com/nonamenebula/kox-shield-mikrotik#шаг-3-запустите-установщик) |
| Несколько локаций: список и переключение | [`$kox switch`](https://github.com/nonamenebula/kox-shield-mikrotik#у-вас-подписка-kox-shield-рекомендуется) |
| Какие сайты идут через VPN | [Категории доменов](https://github.com/nonamenebula/kox-shield-mikrotik#категории-доменов) |
| Статус, логи, выключить туннель | [Полезные команды](https://github.com/nonamenebula/kox-shield-mikrotik#полезные-команды) |
| Удалить KOX с роутера | [Удаление](https://github.com/nonamenebula/kox-shield-mikrotik#удаление) |

Переключение сервера, если скрипт ещё не загружен в эту сессию терминала:

```routeros
/import file-name=kox-switch.rsc
$kox switch
$kox switch 1
```

Без номера печатается список локаций и пинг. С номером контейнер переключается на эту локацию. Номер берите из списка: порядок серверов может меняться. Для одной своей ссылки `hy2://` или `vless://` этот список не нужен, сервер задаётся при установке.

## Контейнер уже установлен и падает

Так бывает после установщика старше 2.9: маршруты и конфиг уже есть, а контейнер скачал обычный образ и сразу остановился с `Illegal instruction`. Заново всю установку запускать не нужно. Папку `kox-mount` не удаляйте, в ней конфиг. Удалите только старый контейнер и его папку `kox-singbox`.

Если контейнер уже остановлен, ошибку первой команды можно пропустить.

```routeros
/container/stop [find where comment="kox-shield-singbox"]
:delay 3s
/container/remove [find where comment="kox-shield-singbox"]
```

В **Files** удалите папку `kox-singbox`, если она осталась. Затем:

```routeros
/tool fetch url="https://kox.nonamenebula.ru/static/kox-mikrotik/sing-box-1.11.9-armv5.tar" mode=https dst-path=kox-singbox-armv5.tar
/container/add file=kox-singbox-armv5.tar hostname=kox-singbox interface=docker-xray-vless-veth root-dir=kox-singbox logging=yes start-on-boot=yes mountlists=kox-singbox-cfg dns=172.18.20.5 cmd="run -c /etc/sing-box/config.json" comment="kox-shield-singbox"
/container/start [find where comment="kox-shield-singbox"]
/container/print
```

Подождите, пока статус станет `running`. В логе не должно быть `Illegal instruction`. Если локаций несколько, сервер выбирается командами из раздела выше. Файл `kox-singbox-armv5.tar` можно удалить.

Тот же архив, если зеркало недоступно: [выпуск v1.11.9](https://github.com/nonamenebula/kox-shield-mikrotik-armv5/releases/tag/v1.11.9).

## Что внутри образа

| | |
|---|---|
| Программа | официальный [sing-box 1.11.9](https://github.com/SagerNet/sing-box/releases/tag/v1.11.9), сборка `linux-armv5` |
| Система образа | `linux/arm/v5` |
| Запуск | `sing-box run -c /etc/sing-box/config.json` |

Формат конфига тот же, что у установщика с образом 1.11.7. Ссылку заново собирать не нужно: подойдёт и подписка KOX, и своя.

На эмуляции ARM v5 проверено: `sing-box version` печатает 1.11.9, `sing-box check` принимает конфиг установщика, `sing-box run` поднимает `tun0`. Живой туннель до сервера проверяется уже на роутере.

Собрать архив заново: `sh build.sh 1.11.9`. Нужны Docker Buildx и официальный архив `linux-armv5`. Бинарник в git не хранится.

# Репозиторий для сборки кастомной версии smartmontools
Поддерживаются два дистрибутива ubuntu: 16.04 и 18.04. По умолчанию используется ubuntu 16.04.
```
ubuntu 16.04 - xenial
ubuntu 18.04 - bionic
```
## Сборка
Клонируем себе репу:
```bash
git clone git@github.com:OrangeAppsRu/build-smartmontools.git
cd build-smartmontools
```
### Подготовка
На первом этапе вам нужно отредактировать файлы `debian_changelog_*` и `debian_control_*` в зависимости от того для какой версии ubuntu вы хотите собрать. `debian_control_*` часто  не требуется редактирования. Если хотите чтобы версия dpkg пакета называлась определенным образом, то вам необходимл испоавить файл`debian_changelog_*` (**Будьте осторожны, changelog имеет четко определнный формат, лишние пробелы, табы, пропуски строк могут сломать сборку**)

Например для ubuntu 16.04 (xenial) я хочу чтобы версия пакета называлась `7.0~xenial~tapclap`. Тогда в начало файла `debian_changelog_xenial` я додавлю следущее:
```
smartmontools (7.0~xenial~tapclap) unstable; urgency=medium

  * Update to 7.0 version

 -- Dmitry Sergeev <identw@gmail.com>  Mon, 27 May 2019 10:16:00 +0000

```
**Заметьте: последний отступ строки обязятелен.**

### Сборка образа docker
```bash
docker build -t build-smartmontools:xenial ./
```
### Сборка smartmontools
Теперь у вас готов образ, в котором есть все что нужно для сборки. Достаточно его запустить и собрать smartmontools
```bash
docker run --rm -it -v $PWD:/root/share build-smartmontools:xenial bash # запустили контейнер и прокинули в него текущую директоию, которая примонтируется в /root/share внутри контейнера
# Теперь мы внутри контейнера 
# В зависимости от того, какой вы аргумент указывали для url_smartmontools_archive. Заходим в папку версии smartmontools которую хотите сбилдить. По умолчанию smartmontools-7.0
cd smartmontools-7.0
# билдим
debuild -b -uc -us
# После билда, собранный архив будет лежать на директорию выше
cd ..
# копируем полученный архив в /root/share
cp -fv *.deb /root/share
# выходим из контейнера (он удалиться сам благодоря опции --rm)
```
В текущей директории у вас будет готоый **deb** пакет

### Сборка для ubuntu18.04(bionic)
```bash
docker build --build-arg ubuntu_version=18.04 --build-arg ubuntu_codename=bionic -t build-smartmontools:bionic ./
```
```bash
docker run --rm -it -v $PWD:/root/share build-smartmontools:bionic bash
cd smartmontools-7.0
debuild -b -uc -us
cp -fv ../*.deb /root/share
```

### Собираем для другой версии smartmontools
В Dockerfile прописана версия 7.0. Это можно поменять, переопределив `url_smartmontools_archive`:
```bash
docker build --build-arg url_smartmontools_archive='https://kent.dl.sourceforge.net/project/smartmontools/smartmontools/6.6/smartmontools-6.6.tar.gz' -t build-smartmontools:xenial ./
```
Редактируем файл `debian_changelog_xenial`, а именно в начало файла добавляем:
```
smartmontools (6.6~xenial~tapclap) unstable; urgency=medium

  * Update to 6.6 version

 -- Dmitry Sergeev <identw@gmail.com>  Mon, 27 May 2019 10:16:00 +0000

```
Если в файле уже есть записи о версиях выше, их нужно удалить.
```bash
docker run --rm -it -v $PWD:/root/share build-smartmontools:xenial bash
cd smartmontools-6.6
debuild -b -uc -us
cp -fv ../*.deb /root/share
```

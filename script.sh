#!/bin/bash

# функция вызова справки для понимания работы скрипта
usage() {
    echo "Usage: $0 [-i] -u <username> -d <working_directory> || -h "
    echo "-u имя пользователя, которое будет создано (для не интерактивного режима)"
    echo "-d рабочая директория для пользователя (для не интерактивного режима)"
    echo "-i интерактивный режим"
    echo "-h помощь" 
    exit 1
}

# bool переменная интерактивного режима
INTERACTIVE_MODE=false

# проверяем параметры -h для вызова справки
while getopts "u:d:i" opt; do
    case ${opt} in
        u) USERNAME=${OPTARG};;
        d) WORKDIR=${OPTARG};;
        i) INTERACTIVE_MODE=true;;
        h) usage;;
        *) usage;;
    esac
done

# определяем текущего пользователя и рабочую директорию, если аргументы не указаны
if [ -z "${USERNAME}" ]; then
    USERNAME=$(whoami)
fi

if [ -z "${WORKDIR}" ]; then
    WORKDIR=$(pwd)
fi

# если интерактивный режим == true => запрашиваем у пользователя ввод параметров
if [ "${INTERACTIVE_MODE}" = true ]; then
    read -p "Введите имя пользователя: " USERNAME
    read -p "Введите рабочую директорию: " WORKDIR
fi

# -y для автоматического подтверждения установки пакетов

dpkg --add-architecture i386

# устанавливаем обновления системы
apt-get update
apt-get upgrade -y

apt-get install -y python2 libc6:i386 zlib1g:i386 libpcre3-dev nodejs npm luajit rename php-cli fakeroot libfakeroot:i386 locales locales-all sudo mc bc git curl libcurl4 flex bison automake pkg-config libtool vim python-numpy libssl-dev rename mtd-utils squashfs-tools wget git-lfs

# !Раскоментировать если pip2 не установлен!
#curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py
#sudo python2 get-pip.py

# создаём симлинк для libfakeroot
ln -s /usr/lib/i386-linux-gnu/libfakeroot /usr/lib32/libfakeroot
ln -s /usr/bin/automake /usr/bin/automake-1.14

# устанавливаем grunt и beautifier через npm (используем -g для глобальной установки и --save-dev для сохранения в devDependencies)
npm install -g grunt-cli
npm install -g beautifier --save-dev
pip2 install sentry_sdk gitpython

# coздаём пользователя и рабочую директорию, если запускается не под текущим пользователем
if [ "${USERNAME}" != "$(whoami)" ]; then
    useradd -m -d ${WORKDIR} -s /bin/bash ${USERNAME}
    chown ${USERNAME}:${USERNAME} ${WORKDIR}
fi

# генерируем ssh, сохраняем ключ в файл ${WORKDIR}/.ssh/id_rsa
sudo -u ${USERNAME} ssh-keygen -t rsa -b 4096 -N"" -f ${WORKDIR}/.ssh/id_rsa

# печатаем публичный ssh ключ для копирования
echo ""
echo ""
echo "Публичный SSH ключ:"
cat ${WORKDIR}/.ssh/id_rsa.pub
echo ""
echo ""


# ставим скрипт на паузу для копирования ключа и настройки аккаунта репозитория
echo "Введите полученный ключ в gitlab. Нажмите Enter, чтобы продолжить."
read -r

cd ${WORKDIR}
sudo -u ${USERNAME} mkdir repositoryes
cd repositoryes
# клонируем какой-то/какие-то репозиторий с github, username и repository заменяем на свои
#sudo -u ${USERNAME} git clone https://github.com/username/repository.git ${WORKDIR}/repositoryes

echo "bootstrap успешно выполнен!"

#! /bin/bash

# Скачивание данных
curl -s https://raw.githubusercontent.com/GreatMedivack/files/master/list.out > data

# Присвоение имени сервера
SERVER=${1:-"DEFAULT"}

# Определение времени
DATE=$(date "+%d_%m_%Y")

echo "$SERVER"
echo "$DATE"

# Создание файла с нерабочими подами
FAILED_PODS_FILE="$SERVER"_"$DATE"_failed.out
touch "$FAILED_PODS_FILE"

# Заполнение файла данными
awk '/Error|CrashLoopBackOff/ { print $1 }' data > "$FAILED_PODS_FILE"

# Создание файла с рабочими подами
RUNNING_PODS_FILE="$SERVER"_"$DATE"_running.out

# Заполнение файла данными
awk '/Running/ { print $1 }' data > "$RUNNING_PODS_FILE"

# Нормализация данных
while read -r line; do
    echo "$line" | awk -F"-" '{ print $NF }' #вывод последнего столбца строки
    echo "$line" | awk -F"-" '{ print $(NF-1)}' #вывод предпоследнего столбца строки
done < "$FAILED_PODS_FILE"

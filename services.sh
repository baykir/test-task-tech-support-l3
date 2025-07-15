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
# while read -r line; do
#     echo "$line" | awk -F"-" '{ print $NF }' #вывод последнего столбца строки
#     echo "$line" | awk -F"-" '{ print $(NF-1)}' #вывод предпоследнего столбца строки
# done < "$FAILED_PODS_FILE"
sed -i -E 's/-[a-z0-9]{10,}-[a-z0-9]{5,}$//' "$FAILED_PODS_FILE"
sed -i -E 's/-[a-z0-9]{10,}-[a-z0-9]{5,}$//' "$RUNNING_PODS_FILE"

# Создание отчёта
touch "$SERVER"_"$DATE"_report.out
chmod 644 "$SERVER"_"$DATE"_report.out

# Подсчёт работающих сервисов
RUNNING_SERVICES=$(wc -l "$RUNNING_PODS_FILE" | cut -d " " -f 1)
FAILED_SERVICES=$(wc -l "$FAILED_PODS_FILE" | cut -d " " -f 1)
USER=$(whoami)
REPORT_DATE=$(date "+%d/%m/%y")
echo "Количество работающих сервисов: $RUNNING_SERVICES" > "$SERVER"_"$DATE"_report.out
echo "Количество сервисов с ошибками: $FAILED_SERVICES" >> "$SERVER"_"$DATE"_report.out
echo "Имя системного пользователя: $USER" >> "$SERVER"_"$DATE"_report.out
echo "Дата: $REPORT_DATE" >> "$SERVER"_"$DATE"_report.out

# Поиск ранее сформированного отчета
FOUND_REPORTS=$(find archives -name "$SERVER"_"$DATE".tar | wc -l)
if [ "$FOUND_REPORTS" -lt 1 ]; then
    tar --create --file "$SERVER"_"$DATE".tar DEFAULT*
    mv "$SERVER"_"$DATE".tar archives
fi

# Удаление временных файлов
rm data DEFAULT*

# # Создание архива с отчётами
# tar --create --file archive.tar DEFAULT*
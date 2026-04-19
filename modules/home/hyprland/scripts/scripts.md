# Hyprland Scripts

Документация скриптов в папке `scripts/`.

## Оглавление

- [Системные](#системные)
- [Дисплей и яркость](#дисплей-и-яркость)
- [Звук](#звук)
- [Скриншоты и медиа](#скриншоты-и-медиа)
- [Окна и управление](#окна-и-управление)
- [Темы и стиль](#темы-и-стиль)
- [Клавиатура и раскладки](#клавиатура-и-раскладки)
- [Утилиты](#утилиты)
- [Специальные](#специальные)

---

## Системные

### Battery.sh
Мониторинг заряда батареи.

```bash
./Battery.sh   # Battery: 85% (Charging)
```

### UptimeNixOS.sh
Время работы системы и информация о сборке NixOS.

### LockScreen.sh
Блокировка сеанса через `loginctl`.

### Wlogout.sh
Меню выключения (power menu).

### Hypridle.sh
Переключение демона hypridle (idle daemon).

### GameMode.sh
Отключение анимаций для игр.

### Hyprsunset.sh
Управление ночным светом (цветовой температурой).

| Действие | Описание |
|----------|----------|
| `toggle` | Включить/выключить |
| `status` | JSON для waybar |
| `init` | Инициализация с сохранённым состоянием |

### AirplaneMode.sh
Переключение режима "в самолёте" (WiFi).

### Polkit-NixOS.sh
Аутентификация Polkit для NixOS.

### PortalHyprland.sh
Обработка порталов для Hyprland.

---

## Дисплей и яркость

### Brightness.sh
Управление яркостью подсветки через `brightnessctl`.

| Действие | Описание |
|----------|----------|
| `--get` | Текущий процент |
| `--inc` | +10% |
| `--dec` | -10% |

### BrightnessKbd.sh
Управление яркостью клавиатуры.

### ChangeBlur.sh
Изменение размытия окон.

### Hyprsunset.sh
См. выше в разделе Системные.

---

## Звук

### Volume.sh
Управление громкостью.

| Действие | Описание |
|----------|----------|
| `--get` | Текущая громкость |
| `--inc` | +5% |
| `--dec` | -5% |
| `--toggle` | Mute/unmute |
| `--toggle-mic` | Mute микрофона |
| `--get-icon` | Иконка громкости |
| `--mic-inc` | Громкость микрофона + |
| `--mic-dec` | Громкость микрофона - |

### Sounds.sh
Воспроизведение системных звуков.

---

## Скриншоты и медиа

### ScreenShot.sh
Захват скриншотов.

| Действие | Описание |
|----------|----------|
| `--now` | Снять сейчас |
| `--in5` | Через 5 секунд |
| `--in10` | Через 10 секунд |
| `--win` | Активное окно |
| `--area` | Выбор области |
| `--swappy` | Редактировать в swappy |

### MediaCtrl.sh
Управление медиаплеером.

| Действие | Описание |
|----------|----------|
| `--nxt` | Следующий трек |
| `--prv` | Предыдущий трек |
| `--pause` | Пауза/play |
| `--stop` | Стоп |

---

## Окна и управление

### Dropterminal.sh
Выпадающий терминал (scratchpad).

```bash
./Dropterminal.sh kitty
./Dropterminal.sh "kitty -e htop"
```

### OverviewToggle.sh
Обзор рабочего стола (AGS или rofi).

### KeyBinds.sh
Поиск привязок клавиш через rofi.

### KeyHints.sh
Показать все привязки клавиш.

### KillActiveProcess.sh
Закрыть активное окно.

### hypr-toggle-windows.sh
Переключение окон.

### update_WindowRules.sh
Обновить windowrules.

### Tak0-Autodispatch.sh
Автоматическое переключение окон (отключение фокуса).

### Tak0-Per-Window-Switch.sh
Настройка переключения для каждого окна.

---

## Темы и стиль

### DarkLight.sh
Переключение между светлой и тёмной темой.

```bash
./DarkLight.sh   # Переключить тему
```

### ThemeChanger.sh
Смена обоев.

### WallustSwww.sh
Применить цвета wallust к awww.

### WaybarScripts.sh
Настройка скриптов waybar.

### WaybarLayout.sh
Настройка раскладки waybar.

### WaybarStyles.sh
Настройка стилей waybar.

### WaybarCava.sh
Настройка cava для waybar.

### Refresh.sh
Перезагрузить конфигурацию (waybar, rofi, swaync).

### RefreshNoWaybar.sh
Перезагрузить без waybar.

### DarkLight.sh
См. выше.

### Animations.sh
Выбор предустановок анимаций.

---

## Клавиатура и раскладки

### KeyboardLayout.sh
Переключение раскладок клавиатуры.

### KeybindsLayoutInit.sh
Инициализация переключателя раскладок.

### ChangeLayout.sh
Изменение конфигурации раскладок.

### TouchPad.sh
Включение/выключение тачпада.

### Keybinds_parser.py
Парсер привязок для отображения.

---

## Утилиты

### ClipManager.sh
Менеджер истории буфера обмена.

- Выбор через rofi
- `Ctrl+Delete` — удалить запись
- `Alt+Delete` — очистить всю историю

### RofiSearch.sh
Поиск в интернете.

### RofiEmoji.sh
Вставка эмодзи.

### RofiThemeSelector.sh
Выбор темы rofi.

### RofiThemeSelector-modified.sh
Выбор модифицированной темы rofi.

### Kool_Quick_Settings.sh
Быстрые настройки.

### MonitorProfiles.sh
Профили мониторов.

### UserConfigsSwitcher.sh
Переключение профилей конфигурации.

### config_picker.sh
Выбор предустановок конфигурации.

### Kitty_themes.sh
Выбор темы терминала Kitty.

### Sounds.sh
См. выше.

### ThemeChanger.sh
См. выше.

---

## Специальные

### OsuLaunch.sh
Запуск osu!.

### PortalHyprland.sh
См. выше.

### Polkit-NixOS.sh
См. выше.

### Keybinds_parser.py
Парсер привязок (Python).

### songdetail.sh
Детали трека для waybar.

---

## Таблица быстрого доступа

| Категория | Скрипт | Назначение |
|-----------|--------|------------|
| Система | Battery.sh | Батарея |
| Система | UptimeNixOS.sh | Uptime |
| Система | LockScreen.sh | Блокировка |
| Система | Wlogout.sh | Меню выключения |
| Система | Hypridle.sh | Idle daemon |
| Яркость | Brightness.sh | Подсветка |
| Яркость | BrightnessKbd.sh | Подсветка клавиатуры |
| Звук | Volume.sh | Громкость |
| Скриншот | ScreenShot.sh | Скриншоты |
| Медиа | MediaCtrl.sh | Управление плеером |
| Окна | Dropterminal.sh | Выпадающий терминал |
| Окна | KeyBinds.sh | Поиск привязок |
| Окна | KeyHints.sh | Справка по клавишам |
| Тема | DarkLight.sh | Светлая/тёмная |
| Тема | ThemeChanger.sh | Обои |
| Тема | Refresh.sh | Перезагрузка |
| Клавиатура | KeyboardLayout.sh | Раскладки |
| Утилита | ClipManager.sh | Буфер обмена |
| Утилита | RofiSearch.sh | Поиск |
| Утилита | RofiEmoji.sh | Эмодзи |
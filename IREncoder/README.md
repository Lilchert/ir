## Моторизированная тележка управляемая по ИК от стандартного пульта ДУ 
### Модуль цифровой схемы для кодирования 32-битных команд в ИК сигналы стандартного формата по NECx2 протоколу
Модуль предназначен для генерации ИК сигналов в формате, совместимом со стандартными пультами ДУ (NECx2 протокол). Он преобразует 32-битные команды в модулированные ИК-импульсы с несущей частотой 36 кГц, показанные на рисунке, которые могут быть приняты ИК-приемником.
Модуль спроектирован для работы на плате ["Карно"](https://github.com/Fabmicro-LLC/Karnix_ASB-254), на базе ПЛИС Lattice ECP5.

<p align="center">
  <img width="800" height="36" src="https://github.com/user-attachments/assets/f6c0f133-2d66-46fb-931a-a5c632fb35ed">
</p>

#### Входные сигналы:
* rst - сигнал сброса;
* clk - тактовая частота;
* cmd - 32-битная команда;
* valid - сигнал валидности.

#### Выходные сигналы:
* ready - сигнал готовности;
* ir_output - модулированные ИК-импульсы.

#### Формат ИК сигнала
Каждая команда передается в следующем формате:
1. Старт-последовательность:
   * 4.5 мс несущей;
   * 4.5 мс паузы.
2. 32 бита данных:
   * 1: 0.55 мс несущей + 1.65 мс паузы;
   * 0: 0.55 мс несущей + 0.55 мс паузы.

#### Тестирование модуля на ОС Linux:
1. Установить тулы YosysHQ, openFPGALoader, make;
2. Скачать папку IREncoder в любую рабочую директорию;
3. Внутри директории IREncoder выполнить `make upload`.

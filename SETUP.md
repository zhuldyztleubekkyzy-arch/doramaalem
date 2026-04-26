# Инструкция по настройке проекта "Дорама Әлем"

## Быстрый старт

### Шаг 1: Настройка Firebase

1. Перейдите на [Firebase Console](https://console.firebase.google.com/)
2. Создайте новый проект или выберите существующий
3. Добавьте Android приложение:
   - Package name: `com.example.dorama_alem` (или ваш)
   - Скачайте `google-services.json`
   - Поместите в `android/app/google-services.json`
4. Добавьте iOS приложение:
   - Bundle ID: `com.example.doramaAleem` (или ваш)
   - Скачайте `GoogleService-Info.plist`
   - Поместите в `ios/Runner/GoogleService-Info.plist`
5. Включите Authentication > Email/Password
6. Для сервера:
   - Project Settings > Service Accounts
   - Нажмите "Generate new private key"
   - Сохраните JSON файл как `server/firebase-service-account-key.json`

### Шаг 2: Настройка Flutter приложения

1. Установите зависимости:
```bash
flutter pub get
```

2. Настройте Firebase в Flutter:
```bash
# Установите FlutterFire CLI если еще не установлен
dart pub global activate flutterfire_cli

# Настройте Firebase
flutterfire configure
```

3. Обновите API URL в `lib/services/api_service.dart`:
   - Для Android эмулятора: `http://10.0.2.2:3000/api`
   - Для iOS симулятора: `http://localhost:3000/api`
   - Для физического устройства: `http://YOUR_IP:3000/api`

### Шаг 3: Настройка PostgreSQL

1. Установите PostgreSQL (если еще не установлен)
2. Создайте базу данных:
```sql
CREATE DATABASE dorama_alem;
```

3. Создайте пользователя (опционально):
```sql
CREATE USER dorama_user WITH PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE dorama_alem TO dorama_user;
```

### Шаг 4: Настройка Backend сервера

1. Перейдите в директорию сервера:
```bash
cd server
```

2. Установите зависимости:
```bash
npm install
```

3. Создайте файл `.env`:
```bash
cp env.example .env
```

4. Отредактируйте `.env`:
```env
PORT=3000
NODE_ENV=development

DB_HOST=localhost
DB_PORT=5432
DB_NAME=dorama_alem
DB_USER=postgres
DB_PASSWORD=your_password

FIREBASE_SERVICE_ACCOUNT_KEY=./firebase-service-account-key.json
ALLOWED_ORIGINS=http://localhost:3000
```

5. Запустите миграции:
```bash
npm run migrate
```

6. Запустите сервер:
```bash
# Development mode (с автоперезагрузкой)
npm run dev

# Production mode
npm start
```

### Шаг 5: Запуск Flutter приложения

1. Убедитесь, что сервер запущен
2. Запустите Flutter приложение:
```bash
flutter run
```

## Проверка работы

1. **Сервер**: Откройте `http://localhost:3000/health` в браузере
   - Должен вернуть: `{"status":"OK","message":"Сервер жұмыс істеп тұр"}`

2. **Flutter приложение**:
   - Запустите приложение
   - Зарегистрируйтесь с новым аккаунтом
   - Войдите в систему
   - Должен отобразиться список дорам

## Решение проблем

### Firebase ошибки

- **Ошибка**: "Firebase not initialized"
  - **Решение**: Убедитесь, что `google-services.json` и `GoogleService-Info.plist` на месте
  - Запустите `flutterfire configure`

### База данных ошибки

- **Ошибка**: "Connection refused"
  - **Решение**: Убедитесь, что PostgreSQL запущен
  - Проверьте настройки в `.env`

- **Ошибка**: "Table does not exist"
  - **Решение**: Запустите миграции: `npm run migrate`

### API ошибки

- **Ошибка**: "Network error" в Flutter
  - **Решение**: Проверьте URL в `api_service.dart`
  - Для физического устройства используйте IP адрес компьютера
  - Убедитесь, что сервер запущен

- **Ошибка**: "401 Unauthorized"
  - **Решение**: Убедитесь, что Firebase токен передается правильно
  - Проверьте настройки Firebase Admin SDK

## Следующие шаги

1. Добавьте больше дорам через API
2. Реализуйте функцию избранного
3. Добавьте просмотр видео
4. Реализуйте комментарии и рейтинги
5. Добавьте push-уведомления

## Полезные команды

```bash
# Flutter
flutter pub get          # Установить зависимости
flutter run              # Запустить приложение
flutter build apk        # Собрать APK
flutter build ios        # Собрать iOS приложение

# Server
npm install              # Установить зависимости
npm run dev              # Запустить в dev режиме
npm start                # Запустить в production режиме
npm run migrate          # Запустить миграции

# PostgreSQL
psql -U postgres         # Подключиться к PostgreSQL
\l                      # Список баз данных
\c dorama_alem          # Подключиться к базе данных
\dt                     # Список таблиц
```


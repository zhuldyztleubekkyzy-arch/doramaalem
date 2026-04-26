# Дорама Әлем

Мобильное приложение для просмотра азиатских драм (дорам) на Flutter с клиент-серверной архитектурой.

## Особенности

- 🔐 Аутентификация через Firebase
- 📱 Flutter мобильное приложение
- 🗄️ PostgreSQL база данных
- 🌐 RESTful API на Node.js/Express
- 🇰🇿 Полная локализация на казахском языке
- 🎨 Современный UI/UX дизайн

## Архитектура

```
dorama_alem/
├── lib/                    # Flutter приложение
│   ├── models/            # Модели данных
│   ├── services/          # Сервисы (API, Auth)
│   ├── providers/         # State management (Provider)
│   ├── screens/           # Экраны приложения
│   ├── widgets/           # Переиспользуемые виджеты
│   └── l10n/              # Локализация
├── server/                # Backend сервер
│   ├── config/           # Конфигурация (DB, Firebase)
│   ├── routes/           # API маршруты
│   ├── migrations/       # SQL миграции
│   └── server.js         # Главный файл сервера
└── assets/               # Ресурсы (изображения, иконки)
```

## Требования

### Flutter приложение

- Flutter SDK (3.7.0 или выше)
- Dart SDK (3.7.0 или выше)
- Firebase проект

### Backend сервер

- Node.js (v16 или выше)
- PostgreSQL (v12 или выше)
- Firebase Admin SDK

## Установка и настройка

### 1. Flutter приложение

1. Установите зависимости:

```bash
flutter pub get
```

2. Настройте Firebase:

   - Создайте проект в Firebase Console
   - Добавьте Android/iOS приложения
   - Скачайте конфигурационные файлы:
     - `android/app/google-services.json` (для Android)
     - `ios/Runner/GoogleService-Info.plist` (для iOS)
   - Запустите:

   ```bash
   flutterfire configure
   ```

3. Обновите API URL в `lib/services/api_service.dart`:

   ```dart
   static const String baseUrl = 'http://your-server-url:3000/api';
   ```

4. Запустите приложение:

```bash
flutter run
```

### 2. Backend сервер

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
cp .env.example .env
```

4. Настройте `.env`:

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

5. Создайте базу данных PostgreSQL:

```sql
CREATE DATABASE dorama_alem;
```

6. Получите Firebase Service Account Key:

   - Firebase Console > Project Settings > Service Accounts
   - Нажмите "Generate new private key"
   - Сохраните JSON файл как `server/firebase-service-account-key.json`

7. Запустите миграции:

```bash
npm run migrate
```

8. Запустите сервер:

```bash
# Development mode
npm run dev

# Production mode
npm start
```

## Использование

### Flutter приложение

1. Запустите приложение
2. Зарегистрируйтесь или войдите с существующим аккаунтом
3. Просматривайте список дорам
4. Открывайте детали дорам
5. Добавляйте в избранное (функция в разработке)

### API Endpoints

- `GET /health` - Проверка состояния сервера
- `GET /api/doramas` - Получить все дорамы
- `GET /api/doramas/search?q=query` - Поиск дорам
- `GET /api/doramas/:id` - Получить дораму по ID
- `POST /api/doramas` - Создать дораму
- `PUT /api/doramas/:id` - Обновить дораму
- `DELETE /api/doramas/:id` - Удалить дораму

Все endpoints требуют Firebase ID token в заголовке:

```
Authorization: Bearer <firebase_id_token>
```

## Структура проекта

### Flutter (lib/)

- **models/** - Модели данных (Dorama, User)
- **services/** - Сервисы для работы с API и Firebase
- **providers/** - State management с Provider
- **screens/** - Экраны приложения:
  - `auth/` - Авторизация и регистрация
  - `home/` - Главный экран
  - `dorama/` - Список и детали дорам
- **l10n/** - Локализация на казахском языке

### Server

- **config/** - Конфигурация базы данных и Firebase
- **routes/** - API маршруты
- **migrations/** - SQL миграции для создания таблиц

## Разработка

### Добавление новых функций

1. **Новая модель**: Создайте файл в `lib/models/`
2. **Новый API endpoint**: Добавьте маршрут в `server/routes/`
3. **Новый экран**: Создайте в соответствующей директории `lib/screens/`
4. **Локализация**: Добавьте переводы в `lib/l10n/app_localizations.dart`

### Тестирование

```bash
# Flutter
flutter test

# Server (если есть тесты)
cd server
npm test
```

## Лицензия

Этот проект создан для образовательных целей.

## Поддержка

При возникновении проблем:

1. Проверьте настройки Firebase
2. Убедитесь, что PostgreSQL запущен
3. Проверьте переменные окружения в `.env`
4. Проверьте логи сервера и приложения

## TODO

- [ ] Добавить функцию избранного
- [ ] Реализовать просмотр видео
- [ ] Добавить комментарии и рейтинги
- [ ] Добавить уведомления
- [ ] Оптимизировать производительность
- [ ] Добавить кэширование
- [ ] Реализовать офлайн режим

# Дорама Әлем - Backend Server

Backend сервер для мобильного приложения "Дорама Әлем" на Node.js/Express с PostgreSQL.

## Требования

- Node.js (v16 или выше)
- PostgreSQL (v12 или выше)
- Firebase Admin SDK ключ

## Установка

1. Установите зависимости:
```bash
npm install
```

2. Создайте файл `.env` на основе `.env.example`:
```bash
cp .env.example .env
```

3. Настройте переменные окружения в `.env`:
   - Настройте подключение к PostgreSQL
   - Добавьте путь к Firebase service account key

4. Создайте базу данных PostgreSQL:
```sql
CREATE DATABASE dorama_alem;
```

5. Запустите миграции:
```bash
npm run migrate
```

6. Запустите сервер:
```bash
# Development mode
npm run dev

# Production mode
npm start
```

## Firebase настройка

1. Перейдите в Firebase Console
2. Project Settings > Service Accounts
3. Скачайте service account key (JSON файл)
4. Поместите файл в директорию `server/` как `firebase-service-account-key.json`
5. Укажите путь в `.env` файле

## API Endpoints

### Health Check
- `GET /health` - Проверка состояния сервера

### Doramas
- `GET /api/doramas` - Получить все дорамы (требует аутентификации)
- `GET /api/doramas/search?q=query` - Поиск дорам (требует аутентификации)
- `GET /api/doramas/:id` - Получить дораму по ID (требует аутентификации)
- `POST /api/doramas` - Создать новую дораму (требует аутентификации)
- `PUT /api/doramas/:id` - Обновить дораму (требует аутентификации)
- `DELETE /api/doramas/:id` - Удалить дораму (требует аутентификации)

## Аутентификация

Все API endpoints требуют Firebase ID token в заголовке:
```
Authorization: Bearer <firebase_id_token>
```

## Структура базы данных

### Таблица: doramas
- `id` - SERIAL PRIMARY KEY
- `title` - VARCHAR(255) NOT NULL
- `description` - TEXT NOT NULL
- `image_url` - VARCHAR(500) NOT NULL
- `genre` - VARCHAR(100) NOT NULL
- `year` - INTEGER NOT NULL
- `rating` - DECIMAL(3,1) DEFAULT 0.0
- `episode_count` - INTEGER DEFAULT 0
- `country` - VARCHAR(100) NOT NULL
- `created_at` - TIMESTAMP DEFAULT CURRENT_TIMESTAMP
- `updated_at` - TIMESTAMP DEFAULT CURRENT_TIMESTAMP


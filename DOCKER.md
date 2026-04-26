# Docker Compose

Docker собирает Flutter web-приложение и раздает его через Nginx. Данные берутся из Supabase.

## Запуск

```bash
docker compose up -d --build
```

После запуска приложение будет доступно здесь:

```bash
http://localhost:8080
```

## Supabase

По умолчанию используется Supabase URL из проекта. Если нужно переопределить параметры, создайте `.env` рядом с `docker-compose.yml`:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

## Полезные команды

```bash
docker compose logs -f app
docker compose down
```

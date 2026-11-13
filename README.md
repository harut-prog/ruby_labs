# Библиотека — Library Management

Учебное приложение для управления библиотекой, разработанное по лабораторным работам 1–16. Каталог книг и авторов, учёт читателей и выдач, поиск без перезагрузки страницы, загрузка обложек и документов, экспорт Excel и Word.

## Возможности и роли

- **Библиотекарь:** управление книгами, авторами, читателями и выдачами; загрузка файлов; скачивание отчётов и документов.
- **Читатель:** просмотр каталога и авторов, поиск книг, просмотр собственных выдач и скачивание собственного скана документа при наличии связанного профиля.
- Поиск по названию, ISBN и автору; фильтры по автору и доступности.
- Вложенные формы: автор с несколькими книгами; выдача с новым читателем.
- При создании выдачи плановый возврат по умолчанию — через 14 дней. Возврат обновляет доступность книги.
- XLSX: все выдачи и должники. DOCX: карточка книги и читательский билет.

## Стек и системные требования

| Компонент | Конфигурация |
| --- | --- |
| Ruby | 3.3.0, закреплён в `.ruby-version` |
| Rails | 7.1.6 |
| Bundler | 2.7.2 согласно `Gemfile.lock` |
| БД | PostgreSQL; локальный порт проекта — **5433** |
| Веб-сервер | Puma |
| Представления | Slim и ERB, Bootstrap 5.3.3, jQuery 3.7.1 |
| JavaScript | Hotwire: Turbo, Stimulus; Importmap |
| Аутентификация | Devise |
| Файлы | Active Storage, локальный DiskService |
| Отчёты | caxlsx_rails, Caracal через caracal-rails |
| Тесты | Minitest 5.x; Capybara и Selenium для системных тестов |

Точные версии зависимостей закреплены в `Gemfile.lock`. Для локального запуска подходят Linux и WSL 2. В WSL проект рекомендуется хранить в Linux-файловой системе, например `~/web-dev-labs/library_management`.

Системные зависимости Debian/Ubuntu:

```bash
sudo apt update
sudo apt install -y build-essential libpq-dev postgresql postgresql-contrib
```

Ruby и Bundler должны быть установлены заранее. Для браузерных системных тестов нужен Chrome/Chromium, доступный Selenium внутри среды запуска. Для обычного набора тестов браузер не требуется. Bootstrap и jQuery загружаются с CDN: для их получения браузеру нужен доступ к Интернету. Node.js, Yarn, Redis и отдельный worker для текущего локального запуска не требуются.

## Локальная установка

### 1. Клонирование и зависимости

```bash
git clone https://github.com/harut-prog/ruby_labs.git library_management
cd library_management
bundle install
```

### 2. PostgreSQL

Для Debian/Ubuntu в WSL запустите PostgreSQL и проверьте кластер:

```bash
sudo service postgresql start
pg_lsclusters
pg_isready -p 5433
```

По умолчанию подключение использует Unix-сокет и роль с именем Linux-пользователя. Если такой роли ещё нет, создайте её:

```bash
sudo -u postgres createuser --createdb "$USER"
```

В `config/database.yml` настроены отдельные базы:

- `library_management_development` — локальная работа;
- `library_management_test` — тесты;
- `library_management_production` — production.

Порт **5433** указан в `default` и `development`. Если ваш кластер работает на другом порту, измените оба значения. Для отдельного PostgreSQL-сервера настройте `host`, `username` и пароль через переменные окружения либо `DATABASE_URL`. Пароль не записывайте в репозиторий.

### 3. Переменные окружения

Для стандартной локальной конфигурации `.env` не обязателен. Автоматическая загрузка `.env` не настроена: при использовании файла загрузите его в оболочку перед командами Rails.

```bash
# Только если нужен локальный .env и файл ещё не существует:
cat > .env <<'EOF'
RAILS_LOG_LEVEL=debug
EOF

set -a
source .env
set +a
```

Для удалённой БД пример значения `DATABASE_URL`:

```bash
export DATABASE_URL='postgresql://[ПОЛЬЗОВАТЕЛЬ]:[ПАРОЛЬ_URL_ENCODED]@[ХОСТ]:[ПОРТ]/library_management_development'
```

Перед тестами удалите development-значение `DATABASE_URL` из окружения: оно может переопределить тестовую БД. `.env` и `config/master.key` исключены из Git. При необходимости расшифровки существующих credentials получите `[RAILS_MASTER_KEY]` у владельца проекта; не генерируйте замену без согласования.

### 4. Подготовка базы и примеры данных

```bash
bin/rails db:prepare
bin/rails db:seed
bin/rails db:migrate:status
```

Seeds создают демонстрационных авторов, книги, читателей и выдачи. Они не создают аккаунт библиотекаря. Повторный запуск использует существующие записи по ключам поиска; даты демонстрационных выдач фиксированы, поэтому они могут отображаться просроченными.

`bin/setup` также устанавливает зависимости и выполняет `db:prepare`, но дополнительно очищает логи и временные файлы. Для существующего стенда используйте явные команды выше.

### 5. Первый библиотекарь

Создайте локальный аккаунт с собственным email и паролем. Пароль вводится скрыто и передаётся только дочернему процессу:

```bash
read -r -p 'Email библиотекаря: ' LIBRARY_ADMIN_EMAIL
read -r -s -p 'Пароль (минимум 12 символов): ' LIBRARY_ADMIN_PASSWORD
printf '\n'
export LIBRARY_ADMIN_EMAIL LIBRARY_ADMIN_PASSWORD

bin/rails runner - <<'RUBY'
password = ENV.fetch('LIBRARY_ADMIN_PASSWORD')
raise 'Пароль должен содержать минимум 12 символов' if password.length < 12

User.create!(
  email: ENV.fetch('LIBRARY_ADMIN_EMAIL'),
  password: password,
  password_confirmation: password,
  role: 'librarian'
)
RUBY

unset LIBRARY_ADMIN_EMAIL LIBRARY_ADMIN_PASSWORD
```

Самостоятельная регистрация создаёт роль `reader`. Для отображения личных выдач библиотечный `Member` должен быть связан с `User` через `members.user_id`. Автоматическая привязка существующего читателя по email не реализована. При необходимости назначьте связь в консоли Rails, предварительно проверив обе записи.

## Запуск приложения

```bash
bin/rails server -b 127.0.0.1
```

Откройте [http://localhost:3000](http://localhost:3000). В WSL можно пользоваться браузером Windows. После изменения Gemfile и установки новых гемов полностью остановите сервер через `Ctrl+C` и запустите заново.

Отдельного `bin/dev`, Foreman/Overmind, сборщика JavaScript и процесса фоновых задач в текущем проекте нет. В development Sprockets обслуживает локальные ассеты, JavaScript подключается через Importmap. Для предварительной сборки production-ассетов:

```bash
RAILS_ENV=production SECRET_KEY_BASE_DUMMY=1 bin/rails assets:precompile
```

`SECRET_KEY_BASE_DUMMY` используется только для сборки; для запуска production нужны собственные секреты.

Часовой пояс приложения — **Москва, UTC+3** (`config.time_zone = "Moscow"`). Для отображения используются `Time.current` и `Date.current`; timestamp в БД хранится в UTC. Настройка не меняет системные часы WSL.

## Тесты и проверки

Тесты запускайте только с отдельной тестовой БД:

```bash
unset DATABASE_URL
RAILS_ENV=test bin/rails db:prepare
PARALLEL_WORKERS=1 bin/rails test
```

Основные проверки ЛР 14:

```bash
bin/rails test test/models/library_test.rb
bin/rails test test/integration/library_flow_test.rb
```

Проверяются уникальность ISBN, диапазон года, вычисление срока возврата, доступность книги, создание выдачи с новым читателем и часть сценариев доступа. Проходящий набор не является полным покрытием приложения.

В проекте закреплён Minitest 5.x: Minitest 6 несовместим с текущим тестовым раннером Rails 7.1. RuboCop, RSpec и Brakeman не подключены. Проверка пробелов и загрузки приложения:

```bash
git diff --check
bin/rails zeitwerk:check
```

Если добавлены браузерные системные тесты и настроен Chrome/Chromium:

```bash
bin/rails test:system
```

## Файлы и отчёты

Обложки книг доступны публично через собственный контроллер. Сканы читателей выдаются только библиотекарю или владельцу связанного профиля. Стандартные blob-маршруты Active Storage отключены. Загрузка ограничена 5 МБ; разрешены PNG/JPEG, для сканов также PDF. Используйте синтетические учебные документы.

Файлы сохраняются в `storage/`, тестовые вложения — в `tmp/storage/`. Эти каталоги не входят в Git. Скачивание реализовано через `DiskService#path_for`; смена хранилища на S3 требует изменения контроллера.

Экспорт доступен библиотекарю:

| Страница | Результат |
| --- | --- |
| Выдачи → «Отчёты Excel» | Все выдачи и должники, `.xlsx` |
| Книга → «Документ Word» | Карточка выбранной книги, `.docx` |
| Читатель → «Документ Word» | Билет читателя с невозвращёнными книгами, `.docx` |

Исходный Excel/Word загружать не нужно: документы формируются из БД. Для Caracal 1.6 результат `render` — `StringIO`; контроллер передаёт в ответ `doc.render.string`.

## Архитектура

- `Author` → `Book`: один автор и несколько книг.
- `Member` → `Borrowing` ← `Book`: читатель, выдача и книга.
- `User` → `Member`: необязательный связанный профиль читателя.
- `ApplicationController` требует входа и определяет доступную пользователю область выдач.
- `BorrowingsController` проверяет занятость книги под блокировкой строки при сохранении.
- `ReportsController` и шаблоны `app/views/reports/` генерируют Excel.
- `WordDocumentsController` использует прямой API Caracal.
- Общая навигация и повторяемые представления вынесены в partials; каталог обновляется через Turbo Frame.

## Деплой

Репозиторий содержит многослойный `Dockerfile` с Ruby 3.3.0, сборкой ассетов и запуском Puma. PostgreSQL в образ не включён. Автоматический деплой, Compose и Kamal не настроены; production-развёртывание пока не проверено.

Перед развёртыванием задайте `[ДОМЕН]`, `[DATABASE_URL_PRODUCTION]` и `[RAILS_MASTER_KEY]`/действующий `SECRET_KEY_BASE`. Настройте HTTPS reverse proxy: в production включён `force_ssl`. Для локального DiskService подключите постоянный том к `/rails/storage`, отдельно обеспечьте резервное копирование PostgreSQL и файлов. Если используете восстановление пароля Devise, настройте `[SMTP_HOST]`, `[SMTP_USER]`, `[SMTP_PASSWORD]` и домен ссылок Action Mailer.

Приложение предназначено для учебного стенда; указанные настройки требуют отдельной проверки перед публичным запуском.

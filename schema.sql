-- Таблица пользователей / сотрудников
CREATE TABLE IF NOT EXISTS pipls_users (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    role TEXT NOT NULL,                   -- Формат: "роль:склад_UUID" или просто "роль"
    access_code TEXT UNIQUE NOT NULL,     -- Уникальный ПИН-код сотрудника
    tg_id BIGINT UNIQUE NOT NULL,        -- Внутренний ID (генерируется случайно при отсутствии)
    last_login_at TIMESTAMP WITH TIME ZONE,
    last_login_method TEXT                -- Способ входа: "password" или "passkey"
);

-- Таблица логов действий (аудит безопасности)
CREATE TABLE IF NOT EXISTS pipls_actions (
    id BIGSERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    tg_id BIGINT,
    user_name TEXT,
    action_type TEXT,                    -- Тип действия: 'cash', 'transfer', 'LOGIN_PASSWORD', 'LOGIN_PASSKEY' и т.д.
    document_number TEXT,                -- Номер связанного документа iiko (CSH-..., TR-... или '-')
    details JSONB                        -- Подробности в формате JSON
);

-- Таблица кассовых отчетов (сдача смены)
CREATE TABLE IF NOT EXISTS pipls_cash_reports (
    id BIGSERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    cashier_tg_id BIGINT,
    cashier_name TEXT,
    reported_cash NUMERIC(15, 2) NOT NULL, -- Сданные кассиром наличные
    iiko_cash NUMERIC(15, 2) NOT NULL,     -- Книга наличных по данным iiko
    difference NUMERIC(15, 2) NOT NULL     -- Расхождение (reported_cash - iiko_cash)
);

-- Таблица ожидающих подтверждения перемещений (Transfers)
CREATE TABLE IF NOT EXISTS pipls_pending_transfers (
    id BIGSERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE,
    creator_tg_id TEXT,                  -- Внутренний ID создателя
    creator_name TEXT,
    creator_role TEXT,
    store_from TEXT,                     -- UUID склада-отправителя
    store_from_name TEXT,
    store_to TEXT,                       -- UUID склада-получателя
    store_to_name TEXT,
    items JSONB,                         -- Список товаров: [{product_id, product_name, quantity, unit, received_quantity}]
    comment TEXT,                        -- Комментарий создателя
    status TEXT,                         -- Статус: 'pending_receiver', 'pending_sender', 'processed', 'rejected'
    receiver_comment TEXT,               -- Комментарий получателя при приемке
    sender_comment TEXT,                 -- Комментарий отправителя при выдаче
    document_number TEXT                 -- Номер созданного документа в iikoWeb после успешного сохранения
);

-- Таблица ключей Passkeys (Face ID / Touch ID / Windows Hello)
CREATE TABLE IF NOT EXISTS pipls_user_passkeys (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES pipls_users(id) ON DELETE CASCADE,
    credential_id TEXT UNIQUE NOT NULL,  -- Уникальный ID ключа
    public_key TEXT NOT NULL,            -- Публичный ключ устройства (Base64)
    counter BIGINT DEFAULT 0 NOT NULL,   -- Счетчик использования (защита от повторов)
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- ============================================================
-- 快递物流平台 数据库设计
-- 题目一：快递物流平台的数据库设计
-- DBMS: PostgreSQL (PG-SQL)
-- ============================================================

-- 清理旧对象（按依赖顺序）
DROP VIEW IF EXISTS v_tracking_detail CASCADE;
DROP VIEW IF EXISTS v_station_packages CASCADE;
DROP VIEW IF EXISTS v_user_orders CASCADE;
DROP TRIGGER IF EXISTS trg_check_courier_role ON TransitRecord CASCADE;
DROP TRIGGER IF EXISTS trg_after_order_create_transit ON Package CASCADE;
DROP TRIGGER IF EXISTS trg_sync_package_status ON TransitRecord CASCADE;
DROP FUNCTION IF EXISTS fn_check_courier_role() CASCADE;
DROP FUNCTION IF EXISTS fn_after_order_create_transit() CASCADE;
DROP FUNCTION IF EXISTS fn_sync_package_status_trigger() CASCADE;
DROP TABLE IF EXISTS TransitRecord CASCADE;
DROP TABLE IF EXISTS Package CASCADE;
DROP TABLE IF EXISTS Station CASCADE;
DROP TABLE IF EXISTS Company CASCADE;
DROP TABLE IF EXISTS "User" CASCADE;
DROP DOMAIN IF EXISTS user_role CASCADE;
DROP DOMAIN IF EXISTS package_status CASCADE;

-- ============================================================
-- 1. 域定义（增强数据约束）
-- ============================================================
CREATE DOMAIN user_role AS VARCHAR(20)
    CHECK (VALUE IN ('普通用户', '快递员', '管理员'));

CREATE DOMAIN package_status AS VARCHAR(20)
    CHECK (VALUE IN ('待取件', '运输中', '已到达', '已签收'));

-- ============================================================
-- 2. 建表
-- ============================================================

-- 用户表
CREATE TABLE "User" (
    user_id         SERIAL          PRIMARY KEY,
    username        VARCHAR(50)     NOT NULL UNIQUE,
    password        VARCHAR(100)    NOT NULL,
    role            user_role       NOT NULL,
    phone           VARCHAR(20),
    real_name       VARCHAR(50)     NOT NULL,
    created_at      TIMESTAMP       DEFAULT NOW()
);

-- 快递公司表
CREATE TABLE Company (
    company_id      SERIAL          PRIMARY KEY,
    company_name    VARCHAR(100)    NOT NULL UNIQUE
);

-- 物流站点表
CREATE TABLE Station (
    station_id      SERIAL          PRIMARY KEY,
    station_name    VARCHAR(100)    NOT NULL,
    address         VARCHAR(200),
    company_id      INT             NOT NULL REFERENCES Company(company_id)
);

-- 快递包裹表（订单）
CREATE TABLE Package (
    tracking_no     VARCHAR(18)     PRIMARY KEY,
    sender_name     VARCHAR(50)     NOT NULL,
    sender_phone    VARCHAR(20)     NOT NULL,
    receiver_name   VARCHAR(50)     NOT NULL,
    receiver_phone  VARCHAR(20)     NOT NULL,
    origin          VARCHAR(200)    NOT NULL,
    destination     VARCHAR(200)    NOT NULL,
    weight          DECIMAL(5,2)    NOT NULL CHECK (weight > 0),
    status          package_status  DEFAULT '待取件',
    order_time      TIMESTAMP       DEFAULT NOW(),
    user_id         INT             NOT NULL REFERENCES "User"(user_id),
    company_id      INT             NOT NULL REFERENCES Company(company_id)
);

-- 物流中转记录表
CREATE TABLE TransitRecord (
    record_id           SERIAL      PRIMARY KEY,
    tracking_no         VARCHAR(18) NOT NULL REFERENCES Package(tracking_no),
    current_station_id  INT         NOT NULL REFERENCES Station(station_id),
    next_station_id     INT         REFERENCES Station(station_id),
    courier_id          INT         NOT NULL REFERENCES "User"(user_id),
    arrival_time        TIMESTAMP   DEFAULT NOW(),
    departure_time      TIMESTAMP
);

-- ============================================================
-- 3. 索引
-- ============================================================
CREATE INDEX idx_package_user_id     ON Package(user_id);
CREATE INDEX idx_package_status      ON Package(status);
CREATE INDEX idx_transit_tracking    ON TransitRecord(tracking_no);
CREATE INDEX idx_transit_station     ON TransitRecord(current_station_id);
CREATE INDEX idx_transit_courier     ON TransitRecord(courier_id);

-- ============================================================
-- 4. 存储过程
-- ============================================================

-- 用户注册
CREATE OR REPLACE FUNCTION sp_user_register(
    p_username  VARCHAR,
    p_password  VARCHAR,
    p_role      VARCHAR,
    p_phone     VARCHAR,
    p_real_name VARCHAR
) RETURNS INT AS $$
DECLARE
    new_id INT;
BEGIN
    INSERT INTO "User" (username, password, role, phone, real_name)
    VALUES (p_username, p_password, p_role, p_phone, p_real_name)
    RETURNING user_id INTO new_id;
    RETURN new_id;
END;
$$ LANGUAGE plpgsql;

-- 用户下单
CREATE OR REPLACE FUNCTION sp_place_order(
    p_tracking_no    VARCHAR,
    p_sender_name    VARCHAR,
    p_sender_phone   VARCHAR,
    p_receiver_name  VARCHAR,
    p_receiver_phone VARCHAR,
    p_origin         VARCHAR,
    p_destination    VARCHAR,
    p_weight         DECIMAL,
    p_user_id        INT,
    p_company_id     INT
) RETURNS VOID AS $$
BEGIN
    INSERT INTO Package (tracking_no, sender_name, sender_phone,
        receiver_name, receiver_phone, origin, destination,
        weight, status, user_id, company_id)
    VALUES (p_tracking_no, p_sender_name, p_sender_phone,
        p_receiver_name, p_receiver_phone, p_origin, p_destination,
        p_weight, '待取件', p_user_id, p_company_id);
END;
$$ LANGUAGE plpgsql;

-- 更新物流状态（记录一次中转）
CREATE OR REPLACE FUNCTION sp_update_transit(
    p_tracking_no         VARCHAR,
    p_current_station_id  INT,
    p_next_station_id     INT,
    p_courier_id          INT
) RETURNS VOID AS $$
BEGIN
    INSERT INTO TransitRecord (tracking_no, current_station_id,
        next_station_id, courier_id)
    VALUES (p_tracking_no, p_current_station_id,
        p_next_station_id, p_courier_id);
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- 5. 触发器函数
-- ============================================================

-- 下单后自动创建首条物流记录（取件）
CREATE OR REPLACE FUNCTION fn_after_order_create_transit()
RETURNS TRIGGER AS $$
DECLARE
    v_station_id INT;
    v_courier_id INT;
BEGIN
    -- 找到该公司离始发地最近的站点（示例取第一个站点）
    SELECT station_id INTO v_station_id
    FROM Station WHERE company_id = NEW.company_id
    ORDER BY station_id LIMIT 1;

    -- 找到该站点的一名快递员
    SELECT user_id INTO v_courier_id
    FROM "User" WHERE role = '快递员'
    ORDER BY user_id LIMIT 1;

    IF v_station_id IS NOT NULL AND v_courier_id IS NOT NULL THEN
        INSERT INTO TransitRecord
            (tracking_no, current_station_id, next_station_id, courier_id)
        VALUES
            (NEW.tracking_no, v_station_id, v_station_id, v_courier_id);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_after_order_create_transit
    AFTER INSERT ON Package
    FOR EACH ROW EXECUTE FUNCTION fn_after_order_create_transit();

-- 关联 TransitRecord 时自动更新 Package 状态
CREATE OR REPLACE FUNCTION fn_sync_package_status_trigger()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Package SET status = '运输中'
    WHERE tracking_no = NEW.tracking_no AND status = '待取件';
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_sync_package_status
    AFTER INSERT ON TransitRecord
    FOR EACH ROW EXECUTE FUNCTION fn_sync_package_status_trigger();

-- 验证快递员角色
CREATE OR REPLACE FUNCTION fn_check_courier_role()
RETURNS TRIGGER AS $$
DECLARE
    v_role user_role;
BEGIN
    SELECT role INTO v_role FROM "User" WHERE user_id = NEW.courier_id;
    IF v_role != '快递员' THEN
        RAISE EXCEPTION '用户 % 不是快递员，不能承担运输任务', NEW.courier_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_courier_role
    BEFORE INSERT OR UPDATE ON TransitRecord
    FOR EACH ROW EXECUTE FUNCTION fn_check_courier_role();

-- ============================================================
-- 6. 视图
-- ============================================================

-- 普通用户查看自己的订单及最新物流状态
CREATE OR REPLACE VIEW v_user_orders AS
SELECT
    p.tracking_no,
    p.sender_name,
    p.receiver_name,
    p.origin,
    p.destination,
    p.weight,
    p.status,
    p.order_time,
    p.user_id,
    t.current_station_id,
    s.station_name AS current_station_name,
    u.real_name   AS courier_name
FROM Package p
LEFT JOIN LATERAL (
    SELECT * FROM TransitRecord
    WHERE tracking_no = p.tracking_no
    ORDER BY record_id DESC LIMIT 1
) t ON true
LEFT JOIN Station s ON t.current_station_id = s.station_id
LEFT JOIN "User" u ON t.courier_id = u.user_id;

-- 快递员查看自己站点当前处理的包裹
CREATE OR REPLACE VIEW v_station_packages AS
SELECT DISTINCT
    t.record_id,
    t.tracking_no,
    p.sender_name,
    p.receiver_name,
    p.origin,
    p.destination,
    p.status,
    t.current_station_id,
    s.station_name AS current_station_name,
    t.next_station_id,
    ns.station_name AS next_station_name,
    t.courier_id,
    t.arrival_time
FROM TransitRecord t
JOIN Package p  ON t.tracking_no = p.tracking_no
JOIN Station s  ON t.current_station_id = s.station_id
LEFT JOIN Station ns ON t.next_station_id = ns.station_id;

-- 运单号查询完整物流轨迹
CREATE OR REPLACE VIEW v_tracking_detail AS
SELECT
    t.record_id,
    t.tracking_no,
    p.sender_name,
    p.receiver_name,
    p.origin,
    p.destination,
    p.weight,
    p.status AS package_status,
    t.current_station_id,
    cs.station_name AS current_station_name,
    t.next_station_id,
    ns.station_name AS next_station_name,
    u.real_name   AS courier_name,
    u.phone       AS courier_phone,
    t.arrival_time,
    t.departure_time
FROM TransitRecord t
JOIN Package p  ON t.tracking_no = p.tracking_no
JOIN Station cs ON t.current_station_id = cs.station_id
LEFT JOIN Station ns ON t.next_station_id = ns.station_id
JOIN "User" u   ON t.courier_id = u.user_id
ORDER BY t.tracking_no, t.record_id;

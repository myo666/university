--
-- PostgreSQL database dump
--

\restrict XWSwUYRjFRohO5dL1MAEc14Lg1osStwggQ5h1hh19OkQoovLog9S51yUMioc60V

-- Dumped from database version 15.17
-- Dumped by pg_dump version 15.17

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: package_status; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.package_status AS character varying(20)
	CONSTRAINT package_status_check CHECK (((VALUE)::text = ANY ((ARRAY['待取件'::character varying, '运输中'::character varying, '已到达'::character varying, '已签收'::character varying])::text[])));


--
-- Name: user_role; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN public.user_role AS character varying(20)
	CONSTRAINT user_role_check CHECK (((VALUE)::text = ANY ((ARRAY['普通用户'::character varying, '快递员'::character varying, '管理员'::character varying])::text[])));


--
-- Name: fn_after_order_create_transit(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_after_order_create_transit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


--
-- Name: fn_check_courier_role(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_check_courier_role() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_role user_role;
BEGIN
    SELECT role INTO v_role FROM "User" WHERE user_id = NEW.courier_id;
    IF v_role != '快递员' THEN
        RAISE EXCEPTION '用户 % 不是快递员，不能承担运输任务', NEW.courier_id;
    END IF;
    RETURN NEW;
END;
$$;


--
-- Name: fn_sync_package_status_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_sync_package_status_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE Package SET status = '运输中'
    WHERE tracking_no = NEW.tracking_no AND status = '待取件';
    RETURN NEW;
END;
$$;


--
-- Name: sp_place_order(character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sp_place_order(p_tracking_no character varying, p_sender_name character varying, p_sender_phone character varying, p_receiver_name character varying, p_receiver_phone character varying, p_origin character varying, p_destination character varying, p_weight numeric, p_user_id integer, p_company_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO Package (tracking_no, sender_name, sender_phone,
        receiver_name, receiver_phone, origin, destination,
        weight, status, user_id, company_id)
    VALUES (p_tracking_no, p_sender_name, p_sender_phone,
        p_receiver_name, p_receiver_phone, p_origin, p_destination,
        p_weight, '待取件', p_user_id, p_company_id);
END;
$$;


--
-- Name: sp_update_transit(character varying, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sp_update_transit(p_tracking_no character varying, p_current_station_id integer, p_next_station_id integer, p_courier_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO TransitRecord (tracking_no, current_station_id,
        next_station_id, courier_id)
    VALUES (p_tracking_no, p_current_station_id,
        p_next_station_id, p_courier_id);
END;
$$;


--
-- Name: sp_user_register(character varying, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sp_user_register(p_username character varying, p_password character varying, p_role character varying, p_phone character varying, p_real_name character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    new_id INT;
BEGIN
    INSERT INTO "User" (username, password, role, phone, real_name)
    VALUES (p_username, p_password, p_role, p_phone, p_real_name)
    RETURNING user_id INTO new_id;
    RETURN new_id;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: User; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."User" (
    user_id integer NOT NULL,
    username character varying(50) NOT NULL,
    password character varying(100) NOT NULL,
    role public.user_role NOT NULL,
    phone character varying(20),
    real_name character varying(50) NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: User_user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."User_user_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: User_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."User_user_id_seq" OWNED BY public."User".user_id;


--
-- Name: company; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.company (
    company_id integer NOT NULL,
    company_name character varying(100) NOT NULL
);


--
-- Name: company_company_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.company_company_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: company_company_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.company_company_id_seq OWNED BY public.company.company_id;


--
-- Name: package; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.package (
    tracking_no character varying(18) NOT NULL,
    sender_name character varying(50) NOT NULL,
    sender_phone character varying(20) NOT NULL,
    receiver_name character varying(50) NOT NULL,
    receiver_phone character varying(20) NOT NULL,
    origin character varying(200) NOT NULL,
    destination character varying(200) NOT NULL,
    weight numeric(5,2) NOT NULL,
    status public.package_status DEFAULT '待取件'::character varying,
    order_time timestamp without time zone DEFAULT now(),
    user_id integer NOT NULL,
    company_id integer NOT NULL,
    CONSTRAINT package_weight_check CHECK ((weight > (0)::numeric))
);


--
-- Name: station; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.station (
    station_id integer NOT NULL,
    station_name character varying(100) NOT NULL,
    address character varying(200),
    company_id integer NOT NULL
);


--
-- Name: station_station_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.station_station_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: station_station_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.station_station_id_seq OWNED BY public.station.station_id;


--
-- Name: transitrecord; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transitrecord (
    record_id integer NOT NULL,
    tracking_no character varying(18) NOT NULL,
    current_station_id integer NOT NULL,
    next_station_id integer,
    courier_id integer NOT NULL,
    arrival_time timestamp without time zone DEFAULT now(),
    departure_time timestamp without time zone
);


--
-- Name: transitrecord_record_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.transitrecord_record_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transitrecord_record_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.transitrecord_record_id_seq OWNED BY public.transitrecord.record_id;


--
-- Name: v_station_packages; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_station_packages AS
 SELECT DISTINCT t.record_id,
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
   FROM (((public.transitrecord t
     JOIN public.package p ON (((t.tracking_no)::text = (p.tracking_no)::text)))
     JOIN public.station s ON ((t.current_station_id = s.station_id)))
     LEFT JOIN public.station ns ON ((t.next_station_id = ns.station_id)));


--
-- Name: v_tracking_detail; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_tracking_detail AS
 SELECT t.record_id,
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
    u.real_name AS courier_name,
    u.phone AS courier_phone,
    t.arrival_time,
    t.departure_time
   FROM ((((public.transitrecord t
     JOIN public.package p ON (((t.tracking_no)::text = (p.tracking_no)::text)))
     JOIN public.station cs ON ((t.current_station_id = cs.station_id)))
     LEFT JOIN public.station ns ON ((t.next_station_id = ns.station_id)))
     JOIN public."User" u ON ((t.courier_id = u.user_id)))
  ORDER BY t.tracking_no, t.record_id;


--
-- Name: v_user_orders; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_user_orders AS
 SELECT p.tracking_no,
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
    u.real_name AS courier_name
   FROM (((public.package p
     LEFT JOIN LATERAL ( SELECT transitrecord.record_id,
            transitrecord.tracking_no,
            transitrecord.current_station_id,
            transitrecord.next_station_id,
            transitrecord.courier_id,
            transitrecord.arrival_time,
            transitrecord.departure_time
           FROM public.transitrecord
          WHERE ((transitrecord.tracking_no)::text = (p.tracking_no)::text)
          ORDER BY transitrecord.record_id DESC
         LIMIT 1) t ON (true))
     LEFT JOIN public.station s ON ((t.current_station_id = s.station_id)))
     LEFT JOIN public."User" u ON ((t.courier_id = u.user_id)));


--
-- Name: User user_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."User" ALTER COLUMN user_id SET DEFAULT nextval('public."User_user_id_seq"'::regclass);


--
-- Name: company company_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.company ALTER COLUMN company_id SET DEFAULT nextval('public.company_company_id_seq'::regclass);


--
-- Name: station station_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.station ALTER COLUMN station_id SET DEFAULT nextval('public.station_station_id_seq'::regclass);


--
-- Name: transitrecord record_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transitrecord ALTER COLUMN record_id SET DEFAULT nextval('public.transitrecord_record_id_seq'::regclass);


--
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."User" (user_id, username, password, role, phone, real_name, created_at) VALUES (1, 'zhangsan', '123456', '普通用户', '13800001111', '张三', '2026-06-27 16:07:38.040121');
INSERT INTO public."User" (user_id, username, password, role, phone, real_name, created_at) VALUES (2, 'lisi', '123456', '普通用户', '13800002222', '李四', '2026-06-27 16:07:38.040121');
INSERT INTO public."User" (user_id, username, password, role, phone, real_name, created_at) VALUES (4, 'courier02', '123456', '快递员', '13900002222', '赵快递', '2026-06-27 16:07:38.040121');
INSERT INTO public."User" (user_id, username, password, role, phone, real_name, created_at) VALUES (5, 'courier03', '123456', '快递员', '13900003333', '陈快递', '2026-06-27 16:07:38.040121');
INSERT INTO public."User" (user_id, username, password, role, phone, real_name, created_at) VALUES (6, 'admin01', '123456', '管理员', '13700001111', '管理员', '2026-06-27 16:07:38.040121');
INSERT INTO public."User" (user_id, username, password, role, phone, real_name, created_at) VALUES (7, 'wangwu', '123456', '普通用户', '13500005555', '王五', '2026-06-27 16:08:01.942097');
INSERT INTO public."User" (user_id, username, password, role, phone, real_name, created_at) VALUES (8, 'courier04', '123456', '快递员', '13900004444', '刘快递', '2026-06-27 16:08:01.946446');
INSERT INTO public."User" (user_id, username, password, role, phone, real_name, created_at) VALUES (3, 'courier01', '123456', '快递员', '13900005555', '王快递', '2026-06-27 16:07:38.040121');


--
-- Data for Name: company; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.company (company_id, company_name) VALUES (1, '顺丰速运');
INSERT INTO public.company (company_id, company_name) VALUES (2, '中通快递');
INSERT INTO public.company (company_id, company_name) VALUES (3, '圆通速递');


--
-- Data for Name: package; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.package (tracking_no, sender_name, sender_phone, receiver_name, receiver_phone, origin, destination, weight, status, order_time, user_id, company_id) VALUES ('202606270000000001', '张三', '13800001111', '王五', '13500001111', '武汉市洪山区', '北京市朝阳区', 2.50, '运输中', '2026-06-27 16:07:38.051916', 1, 1);
INSERT INTO public.package (tracking_no, sender_name, sender_phone, receiver_name, receiver_phone, origin, destination, weight, status, order_time, user_id, company_id) VALUES ('202606270000000002', '李四', '13800002222', '赵六', '13600002222', '武汉市江夏区', '广州市白云区', 1.20, '运输中', '2026-06-27 16:07:38.051916', 2, 2);
INSERT INTO public.package (tracking_no, sender_name, sender_phone, receiver_name, receiver_phone, origin, destination, weight, status, order_time, user_id, company_id) VALUES ('202606270000000004', '张三', '13800001111', '周八', '13300004444', '武汉市汉阳区', '深圳市南山区', 5.00, '已签收', '2026-06-27 16:07:38.051916', 1, 3);
INSERT INTO public.package (tracking_no, sender_name, sender_phone, receiver_name, receiver_phone, origin, destination, weight, status, order_time, user_id, company_id) VALUES ('202606270000000003', '张三', '13800001111', '孙七', '13700003333', '武汉市洪山区', '上海市浦东新区', 0.80, '运输中', '2026-06-27 16:07:38.051916', 1, 1);
INSERT INTO public.package (tracking_no, sender_name, sender_phone, receiver_name, receiver_phone, origin, destination, weight, status, order_time, user_id, company_id) VALUES ('202606270000000005', '王五', '13500005555', '钱九', '13400009999', '武汉市江夏区', '北京市朝阳区', 3.00, '已签收', '2026-06-27 16:08:01.947379', 5, 1);


--
-- Data for Name: station; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.station (station_id, station_name, address, company_id) VALUES (1, '顺丰武汉集散中心', '武汉市洪山区', 1);
INSERT INTO public.station (station_id, station_name, address, company_id) VALUES (2, '顺丰北京集散中心', '北京市朝阳区', 1);
INSERT INTO public.station (station_id, station_name, address, company_id) VALUES (3, '顺丰上海集散中心', '上海市浦东新区', 1);
INSERT INTO public.station (station_id, station_name, address, company_id) VALUES (4, '中通武汉站点', '武汉市江夏区', 2);
INSERT INTO public.station (station_id, station_name, address, company_id) VALUES (5, '中通广州站点', '广州市白云区', 2);
INSERT INTO public.station (station_id, station_name, address, company_id) VALUES (6, '圆通武汉站点', '武汉市汉阳区', 3);
INSERT INTO public.station (station_id, station_name, address, company_id) VALUES (7, '圆通深圳站点', '深圳市南山区', 3);


--
-- Data for Name: transitrecord; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.transitrecord (record_id, tracking_no, current_station_id, next_station_id, courier_id, arrival_time, departure_time) VALUES (1, '202606270000000001', 1, 1, 3, '2026-06-27 16:07:38.051916', NULL);
INSERT INTO public.transitrecord (record_id, tracking_no, current_station_id, next_station_id, courier_id, arrival_time, departure_time) VALUES (2, '202606270000000002', 4, 4, 3, '2026-06-27 16:07:38.051916', NULL);
INSERT INTO public.transitrecord (record_id, tracking_no, current_station_id, next_station_id, courier_id, arrival_time, departure_time) VALUES (3, '202606270000000003', 1, 1, 3, '2026-06-27 16:07:38.051916', NULL);
INSERT INTO public.transitrecord (record_id, tracking_no, current_station_id, next_station_id, courier_id, arrival_time, departure_time) VALUES (4, '202606270000000004', 6, 6, 3, '2026-06-27 16:07:38.051916', NULL);
INSERT INTO public.transitrecord (record_id, tracking_no, current_station_id, next_station_id, courier_id, arrival_time, departure_time) VALUES (5, '202606270000000001', 1, 1, 3, '2026-06-27 09:00:00', '2026-06-27 09:30:00');
INSERT INTO public.transitrecord (record_id, tracking_no, current_station_id, next_station_id, courier_id, arrival_time, departure_time) VALUES (6, '202606270000000001', 1, 2, 3, '2026-06-27 14:00:00', '2026-06-27 14:30:00');
INSERT INTO public.transitrecord (record_id, tracking_no, current_station_id, next_station_id, courier_id, arrival_time, departure_time) VALUES (7, '202606270000000001', 2, NULL, 3, '2026-06-28 08:00:00', NULL);
INSERT INTO public.transitrecord (record_id, tracking_no, current_station_id, next_station_id, courier_id, arrival_time, departure_time) VALUES (8, '202606270000000002', 4, 4, 4, '2026-06-27 10:00:00', '2026-06-27 10:20:00');
INSERT INTO public.transitrecord (record_id, tracking_no, current_station_id, next_station_id, courier_id, arrival_time, departure_time) VALUES (9, '202606270000000002', 4, 5, 4, '2026-06-27 16:00:00', '2026-06-27 16:30:00');
INSERT INTO public.transitrecord (record_id, tracking_no, current_station_id, next_station_id, courier_id, arrival_time, departure_time) VALUES (10, '202606270000000002', 5, NULL, 5, '2026-06-28 09:00:00', NULL);
INSERT INTO public.transitrecord (record_id, tracking_no, current_station_id, next_station_id, courier_id, arrival_time, departure_time) VALUES (11, '202606270000000004', 6, 6, 5, '2026-06-26 09:00:00', '2026-06-26 09:30:00');
INSERT INTO public.transitrecord (record_id, tracking_no, current_station_id, next_station_id, courier_id, arrival_time, departure_time) VALUES (12, '202606270000000004', 6, 7, 5, '2026-06-27 08:00:00', '2026-06-27 08:30:00');
INSERT INTO public.transitrecord (record_id, tracking_no, current_station_id, next_station_id, courier_id, arrival_time, departure_time) VALUES (13, '202606270000000004', 7, NULL, 5, '2026-06-28 10:00:00', NULL);
INSERT INTO public.transitrecord (record_id, tracking_no, current_station_id, next_station_id, courier_id, arrival_time, departure_time) VALUES (14, '202606270000000005', 1, 1, 3, '2026-06-27 16:08:01.947379', NULL);


--
-- Name: User_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."User_user_id_seq"', 8, true);


--
-- Name: company_company_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.company_company_id_seq', 3, true);


--
-- Name: station_station_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.station_station_id_seq', 7, true);


--
-- Name: transitrecord_record_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.transitrecord_record_id_seq', 15, true);


--
-- Name: User User_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_pkey" PRIMARY KEY (user_id);


--
-- Name: User User_username_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_username_key" UNIQUE (username);


--
-- Name: company company_company_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.company
    ADD CONSTRAINT company_company_name_key UNIQUE (company_name);


--
-- Name: company company_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.company
    ADD CONSTRAINT company_pkey PRIMARY KEY (company_id);


--
-- Name: package package_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.package
    ADD CONSTRAINT package_pkey PRIMARY KEY (tracking_no);


--
-- Name: station station_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.station
    ADD CONSTRAINT station_pkey PRIMARY KEY (station_id);


--
-- Name: transitrecord transitrecord_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transitrecord
    ADD CONSTRAINT transitrecord_pkey PRIMARY KEY (record_id);


--
-- Name: idx_package_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_package_status ON public.package USING btree (status);


--
-- Name: idx_package_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_package_user_id ON public.package USING btree (user_id);


--
-- Name: idx_transit_courier; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_transit_courier ON public.transitrecord USING btree (courier_id);


--
-- Name: idx_transit_station; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_transit_station ON public.transitrecord USING btree (current_station_id);


--
-- Name: idx_transit_tracking; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_transit_tracking ON public.transitrecord USING btree (tracking_no);


--
-- Name: package trg_after_order_create_transit; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_after_order_create_transit AFTER INSERT ON public.package FOR EACH ROW EXECUTE FUNCTION public.fn_after_order_create_transit();


--
-- Name: transitrecord trg_check_courier_role; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_check_courier_role BEFORE INSERT OR UPDATE ON public.transitrecord FOR EACH ROW EXECUTE FUNCTION public.fn_check_courier_role();


--
-- Name: transitrecord trg_sync_package_status; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_sync_package_status AFTER INSERT ON public.transitrecord FOR EACH ROW EXECUTE FUNCTION public.fn_sync_package_status_trigger();


--
-- Name: package package_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.package
    ADD CONSTRAINT package_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.company(company_id);


--
-- Name: package package_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.package
    ADD CONSTRAINT package_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."User"(user_id);


--
-- Name: station station_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.station
    ADD CONSTRAINT station_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.company(company_id);


--
-- Name: transitrecord transitrecord_courier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transitrecord
    ADD CONSTRAINT transitrecord_courier_id_fkey FOREIGN KEY (courier_id) REFERENCES public."User"(user_id);


--
-- Name: transitrecord transitrecord_current_station_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transitrecord
    ADD CONSTRAINT transitrecord_current_station_id_fkey FOREIGN KEY (current_station_id) REFERENCES public.station(station_id);


--
-- Name: transitrecord transitrecord_next_station_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transitrecord
    ADD CONSTRAINT transitrecord_next_station_id_fkey FOREIGN KEY (next_station_id) REFERENCES public.station(station_id);


--
-- Name: transitrecord transitrecord_tracking_no_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transitrecord
    ADD CONSTRAINT transitrecord_tracking_no_fkey FOREIGN KEY (tracking_no) REFERENCES public.package(tracking_no);


--
-- PostgreSQL database dump complete
--

\unrestrict XWSwUYRjFRohO5dL1MAEc14Lg1osStwggQ5h1hh19OkQoovLog9S51yUMioc60V


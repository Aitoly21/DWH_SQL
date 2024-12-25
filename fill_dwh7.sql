--========================================
-- Заполнение таблицы d_craftsmans
--========================================

INSERT INTO dwh.d_craftsmans (
    craftsman_id,
    craftsman_name,
    craftsman_address,
    craftsman_birthday,
    craftsman_email,
    load_dttm
)
OVERRIDING SYSTEM VALUE
SELECT
    craftsman_id,
    craftsman_name,
    craftsman_address,
    craftsman_birthday,
    craftsman_email,
    load_dttm
FROM (
    SELECT DISTINCT ON (craftsman_id)
        craftsman_id,
        craftsman_name,
        craftsman_address,
        craftsman_birthday,
        craftsman_email,
        load_dttm
    FROM (
        -- Источник №1
        SELECT
            c1.craftsman_id,
            c1.craftsman_name,
            c1.craftsman_address,
            c1.craftsman_birthday,
            c1.craftsman_email,
            NOW() AS load_dttm,
            1    AS priority
        FROM source1.craft_market_wide c1

        UNION ALL

        -- Источник №3
        SELECT
            c3.craftsman_id,
            c3.craftsman_name,
            c3.craftsman_address,
            c3.craftsman_birthday,
            c3.craftsman_email,
            NOW() AS load_dttm,
            3    AS priority
        FROM source3.craft_market_craftsmans c3

        UNION ALL

        -- Источник №2
        SELECT
            c2.craftsman_id,
            c2.craftsman_name,
            c2.craftsman_address,
            c2.craftsman_birthday,
            c2.craftsman_email,
            NOW() AS load_dttm,
            2    AS priority
        FROM source2.craft_market_masters_products c2

    ) priority_queue
    ORDER BY craftsman_id, priority
) final_selection
ON CONFLICT (craftsman_id) DO UPDATE
SET
    craftsman_name       = EXCLUDED.craftsman_name,
    craftsman_address    = EXCLUDED.craftsman_address,
    craftsman_birthday   = EXCLUDED.craftsman_birthday,
    craftsman_email      = EXCLUDED.craftsman_email,
    load_dttm            = EXCLUDED.load_dttm;


--========================================
-- Заполнение таблицы d_customers
--========================================

INSERT INTO dwh.d_customers (
    customer_id,
    customer_name,
    customer_address,
    customer_birthday,
    customer_email,
    load_dttm
)
OVERRIDING SYSTEM VALUE
SELECT
    customer_id,
    customer_name,
    customer_address,
    customer_birthday,
    customer_email,
    load_dttm
FROM (
    SELECT DISTINCT ON (customer_id)
        customer_id,
        customer_name,
        customer_address,
        customer_birthday,
        customer_email,
        load_dttm
    FROM (
        -- Источник №2
        SELECT
            oc.customer_id,
            oc.customer_name,
            oc.customer_address,
            oc.customer_birthday,
            oc.customer_email,
            NOW() AS load_dttm,
            2    AS priority
        FROM source2.craft_market_orders_customers oc

        UNION ALL

        -- Источник №1
        SELECT
            w.customer_id,
            w.customer_name,
            w.customer_address,
            w.customer_birthday,
            w.customer_email,
            NOW() AS load_dttm,
            1    AS priority
        FROM source1.craft_market_wide w

        UNION ALL

        -- Источник №3
        SELECT
            c3.customer_id,
            c3.customer_name,
            c3.customer_address,
            c3.customer_birthday,
            c3.customer_email,
            NOW() AS load_dttm,
            3    AS priority
        FROM source3.craft_market_customers c3

    ) priority_queue
    ORDER BY customer_id, priority
) final_selection
ON CONFLICT (customer_id) DO UPDATE
SET
    customer_name        = EXCLUDED.customer_name,
    customer_address     = EXCLUDED.customer_address,
    customer_birthday    = EXCLUDED.customer_birthday,
    customer_email       = EXCLUDED.customer_email,
    load_dttm            = EXCLUDED.load_dttm;


--========================================
-- Заполнение таблицы d_products
--========================================

INSERT INTO dwh.d_products (
    product_id,
    product_name,
    product_description,
    product_type,
    product_price,
    load_dttm
)
OVERRIDING SYSTEM VALUE
SELECT
    product_id,
    product_name,
    product_description,
    product_type,
    product_price,
    load_dttm
FROM (
    SELECT DISTINCT ON (product_id)
        product_id,
        product_name,
        product_description,
        product_type,
        product_price,
        load_dttm
    FROM (
        -- Источник №2
        SELECT
            mp.product_id,
            mp.product_name,
            mp.product_description,
            mp.product_type,
            mp.product_price,
            NOW() AS load_dttm,
            2    AS priority
        FROM source2.craft_market_masters_products mp

        UNION ALL

        -- Источник №1
        SELECT
            mw.product_id,
            mw.product_name,
            mw.product_description,
            mw.product_type,
            mw.product_price,
            NOW() AS load_dttm,
            1    AS priority
        FROM source1.craft_market_wide mw

        UNION ALL

        -- Источник №3
        SELECT
            mo.product_id,
            mo.product_name,
            mo.product_description,
            mo.product_type,
            mo.product_price,
            NOW() AS load_dttm,
            3    AS priority
        FROM source3.craft_market_orders mo

    ) priority_queue
    ORDER BY product_id, priority
) final_selection
ON CONFLICT (product_id) DO UPDATE
SET
    product_name         = EXCLUDED.product_name,
    product_description  = EXCLUDED.product_description,
    product_type         = EXCLUDED.product_type,
    product_price        = EXCLUDED.product_price,
    load_dttm            = EXCLUDED.load_dttm;


--========================================
-- Заполнение таблицы f_orders
--========================================

INSERT INTO dwh.f_orders (
    order_id,
    product_id,
    craftsman_id,
    customer_id,
    order_created_date,
    order_completion_date,
    order_status,
    load_dttm
)
OVERRIDING SYSTEM VALUE
SELECT
    order_id,
    product_id,
    craftsman_id,
    customer_id,
    order_created_date,
    order_completion_date,
    order_status,
    load_dttm
FROM (
    SELECT DISTINCT ON (order_id)
        order_id,
        product_id,
        craftsman_id,
        customer_id,
        order_created_date,
        order_completion_date,
        order_status,
        load_dttm
    FROM (
        -- Источник №3
        SELECT
            o3.order_id,
            o3.product_id,
            o3.craftsman_id,
            o3.customer_id,
            o3.order_created_date    AS order_created_date,
            o3.order_completion_date AS order_completion_date,
            o3.order_status,
            NOW() AS load_dttm,
            3    AS priority
        FROM source3.craft_market_orders o3

        UNION ALL

        -- Источник №1
        SELECT
            w.order_id,
            w.product_id,
            w.craftsman_id,
            w.customer_id,
            w.order_created_date,
            w.order_completion_date,
            w.order_status,
            NOW() AS load_dttm,
            1    AS priority
        FROM source1.craft_market_wide w

        UNION ALL

        -- Источник №2
        SELECT
            oc.order_id,
            oc.product_id,
            oc.craftsman_id,
            oc.customer_id,
            oc.order_created_date,
            oc.order_completion_date,
            oc.order_status,
            NOW() AS load_dttm,
            2    AS priority
        FROM source2.craft_market_orders_customers oc

    ) priority_queue
    ORDER BY order_id, priority
) final_selection
ON CONFLICT (order_id) DO UPDATE
SET
    order_created_date    = EXCLUDED.order_created_date,
    order_completion_date = EXCLUDED.order_completion_date,
    order_status          = EXCLUDED.order_status,
    load_dttm             = EXCLUDED.load_dttm;

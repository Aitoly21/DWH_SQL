/*=============================================================
  Заполнение dwh.craftsman_report_datamart
=============================================================*/
INSERT INTO dwh.craftsman_report_datamart (
    craftsman_id,
    craftsman_name,
    craftsman_address,
    craftsman_birthday,
    craftsman_email,
    craftsman_money,
    platform_money,
    count_order,
    avg_price_order,
    avg_age_customer,
    median_time_order_completed,
    top_product_category,
    count_order_created,
    count_order_in_progress,
    count_order_delivery,
    count_order_done,
    count_order_not_done,
    report_period
)
SELECT
    cm.craftsman_id,
    cm.craftsman_name,
    cm.craftsman_address,
    cm.craftsman_birthday,
    cm.craftsman_email,

    /* Часть суммы достаётся ремесленнику */
    SUM(pr.product_price * 0.9) AS craftsman_money,

    /* Часть суммы достаётся платформе */
    SUM(pr.product_price * 0.1) AS platform_money,

    /* Общее количество заказов */
    COUNT(ord.order_id) AS count_order,

    /* Средняя цена заказов */
    AVG(pr.product_price) AS avg_price_order,

    /* Средний возраст клиентов (на дату заказа) */
    AVG(
        DATE_PART('year', AGE(cst.customer_birthday))
    ) AS avg_age_customer,

    /* Медиана времени выполнения заказа */
    PERCENTILE_CONT(0.5) WITHIN GROUP (
        ORDER BY (ord.order_completion_date - ord.order_created_date)
    ) AS median_time_order_completed,

    /* Самая популярная категория товаров для данного ремесленника */
    (
        SELECT p2.product_type
        FROM dwh.d_products p2
        JOIN dwh.f_orders o2 ON p2.product_id = o2.product_id
        WHERE o2.craftsman_id = cm.craftsman_id
        GROUP BY p2.product_type
        ORDER BY COUNT(*) DESC
        LIMIT 1
    ) AS top_product_category,

    /* Подсчёт заказов в различных статусах */
    COUNT(CASE WHEN ord.order_status = 'created'      THEN 1 END) AS count_order_created,
    COUNT(CASE WHEN ord.order_status = 'in progress'  THEN 1 END) AS count_order_in_progress,
    COUNT(CASE WHEN ord.order_status = 'delivery'     THEN 1 END) AS count_order_delivery,
    COUNT(CASE WHEN ord.order_status = 'done'         THEN 1 END) AS count_order_done,
    COUNT(CASE WHEN ord.order_status = 'not_done'     THEN 1 END) AS count_order_not_done,

    /* Формируем период отчётности (год-месяц) */
    TO_CHAR(
        DATE_TRUNC('month', MIN(ord.order_created_date)),
        'YYYY-MM'
    ) AS report_period

FROM dwh.d_craftsmans cm
/* Соединяемся с таблицей фактов заказов */
JOIN dwh.f_orders ord
    ON cm.craftsman_id = ord.craftsman_id
/* Подтягиваем данные о клиентах */
JOIN dwh.d_customers cst
    ON ord.customer_id = cst.customer_id
/* И данные о товарах */
JOIN dwh.d_products pr
    ON ord.product_id = pr.product_id

GROUP BY
    cm.craftsman_id,
    cm.craftsman_name,
    cm.craftsman_address,
    cm.craftsman_birthday,
    cm.craftsman_email
;


/*-------------------------------------------------------------
  Логирование даты/времени обновления
-------------------------------------------------------------*/
INSERT INTO dwh.load_dates_craftsman_report_datamart (load_dttm)
VALUES (CURRENT_TIMESTAMP);

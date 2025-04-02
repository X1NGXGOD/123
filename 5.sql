WITH 
-- 1. Назви товарів через кому для кожного виробника
goods_list_per_manufacturer AS (
    SELECT m.name AS manufacturer, GROUP_CONCAT(g.name, ', ') AS goods_list
    FROM goods g
    JOIN manufacturers m ON g.manufacturer_code = m.code
    GROUP BY m.name
),

-- 2. Кількість товарів < 20 грн для кожного виробника
cheap_goods_count AS (
    SELECT m.name AS manufacturer, COUNT(g.code) AS cheap_goods_count
    FROM goods g
    JOIN manufacturers m ON g.manufacturer_code = m.code
    WHERE g.price < 20
    GROUP BY m.name
),

-- 3. Середня ціна всіх товарів
average_price_cte AS (
    SELECT AVG(price) AS average_price FROM goods
),

-- 4. Виробники з >1 товаром < 20 грн
manufacturers_with_multiple_cheap_goods AS (
    SELECT m.name AS manufacturer
    FROM goods g
    JOIN manufacturers m ON g.manufacturer_code = m.code
    WHERE g.price < 20
    GROUP BY m.name
    HAVING COUNT(g.code) > 1
)

SELECT 
    g.manufacturer,
    g.goods_list,
    c.cheap_goods_count,
    (SELECT average_price FROM average_price_cte) AS average_price,
    CASE WHEN m.manufacturer IS NOT NULL THEN 'Yes' ELSE 'No' END AS has_multiple_cheap_goods
FROM goods_list_per_manufacturer g
LEFT JOIN cheap_goods_count c ON g.manufacturer = c.manufacturer
LEFT JOIN manufacturers_with_multiple_cheap_goods m ON g.manufacturer = m.manufacturer;

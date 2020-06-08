SELECT
    test_id,
    test_assignment,
    test_events.user_id,
    MAX(CASE WHEN orders.created_at > test_events.event_time 
        THEN 1 
        ELSE 0
        END  ) AS checked_if_orders
FROM
        (SELECT 
          event_id,
          event_time,
          user_id,
          MAX(CASE WHEN parameter_name = 'test_id' 
                THEN CAST(parameter_value AS INT)
                 ELSE NULL
              END) as test_id,
          MAX(CASE WHEN parameter_name ='test_assignment'
                THEN parameter_value
                ELSE NULL
              END) AS test_assignment
      FROM 
          events
      where 
          event_name = 'test_assignment'
      GROUP BY 
          event_id,
          event_time,
          user_id,
          platform
      ORDER BY 
          event_id) test_events
JOIN 
    orders
ON 
    orders.user_id=test_events.user_id
GROUP BY 
    test_id, 
    test_assignment,
    test_events.user_id
ORDER BY checked_if_orders;

--Using the table from the previous exercise, add the following metrics
--1) the number of orders/invoices
--2) the number of items/line-items ordered
--3) the total revenue from the order after treatment
--SELECT *
--FROM dsv1069.orders

SELECT
  
  test_id,
  test_assignment,
  test_events.user_id,
  COUNT(
      DISTINCT(CASE WHEN orders.created_at > test_events.event_time 
          THEN invoice_id
          ELSE NULL
      END  ) 
  ) AS number_of_invoice,
  COUNT(
      DISTINCT(CASE WHEN orders.created_at > test_events.event_time 
          THEN line_item_id
          ELSE NULL
      END  )
  ) AS number_of_ordered_items,
   SUM(
      CASE
           WHEN orders.created_at > test_events.event_time THEN price
           ELSE 0
      END) AS total_revenue

FROM
      (SELECT 
          event_id,
          event_time,
          user_id,
          --platform,
          MAX(CASE WHEN parameter_name = 'test_id' 
                THEN CAST(parameter_value AS INT)
                 ELSE NULL
              END) as test_id,
          MAX(CASE WHEN parameter_name ='test_assignment'
                THEN parameter_value
                ELSE NULL
              END) AS test_assignment
      FROM 
          dsv1069.events
      where 
          event_name = 'test_assignment'
      GROUP BY 
          event_id,
          event_time,
          user_id,
          platform
      ORDER BY 
          event_id) test_events
JOIN 
    dsv1069.orders
ON 
    orders.user_id=test_events.user_id
GROUP BY 
    test_id, 
    test_assignment,
    test_events.user_id
ORDER BY total_revenue DESC


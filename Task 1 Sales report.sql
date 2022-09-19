-- 1 Отчет по дням.
WITH cal AS 
  (SELECT strg,dt FROM 
    (SELECT strg,dt FROM nfvsn UNION ALL SELECT strg,add_months(dt,1) FROM nfvsn UNION ALL SELECT strg,add_months(dt,12) FROM nfvsn) 
  GROUP BY strg,dt ORDER BY strg,dt) 
SELECT cal.strg , cal.dt , ROUND(nfvsn.sales/1000,4) as sales,
    ROUND(LAG(nfvsn.sales,1) OVER (PARTITION BY substr(cal.dt,1,5),cal.strg ORDER BY cal.dt )/1000,4) as prev_year,
    ROUND(LAG(nfvsn.sales,1) OVER (PARTITION BY substr(cal.dt,1,2),cal.strg ORDER BY cal.dt )/1000,4) as prev_months
  FROM cal LEFT JOIN nfvsn ON cal.strg=nfvsn.strg And cal.dt=nfvsn.dt 
ORDER BY strg,dt

-- 2 Отчет по месяцам
WITH PRE AS 
    (SELECT strg,substr(dt,4,7)  dt1, SUM(sales) OVER (PARTITION BY strg,substr(dt,4,7) )  s1 FROM nfvsn 
  ORDER BY strg,dt),
    PRE1 AS 
      (SELECT strg,dt1,s1 FROM PRE 
    GROUP BY strg,dt1,s1 ORDER BY  strg,substr(dt1,4,4),dt1),
    CAL AS 
    (SELECT strg,substr(dt,4,7) AS dt  
      FROM (SELECT strg,dt FROM nfvsn UNION ALL SELECT strg,add_months(dt,1) FROM nfvsn UNION ALL SELECT strg,add_months(dt,12) FROM nfvsn) 
    GROUP BY strg,substr(dt,4,7) ORDER BY strg,substr(substr(dt,4,7),4,4),substr(dt,4,7)) 
SELECT cal.strg,cal.dt, pre1.s1 as sales, 
    ROUND(LAG(pre1.s1,1) OVER (PARTITION BY substr(cal.dt,1,2),cal.strg ORDER BY TO_DATE(cal.dt,'mm.yyyy' ))/1000,4) as prev_year,
    ROUND(LAG(pre1.s1,1) OVER (PARTITION BY cal.strg ORDER BY TO_DATE(cal.dt,'mm.yyyy' ))/1000,4) as prev_months
  FROM cal LEFT JOIN pre1 ON pre1.strg=cal.strg AND cal.dt=pre1.dt1
ORDER BY strg, TO_DATE(dt,'mm.yyyy')
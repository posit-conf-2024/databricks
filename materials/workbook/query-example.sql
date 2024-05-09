-- !preview conn=DBI::dbConnect(odbc::odbc(), "warehouse")

SELECT * FROM samples.tpch.customer LIMIT 10
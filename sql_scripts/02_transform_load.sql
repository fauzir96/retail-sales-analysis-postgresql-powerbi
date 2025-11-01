/*
 ====================================================================
 Project: Retail Sales Analysis (PostgreSQL + Power BI)
 File: 02_transform_load.sql
 Description: This script transforms the data from the staging table
 (data_mentah_retail) and loads it into the Star Schema model.
 THIS IS ONLY RUN AFTER raw data has been successfully loaded
 into data_mentah_retail (e.g., using psql \COPY).
 ====================================================================
*/

-- 1. POPULATE DIMENSION TABLES
-- Take the UNIQUE values from the raw table.

INSERT INTO dim_produk (product_id_sumber, kategori_produk)
SELECT DISTINCT productid, productcategory FROM data_mentah_retail;

INSERT INTO dim_lokasi (nama_lokasi_toko)
SELECT DISTINCT storelocation FROM data_mentah_retail;

INSERT INTO dim_pelanggan (customer_id_sumber)
SELECT DISTINCT customerid FROM data_mentah_retail;

-- Populate dim_waktu by deconstructing the date column
INSERT INTO dim_waktu (id_tanggal_pk, tahun, kuartal, bulan, nama_bulan, hari_dalam_minggu)
SELECT
    tanggal_unik AS id_tanggal_pk,
    EXTRACT(YEAR FROM tanggal_unik) AS tahun,
    EXTRACT(QUARTER FROM tanggal_unik) AS kuartal,
    EXTRACT(MONTH FROM tanggal_unik) AS bulan,
    TRIM(TO_CHAR(tanggal_unik, 'Month')) AS nama_bulan,
    TRIM(TO_CHAR(tanggal_unik, 'Day')) AS hari_dalam_minggu
FROM (
    -- Subquery to get one row per unique day
    SELECT DISTINCT transactiondate::date AS tanggal_unik
    FROM data_mentah_retail
) AS t
ON CONFLICT (id_tanggal_pk) DO NOTHING; -- Safety check if data is re-run

/*
 ====================================================================
 2. POPULATE THE FACT TABLE (THE MAIN QUERY)
 Joins the raw data with the dimensions to swap
 'Business Keys' (slow text) with 'Surrogate Keys' (fast integer).
 ====================================================================
*/

INSERT INTO fakta_penjualan (
    id_produk_fk, id_lokasi_fk, id_pelanggan_fk, id_tanggal_fk,
    tanggal_transaksi, metode_pembayaran, kuantitas,
    harga_satuan, diskon_persen, total_harga
)
SELECT
    p.id_produk_pk,         -- Get the Surrogate Key (Integer) from dim_produk
    l.id_lokasi_pk,         -- Get the Surrogate Key (Integer) from dim_lokasi
    c.id_pelanggan_pk,      -- Get the Surrogate Key (Integer) from dim_pelanggan
    mentah.transactiondate::date, -- The Date Key (Date)
    
    -- The raw measures and degenerate dimensions
    mentah.transactiondate, mentah.paymentmethod, mentah.quantity,
    mentah.price, mentah.discount_percent, mentah.totalamount
FROM
    data_mentah_retail AS mentah
-- Join on each dimension
JOIN
    dim_produk AS p ON mentah.productid = p.product_id_sumber
JOIN
    dim_lokasi AS l ON mentah.storelocation = l.nama_lokasi_toko
JOIN
    dim_pelanggan AS c ON mentah.customerid = c.customer_id_sumber;

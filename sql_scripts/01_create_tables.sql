/*
 ====================================================================
 Project: Retail Sales Analysis (PostgreSQL + Power BI)
 File: 01_create_tables.sql
 Description: This script creates all tables necessary for the
 ETL workflow, including:
    1. The Staging Table (for raw, messy data)
    2. The Dimension Tables (Star Schema)
    3. The Fact Table (Star Schema)
 ====================================================================
*/

-- 1. STAGING TABLE (To hold the raw, uncleaned CSV data)
CREATE TABLE data_mentah_retail (
    customerid VARCHAR(50),
    productid VARCHAR(50),
    quantity INTEGER,
    price DECIMAL(18, 9),
    transactiondate TIMESTAMP,
    paymentmethod VARCHAR(50),
    storelocation VARCHAR(100),
    productcategory VARCHAR(100),
    discount_percent DECIMAL(18, 9),
    totalamount DECIMAL(18, 9)
);

/*
 ====================================================================
 2. STAR SCHEMA TABLES (The optimized Data Warehouse model)
 These tables will be populated from data_mentah_retail and
 will be consumed by Power BI.
 ====================================================================
*/

-- 2a. DIMENSION TABLES

CREATE TABLE dim_produk (
    id_produk_pk SERIAL PRIMARY KEY,
    product_id_sumber VARCHAR(50),
    kategori_produk VARCHAR(100)
);

CREATE TABLE dim_lokasi (
    id_lokasi_pk SERIAL PRIMARY KEY,
    nama_lokasi_toko VARCHAR(100)
);

CREATE TABLE dim_pelanggan (
    id_pelanggan_pk SERIAL PRIMARY KEY,
    customer_id_sumber VARCHAR(50)
);

CREATE TABLE dim_waktu (
    id_tanggal_pk DATE PRIMARY KEY,
    tahun SMALLINT NOT NULL,
    kuartal SMALLINT NOT NULL,
    bulan SMALLINT NOT NULL,
    nama_bulan VARCHAR(20) NOT NULL,
    hari_dalam_minggu VARCHAR(20) NOT NULL
);

-- 2b. FACT TABLE

CREATE TABLE fakta_penjualan (
    id_transaksi_pk SERIAL PRIMARY KEY,

    -- Foreign Keys (Linking to Dimensions)
    id_produk_fk INTEGER REFERENCES dim_produk(id_produk_pk),
    id_lokasi_fk INTEGER REFERENCES dim_lokasi(id_lokasi_pk),
    id_pelanggan_fk INTEGER REFERENCES dim_pelanggan(id_pelanggan_pk),
    id_tanggal_fk DATE REFERENCES dim_waktu(id_tanggal_pk),

    -- Transactional Info (Degenerate Dimensions)
    tanggal_transaksi TIMESTAMP,
    metode_pembayaran VARCHAR(50),

    -- The Measures (Numeric Facts)
    kuantitas INTEGER,
    harga_satuan DECIMAL(18, 9),
    diskon_persen DECIMAL(18, 9),
    total_harga DECIMAL(18, 9)
);

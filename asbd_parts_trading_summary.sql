%sql

SELECT
    a.id_dlr,
    a.buysell_dlr_id,
    a.dte_inv_clos_orgnl,
    a.id_mstr,
    a.nam_cust,
    a.mbusa_segmentation,
    a.sub_type,
    CASE
        WHEN a.part_category IN (' ', 'N/A', 'OTHER', 'UNSPECIFIED') THEN 'UNSPECIFIED'
        ELSE TRIM(a.part_category)
    END AS part_category,
    COUNT(DISTINCT a.num_dms_inv) AS inv_count,
    SUM(a.total_inv_amount) AS total_inv_amount,
    SUM(a.total_cost) AS total_cost,
    SUM(a.total_amount_calc) AS total_amount_calc,
    SUM(a.qty_dms_pt_sld_inv) AS qty_dms_pt_sld_inv,
    CASE
        WHEN b.category_code NOT IN ('003','004','026','032','033') OR b.category_code IS NULL THEN SUM(a.total_cost)
        ELSE 0
    END AS amt_mechanical_cst,
    CASE
        WHEN b.category_code IN ('003','004','026','032','033') THEN SUM(a.total_cost)
        ELSE 0
    END AS amt_collision_cst,
    CASE
        WHEN b.category_code NOT IN ('003','004','026','032','033') OR b.category_code IS NULL THEN SUM(a.total_inv_amount)
        ELSE 0
    END AS amt_mechanical_inv,
    CASE
        WHEN b.category_code IN ('003','004','026','032','033') THEN SUM(a.total_inv_amount)
        ELSE 0
    END AS amt_collision_inv
FROM eastus2_extollo_ms_us_edwdev_adbv.`xto-us-12_parts-gld`.tmp_for_business_validation_adw_pdw_edw__asbd_parts_trading_raw a
JOIN eastus2_extollo_ms_us_edwdev_adbv.`xto-us-12_parts-gld`.v_asbd_part_dim b
    ON a.part_number_db_format = b.part_number_db
WHERE a.ind_actv_mbusa_dlr = 'Y'
    AND a.dte_inv_clos_orgnl >= CAST(CONCAT(YEAR(current_date()) - 3, '-01-01') AS DATE)
GROUP BY
    a.id_dlr,
    a.buysell_dlr_id,
    a.dte_inv_clos_orgnl,
    a.id_mstr,
    a.nam_cust,
    a.mbusa_segmentation,
    a.sub_type,
    a.part_category,
    b.category_code;

Transform::Dsl.draw do
  define_collection :Denorm_UPC_Nonzero_sls,
                    :UPC_NBR, :WEEK_ID, :FS_SUB_CATEGORY_ID, :FS_SALES_DLRS, :FS_COSTS_DLRS, :FS_PROMO_SALES_DLRS, :FS_VENDOR_FUNDING_DLRS, :FS_SALES_UNITS, :FS_PROMO_SALES_UNITS, :FS_NBR_TRANSACTIONS, :FS_AVG_BASKET_SIZE, :FS_UNADJUSTED_MARGIN_DLRS, :FS_Lifecycle_stage, :DP_PROMO_FLAG, :DC_WEEK_NUM, :DC_YEAR_NUM, :DC_WEEK_DATE, :DC_AD_WEEK, :DS_SUB_CATEGORY_ID, :DS_SEASONALITY_INDEX, :FN_start_sale_week, :FN_end_sale_week, :ADJ_SALES_DLRS
  filter(:evaluation_period, :Denorm_UPC_Nonzero_sls) { |sale| sale.UPC_NBR.to_i == 28 && (sale.DC_WEEK_NUM.to_i-20).abs <= 8 }
  generate(:exponential_sequence, :factor, 17) { |i| i==8 ? 0 : (0.5**((i - 8).abs+1))/(1-0.5**8) }
  compose(:period_with_factors, :evaluation_period, :exponential_sequence)
  project(:period_non_promo_sales, :period_with_factors, pwk_sales: lambda { |week| week.DP_PROMO_FLAG.to_i == 1 ? week.previous.pwk_sales : week.FS_SALES_DLRS })
  aggregate(:deseasonalized_baseline, :period_non_promo_sales, 0, :deseasonalized_baseline) { |total, week| total + week.pwk_sales.to_f*week.factor.to_f/week.DS_SEASONALITY_INDEX.to_f }
  compose(:baseline_with_seasonality, :deseasonalized_baseline, :period_with_factors) { |baseline, week| week.factor == "0" }
  calculate(:reseasonalized_baseline, :baseline_with_seasonality, :reseasonalized_baseline) { |week| week.deseasonalized_baseline.to_f * week.DS_SEASONALITY_INDEX.to_f }
  store :reseasonalized_baseline
end
Transform::Dsl.draw do
  define_collection :Denorm_UPC_Nonzero_sls,
                    :UPC_NBR, :WEEK_ID, :FS_SUB_CATEGORY_ID, :FS_SALES_DLRS, :FS_COSTS_DLRS, :FS_PROMO_SALES_DLRS,
                    :FS_VENDOR_FUNDING_DLRS, :FS_SALES_UNITS, :FS_PROMO_SALES_UNITS, :FS_NBR_TRANSACTIONS,
                    :FS_AVG_BASKET_SIZE, :FS_UNADJUSTED_MARGIN_DLRS, :FS_Lifecycle_stage, :DP_PROMO_FLAG,
                    :DC_WEEK_NUM, :DC_YEAR_NUM, :DC_WEEK_DATE, :DC_AD_WEEK, :DS_SUB_CATEGORY_ID, :DS_SEASONALITY_INDEX,
                    :FN_start_sale_week, :FN_end_sale_week, :ADJ_SALES_DLRS
  define_collection :MARKET_SHARE, :FS_SUB_CATEGORY_ID, :ADJUSTMENT_FACTOR
  filter(:evaluation_period, :Denorm_UPC_Nonzero_sls) do |sale|
    sale.UPC_NBR.to_i == 28 && (sale.DC_WEEK_NUM.to_i-20).abs <= 8
  end
  generate(:exponential_sequence, :factor, 17) { |i| i==8 ? 0 : (0.5**((i - 8).abs+1))/(1-0.5**8) }
  compose(:period_with_factors, :evaluation_period, :exponential_sequence)
  project(:period_non_promo_sales, :period_with_factors,
          pwk_sales: lambda { |week| week.DP_PROMO_FLAG.to_i == 1 ? week.previous.pwk_sales : week.FS_SALES_DLRS })
  aggregate(:deseasonalized_baseline, :period_non_promo_sales, 0, :deseasonalized_baseline) do |total, week|
    total + week.pwk_sales.to_f*week.factor.to_f/week.DS_SEASONALITY_INDEX.to_f
  end
  compose(:baseline_with_seasonality, :deseasonalized_baseline, :period_with_factors) do |baseline, week|
    week.factor == "0"
  end
  compose(:baseline_with_market_adjustment, :baseline_with_seasonality, :MARKET_SHARE) do |baseline, market|
    baseline.FS_SUB_CATEGORY_ID == market.FS_SUB_CATEGORY_ID
  end
  calculate(:reseasonalized_adjusted_baseline, :baseline_with_market_adjustment, :reseasonalized_adjusted_baseline) do |week|
    week.deseasonalized_baseline.to_f * week.DS_SEASONALITY_INDEX.to_f * week.ADJUSTMENT_FACTOR.to_f
  end
  store :reseasonalized_adjusted_baseline
end

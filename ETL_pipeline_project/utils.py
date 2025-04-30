# utils.py

import logging

def setup_logging(log_file='etl_pipeline.log'):
    logging.basicConfig(
        filename=log_file,
        level=logging.INFO,
        format='%(asctime)s %(levelname)s:%(message)s'
    )

def validate_data(df):
    try:
        if df.isnull().sum().any():
            logging.warning("⚠️ Missing values detected in the data.")
        else:
            logging.info("✅ No missing values detected.")

        if (df['unit_price'] < 0).any():
            logging.error("❌ Negative unit prices found.")
            raise ValueError("Data validation failed: Negative unit prices.")
        
    except Exception as e:
        logging.error(f"Error during validation: {e}")
        raise

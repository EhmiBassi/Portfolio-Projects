# etl_pipeline.py

import pandas as pd
from sqlalchemy import create_engine
from getpass import getpass
import logging

from utils import setup_logging, validate_data

def extract_data(sales_dataset):
    try:
        df = pd.read_csv("sales_dataset.csv")
        logging.info("✅ Data extracted successfully.")
        return df
    except FileNotFoundError as e:
        logging.error(f"File not found: {e}")
    except Exception as e:
        logging.error(f"❌ Error extracting data: {e}")
        raise

def transform_data(df):
    try:
        df['total_sales'] = df['quantity'] * df['unit_price']
        df['date'] = pd.to_datetime(df['date'])
        df['year'] = df['date'].dt.year
        df['month'] = df['date'].dt.month

        def assign_age_group(age):
            if pd.isnull(age):
                return 'Unknown'
            age = int(age)
            if age < 18:
                return 'Under 18'
            elif 18 <= age <= 25:
                return '18-25'
            elif 26 <= age <= 35:
                return '26-35'
            elif 36 <= age <= 45:
                return '36-45'
            else:
                return '46+'

        df['age_group'] = df['customer_age'].apply(assign_age_group)

        text_columns = ['store_location', 'product_category', 'payment_method']
        for col in text_columns:
            df[col] = df[col].str.title()

        logging.info("✅ Data transformed successfully.")
        return df
    except Exception as e:
        logging.error(f"❌ Error transforming data: {e}")
        raise

def load_data(df, user, password, host, port, database, table_name):
    try:
        engine = create_engine(f'postgresql+psycopg2://{user}:{password}@{host}:{port}/{database}')
        df.to_sql(table_name, engine, if_exists='replace', index=False)
        logging.info(f"✅ Data loaded into table: {table_name}")
    except Exception as e:
        logging.error(f"❌ Error loading data: {e}")
        raise

def main():
    setup_logging()
    logging.info("🚀 ETL pipeline started.")

    file_path = 'sales_dataset'
    user = 'postgres'
    password = getpass("Enter your PostgreSQL password: ")
    host = 'localhost'
    port = '5432'
    database = 'postgres'
    table_name = 'retail_sales'

    try:
        raw_data = extract_data(file_path)
        validate_data(raw_data)
        transformed_data = transform_data(raw_data)
        load_data(transformed_data, user, password, host, port, database, table_name)

        logging.info("🎉 ETL pipeline completed successfully.")

    except Exception as e:
        logging.critical(f"🔥 ETL pipeline failed: {e}")
        print(f"Pipeline failed: {e}")

if __name__ == "__main__":
    main()

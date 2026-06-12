# Retail Sales ETL Pipeline

This ETL project extracts retail sales data from a CSV file, validates and transforms the data, and loads it into a PostgreSQL database.

## Project Structure
- **etl_pipeline.py**: Main ETL script.
- **utils.py**: Helper functions for logging and validation.
- **sales_dataset.csv**: Source data.
- **etl_pipeline.log**: Logs for monitoring ETL steps.

## Features
- Data validation (missing values, negative unit prices)
- Clean modular code
- Error handling and logging
- Secure password handling (getpass)

## How to Run
```bash
python etl_pipeline.py

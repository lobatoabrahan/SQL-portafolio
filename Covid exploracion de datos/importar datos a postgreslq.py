import pandas as pd
from sqlalchemy import create_engine
import psycopg2

engine = create_engine('postgresql+psycopg2://user:password@hostname/database')
df = pd.read_excel('Covid/Datasets/CovidVaccinations.xlsx')
df.to_sql(name='covid_vaccunations', con=engine, if_exists='append', index=False)

df = pd.read_excel('Covid/Datasets/CovidDeaths.xlsx')
df.to_sql(name='covid_deaths', con=engine, if_exists='append', index=False)

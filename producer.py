import pandas as pd
from kafka import KafkaConsumer,KafkaProducer
from time import sleep
from json import dumps
import json

producer = KafkaProducer(bootstrap_servers=['44.222.74.31:9092'], #change ip here
                         value_serializer=lambda x: 
                         dumps(x).encode('utf-8'))

producer.send('demo_testing', value={'surnasdasdame':'parasdasdmar'})

df = pd.read_csv(r"/home/mohit/stock-market-kafka/indexProcessed.csv")

df.head()

while True:
    dict_stock = df.sample(1).to_dict(orient="records")[0]
    producer.send('demo_testing', value=dict_stock)
    sleep(1)

producer.flush() #clear data from kafka server

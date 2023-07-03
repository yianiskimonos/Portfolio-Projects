#!/usr/bin/env python
# coding: utf-8

# In[307]:


# This script utilizes CoinmarketCap's API to extract data from their website and store it in a CSV file.
# Subsequently, the data is transformed into various graphs for visualization purposes."

import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.dates import DateFormatter
from matplotlib.ticker import MultipleLocator
from dateutil.parser import parse


# In[308]:


from requests import Session
from requests.exceptions import ConnectionError, Timeout, TooManyRedirects
import json
from time import time, sleep

df = pd.DataFrame()

def api_runner():
    global df
    url = 'https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest' 
    # Original Sandbox Environment: 'https://sandbox-api.coinmarketcap.com/v1/cryptocurrency/listings/latest'
    parameters = {
        'start': '1',
        'limit': '31',
        'convert': 'USD'
    }
    headers = {
        'Accepts': 'application/json',
        'X-CMC_PRO_API_KEY': 'aad4bb09-b00b-4da5-9ebc-ec926199e14f',
    }

    session = Session()
    session.headers.update(headers)

    try:
        response = session.get(url, params=parameters)
        data = json.loads(response.text)
        # print(data)
    except (ConnectionError, Timeout, TooManyRedirects) as e:
        print(e)

    # Use this if you just want to keep it in a dataframe
    df = pd.json_normalize(data['data'])
    df['Timestamp'] = pd.to_datetime('now', utc=True).strftime("%d-%m-%Y %H:%M:%S")
    df 
    
    if not os.path.isfile('/Users/coding/Documents/Python tests/APIDATA.csv'):
        df.to_csv('/Users/coding/Documents/Python tests/APIDATA0.csv', header = 'column_names')
    else: 
        df.to_csv('/Users/coding/Documents/Python tests/APIDATA0.csv', mode = 'a', header = False)

for i in range(300):
    api_runner()
    print('API has been successfully run!')
    sleep(60)  # sleep for 1 minute


# In[316]:


df = pd.read_csv('/Users/coding/Documents/Python tests/APIDATA0.csv')
df


# In[318]:


# In this visualization, I plot the top 30 largest cryptocurrencies of 2023 on a scatter plot.
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from matplotlib.dates import DateFormatter, YearLocator


f = pd.read_csv('/Users/coding/Documents/Python tests/APIDATA0.csv')
pd.set_option('display.float_format', lambda x: '%.2f' % x)  # Set display format

df = f.drop(columns=['id', 'platform.id', 'platform.symbol', 'platform.slug', 'platform.token_address', 'platform.name', 'quote.USD.tvl', 'quote.USD.last_updated', 'Unnamed: 0'])

x = df['date_added'].apply(parse)  # Use dateutil.parser.parse for correct date parsing
y = df['name']

plt.scatter(x, y, color='green')  # Change the color to green
plt.xlabel('Date')
plt.ylabel('Cryptocurrency')
plt.title('Top 30 Cryptocurrency Market Entry - 2023')

# Reverse the order of Y-axis
plt.gca().invert_yaxis()

# Set the x-axis major locator and formatter
plt.gca().xaxis.set_major_locator(YearLocator(base=1))  # 1-year intervals
plt.gca().xaxis.set_major_formatter(DateFormatter('%Y'))

plt.xticks(rotation=45)  # Rotate x-axis tick labels for better visibility
plt.tight_layout()  # Adjust layout to prevent overlapping labels
plt.show()


# In[233]:


df


# In[236]:


df50 = df.rename(columns={'quote.USD.market_cap_dominance': 'Market_Cap'})
df51 = selected_columns = df50[['name', 'Market_Cap']]

df51


# In[237]:


# In order to ensure accurate graph results, I implemented a mechanism to calculate and incorporate the missing remainder data, as it was not originally included in the dataset.
column_data = df11['Market_Cap']
column_sum = sum(column_data)
remainder = 100 - column_sum
remainder = 6.374600000000001
formatted_remainder = "{:.3g}".format(remainder)
formatted_remainder


# In[225]:


df12

df12.drop_duplicates(subset=['name', 'Market_Cap'], keep='first', inplace=True)

# Print the updated DataFrame
print(df12)


# In[238]:


# In order to incorporate the calculated remainder information, I introduced a new row containing the derived values.
new_row = {'name': 'Rest of the Market', 'Market_Cap': 6.37}

df51.loc[df.index.max() + 1] = new_row


# In[240]:


df51


# In[241]:


# Reset the order of the 'quote.USD.market_cap_dominance' column in descending order
df51_sorted = df12.sort_values('Market_Cap', ascending=False)

df51 = pd.DataFrame(df10_sorted)
print(df51_sorted)


# In[242]:


df51


# In[244]:


df51.drop_duplicates(subset=['name', 'Market_Cap'], keep='first', inplace=True)

# Print the updated DataFrame
print(df51)


# In[245]:


df51


# In[311]:


# In this visualization, I represent the data mentioned above through a pie chart, illustrating the distribution of market capitalization among the top currencies in 2023.
# Assuming you have a DataFrame named 'df51' with columns 'name' and 'Market_Cap'
market_cap_data = df51['Market_Cap']
label_threshold = 1

# Create labels for pie chart
labels = ['' if pct <= label_threshold else f"{label}: {pct:.1f}%" for label, pct in zip(df51['name'], market_cap_data)]

# Plotting the pie chart
_, _, autotexts = plt.pie(market_cap_data, labels=labels, autopct='', startangle=90)

# Adjusting label properties
for i, autotext in enumerate(autotexts):
    if market_cap_data[i] <= label_threshold:
        autotext.set_visible(False)  # Hide labels for smaller areas
    else:
        angle = np.degrees(np.arctan2(*autotext.get_position()))  # Get angle of text position
        x = autotext.get_position()[0] + 0.1 * (1 if angle < -90 else -1)  # Adjust x-position based on angle
        y = autotext.get_position()[1] + 0.05  # Adjust y-position
        plt.annotate(autotext.get_text(), (x, y), color='white')  # Add label to the pie chart

plt.axis('equal')  # Ensure pie is drawn as a circle
plt.title('Market Cap Distribution - 2023')  # Add title to the pie chart
plt.show()


# In[269]:


df50


# In[275]:


df52 = df50.rename(columns={'quote.USD.percent_change_1h': '1 HOUR', 'quote.USD.percent_change_24h': '24 HOUR','quote.USD.percent_change_7d': '7 DAYS','quote.USD.percent_change_30d': '30 DAYS','quote.USD.percent_change_60d': '60 DAYS','quote.USD.percent_change_90d': '90 DAYS'})
df53 = df52[['name', '1 HOUR', '24 HOUR', '7 DAYS', '30 DAYS', '60 DAYS', '90 DAYS']]

df53


# In[288]:


df55 = df53.set_index('name')
df55


# In[292]:


type(df55)


# In[324]:


# This line graph displays the top 15 cryptocurrencies with the highest percentage change over different time periods, highlighting their performance.
import pandas as pd
import matplotlib.pyplot as plt


# Sort the DataFrame by the desired column ('1 HOUR' in this example) in descending order
df_sorted = df53.sort_values('60 DAYS', ascending=True)

# Select the top N values (e.g., top 10)
top_n = 15
df_top = df_sorted.head(top_n)

# Transpose the DataFrame
df_transposed = df_top.set_index('name').T

# Plot the transposed DataFrame
ax = df_transposed.plot(kind='line')

plt.xlabel('Hours')
plt.ylabel('Percentage Change')
plt.title(f'Top {top_n} Cryptocurrencies with Highest Percentage Change')

# Move the legend keys to the right
ax.legend(title='Cryptocurrency', bbox_to_anchor=(1, 0.5), loc='center left')

plt.show()







# In[ ]:





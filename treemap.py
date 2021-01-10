import plotly.express as px
import numpy as np

df = px.data.gapminder().query("year == 2007")
df["world"] = "world" # in order to have a single root node
fig = px.treemap(df, path=['world', 'continent', 'country'], values='pop',
                  color='lifeExp', hover_data=['iso_alpha'],
                  color_continuous_scale='viridis',
                  color_continuous_midpoint=np.average(df['lifeExp'], weights=df['pop']))

fig.write_html("/tmp/plotly.html")

import plotly.express as px

fig = px.treemap(joined_df,
    path=['family', 'item'],
    values='chaos_total',
    color='chaos_unity'
)

fig.write_html("/tmp/plotly.html")

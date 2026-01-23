import streamlit as st
import plotly.graph_objects as go
import pandas as pd
import snowflake.connector

st.set_page_config(page_title="TradingView", layout="wide", page_icon="🕯️")

# CONTROLS (TOP)
col1, col2 = st.columns([3,1])
with col1:
    theme = st.selectbox("🎨 Theme", ["Dark", "Light"], index=0)
with col2:
    timeframe = st.selectbox("⏰", ["15m", "5m", "1m", "1d"])

# THEME COLORS
if theme == "Dark":
    chart_bg = '#1a1a1a'
    grid_color = 'rgba(51,51,51,0.2)'
    font_color = 'white'
else:
    chart_bg = '#ffffff'
    grid_color = 'rgba(200,200,200,0.2)'
    font_color = 'black'

# 🔥 FULL CANDLE COLOR CONTROLS
st.markdown("### 🟢🔴 **COMPLETE CANDLE CUSTOMIZATION**")
candle_col1, candle_col2, candle_col3, candle_col4 = st.columns(4)
with candle_col1:
    green_fill = st.color_picker("🟢 Bull Fill", "#00ff88")
with candle_col2:
    green_border = st.color_picker("🟢 Bull Border/Wick", "#00cc66")
with candle_col3:
    red_fill = st.color_picker("🔴 Bear Fill", "#ff4444")
with candle_col4:
    red_border = st.color_picker("🔴 Bear Border/Wick", "#cc3333")

st.markdown("---")

# SNOWFLAKE
@st.cache_resource
def init_connection():
    return snowflake.connector.connect(
        account = "HVHRXFX-BU65307",
        user = "NIKHIL",
        password = "Snowbrixai@123",
        warehouse = "COMPUTE_WH",
        database = "CRYPTO_DB",
        schema = "GOLD"
    )

@st.cache_data(ttl=5)
def load_data(timeframe):
    conn = init_connection()
    table_map = {"1m": "TRADES_OHLC_1M", "5m": "TRADES_OHLC_5M", 
                 "15m": "TRADES_OHLC_15M", "1d": "TRADES_OHLC_1D"}
    table = table_map.get(timeframe, "TRADES_OHLC_15M")
    df = pd.read_sql(f"""
        SELECT DATE, TIME, OPEN, HIGH, LOW, CLOSE, VOLUME 
        FROM {table} 
        WHERE DATE >= CURRENT_DATE() - 7
        ORDER BY DATE, TIME
    """, conn)
    return df

df = load_data(timeframe)

# FULLY CUSTOMIZED CHART
if not df.empty:
    df['DATETIME'] = pd.to_datetime(df['DATE'].astype(str) + ' ' + df['TIME'])
    
    fig = go.Figure()
    fig.add_trace(go.Candlestick(
        x=df['DATETIME'],
        open=df['OPEN'],
        high=df['HIGH'],
        low=df['LOW'],
        close=df['CLOSE'],
        # FILL COLORS
        increasing_fillcolor=green_fill,
        decreasing_fillcolor=red_fill,
        # BORDER + WICK COLORS (NEW!)
        increasing_line_color=green_border,
        decreasing_line_color=red_border,
        line=dict(width=1),  # BORDER THICKNESS
        showlegend=False
    ))
    
    fig.update_layout(
        paper_bgcolor=chart_bg,
        plot_bgcolor=chart_bg,
        height=700,
        xaxis=dict(
            title="🕐 TIME",
            showgrid=False,
            zeroline=False,
            showline=False,
            tickfont=dict(color=font_color, size=12)
        ),
        yaxis=dict(
            title="💰 PRICE (₹)",
            showgrid=False,
            zeroline=False,
            showline=False,
            tickfont=dict(color=font_color, size=12)
        ),
        margin=dict(l=60, r=10, t=30, b=40),
        dragmode='zoom'
    )
    
    config = {
        'scrollZoom': True,
        'doubleClick': 'reset+autosize',
        'displayModeBar': False,
        'displaylogo': False
    }
    
    st.plotly_chart(fig, use_container_width=True, config=config)

    # COLOR PREVIEW
    st.markdown(f"""
    **Current Colors**:
    - 🟢 Bull: Fill={green_fill} | Border/Wick={green_border}
    - 🔴 Bear: Fill={red_fill} | Border/Wick={red_border}
    """)

# HIDDEN INFO
with st.expander("📊 Info", expanded=False):
    if not df.empty:
        latest = df.iloc[-1]
        st.success(f"Loaded {len(df)} {timeframe} candles | Close: ₹{latest.CLOSE:,.0f}")

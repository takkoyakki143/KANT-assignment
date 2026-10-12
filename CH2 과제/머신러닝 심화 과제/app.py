# TODO
# 지금까지 작성한 코드를 하나의 app.py로 연결하세요.
import streamlit as st
import pandas as pd

from statsmodels.tsa.arima.model import ARIMA

st.title("Bike Sharing 시계열 예측")
st.write("월별 자전거 대여량을 확인하고 미래 값을 예측합니다.")

uploaded_file = st.file_uploader(
    "CSV 파일을 업로드하세요.",
    type=['csv']
)

if uploaded_file is not None:
    data = pd.read_csv(uploaded_file)

    st.write("원본 데이터")
    st.dataframe(data)

    data['datetime'] = pd.to_datetime(data['datetime'])
    data = data.sort_values('datetime')

    data['month'] = (data['datetime'].dt.to_period('M').dt.to_timestamp())

    monthly = (data.groupby('month', as_index=False)['count'].sum())
    monthly = monthly.set_index('month')

    st.write("월별 자전거 대여량")
    st.dataframe(monthly)
    st.write("시간에 따른 월별 대여량 변화")
    st.line_chart(monthly)

    forecast_period = st.selectbox(
        "예측 기간을 선택하세요.",
        [1, 3, 6]
    )   

    model = ARIMA(monthly['count'], order=(2, 1, 1))
    model_fit = model.fit()

    forecast = model_fit.forecast(steps=forecast_period)
    st.write("예측 결과")
    st.line_chart(forecast)

    last_month = monthly.index.max()
    future_dates = pd.date_range(
        start=last_month + pd.DateOffset(months=1),
        periods=forecast_period,
        freq='MS'   
    )

    forecast_df = pd.DataFrame(
        {'forecast': forecast.values},
        index=future_dates
    )
    forecast_df.index.name = 'month'

    st.write("미래 예측 결과")
    st.dataframe(forecast_df)

    combined = pd.concat([
        monthly.rename(columns={'count': 'actual'}),
        forecast_df
    ])

    st.write("실제값과 예측값 비교")
    st.line_chart(combined)

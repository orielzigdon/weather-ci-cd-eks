FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1

WORKDIR /weather
COPY requirements.txt /weather
RUN pip install --no-cache-dir -r requirements.txt

COPY web_app_project/ /weather

CMD [ "gunicorn", "--bind", "0.0.0.0:5000", "weather:app" ]

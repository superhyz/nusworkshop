FROM python:3.11-slim

WORKDIR /app

# Copy from the current directory (llm-frontend-python)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Port 5000 based on your README (image_1b20a6.jpg)
EXPOSE 5000

CMD ["python", "app.py"]
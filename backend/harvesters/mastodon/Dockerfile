FROM python:3.8-slim

WORKDIR /app

# Copy requirements first to leverage Docker cache
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the harvester code
COPY harvester.py .
COPY preprocess.py .

# Copy common utilities
COPY ../common/elasticsearch_client.py ./common/
COPY ../common/text_preprocessing.py ./common/

# Environment variables will be provided through Kubernetes secrets
ENV MASTODON_ACCESS_TOKEN=""
ENV MASTODON_INSTANCE_URL=""
ENV ELASTICSEARCH_URL=""

# Command to run the harvester
CMD ["python", "harvester.py"] 
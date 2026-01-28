
# escape= 
# syntax=docker/dockerfile:1
FROM python:3.11-slim-bookworm AS base


RUN apt-get update && apt-get install -y --no-install-recommends

RUN python -m venv /opt/venv
ENV PATH=/opt/venv/bin:$PATH

WORKDIR /app 

COPY requirements.txt .

RUN pip install --no-cache-dir --upgrade pip && pip install --no-cache-dir -r requirements.txt




FROM python:3.11-slim-bookworm 

RUN apt-get update && apt-get install -y --no-install-recommends

RUN python -m venv /opt/venv
ENV     PATH=/opt/venv/bin:$PATH
WORKDIR /app
# Copy virtual environment from builder
COPY --from=base --chown=appuser:appgroup /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
ENV VIRTUAL_ENV="/opt/venv"

LABEL description="dept is infotech@globallogic"
LABEL version=version="1.0.0"

COPY --from=base --chown=appuser:appgroup  ./app .
COPY /app .
RUN addgroup -gid 1001 appgroup && \
    adduser -uid 1001 -gid 1001 appuser

USER appuser

EXPOSE 5000

VOLUME [/app]

# CMD ["flask", "run"]
# CMD ["gunicorn", "app:app", "--bind", "0.0.0.0:8080"]
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "4", "app:app"]

FROM python:3.15.2-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    HOST=0.0.0.0 \
    PORT=8000

WORKDIR /app
RUN useradd --uid 10001 --create-home app \
    && chown app:app /app

# Add dependency installation here once requirements.txt or pyproject.toml exists.
COPY --chown=app:app . .

USER app
EXPOSE 8000

# Requires a future app.py entrypoint that binds to HOST and PORT.
CMD ["python", "app.py"]

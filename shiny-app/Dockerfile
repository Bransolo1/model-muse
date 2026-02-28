# ============================================================================
# Sensehub AutoM/L — Dockerfile
# Multi-stage build using rocker/shiny for minimal footprint.
# ============================================================================

FROM rocker/shiny:4.3.2 AS base

# System dependencies for R packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user for running the app
RUN useradd --create-home --shell /bin/bash sensehub

# Set working directory
WORKDIR /home/sensehub/app

# Copy renv files first for layer caching
COPY renv.lock renv.lock
COPY .Rprofile .Rprofile

# Install renv and restore packages
RUN R -e "install.packages('renv', repos='https://cloud.r-project.org')" && \
    R -e "renv::restore()" || \
    R -e "install.packages(c( \
      'shiny', 'bslib', 'DT', 'shinyWidgets', 'shinyjs', \
      'tidymodels', 'recipes', 'parsnip', 'workflows', 'workflowsets', \
      'tune', 'rsample', 'yardstick', 'dials', 'stacks', 'probably', \
      'glmnet', 'ranger', 'xgboost', 'kknn', 'kernlab', 'discrim', 'naivebayes', 'rpart', \
      'promises', 'future', \
      'dplyr', 'tidyr', 'purrr', 'readr', 'forcats', 'readxl', 'lubridate', \
      'ggplot2', 'jsonlite', 'vip', 'themis' \
    ), repos='https://cloud.r-project.org')"

# Copy application code
COPY global.R server.R ui.R ./
COPY R/ R/

# Ensure proper ownership
RUN chown -R sensehub:sensehub /home/sensehub/app

# Switch to non-root user
USER sensehub

# Expose Shiny default port
EXPOSE 3838

# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD curl -f http://localhost:3838/ || exit 1

# Run the app
CMD ["R", "-e", "shiny::runApp('.', host='0.0.0.0', port=3838)"]

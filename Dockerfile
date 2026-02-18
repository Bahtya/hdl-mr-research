FROM rocker/r-ver:4.3.0

# 安装系统依赖（不用代理）
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# 安装 CRAN 包（不用代理）
RUN R -e "install.packages(c('ggplot2', 'dplyr', 'tidyr', 'knitr', 'rmarkdown', 'remotes'), repos='https://cloud.r-project.org/')"

# 安装 TwoSampleMR 从 GitHub（需要代理）
ARG HTTPS_PROXY=http://192.168.1.18:7890
ARG HTTP_PROXY=http://192.168.1.18:7890
ENV HTTP_PROXY=${HTTP_PROXY}
ENV HTTPS_PROXY=${HTTPS_PROXY}
ENV http_proxy=${HTTP_PROXY}
ENV https_proxy=${HTTPS_PROXY}
RUN R -e "options(download.file.method='libcurl'); remotes::install_github('MRCIEU/TwoSampleMR', upgrade='never')"
ENV HTTP_PROXY=
ENV HTTPS_PROXY=
ENV http_proxy=
ENV https_proxy=

# 安装其他包
RUN R -e "install.packages(c('patchwork', 'jsonlite'), repos='https://cloud.r-project.org/')"

WORKDIR /research

CMD ["/bin/bash"]

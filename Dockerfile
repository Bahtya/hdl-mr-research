FROM rocker/r-ver:4.3.0

# 安装系统依赖
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
    && rm -rf /var/lib/apt/lists/*

# 安装R包用于孟德尔随机化
RUN R -e "install.packages(c('TwoSampleMR', 'ggplot2', 'dplyr', 'tidyr', 'forestplot', 'patchwork', 'knitr', 'rmarkdown'), repos='https://cloud.r-project.org/')"

# 安装renv用于包管理
RUN R -e "install.packages('renv', repos='https://cloud.r-project.org/')"

WORKDIR /research

CMD ["/bin/bash"]

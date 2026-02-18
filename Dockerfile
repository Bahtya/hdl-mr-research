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
    git \
    && rm -rf /var/lib/apt/lists/*

# 安装 CRAN 包
RUN R -e "install.packages(c('ggplot2', 'dplyr', 'tidyr', 'knitr', 'rmarkdown', 'remotes', 'patchwork', 'jsonlite'), repos='https://cloud.r-project.org/')"

# 安装 GitHub 包（构建时传入代理参数）
ARG HTTP_PROXY
ARG HTTPS_PROXY

# 先安装 ieugwasr 依赖
RUN R -e "remotes::install_github('mrcieu/ieugwasr', upgrade='never')"

# 再安装 TwoSampleMR
RUN R -e "remotes::install_github('MRCIEU/TwoSampleMR', upgrade='never')"

WORKDIR /research

CMD ["/bin/bash"]

FROM rstudio/r-session-complete:jammy
RUN /opt/R/4.4.0/bin/R -e 'install.packages(c("tidyverse", "sparklyr", "pysparklyr", "chattr", "DBI", "odbc", "shiny", "quarto", "tidymodels", "ggiraph", "vetiver", "nycflights13"), repos="https://packagemanager.rstudio.com/cran/__linux__/jammy/latest")'
# RUN /opt/R/4.4.0/bin/R -e 'reticulate::install_python(version = "3.11")'
RUN git clone https://github.com/posit-conf-2024/databricks.git dbworkshop
RUN /opt/R/4.4.0/bin/R -e 'install.packages("/dbworkshop/assets/utils/workshop_0.0.0.9000.tar.gz", repos = NULL, type = "source")'

# docker run -it databricks /bin/bash
# docker build . -f Dockerfile -t databricks

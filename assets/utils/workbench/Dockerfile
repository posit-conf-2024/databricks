FROM rstudio/r-session-complete:jammy
RUN /opt/R/4.4.0/bin/R -e 'install.packages(c("tidyverse", "sparklyr", "pysparklyr", "chattr", "DBI", "odbc", "shiny", "quarto", "tidymodels", "ggiraph", "vetiver", "nycflights13"), repos="https://packagemanager.rstudio.com/cran/__linux__/jammy/latest")'
RUN /opt/R/4.4.0/bin/R -e 'reticulate::install_python(version = "3.11")'
RUN /opt/R/4.4.0/bin/R -e 'pysparklyr::install_databricks("15.3", python_version = "3.11")'
RUN git clone https://github.com/posit-conf-2024/databricks.git
RUN /opt/R/4.4.0/bin/R -e 'install.packages("/databricks/assets/utils/workshop_0.0.0.9000.tar.gz", repos = NULL, type = "source")'

# docker run -it databricks /bin/bash
# docker build . -f Dockerfile -t databricks

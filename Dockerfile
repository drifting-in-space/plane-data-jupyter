FROM python:3.11.3-slim

# This entire section is only needed while we are using notebook directly from git instead of pypi.
# If it were permanent, we would want to do a multi-stage built, but it's not.
RUN apt-get update
RUN apt-get install -y build-essential
RUN apt-get install -y git
RUN apt-get install -y curl
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get install -y nodejs

RUN useradd -m jupyter
USER jupyter
WORKDIR /home/jupyter

RUN python3 -m venv notebook-env
COPY --chown=jupyter freeze.txt ./
COPY empty.ipynb ./

RUN /home/jupyter/notebook-env/bin/pip install --upgrade pip
RUN /home/jupyter/notebook-env/bin/pip install -r freeze.txt

# Warm up the kernel. Disabled until we can prove that this helps.
#RUN /home/jupyter/notebook-env/bin/pip install nbconvert
#RUN /home/jupyter/notebook-env/bin/jupyter nbconvert --to markdown --execute empty.ipynb

COPY --chown=jupyter notebook ./notebook
RUN /home/jupyter/notebook-env/bin/ipython profile create default

ENV PATH=/home/jupyter/notebook-env/bin:$PATH

RUN jupyter labextension disable "@jupyterlab/apputils-extension:announcements"

WORKDIR /home/jupyter/notebook

COPY start.sh .

CMD ./start.sh

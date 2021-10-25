FROM python:alpine
ENV FLASK_APP=main.py
RUN mkdir /docker
WORKDIR /docker
COPY main.py requirements.txt /docker/
RUN pip install --no-cache-dir -r requirements.txt
CMD ["flask", "run", "--host=0.0.0.0"]
#ENTRYPOINT ["flask", "run"]

FROM python:3.11
ADD src/app /app
WORKDIR /app
COPY requirements.txt /tmp
RUN pip install -r /tmp/requirements.txt
ENV FLASK_APP=/app
EXPOSE 5000
CMD ["flask", "run", "-h", "0.0.0.0"]
 
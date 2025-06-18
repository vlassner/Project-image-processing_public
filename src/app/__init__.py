'''
DSML 3850 - Cloud Computing - Spring 2025
Instructor: Thyago Mota
Student(s): Victoria Lassner
'''
 
from flask import Flask
import boto3
import configparser
 
 
app = Flask(__name__, template_folder='templates')
 
# consider using an ENVIRONMENT VARIABLE or external file to improve security
app.secret_key = 'you-will-never-guess'
 
# db initialization
from flask_sqlalchemy import SQLAlchemy
db = SQLAlchemy()
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///app.db'
db.init_app(app)
 
# TODOd: change it to your bucket's name
S3_BUCKET = 'prj-01-bucket-vl'
 
# AWS S3 configuration for Part 2
# config = configparser.ConfigParser()
# with open('user_credentials.txt') as f:
#     config.read_string('[DEFAULT]\n' + f.read().replace(':', '='))
# S3_ACCESS_KEY_ID = config['DEFAULT']['aws_access_key_id']
# S3_SECRET_ACCESS_KEY = config['DEFAULT']['aws_secret_access_key']
# s3_client = boto3.client(
#     's3',
#     aws_access_key_id=S3_ACCESS_KEY_ID,
#     aws_secret_access_key=S3_SECRET_ACCESS_KEY
# )
 
# AWS S3 configuration for Part 3 and on
s3_client = boto3.client(
    's3'
)
 
# db from models
from app import models
with app.app_context():
    db.create_all()
 
# login manager
from flask_login import LoginManager
login_manager = LoginManager()
login_manager.init_app(app)
 
from app.models import User
 
# user_loader callback
@login_manager.user_loader
def load_user(id):
    try:
        return db.session.query(User).filter(User.id==id).one()
    except:
        return None
 
from app import routes
'''
DSML 3850 - Cloud Computing - Spring 2025
Instructor: Thyago Mota
Student(s):
'''

from app import db 
from flask_login import UserMixin
from datetime import datetime, timezone

class User(db.Model, UserMixin):
    __tablename__ = 'users'
    id = db.Column(db.String, primary_key=True)
    name = db.Column(db.String)
    password = db.Column(db.LargeBinary)

class File(db.Model):
    __tablename__ = 'files'
    id = db.Column(db.String, primary_key=True)
    name = db.Column(db.String, nullable=False)
    status = db.Column(db.String, nullable=False)
    date_uploaded = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))    
    user_id = db.Column(db.String, db.ForeignKey('users.id'), nullable=False)
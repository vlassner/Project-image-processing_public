'''
DSML 3850 - Cloud Computing - Spring 2025
Instructor: Thyago Mota
Student(s): Victoria Lassner
'''

from app import app, db
from app.models import User
import bcrypt

# creates a user with (optional) defaults
def create_user(id, name='', password=bcrypt.hashpw('12345678'.encode('utf-8'), bcrypt.gensalt())): 
    with app.app_context(): 
        user = User(
            id=id, 
            name=name, 
            password=password)          
        db.session.add(user)
        db.session.commit()

# deletes a user given their id
def delete_user(id): 
    with app.app_context(): 
        user = User.query.filter_by(id=id).one()
        db.session.delete(user)
        db.session.commit()

# retrieves a user given their id
def retrieve_user(id): 
    user = None
    with app.app_context(): 
        user = User.query.filter_by(id=id).one()
    return user

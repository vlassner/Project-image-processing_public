'''
DSML 3850 - Cloud Computing - Spring 2025
Instructor: Thyago Mota
Student(s): Victoria Lassner
''' 

from app import app, db, s3_client, S3_BUCKET
from flask import render_template, redirect, url_for
from flask_login import current_user, login_required, login_user, logout_user
from app.forms import SignUpForm, LoginForm, UploadForm
import bcrypt
from app.models import File
from app.utils import create_user, retrieve_user
from werkzeug.utils import secure_filename
import uuid

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

 
@app.route('/')
def index():
    return render_template('index.html')
 
@app.route('/users/signup', methods=['GET', 'POST'])
def signup():
    form = SignUpForm()
    if form.validate_on_submit():
        if form.password.data == form.password_confirm.data:
            hashed_password = bcrypt.hashpw(form.password.data.encode('utf-8'), bcrypt.gensalt())
            try:
                create_user(
                    form.id.data,
                    name=form.name.data,
                    password=hashed_password
                )
            except Exception as ex:
                return f'<p>There was an error creating the user: {ex}</p>'
            return redirect(url_for('index'))
        else:
            return f'<p>Passwords do not match!</p>'
    return render_template('signup.html', form=form)
 
@app.route('/users/login', methods=['GET', 'POST'])
def login():
    form = LoginForm()
    if form.validate_on_submit():
        try:
            user = retrieve_user(form.id.data)
            if user and bcrypt.checkpw(form.password.data.encode(), user.password):
                login_user(user)
                return redirect(url_for('files'))
        except Exception as ex:
            return f'<p>There was an error retrieving the user: {ex}</p>'
    return render_template('login.html', form=form)
 
@app.route('/users/signout', methods=['GET', 'POST'])
@login_required
def signout():
    logout_user()
    return redirect(url_for('index'))
 
@app.route('/files')
@login_required
def files():
    user_id = current_user.id
    files = File.query.filter_by(user_id=user_id).all()
    return render_template('files.html', user_id=user_id, files=files)
 
@app.route('/files/upload', methods=['GET', 'POST'])
def upload_file():
    form = UploadForm()
    if form.validate_on_submit():
        file = form.file.data
        id = str(uuid.uuid4())
        filename = f'{secure_filename(file.filename)}_{id}'
        try:
            # TODOd: upload file with filename to the S3 bucket
            s3_client.upload_fileobj(file, S3_BUCKET, filename)
 
            new_file = File(
                id=id,
                name=filename,
                status='uploaded',
                user_id=current_user.id)
 
            db.session.add(new_file)
            db.session.commit()
            return redirect(url_for('files'))
        except Exception as ex:
            return f'<p>Error uploading the file: {ex}</p>'
    return render_template('file_upload.html', form=form)
 
@app.route('/files/delete/<file_id>', methods=['POST'])
@login_required
def delete_file(file_id):
    file = File.query.get(file_id)
    if file and file.user_id == current_user.id:
        # TODOd: delete file from the S3 bucket using file.name as the key
        s3_client.delete_object(Bucket = S3_BUCKET, Key=file.name)
 
        db.session.delete(file)
        db.session.commit()
    return redirect(url_for('files'))
 
@app.route('/files/process/<file_id>', methods=['POST'])
@login_required
def process_file(file_id):
    file = File.query.get(file_id)
    file.status = 'processed'
    db.session.commit()
    return redirect(url_for('files'))
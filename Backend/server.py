import firebase_admin
from firebase_admin import credentials, firestore
from fastapi import FastAPI
from pydantic import BaseModel
import os
import uuid

app = FastAPI()

#https://fastapi.tiangolo.com/tutorial/first-steps/
@app.get("/")
async def root():
    return {""}

#Ref for setup https://medium.com/@cbrannen/importing-data-into-firestore-using-python-dce2d6d3cd51
#https://rollout.com/integration-guides/firestore/sdk/step-by-step-guide-to-building-a-firestore-api-integration-in-python
cred = credentials.Certificate("/Users/frederikdahlhansen/Documents/nowastemate-app/nowastemate-firebase-firebase-adminsdk-fbsvc-260a57ac1d.json")
dbInit = firebase_admin.initialize_app(cred)

store = firestore.client()

class User(BaseModel):
    first: str
    last: str
    email: str
    password: str

@app.post("/users/")
async def create_user(user: User):

    id = str(uuid.uuid4())



    doc_ref = store.collection('users').document(f'{id}')
    doc_ref.set({
        'first': user.first,
        'last': user.last,
        'email': user.email,
        'password': user.password
    })



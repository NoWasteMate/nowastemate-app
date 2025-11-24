import firebase_admin
from firebase_admin import credentials, firestore
from fastapi import FastAPI
from pydantic import BaseModel
import os

app = FastAPI()

#https://fastapi.tiangolo.com/tutorial/first-steps/
@app.get("/")
async def root():
    return {""}

#Ref for setup https://medium.com/@cbrannen/importing-data-into-firestore-using-python-dce2d6d3cd51
cred = credentials.Certificate("/Users/frederikdahlhansen/Documents/nowastemate-app/nowastemate-firebase-firebase-adminsdk-fbsvc-260a57ac1d.json")
dbInit = firebase_admin.initialize_app(cred)

store = firestore.client()

class User(BaseModel):
    first: str
    last: str
    born: int


doc_ref = store.collection('users').document('alovelace')
doc_ref.set({
    'first': 'Adaa',
    'last': 'Lovelace',
    'born': 1815
})

@app.post("/users/")
async def create_item(user: User):
    doc_ref = store.collection('users').document('alovelace')
    doc_ref.set({
        'first': user.first,
        'last': user.last,
        'born': user.born
    })



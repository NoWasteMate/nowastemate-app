import firebase_admin
from firebase_admin import credentials, firestore

#Ref for setup https://medium.com/@cbrannen/importing-data-into-firestore-using-python-dce2d6d3cd51
cred = credentials.Certificate("/Users/frederikdahlhansen/Documents/nowastemate-app/nowastemate-firebase-firebase-adminsdk-fbsvc-260a57ac1d.json")
app = firebase_admin.initialize_app(cred)

store = firestore.client()

doc_ref = store.collection('users').document('alovelace')
doc_ref.set({
    'first': 'Adaa',
    'last': 'Lovelace',
    'born': 1815
})
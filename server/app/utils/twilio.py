import os
from twilio.rest import Client

account_sid = os.getenv('TWILIO_ACCOUNT_SID')
auth_token = os.getenv('TWILIO_AUTH_TOKEN')
client = Client(account_sid, auth_token)

message = client.messages.create(
  from_=os.getenv('TWILIO_WHATSAPP_FROM'),
  content_sid=os.getenv('TWILIO_CONTENT_SID'),
  content_variables='{"1":"12/1","2":"3pm"}',
  to='whatsapp:+919482698406'
)

print(message.sid)
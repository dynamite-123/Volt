import os
from dotenv import load_dotenv
from twilio.rest import Client

# Load environment variables
load_dotenv()

# Initialize Twilio client
account_sid = os.getenv('TWILIO_ACCOUNT_SID')
auth_token = os.getenv('TWILIO_AUTH_TOKEN')

client = Client(account_sid, auth_token)

# Fetch sandbox details
try:
    # Get the WhatsApp sandbox
    sandbox = client.messaging.v1.services.list(limit=1)
    
    # Alternative: Check incoming phone numbers for sandbox
    numbers = client.incoming_phone_numbers.list(phone_number='+14155238886', limit=1)
    
    if numbers:
        print(f"Sandbox Number: {numbers[0].phone_number}")
        print(f"Friendly Name: {numbers[0].friendly_name}")
    
    # The sandbox join code is typically in your account settings
    # Let's try to get it from the API
    print("\nTo find your sandbox join code:")
    print("1. Go to: https://console.twilio.com/us1/develop/sms/try-it-out/whatsapp-learn")
    print("2. Look for 'join <your-code>' in the Sandbox section")
    print(f"\nOr visit: https://console.twilio.com/us1/account/manage")
    
except Exception as e:
    print(f"Error: {e}")
    print("\nPlease visit Twilio Console to get your sandbox join code:")
    print("https://console.twilio.com/us1/develop/sms/try-it-out/whatsapp-learn")

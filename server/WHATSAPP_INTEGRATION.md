# WhatsApp Expense Tracker Integration

This guide explains how to set up and use the WhatsApp integration for automatic expense tracking in Kronyx.

## 🎯 Overview

Users can send transaction receipts (images or PDFs) via WhatsApp, and the system will:
1. Download the media from Twilio
2. Extract transaction details using OCR (Google Gemini AI)
3. Find the user by phone number
4. Add the transaction to their account automatically
5. Send a confirmation message with transaction details

## 🔧 Setup Instructions

### 1. Configure Twilio Webhook

Your webhook URL is: **`https://15f85677a64e31.lhr.life/twilio/whatsapp/webhook`**

1. Go to [Twilio WhatsApp Sandbox](https://console.twilio.com/us1/develop/sms/settings/whatsapp-sandbox)
2. In **"WHEN A MESSAGE COMES IN"** field, paste: `https://15f85677a64e31.lhr.life/twilio/whatsapp/webhook`
3. Set method to: **POST**
4. Click **Save**

### 2. Link User Phone Numbers

Users must have their WhatsApp phone numbers registered in the database:

```bash
# List all users
python update_user_phone.py list

# Update user phone number (use international format with +)
python update_user_phone.py <user_id> <phone_number>

# Example for Indian number:
python update_user_phone.py 1 +919482698406
```

**Important:** Phone numbers must be in international format starting with `+` (e.g., `+919482698406` for India)

### 3. Join WhatsApp Sandbox

Users need to join the Twilio sandbox:
1. Send the join code from [Twilio Sandbox page](https://console.twilio.com/us1/develop/sms/try-it-out/whatsapp-learn) to `+1 415 523 8886`
2. Typically something like: `join <your-code>`

## 💬 How to Use

### Commands

Users can send these commands via WhatsApp:

- **`help`** - Show welcome message and instructions
- **`balance`** - Check current account balance
- **`recent`** - View last 5 transactions

### Tracking Expenses

1. **Take a photo** of your transaction receipt or bill
2. **Send it via WhatsApp** to the Twilio number
3. **Wait 10-20 seconds** for OCR processing
4. **Receive confirmation** with extracted transaction details

The system automatically extracts:
- 💰 Amount
- 🏪 Merchant name
- 📅 Transaction date/time
- 📊 Transaction type (debit/credit)
- 🏷️ Category (if identifiable)
- 🔖 Transaction ID
- 🏦 Bank name
- 💳 Account number

## 📱 Example Workflow

```
User: [Sends receipt image via WhatsApp]

Bot: 📄 Receipt Received!
     🔍 Processing your transaction...
     This will take 10-20 seconds.

[After OCR processing]

Bot: ✅ Transaction Added Successfully!

     💰 Amount: ₹2,500.00
     🏪 Merchant: Amazon
     📅 Date: 13 Dec 2025, 02:30 PM
     📊 Type: DEBIT
     🏷️ Category: Shopping
     🔖 Txn ID: TXN123456789
     
     💡 Your balance: ₹45,250.00
     
     📸 Send another receipt to track more expenses!
```

## 🔍 Technical Details

### Endpoint: `/twilio/whatsapp/webhook`

**Method:** POST

**Form Parameters:**
- `From` - WhatsApp number (format: `whatsapp:+919482698406`)
- `Body` - Text message (optional)
- `NumMedia` - Number of media attachments
- `MediaUrl0` - URL of first media attachment
- `MediaContentType0` - MIME type of media

### Supported File Types

- **Images:** JPEG, PNG
- **Documents:** PDF

### OCR Processing

The system uses Google Gemini AI (via `pydantic-ai`) to:
1. Extract text from images using vision capabilities
2. Parse transaction details intelligently
3. Structure data into transaction schema
4. Validate extracted information

### Database Integration

Transactions are stored in the `transactions` table linked to users via:
- User lookup by phone number
- Automatic user_id assignment
- Transaction timestamp recording
- All extracted fields preserved

## 🚀 Key Features

### ✅ Automatic User Matching
- Matches WhatsApp sender with database user by phone number
- Shows error if phone number not registered
- Prevents unauthorized transaction creation

### ✅ Smart OCR Extraction
- Powered by Google Gemini 2.5 Flash
- Extracts multiple transaction fields
- Handles both images and PDFs
- Works with various receipt formats

### ✅ Real-time Feedback
- Immediate acknowledgment of receipt
- Processing status updates
- Detailed confirmation with extracted data
- Error messages with helpful suggestions

### ✅ User Commands
- Check balance instantly
- View recent transactions
- Get help and instructions
- All via WhatsApp chat

## 🔒 Security Notes

1. **Phone Number Validation:** Only registered phone numbers can add transactions
2. **Twilio Authentication:** Media downloads require Twilio credentials
3. **Request Validation:** Can enable Twilio signature validation (currently commented out)

To enable request validation, uncomment in `twilio_webhook.py`:
```python
signature = request.headers.get('X-Twilio-Signature', '')
url = str(request.url)
if not validator.validate(url, data, signature):
    raise HTTPException(status_code=403, detail="Invalid Twilio signature")
```

## 🐛 Troubleshooting

### "Account Not Found" Error
- Verify phone number is registered in database
- Check phone number format (must include + and country code)
- Run `python update_user_phone.py list` to see all users

### OCR Processing Fails
- Ensure good image quality and lighting
- Try sending as PDF instead of image
- Check if receipt has clear, readable text
- Verify Gemini API key is configured

### Webhook Not Receiving Messages
- Verify tunnel is running (`ssh -R 80:localhost:8000 nokey@localhost.run`)
- Check webhook URL in Twilio console
- Ensure server is running (`docker ps`)
- Check logs: `docker logs kronyx-api`

## 📊 Monitoring

View logs for debugging:
```bash
# API logs
docker logs kronyx-api -f

# Check for webhook calls
docker logs kronyx-api | grep "Received WhatsApp message"

# Check OCR processing
docker logs kronyx-api | grep "OCR extracted"
```

## 🔄 Restarting Services

If you make changes to the webhook code:
```bash
# Restart API container
docker restart kronyx-api

# Restart all services
cd /media/D/programming/projects/kronyx/server
python run.py stop
python run.py
```

## 📝 Environment Variables Required

Ensure these are set in your `.env` file:
```env
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=xxxxxxxxxxxxxxxxx
TWILIO_WHATSAPP_FROM=whatsapp:+14155238886
GEMINI_API_KEY=AIzaSyxxxxxxxxxxxxxxxxx
```

## 🎉 Success!

Your WhatsApp expense tracker is now ready! Users can start sending receipts and tracking expenses automatically.

---

*For support, contact the development team or check the logs for detailed error messages.*

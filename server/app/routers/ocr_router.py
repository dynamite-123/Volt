from typing import List, Annotated, Optional
from fastapi import APIRouter, Depends, HTTPException, status, File, UploadFile, Body
from sqlalchemy.orm import Session
from pydantic import BaseModel

from app.database import get_db
from app.oauth2 import get_current_user
from app.models.user import User
from app.models.transactions import Transaction
from app.schemas.transaction_schemas import TransactionCreate, TransactionResponse
from app.utils.ocr import OCRAgent
from app.utils.pdf_to_text import extract_text_from_pdf

router = APIRouter(
    prefix="/ocr",
    tags=["OCR"]
)


class TextExtractionRequest(BaseModel):
    text: str

@router.post("/images-to-text", response_model=TransactionCreate)
async def extract_text_from_images(
    file: UploadFile = File(...)
):
    """
    Extract transaction details from an image using OCR.
    
    - **file**: Image file (JPEG/PNG) of a transaction
    - Returns transaction data as JSON
    """
    try:
        # Validate file type
        if file.content_type and not (file.content_type.startswith('image/') or file.content_type == 'application/octet-stream'):
            raise HTTPException(status_code=400, detail=f"File is not an image")
        
        # Read file content
        content = await file.read()
        if not content:
            raise HTTPException(status_code=400, detail=f"File is empty")

        # Extract transaction using OCR Agent
        ocr_agent = OCRAgent()
        transaction_data = await ocr_agent.extract_transaction(content)
        
        return transaction_data
        
    except HTTPException:
        raise
    except Exception as e:
        print(f"Error processing image: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Transaction extraction failed: {str(e)}")


@router.post("/text-to-transaction", response_model=TransactionCreate)
async def extract_transaction_from_text(
    file: UploadFile = File(...)
):
    """
    Extract transaction details from PDF using PyMuPDF and AI.
    
    - **file**: PDF file containing transaction details
    - Returns transaction data as JSON
    """
    try:
        # Validate file type
        if file.content_type and not (file.content_type == 'application/pdf' or file.content_type == 'application/octet-stream'):
            raise HTTPException(status_code=400, detail="File must be a PDF")
        
        # Read PDF content
        content = await file.read()
        if not content:
            raise HTTPException(status_code=400, detail="File is empty")

        # Extract text from PDF using utility function
        extracted_text = extract_text_from_pdf(content)
        
        if not extracted_text:
            raise HTTPException(status_code=400, detail="No text found in PDF")

        # Extract transaction using OCR Agent
        ocr_agent = OCRAgent()
        transaction_data = await ocr_agent.extract_transaction_from_text(extracted_text)
        
        return transaction_data

    except HTTPException:
        raise
    except Exception as e:
        print(f"Error processing PDF: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Transaction extraction failed: {str(e)}")

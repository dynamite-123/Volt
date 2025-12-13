import pymupdf
from typing import Union


def extract_text_from_pdf(pdf_content: bytes) -> str:
    """
    Extract text from PDF file using PyMuPDF.
    
    Args:
        pdf_content: PDF file content as bytes
        
    Returns:
        Extracted text from all pages of the PDF
        
    Raises:
        Exception: If PDF parsing fails
    """
    try:
        # Open PDF from bytes
        pdf_document = pymupdf.open(stream=pdf_content, filetype="pdf")
        
        # Extract text from all pages
        extracted_text = ""
        for page_num in range(len(pdf_document)):
            page = pdf_document[page_num]
            extracted_text += page.get_text()
        
        # Close the document
        pdf_document.close()
        
        return extracted_text.strip()
        
    except Exception as e:
        raise Exception(f"Failed to extract text from PDF: {str(e)}")

import easyocr
import logging
import os

logger = logging.getLogger(__name__)

# Initialize the reader once (this extracts/downloads models if needed)
# For production, you might want to specify specific languages.
READER = None

def get_reader():
    global READER
    if READER is None:
        logger.info("Initializing EasyOCR Reader...")
        READER = easyocr.Reader(['en']) # Defaulting to English
    return READER

def extract_text_from_file(file_path):
    """
    Extracts text from an image or PDF file using EasyOCR.
    """
    try:
        reader = get_reader()
        if not os.path.exists(file_path):
            logger.error(f"File not found: {file_path}")
            return None
        
        # EasyOCR works directly with file paths
        results = reader.readtext(file_path)
        
        # results is a list of [bbox, text, confidence]
        full_text = " ".join([res[1] for res in results])
        return {
            "text": full_text,
            "details": [{"text": res[1], "confidence": float(res[2]), "bbox": [list(map(int, pt)) for pt in res[0]]} for res in results]
        }
    except Exception as e:
        logger.error(f"Error during OCR extraction: {e}")
        return None

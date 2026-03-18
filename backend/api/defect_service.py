import cv2
import numpy as np
from skimage.filters import frangi, hessian
import logging
import os

logger = logging.getLogger(__name__)

def detect_defects(image_path):
    """
    Identifies structural defects (cracks) in an image using ridge filters.
    """
    try:
        if not os.path.exists(image_path):
            logger.error(f"Image not found: {image_path}")
            return None

        # Load image
        img = cv2.imread(image_path)
        if img is None:
            logger.error(f"Failed to load image: {image_path}")
            return None

        # Convert to grayscale
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        
        # Apply Frangi filter (good for ridge/crack detection)
        # Note: input should be normalized 0-1
        gray_norm = gray.astype(np.float32) / 255.0
        ridges = frangi(gray_norm, sigmas=range(1, 5, 1))
        
        # Threshold the ridges to find strong cracks
        # Frangi output is usually very small values
        threshold = np.percentile(ridges, 98) # Take top 2% of ridge responses
        binary_ridges = (ridges > threshold).astype(np.uint8) * 255
        
        # Find contours of the detected ridges
        contours, _ = cv2.findContours(binary_ridges, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        
        defects = []
        for i, cnt in enumerate(contours):
            area = cv2.contourArea(cnt)
            if area > 10: # Filter out noise
                x, y, w, h = cv2.boundingRect(cnt)
                defects.append({
                    "type": "Crack/Structural Issue",
                    "bbox": [x, y, x + w, y + h],
                    "area": float(area),
                    "confidence": float(np.mean(ridges[binary_ridges > 0])) # Use mean ridge response as confidence
                })
        
        return {
            "count": len(defects),
            "defects": defects,
            "summary": f"Detected {len(defects)} potential structural issues."
        }
    except Exception as e:
        logger.error(f"Error during defect detection: {e}")
        return None

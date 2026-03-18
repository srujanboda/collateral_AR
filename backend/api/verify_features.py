import os
import cv2
import numpy as np
import sys

# Add current directory to path so we can import services
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

try:
    import ocr_service
    import defect_service
    print("Services imported successfully.")
except ImportError as e:
    print(f"Import error: {e}")
    sys.exit(1)

def create_test_images():
    print("Creating test images...")
    # 1. OCR Test Image (White background, black text "HELLO WORLD")
    ocr_img = np.ones((100, 300, 3), dtype=np.uint8) * 255
    cv2.putText(ocr_img, "HELLO WORLD", (20, 60), cv2.FONT_HERSHEY_SIMPLEX, 1.5, (0, 0, 0), 3)
    cv2.imwrite("test_ocr.png", ocr_img)
    
    # 2. Defect Test Image (Gray background, jagged black line as "crack")
    defect_img = np.ones((200, 200, 3), dtype=np.uint8) * 200
    pts = np.array([[20, 20], [50, 80], [100, 100], [150, 180]], np.int32)
    cv2.polylines(defect_img, [pts], False, (50, 50, 50), 2)
    cv2.imwrite("test_defect.png", defect_img)
    print("Test images created.")

def run_tests():
    # Test OCR
    print("\n--- Testing OCR Service ---")
    ocr_result = ocr_service.extract_text_from_file("test_ocr.png")
    if ocr_result:
        print(f"Extracted Text: {ocr_result.get('text')}")
        if "HELLO" in ocr_result.get('text').upper():
            print("OCR SUCCESS")
        else:
            print("OCR FAILED (text mismatch)")
    else:
        print("OCR FAILED (no result)")

    # Test Defect Detection
    print("\n--- Testing Defect Detection Service ---")
    defect_result = defect_service.detect_defects("test_defect.png")
    if defect_result:
        print(f"Summary: {defect_result.get('summary')}")
        print(f"Defects Found: {defect_result.get('count')}")
        if defect_result.get('count', 0) > 0:
            print("Defect Detection SUCCESS")
        else:
            print("Defect Detection FAILED (no defects detected)")
    else:
        print("Defect Detection FAILED (no result)")

if __name__ == "__main__":
    create_test_images()
    run_tests()
    # Cleanup
    if os.path.exists("test_ocr.png"): os.remove("test_ocr.png")
    if os.path.exists("test_defect.png"): os.remove("test_defect.png")

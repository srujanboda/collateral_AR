# Backend Services Explanation

This document provides an overview of the specialized services running in the backend to support property verification and document processing.

## 1. OCR (Optical Character Recognition)
**Technology:** [EasyOCR](https://github.com/JaidedAI/EasyOCR)  
**Location:** `backend/api/ocr_service.py`

**What it does:**
When a user uploads documents (like Land Records or Building Plans) through the web app, the OCR service automatically scans the images and PDFs to extract text. It identifies words, numbers, and their positions on the page.

**Why we use it:**
- **Automated Data Entry:** Extracts property addresses, owner names, and registration numbers directly from documents.
- **Validation:** Cross-references the text in the document with the data provided in the application to ensure consistency.

---

## 2. Defect Service (AI Structural Analysis)
**Technology:** OpenCV (Custom Ridge Filters)  
**Location:** `backend/api/defect_service.py`

**What it does:**
This service analyzes photos taken during the field verification (from the Flutter app). It uses advanced image processing (Ridge Filters) to look for structural anomalies, specifically **cracks** in walls or foundations.

**What it reports:**
- **Defect Count:** Number of potential cracks identified.
- **Summary:** A text description of the findings (e.g., "3 potential defects detected").
- **Audit Log:** Stores the exact coordinates of detected defects for review by a human agent.

---

## 3. Verify Features
**Location:** `backend/api/verify_features.py`

**What it does:**
This is a suite of automated validation scripts. It ensures that the AI services (OCR and Defect) are performing as expected.

**Functionality:**
- **Feature Testing:** Runs the OCR and Defect logic against "gold standard" test images to verify accuracy.
- **Backend Health:** Checks if dependencies (like EasyOCR) are loaded and ready to process requests.
- **Workflow Verification:** Simulates the end-to-end process of document upload -> OCR extraction -> result storage.

---

## 4. Multi-user Isolation (Perfios ID)
**How it works:**
The system uses `perfios_id` (e.g., `PERF-4821`) as a unique identifier for each application. 

**Privacy & Security:**
- **Data Segregation:** All files and data points are indexed by this ID. 
- **Application Context:** When a user "logs in" with their ID in the Flutter app, the backend only returns documents associated with that specific `perfios_id`. This ensures that User A never sees User B's floor plan or personal documents.

import { useState } from 'react';
import { AlertCircle } from 'lucide-react';
import { useNavigate, useLocation } from 'react-router-dom';
import { MAX_FILE_SIZE_BYTES, MAX_FILE_SIZE_MB } from '../constants';

import { Stepper } from '../components/features/Stepper';
import { FileUpload } from '../components/features/FileUpload';
import { Button } from '../components/common/Button';
import { appConfig } from '../config/appConfig';

export default function UploadPage() {
    const navigate = useNavigate();
    const [step, setStep] = useState(1);

    const [allFiles, setAllFiles] = useState<Record<number, File[]>>({});
    const [error, setError] = useState<string | null>(null);

    const { steps, titlePrefix, subtitle, infoBoxPrefix, errors, buttons } = appConfig.uploadPage;

    const currentStepData = steps.find(s => s.id === step);
    const currentFiles = allFiles[step] || [];

    const handleFilesSelected = (newFiles: File[]) => {
        setError(null);
        // Validation
        const invalidFiles = newFiles.filter(file => file.size > MAX_FILE_SIZE_BYTES);
        if (invalidFiles.length > 0) {
            setError(errors.sizeLimit(MAX_FILE_SIZE_MB));
        }

        const validFiles = newFiles.filter(file => file.size <= MAX_FILE_SIZE_BYTES);

        if (validFiles.length > 0) {
            setAllFiles(prev => ({
                ...prev,
                [step]: [...(prev[step] || []), ...validFiles]
            }));
        }
    };

    const removeFile = (indexToRemove: number) => {
        setAllFiles(prev => ({
            ...prev,
            [step]: (prev[step] || []).filter((_, index) => index !== indexToRemove)
        }));
    };

    const locationState = useLocation().state as { perfios_id?: string };
    const perfios_id = locationState?.perfios_id || new URLSearchParams(window.location.search).get('perfios_id');

    // Dynamic API Base URL
    const rawUrl = import.meta.env.VITE_API_URL || 'http://10.84.153.247:8000';
    const API_BASE = rawUrl.endsWith('/') ? rawUrl.slice(0, -1) : rawUrl;

    const handleNext = async () => {
        // Upload files for current step to backend
        if (currentFiles.length > 0 && perfios_id) {
            const formData = new FormData();
            formData.append('perfios_id', perfios_id);
            formData.append('step_id', step.toString());
            currentFiles.forEach(file => {
                formData.append('files', file);
            });

            console.log('Uploading to:', `${API_BASE}/api/application/upload-document/`);
            console.log('perfios_id:', perfios_id);
            console.log('step_id:', step);
            console.log('files count:', currentFiles.length);

            try {
                const response = await fetch(`${API_BASE}/api/application/upload-document/`, {
                    method: 'POST',
                    body: formData,
                });

                console.log('Response status:', response.status);

                if (!response.ok) {
                    const errorText = await response.text();
                    console.error('Server error:', errorText);
                    throw new Error(`Server responded with ${response.status}`);
                }

                const result = await response.json();
                console.log('Upload successful:', result);
            } catch (err) {
                console.error('Upload failed:', err);
                setError('Failed to upload files to server. Please try again.');
                return;
            }
        }

        if (step < 4) {
            setStep(step + 1);
        } else {
            // Navigate to Success Page with files state
            navigate('/success', { state: { files: allFiles, perfios_id } });
        }
    };

    const isStepAccessible = (stepId: number) => {
        // Accessibility logic:
        // You can always go back (s.id < step).
        // You can click the current step.
        // You can ONLY go forward if all previous steps are done.

        if (stepId <= step) return true;

        let allPreviousCompleted = true;
        for (let i = 1; i < stepId; i++) {
            if (!allFiles[i] || allFiles[i].length === 0) {
                allPreviousCompleted = false;
                break;
            }
        }
        return allPreviousCompleted;
    };

    return (
        <div className="page-container">

            {/* Stepper */}
            <Stepper
                steps={steps}
                currentStep={step}
                completedSteps={steps.filter(s => allFiles[s.id] && allFiles[s.id].length > 0).map(s => s.id)}
                onStepClick={setStep}
                isStepAccessible={isStepAccessible}
            />

            {/* Title */}
            <div>
                <h2 style={{ fontSize: '24px', fontWeight: 'bold', marginBottom: '8px' }}>
                    {titlePrefix} {currentStepData?.label}
                </h2>
                <p style={{ fontSize: '15px' }}>
                    {subtitle}
                </p>
            </div>

            {/* Error Message */}
            {error && (
                <div style={{
                    padding: '12px', borderRadius: 'var(--border-radius-sm)',
                    backgroundColor: '#FEF2F2', color: 'var(--error-color)',
                    display: 'flex', alignItems: 'center', gap: '8px', fontSize: '14px'
                }}>
                    <AlertCircle size={18} />
                    {error}
                </div>
            )}

            {/* Info Box */}
            <div style={{
                backgroundColor: '#FFFBEB', padding: '12px 16px', borderRadius: 'var(--border-radius-sm)',
                display: 'flex', gap: '12px', alignItems: 'center', border: '1px solid #FDE68A'
            }}>
                <div style={{
                    width: '24px', height: '24px', borderRadius: '50%',
                    backgroundColor: '#F59E0B', color: 'white', display: 'flex',
                    alignItems: 'center', justifyContent: 'center', fontWeight: 'bold', fontSize: '14px',
                    flexShrink: 0
                }}>i</div>
                <span style={{ fontSize: '14px', color: '#92400E', fontWeight: 500 }}>
                    {infoBoxPrefix} {currentStepData?.label?.toLowerCase()}
                </span>
            </div>

            {/* Upload Area or File List */}
            <FileUpload
                files={currentFiles}
                label={currentStepData?.label}
                onFilesSelected={handleFilesSelected}
                onFileRemove={removeFile}
            />

            {/* Validation & Navigation */}
            <div style={{ marginTop: 'auto' }}>
                {step === 4 && steps.some(s => !allFiles[s.id] || allFiles[s.id].length === 0) && (
                    <div style={{
                        color: 'var(--error-color)', fontSize: '13px', marginBottom: '16px',
                        padding: '12px', backgroundColor: '#FEF2F2', borderRadius: 'var(--border-radius-sm)',
                        display: 'flex', alignItems: 'center', gap: '8px', border: '1px solid #FECACA'
                    }}>
                        <AlertCircle size={16} />
                        {errors.allStepsRequired}
                    </div>
                )}

                <Button
                    type="button"
                    onClick={handleNext}
                    disabled={
                        step < 4
                            ? currentFiles.length === 0
                            : steps.some(s => !allFiles[s.id] || allFiles[s.id].length === 0)
                    }
                    style={{
                        padding: '16px',
                        fontSize: '16px'
                    }}
                >
                    {step === 4 ? buttons.finish : buttons.next}
                </Button>


            </div>
        </div>
    );
}


import React from 'react';
import { CheckCircle } from 'lucide-react';

interface Step {
    id: number;
    label: string;
}

interface StepperProps {
    steps: Step[];
    currentStep: number;
    completedSteps: number[]; // Or logic to drive completion
    onStepClick: (stepId: number) => void;
    // We can also pass a function to check accessibility if needed, 
    // but passing pre-calculated state is often cleaner.
    isStepAccessible: (stepId: number) => boolean;
}

export const Stepper: React.FC<StepperProps> = ({ steps, currentStep, onStepClick, isStepAccessible, completedSteps }) => {
    // Calculate progress percentage
    // e.g. Step 1 (index 0) of 4 => 0%
    // Step 2 (index 1) of 4 => 33%
    // Step 4 (index 3) of 4 => 100%
    const progress = Math.min(100, Math.max(0, ((currentStep - 1) / (steps.length - 1)) * 100));

    return (
        <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '8px', position: 'relative', marginTop: '16px' }}>
            {/* Connector Line */}
            {/* Background Connector Line */}
            <div style={{
                position: 'absolute', top: '16px', left: '0', right: '0',
                height: '2px', background: '#E5E7EB', zIndex: 0
            }}></div>

            {/* Traveling Progress Line (Green) */}
            <div style={{
                position: 'absolute', top: '16px', left: '0',
                width: `${progress}%`,
                height: '2px',
                background: 'var(--success-color)', // Using success color (green) as requested
                zIndex: 0,
                transition: 'width 0.4s ease-in-out' // Smooth animation
            }}></div>

            {steps.map((s) => {
                const isActive = s.id === currentStep;
                const isCompleted = completedSteps.includes(s.id);
                const accessible = isStepAccessible(s.id);

                return (
                    <div
                        key={s.id}
                        onClick={() => {
                            if (accessible) onStepClick(s.id);
                        }}
                        style={{
                            display: 'flex', flexDirection: 'column', alignItems: 'center', zIndex: 1,
                            background: 'transparent', width: '80px',
                            cursor: accessible ? 'pointer' : 'not-allowed',
                            opacity: accessible ? 1 : 0.5
                        }}
                    >
                        <div style={{
                            width: '32px', height: '32px',
                            borderRadius: '50%',
                            border: `2px solid ${isActive ? 'var(--primary-color)' : (isCompleted ? 'var(--success-color)' : '#E5E7EB')}`,
                            backgroundColor: isActive ? 'var(--primary-color)' : (isCompleted ? 'var(--success-color)' : 'white'),
                            display: 'flex', alignItems: 'center', justifyContent: 'center',
                            color: (isActive || isCompleted) ? 'white' : '#9CA3AF',
                            fontWeight: 'bold', fontSize: '14px',
                            marginBottom: '6px',
                            transition: 'all 0.2s',
                            boxShadow: isActive ? '0 0 0 4px rgba(0, 86, 210, 0.1)' : 'none'
                        }}>
                            {isCompleted && !isActive ? <CheckCircle size={18} /> : s.id}
                        </div>
                        <span style={{
                            fontSize: '11px',
                            color: isActive ? 'var(--primary-color)' : '#6B7280',
                            textAlign: 'center',
                            fontWeight: isActive ? 600 : 400,
                            lineHeight: '1.2'
                        }}>
                            {s.label}
                        </span>
                    </div>
                )
            })}
        </div>
    );
};

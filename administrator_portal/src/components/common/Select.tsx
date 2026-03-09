import React from 'react';
import { ChevronDown } from 'lucide-react';

interface Option {
    value: string;
    label: string;
}

interface SelectProps extends React.SelectHTMLAttributes<HTMLSelectElement> {
    label?: string;
    options: Option[];
}

const Select: React.FC<SelectProps> = ({ label, options, style, ...props }) => {
    return (
        <div style={{ width: '100%' }}>
            {label && (
                <label
                    style={{
                        display: 'block',
                        marginBottom: '0.5rem',
                        fontSize: '0.875rem',
                        color: '#666',
                        fontWeight: 500
                    }}
                >
                    {label}
                </label>
            )}
            <div style={{ position: 'relative' }}>
                <select
                    style={{
                        width: '100%',
                        padding: '0.75rem 1rem',
                        borderRadius: '8px',
                        border: '1px solid #e0e0e0',
                        fontSize: '1rem',
                        outline: 'none',
                        transition: 'border-color 0.2s',
                        color: '#333',
                        appearance: 'none',
                        backgroundColor: 'white',
                        ...style
                    }}
                    onFocus={(e) => e.target.style.borderColor = '#0052cc'}
                    onBlur={(e) => e.target.style.borderColor = '#e0e0e0'}
                    {...props}
                >
                    <option value="" disabled>Select {label}</option>
                    {options.map((option) => (
                        <option key={option.value} value={option.value}>
                            {option.label}
                        </option>
                    ))}
                </select>
                <div style={{
                    position: 'absolute',
                    right: '1rem',
                    top: '50%',
                    transform: 'translateY(-50%)',
                    pointerEvents: 'none',
                    color: '#666'
                }}>
                    <ChevronDown size={20} />
                </div>
            </div>
        </div>
    );
};

export default Select;

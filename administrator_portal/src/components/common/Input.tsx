import React, { useState, type ReactNode } from 'react';

interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {
    label?: string;
    icon?: ReactNode;
    error?: string;
}

import { theme } from '../../config/theme';

const Input: React.FC<InputProps> = ({ label, type = 'text', icon, error, className = '', ...props }) => {
    const [showPassword, setShowPassword] = useState(false);
    const isPassword = type === 'password';

    const togglePassword = () => {
        setShowPassword(!showPassword);
    };

    return (
        <div style={{ width: '100%' }}>
            {label && (
                <label
                    style={{
                        display: 'block',
                        marginBottom: '0.5rem',
                        fontSize: '0.875rem',
                        color: error ? theme.colors.danger : theme.colors.text.tertiary,
                        fontWeight: 500
                    }}
                >
                    {label}
                </label>
            )}
            <div style={{ position: 'relative' }}>
                {icon && (
                    <div style={{
                        position: 'absolute',
                        left: '12px',
                        top: '50%',
                        transform: 'translateY(-50%)',
                        color: theme.colors.text.tertiary,
                        display: 'flex',
                        alignItems: 'center',
                        pointerEvents: 'none'
                    }}>
                        {icon}
                    </div>
                )}
                <input
                    type={isPassword ? (showPassword ? 'text' : 'password') : type}
                    style={{
                        width: '100%',
                        padding: '0.75rem 1rem',
                        paddingLeft: icon ? '2.5rem' : '1rem', // Add extra padding if icon exists
                        borderRadius: '8px',
                        border: `1px solid ${error ? theme.colors.danger : theme.colors.border.main}`,
                        fontSize: '1rem',
                        outline: 'none',
                        transition: 'border-color 0.2s',
                        color: theme.colors.text.primary
                    }}
                    onFocus={(e) => !error && (e.target.style.borderColor = theme.colors.primary.main)}
                    onBlur={(e) => !error && (e.target.style.borderColor = theme.colors.border.main)}
                    {...props}
                />
                {isPassword && (
                    <button
                        type="button"
                        onClick={togglePassword}
                        style={{
                            position: 'absolute',
                            right: '10px',
                            top: '50%',
                            transform: 'translateY(-50%)',
                            background: 'none',
                            border: 'none',
                            cursor: 'pointer',
                            color: theme.colors.text.tertiary
                        }}
                    >
                        {showPassword ? (
                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                                <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path>
                                <line x1="1" y1="1" x2="23" y2="23"></line>
                            </svg>
                        ) : (
                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                                <circle cx="12" cy="12" r="3"></circle>
                            </svg>
                        )}
                    </button>
                )}
            </div>
            {error && (
                <div style={{ display: 'flex', alignItems: 'center', gap: '6px', marginTop: '0.5rem', color: theme.colors.danger, fontSize: '0.8rem' }}>
                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                        <circle cx="12" cy="12" r="10"></circle>
                        <line x1="12" y1="8" x2="12" y2="12"></line>
                        <line x1="12" y1="16" x2="12.01" y2="16"></line>
                    </svg>
                    <span>{error}</span>
                </div>
            )}
        </div>
    );
};

export default Input;

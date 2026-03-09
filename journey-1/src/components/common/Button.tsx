import React from 'react';
import '../../index.css';

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
    variant?: 'primary' | 'secondary' | 'danger'; // Extend for potential future variants
    children: React.ReactNode;
}

export const Button: React.FC<ButtonProps> = ({
    children,
    className = '',
    variant = 'primary',
    ...props
}) => {
    // Currently we mainly use .btn-primary from index.css
    // We can expand this later if we add more button types
    const baseClass = variant === 'primary' ? 'btn-primary' : '';

    return (
        <button
            className={`${baseClass} ${className}`}
            {...props}
        >
            {children}
        </button>
    );
};

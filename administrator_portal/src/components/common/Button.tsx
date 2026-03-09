import React from 'react';
import { theme } from '../../config/theme';

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
    fullWidth?: boolean;
    variant?: 'primary' | 'secondary' | 'outline';
}

const Button: React.FC<ButtonProps> = ({
    children,
    fullWidth = false,
    variant = 'primary',
    className = '',
    style,
    disabled,
    ...props
}) => {
    const widthClass = fullWidth ? 'w-full' : '';

    // Calculate inline styles based on variant to enforce theme colors
    const getVariantStyle = () => {
        switch (variant) {
            case 'primary':
                return { backgroundColor: theme.colors.primary.main, color: theme.colors.text.white, border: 'none' };
            case 'secondary':
                return { backgroundColor: theme.colors.background.paper, color: theme.colors.text.secondary, border: `1px solid ${theme.colors.border.main}` };
            case 'outline':
                return { backgroundColor: theme.colors.background.paper, color: theme.colors.primary.main, border: `1px solid ${theme.colors.primary.main}` };
            default:
                return {};
        }
    };

    return (
        <button
            disabled={disabled}
            className={`btn ${widthClass} ${className}`}
            style={{ ...getVariantStyle(), ...style }}
            {...props}
        >
            {children}
        </button>
    );
};

export default Button;

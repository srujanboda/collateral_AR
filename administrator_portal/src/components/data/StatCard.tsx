import React from 'react';

interface StatCardProps {
    label: string;
    count: string;
    icon: React.ReactNode;
    color: string;
    bgColor: string;
}

const StatCard: React.FC<StatCardProps> = ({ label, count, icon, color, bgColor }) => {
    return (
        <div style={{
            backgroundColor: 'white',
            borderRadius: '8px',
            padding: '1.5rem',
            border: '1px solid #e0e0e0',
            boxShadow: '0 1px 3px rgba(0,0,0,0.05)',
            display: 'flex',
            alignItems: 'center',
            gap: '1rem'
        }}>
            <div style={{
                width: '48px',
                height: '48px',
                borderRadius: '50%',
                backgroundColor: bgColor,
                color: color,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center'
            }}>
                {icon}
            </div>
            <div>
                <div style={{ fontSize: '1.5rem', fontWeight: 700, color: '#1a1a1a' }}>
                    {count}
                </div>
                <div style={{ fontSize: '0.875rem', color: '#666', marginTop: '0.25rem' }}>
                    {label}
                </div>
            </div>
        </div>
    );
};

export default StatCard;

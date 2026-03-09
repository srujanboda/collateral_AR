import React from 'react';

interface PageHeaderProps {
    title: string;
    action?: React.ReactNode;
}

const PageHeader: React.FC<PageHeaderProps> = ({ title, action }) => {
    return (
        <div style={{
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
            marginBottom: '1.5rem',
            flexWrap: 'wrap',
            gap: '1rem'
        }}>
            <h1 style={{ fontSize: '1.5rem', fontWeight: 600, color: '#333', margin: 0 }}>
                {title}
            </h1>
            {action && (
                <div>
                    {action}
                </div>
            )}
        </div>
    );
};

export default PageHeader;

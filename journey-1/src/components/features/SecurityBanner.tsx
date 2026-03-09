import React, { useState } from 'react';
import { Shield, ChevronDown, X } from 'lucide-react';
import { appConfig } from '../../config/appConfig';

export const SecurityBanner: React.FC = () => {
    const [showDetailedBanner, setShowDetailedBanner] = useState(false);
    const { collapsedText, expandedTitle, expandedDescription, expandedDetail } = appConfig.landingPage.securityBanner;

    if (!showDetailedBanner) {
        return (
            <div style={{
                backgroundColor: '#FFFBEB',
                padding: '16px',
                borderRadius: 'var(--border-radius-sm)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                border: '1px solid #FCD34D'
            }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                    <Shield size={20} fill="var(--secondary-color)" stroke="none" />
                    <span style={{ fontSize: '15px', color: '#92400E', fontWeight: 500 }}>
                        {collapsedText}
                    </span>
                </div>
                <button
                    onClick={() => setShowDetailedBanner(true)}
                    style={{
                        display: 'flex',
                        alignItems: 'center',
                        color: 'var(--primary-color)',
                        fontSize: '13px',
                        fontWeight: 600,
                        background: 'none',
                        border: 'none',
                        cursor: 'pointer',
                        gap: '4px'
                    }}
                >
                    Learn More <ChevronDown size={14} />
                </button>
            </div>
        );
    }

    return (
        <div style={{
            backgroundColor: '#FFFBEB',
            padding: '24px',
            borderRadius: 'var(--border-radius-sm)',
            display: 'flex',
            alignItems: 'flex-start',
            gap: '16px',
            position: 'relative',
            animation: 'fadeIn 0.2s ease-in-out'
        }}>
            <div style={{ flexShrink: 0 }}>
                <Shield size={48} fill="#D97706" stroke="white" strokeWidth={1} style={{ filter: 'drop-shadow(0 2px 4px rgba(0,0,0,0.1))' }} />
            </div>
            <div style={{ flex: 1, paddingRight: '20px' }}>
                <h3 style={{ fontSize: '16px', fontWeight: 'bold', color: '#111827', marginBottom: '8px', marginTop: '4px' }}>
                    {expandedTitle}
                </h3>
                <p style={{ fontSize: '14px', color: '#4B5563', lineHeight: '1.5' }}>
                    {expandedDescription}
                    <br />
                    {expandedDetail}
                </p>
            </div>
            <button
                onClick={() => setShowDetailedBanner(false)}
                style={{
                    background: 'none', border: 'none', cursor: 'pointer',
                    color: '#0056D2', padding: '4px', position: 'absolute', top: '16px', right: '16px'
                }}
            >
                <X size={20} />
            </button>
            <style>{`
                @keyframes fadeIn {
                    from { opacity: 0; transform: translateY(-5px); }
                    to { opacity: 1; transform: translateY(0); }
                }
            `}</style>
        </div>
    );
};

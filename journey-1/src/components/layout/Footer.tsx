import React from 'react';
import PerfiosLogo from '../../assets/perfios-logo.png';

export const Footer: React.FC = () => {
    return (
        <div style={{ marginTop: '12px', textAlign: 'center', fontSize: '12px', color: '#9CA3AF' }}>
            Powered by <img src={PerfiosLogo} alt="Perfios" style={{ height: '12px', verticalAlign: 'middle', marginLeft: '4px' }} />
        </div>
    );
};

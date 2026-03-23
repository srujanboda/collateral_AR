import { useLocation } from 'react-router-dom';
import { SuccessCheckmark } from '../components/features/SuccessCheckmark';
import { appConfig } from '../config/appConfig';

import { useEffect } from 'react';

export default function SuccessPage() {
    const location = useLocation();
    const perfios_id = location.state?.perfios_id;

    const API_BASE = appConfig.apiBaseUrl.endsWith('/') ? appConfig.apiBaseUrl.slice(0, -1) : appConfig.apiBaseUrl;

    useEffect(() => {
        if (perfios_id) {
            fetch(`${API_BASE}/api/application/complete-journey/`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ perfios_id })
            }).catch(err => console.error('Journey completion update failed:', err));
        }
    }, [perfios_id]);

    const { title, message } = appConfig.successPage;

    return (
        <div className="page-container" style={{ alignItems: 'center', justifyContent: 'center' }}>

            <div style={{
                marginBottom: '32px', display: 'flex', flexDirection: 'column',
                alignItems: 'center', textAlign: 'center'
            }}>
                <SuccessCheckmark />
                <h2 style={{ fontSize: '28px', fontWeight: 'bold', color: 'var(--text-primary)', marginBottom: '12px' }}>
                    {title}
                </h2>
                <p style={{ color: 'var(--text-secondary)', fontSize: '16px' }}>
                    {message}
                </p>
            </div>
        </div>
    );
}

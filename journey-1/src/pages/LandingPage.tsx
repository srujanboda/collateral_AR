import { useNavigate } from 'react-router-dom';
import { useState } from 'react';
import { SecurityBanner } from '../components/features/SecurityBanner';
import { DocumentsList } from '../components/features/DocumentsList';
import { TermsModal } from '../components/features/TermsModal';
import { Button } from '../components/common/Button';
import { appConfig } from '../config/appConfig';

function LandingPage() {
    const navigate = useNavigate();
    const [isAgreed, setIsAgreed] = useState(false);
    const [showTerms, setShowTerms] = useState(false);

    const { title, description, documents, buttons } = appConfig.landingPage;

    return (
        <div className="page-container">
            {/* Security Banner */}
            <SecurityBanner />

            {/* Title */}
            <div>
                <h1 style={{ fontSize: '28px', fontWeight: 'bold', marginBottom: '12px' }}>
                    {title}
                </h1>
                <p style={{ fontSize: '16px', lineHeight: '1.6' }}>
                    {description}
                </p>
            </div>

            {/* The List */}
            <DocumentsList documents={documents} />

            {/* Footer / Action Area */}
            <div style={{ marginTop: 'auto', paddingTop: '32px' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '24px' }}>
                    <input
                        type="checkbox"
                        id="agree"
                        checked={isAgreed}
                        onChange={(e) => setIsAgreed(e.target.checked)}
                        style={{ width: '20px', height: '20px', cursor: 'pointer', accentColor: 'var(--primary-color)' }}
                    />
                    <label htmlFor="agree" style={{ fontSize: '14px', color: 'var(--text-secondary)', cursor: 'pointer' }}>
                        I hereby agree to the <span onClick={(e) => { e.preventDefault(); setShowTerms(true); }} style={{ color: 'var(--primary-color)', fontWeight: 500, cursor: 'pointer', textDecoration: 'underline' }}>terms and conditions</span>.
                    </label>
                </div>

                <Button
                    onClick={() => {
                        const params = new URLSearchParams(window.location.search);
                        const perfios_id = params.get('perfios_id');
                        navigate('/upload', { state: { perfios_id } });
                    }}
                    disabled={!isAgreed}
                    style={{ opacity: isAgreed ? 1 : 0.5, cursor: isAgreed ? 'pointer' : 'not-allowed' }}
                >
                    {buttons.startUpload}
                </Button>


            </div>

            {/* Terms Modal */}
            <TermsModal isOpen={showTerms} onClose={() => setShowTerms(false)} />
        </div>
    );
}

export default LandingPage;

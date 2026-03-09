import React from 'react';
import { Modal } from '../common/Modal';

interface TermsModalProps {
    isOpen: boolean;
    onClose: () => void;
}

export const TermsModal: React.FC<TermsModalProps> = ({ isOpen, onClose }) => {
    return (
        <Modal isOpen={isOpen} onClose={onClose}>
            <div style={{ textAlign: 'center' }}>
                <h3 style={{ marginBottom: '16px', fontSize: '18px', fontWeight: 'bold' }}>Terms and Conditions</h3>
                <p style={{ marginBottom: '24px', color: '#666' }}>We will be updating soon..</p>
                <button
                    onClick={onClose}
                    style={{
                        width: '100%', padding: '10px',
                        backgroundColor: 'var(--primary-color)', color: 'white',
                        border: 'none', borderRadius: '4px', cursor: 'pointer', fontWeight: 500
                    }}
                >
                    Close
                </button>
            </div>
        </Modal>
    );
};

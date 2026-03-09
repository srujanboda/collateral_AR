import React from 'react';
import { Card } from '../common/Card';

interface DocumentsListProps {
    documents: Array<{ id: number; label: string }>;
}

export const DocumentsList: React.FC<DocumentsListProps> = ({ documents }) => {
    return (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(100%, 1fr))', gap: '16px' }}>
            {documents.map((doc) => (
                <Card key={doc.id} style={{ display: 'flex', alignItems: 'center', padding: '16px', boxShadow: 'none', border: '1px solid #E5E7EB' }}>
                    <div style={{
                        width: '32px', height: '32px',
                        borderRadius: '50%',
                        backgroundColor: '#EFF6FF',
                        color: 'var(--primary-color)',
                        display: 'flex', alignItems: 'center', justifyContent: 'center',
                        fontWeight: 'bold', fontSize: '14px', marginRight: '16px',
                        flexShrink: 0
                    }}>
                        {doc.id}
                    </div>
                    <span style={{ fontSize: '16px', fontWeight: 500 }}>
                        {doc.label}
                    </span>
                </Card>
            ))}
        </div>
    );
};

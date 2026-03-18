import React from 'react';
import { ArrowLeft, MapPin, FileText, ExternalLink, Image as ImageIcon } from 'lucide-react';
import Card from '../common/Card';
import { theme } from '../../config/theme';

interface ApplicantDetailViewProps {
    applicant: any;
    onBack: () => void;
    apiBase: string;
    documentSteps: { id: number; label: string }[];
}

const ApplicantDetailView: React.FC<ApplicantDetailViewProps> = ({
    applicant,
    onBack,
    apiBase,
    documentSteps
}) => {
    return (
        <div style={{ padding: '1.5rem' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '1rem', marginBottom: '2rem' }}>
                <button
                    onClick={onBack}
                    style={{
                        background: 'none',
                        border: 'none',
                        cursor: 'pointer',
                        display: 'flex',
                        alignItems: 'center',
                        gap: '8px',
                        color: theme.colors.primary.main,
                        fontWeight: '500',
                        fontSize: '1rem',
                        padding: '0.5rem',
                        borderRadius: '8px',
                        transition: 'background 0.2s'
                    }}
                    onMouseOver={(e) => e.currentTarget.style.backgroundColor = '#f0f4ff'}
                    onMouseOut={(e) => e.currentTarget.style.backgroundColor = 'transparent'}
                >
                    <ArrowLeft size={20} />
                    Back to Applications
                </button>
            </div>

            <div style={{ marginBottom: '2rem' }}>
                <h1 style={{ fontSize: '1.6rem', fontWeight: 'bold', marginBottom: '0.75rem', display: 'flex', alignItems: 'center', flexWrap: 'wrap' }}>
                    {applicant.name}
                    <span style={{ color: '#ccc', fontWeight: '300', margin: '0 0.75rem' }}>|</span>
                    <span style={{ color: '#555', fontSize: '1.2rem' }}>{applicant.applicant_id}</span>
                    <span style={{ color: '#ccc', fontWeight: '300', margin: '0 0.75rem' }}>|</span>
                    <span style={{ color: '#555', fontSize: '1.2rem' }}>{applicant.perfios_id}</span>
                </h1>
                <div style={{ display: 'flex', alignItems: 'center', gap: '8px', color: '#666', fontSize: '1rem' }}>
                    <MapPin size={18} color={theme.colors.primary.main} />
                    <span>
                        {applicant.address}, {applicant.city}, {applicant.district}, {applicant.state}, {applicant.pincode}, {applicant.country}
                    </span>
                </div>
            </div>

            <Card>
                <div style={{ padding: '1.5rem' }}>
                    <h2 style={{ fontSize: '1.25rem', fontWeight: 'bold', marginBottom: '1.5rem', borderBottom: '2px solid #f0f0f0', paddingBottom: '0.75rem' }}>
                        Uploaded Documents
                    </h2>
                    <div style={{ display: 'flex', flexDirection: 'column', gap: '1.2rem' }}>
                        {documentSteps.map(step => {
                            const doc = applicant.documents?.find((d: any) => d.step_id === step.id.toString());
                            return (
                                <div key={step.id} style={{
                                    padding: '1.25rem',
                                    border: '1px solid #eee',
                                    borderRadius: '12px',
                                    backgroundColor: doc ? '#fff' : '#f9f9f9',
                                    boxShadow: doc ? '0 2px 4px rgba(0,0,0,0.02)' : 'none'
                                }}>
                                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '1rem' }}>
                                        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                                            <div style={{
                                                width: '40px',
                                                height: '40px',
                                                borderRadius: '8px',
                                                backgroundColor: doc ? '#eef2ff' : '#f0f0f0',
                                                display: 'flex',
                                                alignItems: 'center',
                                                justifyContent: 'center'
                                            }}>
                                                <FileText size={22} color={doc ? theme.colors.primary.main : '#999'} />
                                            </div>
                                            <div>
                                                <div style={{ fontWeight: '600', color: '#333' }}>{step.label}</div>
                                                <div style={{ fontSize: '0.85rem', color: doc ? theme.colors.success.main : '#999' }}>
                                                    {doc ? 'Documents available' : 'No documents uploaded yet'}
                                                </div>
                                            </div>
                                        </div>

                                        {doc ? (
                                            <div style={{ display: 'flex', gap: '0.75rem', flexWrap: 'wrap' }}>
                                                {doc.files.map((file: string, idx: number) => {
                                                    return (
                                                        <a
                                                            key={idx}
                                                            href={`${apiBase}/media/${file}`}
                                                            target="_blank"
                                                            rel="noopener noreferrer"
                                                            style={{
                                                                backgroundColor: '#f0f4ff',
                                                                color: theme.colors.primary.main,
                                                                textDecoration: 'none',
                                                                fontSize: '0.85rem',
                                                                padding: '0.5rem 0.75rem',
                                                                borderRadius: '6px',
                                                                display: 'flex',
                                                                alignItems: 'center',
                                                                gap: '6px',
                                                                fontWeight: '500',
                                                                border: '1px solid #dbe4ff'
                                                            }}
                                                        >
                                                            <ExternalLink size={14} />
                                                            View {doc.files.length > 1 ? `File ${idx + 1}` : 'File'}
                                                        </a>
                                                    );
                                                })}
                                            </div>
                                        ) : (
                                            <div style={{ padding: '0.5rem 0.75rem', borderRadius: '6px', border: '1px dashed #ccc', color: '#999', fontSize: '0.85rem' }}>
                                                Pending
                                            </div>
                                        )}
                                    </div>
                                </div>
                            );
                        })}
                    </div>
                </div>
            </Card>

            {/* Field Media Section */}
            {applicant.field_media && applicant.field_media.length > 0 && (
                <div style={{ marginTop: '2rem' }}>
                    <Card>
                        <div style={{ padding: '1.5rem' }}>
                            <h2 style={{ fontSize: '1.25rem', fontWeight: 'bold', marginBottom: '1.5rem', borderBottom: '2px solid #f0f0f0', paddingBottom: '0.75rem', display: 'flex', alignItems: 'center', gap: '8px' }}>
                                <ImageIcon size={22} color={theme.colors.primary.main} />
                                Flutter App Field Media
                            </h2>
                            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(200px, 1fr))', gap: '1rem' }}>
                                {applicant.field_media.map((mediaPath: string, idx: number) => {
                                    // Determine if it's an image or video based on extension, basic check
                                    const isImage = mediaPath.toLowerCase().match(/\.(jpeg|jpg|gif|png)$/) != null;
                                    const fullUrl = `${apiBase}/media/${mediaPath}`;

                                    return (
                                        <div key={idx} style={{ border: '1px solid #eee', borderRadius: '8px', overflow: 'hidden', display: 'flex', flexDirection: 'column' }}>
                                            {isImage ? (
                                                <a href={fullUrl} target="_blank" rel="noopener noreferrer" style={{ display: 'block', height: '150px', backgroundColor: '#f9f9f9' }}>
                                                    <img src={fullUrl} alt={`Field Media ${idx + 1}`} style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                                                </a>
                                            ) : (
                                                <div style={{ height: '150px', backgroundColor: '#f0f4ff', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                                                    <a href={fullUrl} target="_blank" rel="noopener noreferrer" style={{ color: theme.colors.primary.main, textDecoration: 'none', fontWeight: '500', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '8px' }}>
                                                        <ExternalLink size={24} />
                                                        View Video {idx + 1}
                                                    </a>
                                                </div>
                                            )}
                                        </div>
                                    );
                                })}
                            </div>
                        </div>
                    </Card>
                </div>
            )}

            {/* Verification Location Section */}
            {applicant.verification_location && (
                <div style={{ marginTop: '2rem' }}>
                    <Card>
                        <div style={{ padding: '1.5rem' }}>
                            <h2 style={{ fontSize: '1.25rem', fontWeight: 'bold', marginBottom: '1.5rem', borderBottom: '2px solid #f0f0f0', paddingBottom: '0.75rem', display: 'flex', alignItems: 'center', gap: '8px' }}>
                                <MapPin size={22} color={theme.colors.primary.main} />
                                Submission Verification Location
                            </h2>
                            <div style={{ padding: '1.25rem', border: '1px solid #eee', borderRadius: '12px', backgroundColor: '#fff' }}>
                                <div style={{ marginBottom: '1rem' }}>
                                    <div style={{ color: '#666', fontSize: '0.85rem', marginBottom: '0.25rem' }}>Captured Address</div>
                                    <div style={{ fontWeight: '600', color: '#333' }}>{applicant.verification_location.address || 'Address not available'}</div>
                                </div>
                                <div style={{ display: 'flex', gap: '2rem', flexWrap: 'wrap', alignItems: 'center' }}>
                                    <div>
                                        <div style={{ color: '#666', fontSize: '0.85rem', marginBottom: '0.25rem' }}>Latitude</div>
                                        <div style={{ fontWeight: '500' }}>{applicant.verification_location.latitude || 'N/A'}</div>
                                    </div>
                                    <div>
                                        <div style={{ color: '#666', fontSize: '0.85rem', marginBottom: '0.25rem' }}>Longitude</div>
                                        <div style={{ fontWeight: '500' }}>{applicant.verification_location.longitude || 'N/A'}</div>
                                    </div>
                                    {(applicant.verification_location.latitude && applicant.verification_location.longitude) && (
                                        <div style={{ marginLeft: 'auto' }}>
                                            <a
                                                href={`https://www.google.com/maps/search/?api=1&query=${applicant.verification_location.latitude},${applicant.verification_location.longitude}`}
                                                target="_blank"
                                                rel="noopener noreferrer"
                                                style={{
                                                    backgroundColor: '#f0f4ff',
                                                    color: theme.colors.primary.main,
                                                    textDecoration: 'none',
                                                    fontSize: '0.85rem',
                                                    padding: '0.6rem 1rem',
                                                    borderRadius: '8px',
                                                    display: 'flex',
                                                    alignItems: 'center',
                                                    gap: '8px',
                                                    fontWeight: '600',
                                                    border: '1px solid #dbe4ff',
                                                    transition: 'all 0.2s'
                                                }}
                                                onMouseOver={(e) => e.currentTarget.style.backgroundColor = '#e0e7ff'}
                                                onMouseOut={(e) => e.currentTarget.style.backgroundColor = '#f0f4ff'}
                                            >
                                                <ExternalLink size={16} />
                                                View on Google Maps
                                            </a>
                                        </div>
                                    )}
                                </div>
                            </div>
                        </div>
                    </Card>
                </div>
            )}
        </div>
    );
};

export default ApplicantDetailView;

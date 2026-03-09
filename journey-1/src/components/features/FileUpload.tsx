import React, { useRef } from 'react';
import { Upload, FileText, Trash2 } from 'lucide-react';
import { formatFileSize } from '../../utils/formatters';
import { MAX_FILE_SIZE_MB } from '../../constants';
// We might need to import constants

interface FileUploadProps {
    files: File[];
    label: string | undefined;
    onFilesSelected: (files: File[]) => void;
    onFileRemove: (index: number) => void;
}

export const FileUpload: React.FC<FileUploadProps> = ({ files, label, onFilesSelected, onFileRemove }) => {
    const fileInputRef = useRef<HTMLInputElement>(null);

    const handleUploadClick = () => {
        fileInputRef.current?.click();
    };

    const handleFileChange = (event: React.ChangeEvent<HTMLInputElement>) => {
        if (event.target.files && event.target.files.length > 0) {
            onFilesSelected(Array.from(event.target.files));
        }
        if (event.target) event.target.value = '';
    };

    return (
        <div style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
            <input
                type="file"
                multiple
                ref={fileInputRef}
                className="hidden"
                style={{ display: 'none' }}
                onChange={handleFileChange}
                accept=".pdf,.jpg,.jpeg,.png"
            />

            {files.length === 0 ? (
                <div
                    onClick={handleUploadClick}
                    style={{
                        border: '2px dashed #D1D5DB', borderRadius: 'var(--border-radius-md)',
                        padding: '40px', display: 'flex', flexDirection: 'column',
                        alignItems: 'center', justifyContent: 'center', cursor: 'pointer',
                        marginTop: '16px', backgroundColor: '#F9FAFB', transition: 'all 0.2s'
                    }}
                    onMouseEnter={(e) => { e.currentTarget.style.borderColor = 'var(--primary-color)'; e.currentTarget.style.backgroundColor = '#EFF6FF'; }}
                    onMouseLeave={(e) => { e.currentTarget.style.borderColor = '#D1D5DB'; e.currentTarget.style.backgroundColor = '#F9FAFB'; }}
                >
                    <div style={{
                        width: '48px', height: '48px', borderRadius: '50%', background: '#EFF6FF',
                        display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: '16px'
                    }}>
                        <Upload size={24} color="var(--primary-color)" />
                    </div>
                    <span style={{ color: 'var(--primary-color)', fontWeight: 600, marginBottom: '8px', fontSize: '16px' }}>
                        Click to upload {label}
                    </span>
                    <span style={{ fontSize: '13px', color: '#6B7280' }}>
                        SVG, PNG, JPG or PDF (max. {MAX_FILE_SIZE_MB}MB)
                    </span>
                </div>
            ) : (
                <div style={{ display: 'flex', flexDirection: 'column', gap: '12px', marginTop: '16px' }}>
                    {files.map((file, index) => (
                        <div key={index} className="card" style={{
                            padding: '16px', display: 'flex', alignItems: 'center', gap: '16px',
                            border: '1px solid #E5E7EB', boxShadow: 'none'
                        }}>
                            <div style={{
                                width: '40px', height: '40px', borderRadius: '8px', background: '#EFF6FF',
                                display: 'flex', alignItems: 'center', justifyContent: 'center'
                            }}>
                                <FileText size={20} color="var(--primary-color)" />
                            </div>
                            <div style={{ flex: 1, minWidth: 0 }}>
                                <div style={{ fontWeight: 500, fontSize: '14px', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                                    {file.name}
                                </div>
                                <div style={{ fontSize: '12px', color: '#6B7280' }}>
                                    {formatFileSize(file.size)}
                                </div>
                            </div>
                            <button
                                onClick={() => onFileRemove(index)}
                                style={{
                                    border: 'none', background: 'none', cursor: 'pointer', padding: '8px',
                                    color: '#EF4444', borderRadius: '6px', display: 'flex'
                                }}
                                className="hover:bg-red-50"
                            >
                                <Trash2 size={18} />
                            </button>
                        </div>
                    ))}

                    <div style={{ display: 'flex', justifyContent: 'center', width: '100%' }}>
                        <button
                            onClick={handleUploadClick}
                            style={{
                                marginTop: '8px', color: 'var(--primary-color)', background: 'none',
                                border: 'none', cursor: 'pointer', display: 'inline-flex', alignItems: 'center', gap: '8px',
                                fontWeight: 600, fontSize: '14px', padding: '8px 16px',
                                borderRadius: 'var(--border-radius-sm)',
                                transition: 'background-color 0.2s'
                            }}
                            className="hover:bg-blue-50"
                            onMouseEnter={(e) => e.currentTarget.style.backgroundColor = '#EFF6FF'}
                            onMouseLeave={(e) => e.currentTarget.style.backgroundColor = 'transparent'}
                        >
                            + Upload More Files
                        </button>
                    </div>
                </div>
            )}
        </div>
    );
};

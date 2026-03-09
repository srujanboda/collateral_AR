import React from 'react';
import DialogBox from '../common/DialogBox';
import Button from '../common/Button';
import { appConfig } from '../../config/appConfig';
import { type User } from '../../services/userService';

interface UserConfirmDialogProps {
    confirmAction: { type: 'delete' | 'deactivate'; user: User } | null;
    onClose: () => void;
    onConfirm: () => void;
}

const UserConfirmDialog: React.FC<UserConfirmDialogProps> = ({ confirmAction, onClose, onConfirm }) => {
    if (!confirmAction) return null;

    const isDelete = confirmAction.type === 'delete';
    const config = isDelete
        ? appConfig.pages.manageUsers.dialogs.delete
        : appConfig.pages.manageUsers.dialogs.deactivate;

    return (
        <DialogBox
            isOpen={!!confirmAction}
            onClose={onClose}
            title={config.title}
            maxWidth="500px"
            minHeight="auto"
        >
            <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
                <p style={{ color: '#333', fontSize: '1rem' }}>
                    {config.message}
                </p>
                <p style={{ color: '#666', fontSize: '0.9rem', marginTop: '-0.5rem' }}>
                    {config.subMessage}
                </p>
                <div style={{ display: 'flex', justifyContent: 'flex-end', alignItems: 'center', gap: '1rem' }}>
                    <button
                        className="btn-danger-text"
                        onClick={onClose}
                        style={{ cursor: 'pointer', fontSize: '0.9rem', border: 'none', background: 'none' }}
                    >
                        {appConfig.common.actions.discard}
                    </button>
                    <Button
                        onClick={onConfirm}
                        style={{
                            minWidth: '100px',
                            backgroundColor: isDelete ? '#d93025' : undefined,
                            borderColor: isDelete ? '#d93025' : undefined
                        }}
                    >
                        {config.confirmButton}
                    </Button>
                </div>
            </div>
        </DialogBox>
    );
};

export default UserConfirmDialog;

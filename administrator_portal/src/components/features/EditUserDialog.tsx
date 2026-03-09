import React, { useState, useEffect } from 'react';
import DialogBox from '../common/DialogBox';
import Input from '../common/Input';
import Select from '../common/Select';
import Button from '../common/Button';
import { appConfig } from '../../config/appConfig';
import { userService, type User } from '../../services/userService';

interface EditUserDialogProps {
    user: User | null;
    isOpen: boolean;
    onClose: () => void;
    onSuccess: () => void;
}

const EditUserDialog: React.FC<EditUserDialogProps> = ({ user, isOpen, onClose, onSuccess }) => {
    const [loading, setLoading] = useState(false);
    const [formData, setFormData] = useState<Partial<User>>({});

    useEffect(() => {
        if (user) {
            setFormData({
                name: user.name,
                organization: user.organization,
                customer: user.customer,
                role: user.role
            });
        }
    }, [user]);

    const handleUpdateUser = async () => {
        if (!user) return;
        if (!formData.name || !formData.organization || !formData.customer || !formData.role) {
            alert('Please fill in all fields');
            return;
        }

        setLoading(true);
        try {
            await userService.updateUser(user.username, formData);
            onSuccess();
            onClose();
        } catch (err: any) {
            alert(err.response?.data?.error || 'Failed to update user');
        } finally {
            setLoading(false);
        }
    };

    return (
        <DialogBox
            isOpen={isOpen}
            onClose={onClose}
            title="Edit User"
        >
            <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
                <Input
                    label={appConfig.pages.manageUsers.dialogs.add.nameLabel}
                    value={formData.name || ''}
                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                />
                <Input
                    label={appConfig.pages.manageUsers.dialogs.add.emailLabel}
                    value={user?.username || ''}
                    disabled
                />
                <Input
                    label={appConfig.pages.manageUsers.dialogs.add.orgLabel}
                    value={formData.organization || ''}
                    onChange={(e) => setFormData({ ...formData, organization: e.target.value })}
                />
                <Input
                    label={appConfig.pages.manageUsers.dialogs.add.customerLabel}
                    value={formData.customer || ''}
                    onChange={(e) => setFormData({ ...formData, customer: e.target.value })}
                />
                <Select
                    label={appConfig.pages.manageUsers.dialogs.add.roleLabel}
                    value={formData.role || ''}
                    onChange={(e) => setFormData({ ...formData, role: e.target.value })}
                    options={[
                        { value: 'Admin', label: 'Admin' },
                        { value: 'Manager', label: 'Manager' },
                        { value: 'Analyst', label: 'Analyst' }
                    ]}
                />
                <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '1rem' }}>
                    <Button
                        variant="secondary"
                        onClick={onClose}
                    >
                        {appConfig.common.actions.cancel}
                    </Button>
                    <Button onClick={handleUpdateUser} disabled={loading}>
                        {loading ? 'Updating...' : appConfig.common.actions.update}
                    </Button>
                </div>
            </div>
        </DialogBox>
    );
};

export default EditUserDialog;

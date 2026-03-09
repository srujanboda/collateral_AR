import React, { useState } from 'react';
import DialogBox from '../common/DialogBox';
import Input from '../common/Input';
import Select from '../common/Select';
import Button from '../common/Button';
import { appConfig } from '../../config/appConfig';
import { userService } from '../../services/userService';

interface AddUserDialogProps {
    isOpen: boolean;
    onClose: () => void;
    onSuccess: () => void;
}

const AddUserDialog: React.FC<AddUserDialogProps> = ({ isOpen, onClose, onSuccess }) => {
    const [loading, setLoading] = useState(false);
    const [newUser, setNewUser] = useState({
        name: '',
        email: '',
        organization: '',
        customer: '',
        role: 'Admin'
    });

    const handleAddUser = async () => {
        if (!newUser.name || !newUser.email || !newUser.organization || !newUser.customer || !newUser.role) {
            alert('Please fill in all fields');
            return;
        }

        setLoading(true);
        try {
            await userService.createUser(newUser);
            setNewUser({ name: '', email: '', organization: '', customer: '', role: 'Admin' });
            onSuccess();
            onClose();
        } catch (err: any) {
            alert(err.response?.data?.error || 'Failed to create user');
        } finally {
            setLoading(false);
        }
    };

    return (
        <DialogBox
            isOpen={isOpen}
            onClose={onClose}
            title={appConfig.pages.manageUsers.dialogs.add.title}
        >
            <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
                <Input
                    label={appConfig.pages.manageUsers.dialogs.add.nameLabel}
                    placeholder={appConfig.pages.manageUsers.dialogs.add.namePlaceholder}
                    value={newUser.name}
                    onChange={(e) => setNewUser({ ...newUser, name: e.target.value })}
                />
                <Input
                    label={appConfig.pages.manageUsers.dialogs.add.emailLabel}
                    type="email"
                    placeholder={appConfig.pages.manageUsers.dialogs.add.emailPlaceholder}
                    value={newUser.email}
                    onChange={(e) => setNewUser({ ...newUser, email: e.target.value })}
                />
                <Input
                    label={appConfig.pages.manageUsers.dialogs.add.orgLabel}
                    placeholder={appConfig.pages.manageUsers.dialogs.add.orgPlaceholder}
                    value={newUser.organization}
                    onChange={(e) => setNewUser({ ...newUser, organization: e.target.value })}
                />
                <Input
                    label={appConfig.pages.manageUsers.dialogs.add.customerLabel}
                    placeholder={appConfig.pages.manageUsers.dialogs.add.customerPlaceholder}
                    value={newUser.customer}
                    onChange={(e) => setNewUser({ ...newUser, customer: e.target.value })}
                />
                <Select
                    label={appConfig.pages.manageUsers.dialogs.add.roleLabel}
                    value={newUser.role}
                    onChange={(e) => setNewUser({ ...newUser, role: e.target.value })}
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
                    <Button onClick={handleAddUser} disabled={loading}>
                        {loading ? 'Adding...' : appConfig.pages.manageUsers.dialogs.add.submitButton}
                    </Button>
                </div>
            </div>
        </DialogBox>
    );
};

export default AddUserDialog;

import React, { useState } from 'react';
import PageHeader from '../components/common/PageHeader';
import Card from '../components/common/Card';
import Button from '../components/common/Button';
import DialogBox from '../components/common/DialogBox';
import Input from '../components/common/Input';
import { appConfig } from '../config/appConfig';

import { userService } from '../services/userService';

const ProfilePage: React.FC = () => {
    const user = JSON.parse(localStorage.getItem('user') || '{}');
    const userEmail = localStorage.getItem('userEmail') || user.username || '';

    const [isChangePasswordOpen, setIsChangePasswordOpen] = useState(false);
    const [loading, setLoading] = useState(false);
    const [passwordData, setPasswordData] = useState({
        current: '',
        new: '',
        confirm: ''
    });
    const [errors, setErrors] = useState({
        current: '',
        new: '',
        confirm: ''
    });

    const handleStartChangePassword = () => {
        setPasswordData({ current: '', new: '', confirm: '' });
        setErrors({ current: '', new: '', confirm: '' });
        setIsChangePasswordOpen(true);
    };

    const handleCloseChangePassword = () => {
        setIsChangePasswordOpen(false);
        setPasswordData({ current: '', new: '', confirm: '' });
        setErrors({ current: '', new: '', confirm: '' });
    };

    const handleUpdatePassword = async () => {
        const newErrors = { current: '', new: '', confirm: '' };
        let isValid = true;

        if (!passwordData.current) {
            newErrors.current = appConfig.pages.profile.sections.password.dialog.errors.currentRequired;
            isValid = false;
        }

        if (!passwordData.new) {
            newErrors.new = appConfig.pages.profile.sections.password.dialog.errors.newRequired;
            isValid = false;
        }

        if (!passwordData.confirm) {
            newErrors.confirm = appConfig.pages.profile.sections.password.dialog.errors.confirmRequired;
            isValid = false;
        } else if (passwordData.new !== passwordData.confirm) {
            newErrors.confirm = appConfig.pages.profile.sections.password.dialog.errors.mismatch;
            isValid = false;
        }

        if (!isValid) {
            setErrors(newErrors);
            return;
        }

        setLoading(true);
        try {
            await userService.changePassword({
                username: userEmail,
                current_password: passwordData.current,
                new_password: passwordData.new
            });
            alert(appConfig.pages.profile.sections.password.dialog.successMessage);
            handleCloseChangePassword();
        } catch (err: any) {
            alert(err.response?.data?.error || 'Failed to update password');
        } finally {
            setLoading(false);
        }
    };

    return (
        <div style={{ padding: '2rem' }}>
            <PageHeader title={appConfig.pages.profile.title} />

            <Card>
                <div style={{ padding: '2rem' }}>
                    <div style={{ display: 'flex', alignItems: 'flex-start', gap: '1.5rem', marginBottom: '2rem' }}>
                        <div style={{
                            width: '80px',
                            height: '80px',
                            borderRadius: '8px',
                            backgroundColor: '#6c757d',
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'center',
                            color: 'white',
                            fontSize: '1.5rem'
                        }}>
                            {(user.name || userEmail || 'U').substring(0, 2).toUpperCase()}
                        </div>
                        <div>
                            <h2 style={{ margin: '0 0 0.25rem 0', fontSize: '1.1rem', color: '#333' }}>{user.name || 'User'}</h2>
                            <p style={{ margin: '0', color: '#666', fontSize: '0.9rem' }}>{userEmail}</p>
                        </div>
                    </div>

                    <div style={{ marginBottom: '2rem' }}>
                        <h3 style={{ color: '#0052cc', borderBottom: '1px solid #e0e0e0', paddingBottom: '0.5rem', marginBottom: '1rem', fontSize: '1rem' }}>{appConfig.pages.profile.sections.password.title}</h3>
                        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', backgroundColor: '#f9fafb', padding: '1rem', borderRadius: '8px' }}>
                            <span style={{ color: '#666', fontSize: '0.85rem' }}>{appConfig.pages.profile.sections.password.description}</span>
                            <Button
                                variant="outline"
                                style={{ fontSize: '0.85rem', padding: '0.5rem 1rem' }}
                                onClick={handleStartChangePassword}
                            >
                                {appConfig.pages.profile.sections.password.changeButton}
                            </Button>
                        </div>
                    </div>

                    <div>
                        <h3 style={{ color: '#0052cc', borderBottom: '1px solid #e0e0e0', paddingBottom: '0.5rem', marginBottom: '1rem', fontSize: '1rem' }}>{appConfig.pages.profile.sections.organisations.title}</h3>
                        <table style={{ width: '100%', borderCollapse: 'collapse' }}>
                            <thead>
                                <tr style={{ borderBottom: '1px solid #e0e0e0', textAlign: 'left' }}>
                                    <th style={{ padding: '0.75rem', color: '#444', fontSize: '0.85rem', fontWeight: 600 }}>{appConfig.pages.profile.sections.organisations.table.headers.name}</th>
                                    <th style={{ padding: '0.75rem', color: '#444', fontSize: '0.85rem', fontWeight: 600 }}>{appConfig.pages.profile.sections.organisations.table.headers.role}</th>
                                    <th style={{ padding: '0.75rem', color: '#444', fontSize: '0.85rem', fontWeight: 600 }}>{appConfig.pages.profile.sections.organisations.table.headers.permission}</th>
                                </tr>
                            </thead>
                            <tbody>
                                {/* Empty State as requested */}
                                <tr>
                                    <td colSpan={3} style={{ padding: '2rem', textAlign: 'center', color: '#999', fontSize: '0.85rem' }}>
                                        {appConfig.pages.profile.sections.organisations.table.empty}
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </Card>

            <DialogBox
                isOpen={isChangePasswordOpen}
                onClose={handleCloseChangePassword}
                title={appConfig.pages.profile.sections.password.dialog.title}
            >
                <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
                    <Input
                        label={appConfig.pages.profile.sections.password.dialog.currentLabel}
                        type="password"
                        value={passwordData.current}
                        onChange={(e) => {
                            setPasswordData({ ...passwordData, current: e.target.value });
                            if (errors.current) setErrors({ ...errors, current: '' });
                        }}
                        placeholder={appConfig.pages.profile.sections.password.dialog.currentPlaceholder}
                        error={errors.current}
                    />

                    <Input
                        label={appConfig.pages.profile.sections.password.dialog.newLabel}
                        type="password"
                        value={passwordData.new}
                        onChange={(e) => {
                            setPasswordData({ ...passwordData, new: e.target.value });
                            if (errors.new) setErrors({ ...errors, new: '' });
                        }}
                        placeholder={appConfig.pages.profile.sections.password.dialog.newPlaceholder}
                        error={errors.new}
                    />

                    <Input
                        label={appConfig.pages.profile.sections.password.dialog.confirmLabel}
                        type="password"
                        value={passwordData.confirm}
                        onChange={(e) => {
                            setPasswordData({ ...passwordData, confirm: e.target.value });
                            if (errors.confirm) setErrors({ ...errors, confirm: '' });
                        }}
                        placeholder={appConfig.pages.profile.sections.password.dialog.confirmPlaceholder}
                        error={errors.confirm}
                    />

                    <div style={{ display: 'flex', justifyContent: 'flex-end', alignItems: 'center', gap: '1rem', marginTop: '1rem' }}>
                        <button
                            className="btn-danger-text"
                            onClick={handleCloseChangePassword}
                            style={{ cursor: 'pointer', fontSize: '0.9rem' }}
                        >
                            {appConfig.common.actions.discard}
                        </button>
                        <Button
                            onClick={handleUpdatePassword}
                            style={{ padding: '0.5rem 1rem', fontSize: '0.9rem' }}
                            disabled={loading}
                        >
                            {loading ? 'Updating...' : appConfig.pages.profile.sections.password.dialog.submitButton}
                        </Button>
                    </div>
                </div>
            </DialogBox>
        </div>
    );
};

export default ProfilePage;

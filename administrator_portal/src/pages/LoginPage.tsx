import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import Input from '../components/common/Input';
import Button from '../components/common/Button';
import DialogBox from '../components/common/DialogBox';
import { appConfig } from '../config/appConfig';
import { theme } from '../config/theme';

import { authService } from '../services/authService';

const LoginPage: React.FC = () => {
    const navigate = useNavigate();
    // View State: 'login' or 'forgot-password'
    const [view, setView] = useState<'login' | 'forgot-password'>('login');
    const [resetSent, setResetSent] = useState(false);
    const [error, setError] = useState<string | null>(null);
    const [loading, setLoading] = useState(false);

    // Login Form State
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [termsAgreed, setTermsAgreed] = useState(false);

    // Forgot Password State
    const [forgotEmail, setForgotEmail] = useState('');

    // Popup State
    const [activePopup, setActivePopup] = useState<'terms' | 'privacy' | null>(null);

    const isLoginValid = email.trim() !== '' && password.trim() !== '' && termsAgreed;
    const isForgotValid = forgotEmail.trim() !== '';

    const handleLogin = async (e: React.FormEvent) => {
        e.preventDefault();
        if (isLoginValid) {
            setError(null);
            setLoading(true);
            try {
                await authService.login(email, password);
                navigate('/app');
            } catch (err: any) {
                setError(err.message);
            } finally {
                setLoading(false);
            }
        }
    };

    const handleForgotSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        if (isForgotValid) {
            setResetSent(true);
            console.log('Reset password for', forgotEmail);
        }
    };

    return (
        <div style={{ display: 'flex', width: '100vw', height: '100vh', overflow: 'hidden' }}>
            {/* Left Side - Image */}
            <div style={{
                flex: 1,
                backgroundColor: theme.colors.primary.main,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                position: 'relative'
            }}>
                <img
                    src={appConfig.auth.login.bannerImage}
                    alt={appConfig.auth.login.bannerAlt}
                    style={{
                        width: '100%',
                        height: '100%',
                        objectFit: 'cover'
                    }}
                />
            </div>

            {/* Right Side - Content */}
            <div style={{
                flex: 1,
                backgroundColor: theme.colors.background.paper,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                flexDirection: 'column',
                padding: '2rem',
                position: 'relative' // For absolute positioning of toast if needed
            }}>

                {/* Success Banner for Reset Link - Only shows when resetSent is true */}
                {view === 'forgot-password' && resetSent && (
                    <div style={{
                        position: 'absolute',
                        top: '2rem',
                        left: '50%',
                        transform: 'translateX(-50%)',
                        width: '90%',
                        maxWidth: '400px',
                        backgroundColor: theme.colors.success.background,
                        border: `1px solid ${theme.colors.success.border}`,
                        borderRadius: '8px',
                        padding: '1rem',
                        display: 'flex',
                        alignItems: 'flex-start',
                        gap: '0.75rem'
                    }}>
                        {/* Check Circle Icon */}
                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill={theme.colors.success.main} stroke="none">
                            <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z" />
                        </svg>
                        <div style={{ flex: 1 }}>
                            <h4 style={{ margin: 0, fontSize: '0.9rem', color: theme.colors.text.primary, fontWeight: 600 }}>{appConfig.auth.forgotPassword.success.title}</h4>
                            <p style={{ margin: '0.25rem 0 0', fontSize: '0.8rem', color: theme.colors.text.tertiary }}>
                                {appConfig.auth.forgotPassword.success.description}
                            </p>
                        </div>
                        <button
                            onClick={() => setResetSent(false)}
                            style={{ background: 'none', border: 'none', cursor: 'pointer', color: theme.colors.text.tertiary }}
                        >
                            ✕
                        </button>
                    </div>
                )}


                <div style={{ width: '100%', maxWidth: '400px' }}>

                    {view === 'login' ? (
                        /* ================= LOGIN FORM ================= */
                        <>
                            <h2 style={{ fontSize: '1.75rem', fontWeight: 600, marginBottom: '2rem', color: theme.colors.text.primary }}>
                                {appConfig.auth.login.title}
                            </h2>

                            {error && (
                                <div style={{
                                    backgroundColor: theme.colors.error.background,
                                    border: `1px solid ${theme.colors.error.border}`,
                                    color: theme.colors.error.main,
                                    padding: '0.75rem',
                                    borderRadius: '8px',
                                    fontSize: '0.875rem',
                                    marginBottom: '1.25rem'
                                }}>
                                    {error}
                                </div>
                            )}

                            <form onSubmit={handleLogin} style={{ display: 'flex', flexDirection: 'column', gap: '1.25rem' }}>
                                <Input
                                    label={appConfig.auth.login.emailLabel}
                                    type="email"
                                    placeholder={appConfig.auth.login.emailPlaceholder}
                                    value={email}
                                    onChange={(e) => setEmail(e.target.value)}
                                />

                                <div style={{ display: 'flex', flexDirection: 'column', gap: '0.25rem' }}>
                                    <Input
                                        label={appConfig.auth.login.passwordLabel}
                                        type="password"
                                        placeholder={appConfig.auth.login.passwordPlaceholder}
                                        value={password}
                                        onChange={(e) => setPassword(e.target.value)}
                                    />
                                    <div style={{ display: 'flex', justifyContent: 'flex-end' }}>
                                        <button
                                            type="button"
                                            onClick={() => { setView('forgot-password'); setResetSent(false); }}
                                            style={{ background: 'none', border: 'none', color: theme.colors.primary.main, fontSize: '0.875rem', fontWeight: 600, cursor: 'pointer', textDecoration: 'none' }}
                                        >
                                            {appConfig.auth.login.forgotPasswordLink}
                                        </button>
                                    </div>
                                </div>

                                <div style={{ textAlign: 'left', display: 'flex', alignItems: 'flex-start', justifyContent: 'flex-start', gap: '8px' }}>
                                    <input
                                        type="checkbox"
                                        id="terms"
                                        checked={termsAgreed}
                                        onChange={(e) => setTermsAgreed(e.target.checked)}
                                        style={{ cursor: 'pointer', width: '16px', height: '16px', accentColor: theme.colors.primary.main }}
                                    />
                                    <label htmlFor="terms" style={{ fontSize: '0.75rem', color: theme.colors.text.tertiary, cursor: 'pointer' }}>
                                        {appConfig.auth.login.terms.preText}{' '}
                                        <button
                                            type="button"
                                            onClick={() => setActivePopup('terms')}
                                            style={{ background: 'none', border: 'none', padding: 0, color: theme.colors.primary.main, fontSize: 'inherit', cursor: 'pointer', textDecoration: 'underline' }}
                                        >
                                            {appConfig.auth.login.terms.termsText}
                                        </button>
                                        {' '}{appConfig.auth.login.terms.andText}{' '}
                                        <button
                                            type="button"
                                            onClick={() => setActivePopup('privacy')}
                                            style={{ background: 'none', border: 'none', padding: 0, color: theme.colors.primary.main, fontSize: 'inherit', cursor: 'pointer', textDecoration: 'underline' }}
                                        >
                                            {appConfig.auth.login.terms.privacyText}
                                        </button>
                                    </label>
                                </div>

                                <Button type="submit" fullWidth disabled={!isLoginValid || loading}>
                                    {loading ? 'Signing in...' : appConfig.auth.login.submitButton}
                                </Button>
                            </form>
                        </>
                    ) : (
                        /* ================= FORGOT PASSWORD FORM ================= */
                        <>
                            <h2 style={{ fontSize: '1.75rem', fontWeight: 600, marginBottom: '1rem', color: theme.colors.text.primary }}>
                                {appConfig.auth.forgotPassword.title}
                            </h2>
                            <p style={{ fontSize: '0.9rem', color: theme.colors.text.tertiary, marginBottom: '2rem', lineHeight: '1.5' }}>
                                {appConfig.auth.forgotPassword.description}
                            </p>

                            <form onSubmit={handleForgotSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '1.5rem' }}>
                                <Input
                                    label={appConfig.auth.forgotPassword.emailLabel}
                                    type="email"
                                    placeholder={appConfig.auth.forgotPassword.emailPlaceholder}
                                    value={forgotEmail}
                                    onChange={(e) => setForgotEmail(e.target.value)}
                                    icon={
                                        <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                                            <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"></path>
                                            <polyline points="22,6 12,13 2,6"></polyline>
                                        </svg>
                                    }
                                />

                                <Button type="submit" fullWidth disabled={!isForgotValid} style={{ marginBottom: '1rem' }}>
                                    {appConfig.auth.forgotPassword.submitButton}
                                </Button>
                            </form>

                            <div style={{ textAlign: 'center' }}>
                                <button
                                    onClick={() => setView('login')}
                                    style={{
                                        background: 'none',
                                        border: 'none',
                                        color: theme.colors.primary.main,
                                        fontSize: '1rem',
                                        fontWeight: 500,
                                        cursor: 'pointer',
                                        display: 'inline-flex',
                                        alignItems: 'center',
                                        gap: '0.5rem'
                                    }}
                                >
                                    <span>←</span> {appConfig.auth.forgotPassword.backToLogin}
                                </button>
                            </div>
                        </>
                    )}


                    <div style={{
                        marginTop: 'auto',
                        paddingTop: '3rem',
                        textAlign: 'center',
                        fontSize: '0.75rem',
                        color: theme.colors.text.muted
                    }}>
                        {appConfig.layout.footer.copyright}
                    </div>
                </div>
            </div>

            {/* Popups */}
            <DialogBox
                isOpen={activePopup === 'terms'}
                onClose={() => setActivePopup(null)}
                title={appConfig.auth.login.terms.termsText}
            >
                <div style={{ color: theme.colors.text.tertiary, lineHeight: '1.6' }}>
                    {/* Empty for now as requested */}
                    <p>No content available yet.</p>
                </div>
            </DialogBox>

            <DialogBox
                isOpen={activePopup === 'privacy'}
                onClose={() => setActivePopup(null)}
                title={appConfig.auth.login.terms.privacyText}
            >
                <div style={{ color: theme.colors.text.tertiary, lineHeight: '1.6' }}>
                    {/* Empty for now as requested */}
                    <p>No content available yet.</p>
                </div>
            </DialogBox>
        </div>
    );
};

export default LoginPage;

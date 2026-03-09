import React, { useState, useRef, useEffect } from 'react';
import {
    CreditCard,
    Users,
    Settings,
    ShieldCheck,
    ChevronsLeft,
    ChevronsRight,
    ChevronRight,
    LogOut,
    UserCircle
} from 'lucide-react';
import { NavLink, useNavigate } from 'react-router-dom';
import { appConfig } from '../../config/appConfig';
import { theme } from '../../config/theme';

const Sidebar: React.FC = () => {
    const [collapsed, setCollapsed] = useState(false);
    const [isProfileMenuOpen, setIsProfileMenuOpen] = useState(false);
    const profileRef = useRef<HTMLDivElement>(null);
    const navigate = useNavigate();

    const toggleCollapse = () => {
        setCollapsed(!collapsed);
    };

    useEffect(() => {
        const handleClickOutside = (event: MouseEvent) => {
            if (profileRef.current && !profileRef.current.contains(event.target as Node)) {
                setIsProfileMenuOpen(false);
            }
        };

        document.addEventListener('mousedown', handleClickOutside);
        return () => {
            document.removeEventListener('mousedown', handleClickOutside);
        };
    }, []);

    const handleLogout = () => {
        setIsProfileMenuOpen(false);
        navigate('/');
    };

    const navItems = [
        { name: appConfig.layout.sidebar.navUser.allApps, icon: <CreditCard size={20} />, path: '/app/applications' },
        { name: appConfig.layout.sidebar.navUser.manageUsers, icon: <Users size={20} />, path: '/app/users' },
    ];

    const footerItems = [
        { name: appConfig.layout.sidebar.navUser.settings, icon: <Settings size={20} />, path: '/app/settings' },
    ];

    return (
        <div style={{
            width: collapsed ? '80px' : '260px',
            height: '100vh',
            backgroundColor: theme.colors.background.sidebar,
            borderRight: `1px solid ${theme.colors.border.main}`,
            display: 'flex',
            flexDirection: 'column',
            transition: 'width 0.3s ease',
            position: 'relative'
        }}>
            {/* Header / Logo */}
            <div style={{
                height: '70px',
                display: 'flex',
                alignItems: 'center',
                padding: '0 1.5rem',
                borderBottom: `1px solid ${theme.colors.border.light}`
            }}>
                <div style={{
                    fontWeight: 700,
                    fontSize: '1.25rem',
                    color: theme.colors.primary.main,
                    display: 'flex',
                    alignItems: 'center',
                    gap: '8px',
                    whiteSpace: 'nowrap',
                    overflow: 'hidden'
                }}>
                    {!collapsed && (
                        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                            <img src={appConfig.app.logo} alt={appConfig.app.companyName} style={{ height: '24px' }} />
                            <span style={{ color: '#ccc', fontSize: '1.25rem', fontWeight: 300 }}>|</span>
                            <span style={{ fontSize: '1rem', color: theme.colors.text.secondary, fontWeight: 600 }}>{appConfig.app.name}</span>
                        </div>
                    )}
                    {collapsed && <img src={appConfig.app.collapsedLogo} alt={appConfig.app.companyName} style={{ height: '32px', borderRadius: '4px' }} />}
                </div>
            </div>

            {/* Main Navigation */}
            <div style={{ flex: 1, padding: '1rem', display: 'flex', flexDirection: 'column', gap: '0.5rem' }}>
                <div style={{
                    fontSize: '0.75rem',
                    color: theme.colors.text.muted,
                    marginBottom: '0.5rem',
                    paddingLeft: '0.75rem',
                    textTransform: 'uppercase',
                    display: collapsed ? 'none' : 'block'
                }}>
                    {appConfig.layout.sidebar.mainMenuLabel}
                </div>
                {navItems.map((item) => (
                    <NavLink
                        key={item.name}
                        to={item.path}
                        className={({ isActive }) =>
                            isActive ? 'nav-item active' : 'nav-item'
                        }
                        style={({ isActive }) => ({
                            display: 'flex',
                            alignItems: 'center',
                            gap: '12px',
                            padding: '0.75rem',
                            borderRadius: '8px',
                            color: isActive ? theme.colors.primary.main : theme.colors.text.secondary,
                            backgroundColor: isActive ? theme.colors.primary.light : 'transparent',
                            textDecoration: 'none',
                            fontSize: '0.9rem',
                            fontWeight: isActive ? 500 : 400,
                            whiteSpace: 'nowrap',
                            overflow: 'hidden',
                            transition: 'all 0.2s'
                        })}
                    >
                        {item.icon}
                        {!collapsed && <span>{item.name}</span>}
                    </NavLink>
                ))}
            </div>

            {/* Footer / User / Settings */}
            <div style={{
                padding: '1rem',
                borderTop: `1px solid ${theme.colors.border.light}`,
                display: 'flex',
                flexDirection: 'column',
                gap: '0.5rem'
            }}>
                {footerItems.map((item) => (
                    <NavLink
                        key={item.name}
                        to={item.path}
                        style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: '12px',
                            padding: '0.75rem',
                            borderRadius: '8px',
                            color: theme.colors.text.secondary,
                            textDecoration: 'none',
                            fontSize: '0.9rem',
                            whiteSpace: 'nowrap',
                            overflow: 'hidden'
                        }}
                    >
                        {item.icon}
                        {!collapsed && <span>{item.name}</span>}
                    </NavLink>
                ))}

                {/* Administrator Profile */}
                <div ref={profileRef} style={{ position: 'relative' }}>
                    <div
                        onClick={() => setIsProfileMenuOpen(!isProfileMenuOpen)}
                        style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: '12px',
                            padding: '0.75rem',
                            marginTop: '0.5rem',
                            borderRadius: '8px',
                            backgroundColor: isProfileMenuOpen ? theme.colors.primary.light : theme.colors.background.profile,
                            cursor: 'pointer',
                            transition: 'background-color 0.2s'
                        }}
                    >
                        <div style={{
                            width: '32px',
                            height: '32px',
                            borderRadius: '50%',
                            backgroundColor: theme.colors.secondary,
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'center',
                            color: 'white',
                            fontSize: '0.75rem',
                            flexShrink: 0
                        }}>
                            <ShieldCheck size={16} />
                        </div>
                        {!collapsed && (
                            <div style={{ flex: 1, overflow: 'hidden' }}>
                                <div style={{ fontSize: '0.875rem', fontWeight: 500, color: theme.colors.text.primary }}>Administrator</div>
                            </div>
                        )}
                        {!collapsed && <ChevronRight size={16} color={theme.colors.text.tertiary} />}
                    </div>

                    {isProfileMenuOpen && (
                        <div style={{
                            position: 'absolute',
                            left: '100%',
                            bottom: '0',
                            marginLeft: '10px',
                            backgroundColor: 'white',
                            boxShadow: '0 4px 20px rgba(0, 0, 0, 0.15)',
                            borderRadius: '8px',
                            padding: '0.5rem',
                            zIndex: 100,
                            minWidth: '180px',
                            border: `1px solid ${theme.colors.border.light}`
                        }}>
                            <div
                                onClick={() => { setIsProfileMenuOpen(false); navigate('/app/profile'); }}
                                style={{
                                    display: 'flex',
                                    alignItems: 'center',
                                    gap: '10px',
                                    padding: '0.75rem 1rem',
                                    cursor: 'pointer',
                                    borderRadius: '6px',
                                    color: theme.colors.text.primary,
                                    fontSize: '0.9rem',
                                    transition: 'background-color 0.1s'
                                }}
                                onMouseEnter={(e) => e.currentTarget.style.backgroundColor = theme.colors.background.profile}
                                onMouseLeave={(e) => e.currentTarget.style.backgroundColor = 'transparent'}
                            >
                                <UserCircle size={18} />
                                {appConfig.layout.sidebar.profile.viewProfile}
                            </div>
                            <div
                                onClick={handleLogout}
                                style={{
                                    display: 'flex',
                                    alignItems: 'center',
                                    gap: '10px',
                                    padding: '0.75rem 1rem',
                                    cursor: 'pointer',
                                    borderRadius: '6px',
                                    color: theme.colors.danger,
                                    fontSize: '0.9rem',
                                    transition: 'background-color 0.1s'
                                }}
                                onMouseEnter={(e) => e.currentTarget.style.backgroundColor = '#fff3e0'}
                                onMouseLeave={(e) => e.currentTarget.style.backgroundColor = 'transparent'}
                            >
                                <LogOut size={18} />
                                {appConfig.layout.sidebar.profile.logout}
                            </div>
                        </div>
                    )}
                </div>

                {/* Collapse Toggle */}
                <button
                    onClick={toggleCollapse}
                    style={{
                        display: 'flex',
                        alignItems: 'center',
                        gap: '12px',
                        padding: '0.75rem',
                        marginTop: '0.5rem',
                        border: 'none',
                        background: 'none',
                        cursor: 'pointer',
                        color: theme.colors.text.tertiary,
                        width: '100%',
                        textAlign: 'left'
                    }}
                >
                    {collapsed ? <ChevronsRight size={20} /> : <ChevronsLeft size={20} />}
                    {!collapsed && <span style={{ fontSize: '0.9rem' }}>{appConfig.layout.sidebar.collapseLabel}</span>}
                </button>
            </div>
        </div>
    );
};

export default Sidebar;

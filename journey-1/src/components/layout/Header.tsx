import { HelpCircle, MoreVertical, LogOut } from 'lucide-react';
import { useState, useRef, useEffect } from 'react';
import { useLocation } from 'react-router-dom';
import { appConfig } from '../../config/appConfig';

function Header() {
    const [isMenuOpen, setIsMenuOpen] = useState(false);
    const location = useLocation();
    const menuRef = useRef<HTMLDivElement>(null);

    useEffect(() => {
        if (!isMenuOpen) return;

        function handleClickOutside(event: MouseEvent) {
            if (menuRef.current && !menuRef.current.contains(event.target as Node)) {
                setIsMenuOpen(false);
            }
        }

        document.addEventListener("mousedown", handleClickOutside);
        return () => {
            document.removeEventListener("mousedown", handleClickOutside);
        };
    }, [isMenuOpen]);

    const handleHelpClick = () => {
        alert("Support coming soon!");
    };

    const handleExit = () => {
        if (window.confirm("Are you sure you want to exit?")) {
            // Since window.close() often fails if not opened by window.open,
            // we redirect to a blank page or a goodbye message.
            window.location.href = "about:blank";
        }
    };

    const toggleMenu = () => {
        setIsMenuOpen(!isMenuOpen);
    };

    return (
        <header style={{
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
            padding: '16px 20px',
            borderBottom: '1px solid #eee',
            backgroundColor: 'white',
            height: '60px',
            position: 'relative', // Needed for absolute positioning of dropdown
            zIndex: 20
        }}>
            <img src={appConfig.landingPage.header.logoSrc} alt={appConfig.landingPage.header.logoAlt} style={{ height: '32px' }} />

            <div style={{ display: 'flex', gap: '16px', alignItems: 'center' }}>
                <button
                    onClick={handleHelpClick}
                    style={{ background: 'none', border: 'none', cursor: 'pointer', padding: 0, display: 'flex' }}
                    aria-label="Help"
                >
                    <HelpCircle size={24} color="#555" />
                </button>

                {location.pathname === '/success' && (
                    <button
                        onClick={handleExit}
                        style={{ background: 'none', border: 'none', cursor: 'pointer', padding: 0, display: 'flex' }}
                        aria-label="Exit"
                        title="Exit Journey"
                    >
                        <LogOut size={24} color="#555" />
                    </button>
                )}

                {location.pathname !== '/success' && (
                    <div style={{ position: 'relative' }} ref={menuRef}>
                        <button
                            onClick={toggleMenu}
                            style={{ background: 'none', border: 'none', cursor: 'pointer', padding: 0, display: 'flex' }}
                            aria-label="More options"
                        >
                            <MoreVertical size={24} color="#555" />
                        </button>

                        {isMenuOpen && (
                            <div style={{
                                position: 'absolute',
                                top: '100%',
                                right: 0,
                                marginTop: '8px',
                                backgroundColor: 'white',
                                border: '1px solid #eee',
                                borderRadius: '8px',
                                boxShadow: '0 4px 12px rgba(0,0,0,0.15)',
                                width: '200px',
                                zIndex: 30,
                                overflow: 'hidden'
                            }}>
                                <button style={{ ...menuItemStyle, color: '#D32F2F' }} onClick={() => alert('Cancel Application')}>
                                    Cancel Application
                                </button>
                            </div>
                        )}
                    </div>
                )}
            </div>
        </header>
    );
}

const menuItemStyle = {
    display: 'block',
    width: '100%',
    padding: '12px 16px',
    textAlign: 'left' as const,
    background: 'none',
    border: 'none',
    borderBottom: '1px solid #f5f5f5',
    fontSize: '14px',
    cursor: 'pointer',
    color: '#333'
};

export default Header;
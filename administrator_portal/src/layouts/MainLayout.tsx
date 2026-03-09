import React from 'react';
import { Outlet } from 'react-router-dom';
import Sidebar from '../components/layout/Sidebar';

const MainLayout: React.FC = () => {
    return (
        <div style={{ display: 'flex', height: '100vh', width: '100vw', overflow: 'hidden' }}>
            <Sidebar />
            <div style={{
                flex: 1,
                backgroundColor: '#f4f5f7',
                overflow: 'auto',
                position: 'relative'
            }}>
                <Outlet />
            </div>
        </div>
    );
};

export default MainLayout;

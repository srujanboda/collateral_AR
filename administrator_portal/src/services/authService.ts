import axios from 'axios';

const rawUrl = import.meta.env.VITE_API_URL || 'https://collateral-ar.onrender.com';
const API_BASE = rawUrl.endsWith('/') ? rawUrl.slice(0, -1) : rawUrl;
const API_URL = `${API_BASE}/api`;

export const authService = {
    login: async (email: string, password: string) => {
        try {
            const response = await axios.post(`${API_URL}/login/`, {
                username: email,
                password: password
            });

            if (response.data.user) {
                localStorage.setItem('user', JSON.stringify(response.data.user));
                localStorage.setItem('userEmail', response.data.user.username);
            }

            return response.data;
        } catch (error: any) {
            if (error.response && error.response.data) {
                throw new Error(error.response.data.error || error.response.data.errors?.username?.[0] || error.response.data.errors?.password?.[0] || 'Login failed');
            }
            throw new Error('Server unreachable. Please check if backend is running.');
        }
    },

    logout: () => {
        localStorage.removeItem('user');
        localStorage.removeItem('userEmail');
    },

    getCurrentUser: () => {
        const user = localStorage.getItem('user');
        return user ? JSON.parse(user) : null;
    }
};

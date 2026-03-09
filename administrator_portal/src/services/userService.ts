import axios from 'axios';

const rawUrl = import.meta.env.VITE_API_URL || 'http://localhost:8000';
const API_BASE = rawUrl.endsWith('/') ? rawUrl.slice(0, -1) : rawUrl;
const API_URL = `${API_BASE}/api`;

export interface User {
    username: string; // This is the email
    name: string;
    organization: string;
    customer: string;
    role: string;
    status: 'Active' | 'Inactive' | 'Suspended';
    created: string;
}

export const userService = {
    listUsers: async (): Promise<User[]> => {
        const response = await axios.get(`${API_URL}/user/list/`);
        return response.data;
    },

    createUser: async (userData: { email: string; name: string; organization: string; customer: string; role: string }) => {
        const response = await axios.post(`${API_URL}/user/create/`, userData);
        return response.data;
    },

    updateUser: async (username: string, updates: Partial<User>) => {
        const response = await axios.patch(`${API_URL}/user/update/`, { username, ...updates });
        return response.data;
    },

    deleteUser: async (username: string) => {
        const response = await axios.delete(`${API_URL}/user/delete/`, { data: { username } });
        return response.data;
    },

    changePassword: async (passwordData: { username: string; current_password: string; new_password: string }) => {
        const response = await axios.post(`${API_URL}/user/change-password/`, passwordData);
        return response.data;
    }
};

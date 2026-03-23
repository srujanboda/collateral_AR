import axios from 'axios';
import { appConfig } from '../config/appConfig';
const rawUrl = appConfig.app.apiBaseUrl;
const API_BASE = rawUrl.endsWith('/') ? rawUrl.slice(0, -1) : rawUrl;

const api = axios.create({
    baseURL: API_BASE,
    headers: {
        'Content-Type': 'application/json',
    },
});

export const applicationService = {
    // Create new applicant
    create: async (data: {
        name: string;
        email: string;
        phone_number: string;
        address: string;
        pincode: string;
        city: string;
        state: string;
        district: string;
        country: string;
    }) => {
        try {
            const response = await api.post('/api/application/create/', data);
            return response.data;
        } catch (error: any) {
            // Axios automatically extracts the error response from Djang
            const message = error.response?.data?.error ||
                JSON.stringify(error.response?.data?.errors) ||
                'Failed to create application';
            throw new Error(message);
        }
    },


    // List all applicants
    list: async () => {
        const response = await api.get('/api/application/list/');
        return response.data;
    },

    // Get single applicant by ID
    getById: async (perfiosId: string) => {
        const response = await api.get(`/api/application/${perfiosId}/`);
        return response.data;
    },

    // Delete applicant
    delete: async (perfiosId: string) => {
        const response = await api.delete('/api/application/delete/', {
            data: { perfios_id: perfiosId }
        });
        return response.data;
    },

    /* 
    // OLD FETCH LOGIC 
    
    create: async (data: {
        name: string;
        email: string;
        phone_number: string;
    }) => {
        const response = await fetch(`${API_BASE}/api/application/create/`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(data),
        });

        const result = await response.json();
        if (!response.ok) {
            throw new Error(result.error || JSON.stringify(result.errors) || 'Failed to create application');
        }
        return result;
    },

    list: async () => {
        const response = await fetch(`${API_BASE}/api/application/list/`);
        if (!response.ok) {
            throw new Error('Failed to fetch applications');
        }
        return await response.json();
    },

    delete: async (perfiosId: string) => {
        const response = await fetch(`${API_BASE}/api/application/delete/`, {
            method: 'DELETE',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ perfios_id: perfiosId }),
        });

        const result = await response.json();
        if (!response.ok) {
            throw new Error(result.error || 'Failed to delete application');
        }
        return result;
    },
    */
};

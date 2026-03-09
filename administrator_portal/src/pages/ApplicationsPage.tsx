import React, { useState, useEffect } from 'react';
import { CheckCircle, Clock, XCircle, Plus, Eye } from 'lucide-react';
import PageHeader from '../components/common/PageHeader';
import StatCard from '../components/data/StatCard';
import Card from '../components/common/Card';
import SearchBar from '../components/common/SearchBar';
import DataTable, { type Column } from '../components/data/DataTable';
import Button from '../components/common/Button';
import DropdownMenu from '../components/common/DropdownMenu';
import { theme } from '../config/theme';
import { appConfig } from '../config/appConfig';
import { applicationService } from '../services/applicationService';
import AddApplicantDialog from '../components/features/AddApplicantDialog';
import ApplicantDetailView from '../components/features/ApplicantDetailView';

// Constants
const API_BASE = `${window.location.protocol}//${window.location.hostname}:8000`;
const documentSteps = [
    { id: 1, label: "Land Records" },
    { id: 2, label: "Ownership Documents" },
    { id: 3, label: "Encumbrance Certificate" },
    { id: 4, label: "Building Plan" },
];

const ApplicationsPage: React.FC = () => {
    // State
    const [searchQuery, setSearchQuery] = useState('');
    const [isAddApplicantOpen, setIsAddApplicantOpen] = useState(false);
    const [selectedApplicant, setSelectedApplicant] = useState<any | null>(null);
    const [isLoading, setIsLoading] = useState(false);
    const [applicants, setApplicants] = useState<any[]>([]);

    // Effects
    useEffect(() => {
        fetchApplicants();
    }, []);

    // WebSocket Effect
    useEffect(() => {
        const rawUrl = import.meta.env.VITE_API_URL || 'http://localhost:8000';
        const wsUrl = rawUrl.replace(/^http/, 'ws') + '/ws/applicants/';
        console.log('Connecting to WebSocket:', wsUrl);
        const socket = new WebSocket(wsUrl);

        socket.onmessage = (event) => {
            const data = JSON.parse(event.data);
            console.log('WebSocket message received:', data);
            if (data.type === 'applicant_update') {
                // Refresh the list when an update is received
                fetchApplicants();
            }
        };

        socket.onopen = () => console.log('WebSocket connected');
        socket.onclose = () => console.log('WebSocket disconnected');
        socket.onerror = (error) => console.error('WebSocket error:', error);

        return () => {
            socket.close();
        };
    }, []);

    // Handlers
    const fetchApplicants = async () => {
        setIsLoading(true);
        try {
            const data = await applicationService.list();
            setApplicants(data);
        } catch (err: any) {
            console.error('Failed to fetch applicants:', err);
        } finally {
            setIsLoading(false);
        }
    };

    const handleViewApplicant = async (row: any) => {
        setIsLoading(true);
        try {
            const details = await applicationService.getById(row.perfios_id);
            setSelectedApplicant(details);
        } catch (err: any) {
            console.error('Failed to fetch applicant details:', err);
            alert('Failed to fetch details. Please try again.');
        } finally {
            setIsLoading(false);
        }
    };

    const handleDeleteApplicant = async (row: any) => {
        if (window.confirm(`Are you sure you want to delete ${row.name}?`)) {
            try {
                await applicationService.delete(row.perfios_id);
                fetchApplicants();
            } catch (err: any) {
                alert(err.message);
            }
        }
    };

    // Stats Calculation
    const successfulCount = applicants.filter(app => app.status === 'Success').length;
    const pendingCount = applicants.filter(app => app.status === 'Pending' || app.status === 'In Progress').length;
    const failedCount = applicants.filter(app => app.status === 'Failed').length;

    const stats = [
        {
            label: appConfig.pages.applications.stats.successful,
            count: successfulCount.toString(),
            color: '#007a33',
            bgColor: '#e6f4ea',
            icon: <CheckCircle size={24} />
        },
        {
            label: appConfig.pages.applications.stats.pending,
            count: pendingCount.toString(),
            color: '#b06000',
            bgColor: '#fef7e0',
            icon: <Clock size={24} />
        },
        {
            label: appConfig.pages.applications.stats.failed,
            count: failedCount.toString(),
            color: '#c5221f',
            bgColor: '#fce8e6',
            icon: <XCircle size={24} />
        },
    ];

    const columns: Column<any>[] = [
        { header: appConfig.pages.applications.table.headers.name, accessorKey: 'name' },
        { header: appConfig.pages.applications.table.headers.id, accessorKey: 'applicant_id' },
        { header: appConfig.pages.applications.table.headers.perfiosId, accessorKey: 'perfios_id' },
        { header: appConfig.pages.applications.table.headers.email, accessorKey: 'email' },
        { header: appConfig.pages.applications.table.headers.contact, accessorKey: 'phone_number' },
        { header: 'Pincode', accessorKey: 'pincode' },
        { header: 'Country', accessorKey: 'country' },
        { header: 'State', accessorKey: 'state' },
        { header: 'District', accessorKey: 'district' },
        { header: 'City', accessorKey: 'city' },
        { header: appConfig.pages.applications.table.headers.status, accessorKey: 'status', cell: (row) => row.status === 'Success' ? 'Completed' : row.status },
        {
            header: appConfig.pages.applications.table.headers.actions,
            width: '180px',
            cell: (row) => (
                <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                    <DropdownMenu
                        items={[
                            { label: appConfig.common.actions.edit, onClick: () => console.log('Edit', row.perfios_id) },
                            {
                                label: appConfig.common.actions.delete,
                                onClick: () => handleDeleteApplicant(row),
                                color: theme.colors.danger
                            }
                        ]}
                    />
                    <button
                        onClick={() => handleViewApplicant(row)}
                        style={{ background: 'none', border: 'none', cursor: 'pointer', color: theme.colors.primary.main }}
                        title={appConfig.pages.applications.table.actions.viewTooltip}
                        disabled={isLoading}
                    >
                        <Eye size={18} />
                    </button>
                </div>
            )
        }
    ];

    if (selectedApplicant) {
        return (
            <ApplicantDetailView
                applicant={selectedApplicant}
                onBack={() => setSelectedApplicant(null)}
                apiBase={API_BASE}
                documentSteps={documentSteps}
            />
        );
    }

    return (
        <div style={{ padding: '1.5rem' }}>
            <PageHeader
                title={appConfig.pages.applications.title}
                action={
                    <Button onClick={() => setIsAddApplicantOpen(true)}>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                            <Plus size={18} />
                            {appConfig.pages.applications.addButton}
                        </div>
                    </Button>
                }
            />

            {/* Stats Cards */}
            <div style={{
                display: 'grid',
                gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))',
                gap: '1rem',
                marginBottom: '1.5rem'
            }}>
                {stats.map((stat) => (
                    <StatCard
                        key={stat.label}
                        label={stat.label}
                        count={stat.count}
                        icon={stat.icon}
                        color={stat.color}
                        bgColor={stat.bgColor}
                    />
                ))}
            </div>

            <Card>
                {/* Search Bar Header */}
                <div style={{
                    padding: '1rem',
                    borderBottom: '1px solid #f0f0f0',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'flex-start',
                    flexWrap: 'wrap',
                    gap: '1rem'
                }}>
                    <SearchBar
                        value={searchQuery}
                        onChange={setSearchQuery}
                        placeholder={appConfig.pages.applications.searchPlaceholder}
                        width="350px"
                    />
                </div>

                <DataTable
                    columns={columns}
                    data={applicants.filter(app =>
                        (app.name?.toLowerCase().includes(searchQuery.toLowerCase())) ||
                        (app.applicant_id?.toLowerCase().includes(searchQuery.toLowerCase())) ||
                        (app.perfios_id?.toLowerCase().includes(searchQuery.toLowerCase()))
                    )}
                    emptyMessage={appConfig.pages.applications.table.empty}
                    minWidth="800px"
                />
            </Card>

            <AddApplicantDialog
                isOpen={isAddApplicantOpen}
                onClose={() => setIsAddApplicantOpen(false)}
                onSuccess={() => {
                    fetchApplicants();
                }}
            />
        </div>
    );
};

export default ApplicationsPage;

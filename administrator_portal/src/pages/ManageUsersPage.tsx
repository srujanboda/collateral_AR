import React, { useState, useEffect } from 'react';
import { Plus, Pencil } from 'lucide-react';
import PageHeader from '../components/common/PageHeader';
import Button from '../components/common/Button';
import Card from '../components/common/Card';
import SearchBar from '../components/common/SearchBar';
import DataTable, { type Column } from '../components/data/DataTable';
import DropdownMenu from '../components/common/DropdownMenu';
import AddUserDialog from '../components/features/AddUserDialog';
import UserConfirmDialog from '../components/features/UserConfirmDialog';
import EditUserDialog from '../components/features/EditUserDialog';
import { appConfig } from '../config/appConfig';
import { userService, type User } from '../services/userService';

const UsersPage: React.FC = () => {
    const [searchQuery, setSearchQuery] = useState('');
    const [users, setUsers] = useState<User[]>([]);
    const [loading, setLoading] = useState(true);
    const [isAddUserOpen, setIsAddUserOpen] = useState(false);
    const [isEditUserOpen, setIsEditUserOpen] = useState(false);
    const [selectedUserForEdit, setSelectedUserForEdit] = useState<User | null>(null);

    const [confirmAction, setConfirmAction] = useState<{ type: 'delete' | 'deactivate'; user: User } | null>(null);

    const loadUsers = async () => {
        setLoading(true);
        try {
            const data = await userService.listUsers();
            setUsers(Array.isArray(data) ? data : []);
        } catch (err) {
            console.error('Failed to load users', err);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        loadUsers();
    }, []);


    const handleEditClick = (user: User) => {
        setSelectedUserForEdit(user);
        setIsEditUserOpen(true);
    };

    const handleStatusChange = async (username: string, newStatus: User['status']) => {
        try {
            await userService.updateUser(username, { status: newStatus });
            loadUsers();
        } catch (err) {
            alert('Failed to update status');
        }
    };

    const handleConfirmAction = async () => {
        if (!confirmAction) return;

        try {
            if (confirmAction.type === 'delete') {
                await userService.deleteUser(confirmAction.user.username);
            } else {
                await handleStatusChange(confirmAction.user.username, 'Inactive');
            }
            setConfirmAction(null);
            loadUsers();
        } catch (err) {
            alert(`Failed to ${confirmAction.type} user`);
        }
    };

    const columns: Column<User>[] = [
        {
            header: appConfig.pages.manageUsers.table.headers.name,
            accessorKey: 'name',
            cell: (user) => user.name || 'N/A'
        },
        {
            header: appConfig.pages.manageUsers.table.headers.email,
            accessorKey: 'username',
            cell: (user) => user.username
        },
        {
            header: appConfig.pages.manageUsers.table.headers.organization,
            accessorKey: 'organization',
            cell: (user) => user.organization || 'N/A'
        },
        {
            header: appConfig.pages.manageUsers.table.headers.customer,
            accessorKey: 'customer',
            cell: (user) => user.customer || 'N/A'
        },
        {
            header: appConfig.pages.manageUsers.table.headers.role,
            accessorKey: 'role',
            cell: (user) => user.role
        },
        {
            header: appConfig.pages.manageUsers.table.headers.created,
            accessorKey: 'created'
        },
        {
            header: appConfig.pages.manageUsers.table.headers.status,
            accessorKey: 'status',
            cell: (user) => (
                <span style={{
                    padding: '4px 8px',
                    borderRadius: '12px',
                    fontSize: '0.75rem',
                    fontWeight: 500,
                    backgroundColor:
                        user.status === 'Active' ? '#e6f4ea' :
                            user.status === 'Inactive' ? '#fce8e6' : '#fff3e0',
                    color:
                        user.status === 'Active' ? '#1e7e34' :
                            user.status === 'Inactive' ? '#d93025' : '#e65100'
                }}>
                    {user.status}
                </span>
            )
        },
        {
            header: '',
            width: '80px',
            cell: (user) => {
                const menuItems = [];
                if (user.status === 'Active') {
                    menuItems.push({ label: 'Deactivate', onClick: () => setConfirmAction({ type: 'deactivate', user }) });
                    menuItems.push({ label: appConfig.common.actions.delete, onClick: () => setConfirmAction({ type: 'delete', user }) });
                } else {
                    menuItems.push({ label: 'Activate', onClick: () => handleStatusChange(user.username, 'Active') });
                    menuItems.push({ label: appConfig.common.actions.delete, onClick: () => setConfirmAction({ type: 'delete', user }) });
                }

                return (
                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                        <button
                            onClick={() => handleEditClick(user)}
                            style={{
                                border: 'none',
                                background: 'none',
                                cursor: 'pointer',
                                color: '#666',
                                padding: '4px',
                                display: 'flex',
                                alignItems: 'center',
                                justifyContent: 'center'
                            }}
                        >
                            <Pencil size={16} />
                        </button>
                        <DropdownMenu items={menuItems} />
                    </div>
                );
            }
        }
    ];


    const emptyState = (
        <>
            <div style={{ marginBottom: '0.5rem' }}>{appConfig.pages.manageUsers.table.empty}</div>
            <div style={{ fontSize: '0.8rem', color: '#999' }}>{appConfig.pages.manageUsers.table.emptySubtext}</div>
        </>
    );

    const filteredUsers = users.filter(user =>
        (user.name?.toLowerCase() || '').includes(searchQuery.toLowerCase()) ||
        (user.username?.toLowerCase() || '').includes(searchQuery.toLowerCase()) ||
        (user.customer?.toLowerCase() || '').includes(searchQuery.toLowerCase())
    );

    if (loading && users.length === 0) {
        return <div style={{ padding: '2rem', textAlign: 'center' }}>Loading users...</div>;
    }

    return (
        <div style={{ padding: '2rem' }}>
            <PageHeader
                title="Manage Users"
                action={
                    <Button onClick={() => setIsAddUserOpen(true)}>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                            <Plus size={18} />
                            {appConfig.pages.manageUsers.addButton}
                        </div>
                    </Button>
                }
            />

            <div style={{ marginBottom: '1rem' }}>
                <SearchBar
                    value={searchQuery}
                    onChange={setSearchQuery}
                    placeholder={appConfig.pages.manageUsers.searchPlaceholder}
                />
            </div>

            <Card>
                <DataTable
                    columns={columns}
                    data={filteredUsers}
                    emptyMessage={emptyState}
                    minWidth="900px"
                />

                <div style={{
                    padding: '1rem',
                    borderTop: '1px solid #e0e0e0',
                    display: 'flex',
                    justifyContent: 'flex-end',
                    fontSize: '0.8rem',
                    color: '#666'
                }}>
                    Showing {filteredUsers.length} of {users.length} items
                </div>
            </Card>

            <AddUserDialog
                isOpen={isAddUserOpen}
                onClose={() => setIsAddUserOpen(false)}
                onSuccess={loadUsers}
            />

            <EditUserDialog
                user={selectedUserForEdit}
                isOpen={isEditUserOpen}
                onClose={() => {
                    setIsEditUserOpen(false);
                    setSelectedUserForEdit(null);
                }}
                onSuccess={loadUsers}
            />

            <UserConfirmDialog
                confirmAction={confirmAction}
                onClose={() => setConfirmAction(null)}
                onConfirm={handleConfirmAction}
            />
        </div>
    );
};

export default UsersPage;

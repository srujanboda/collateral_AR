import logo from '../assets/Logo.svg';
import collapsedLogo from '../assets/SidebarSmallLogo.jpg';
import loginBanner from '../assets/login-banner.png';

export const appConfig = {
    app: {
        name: 'Collateral AR',
        companyName: 'Perfios',
        logo: logo,
        collapsedLogo: collapsedLogo,
        appName: 'Applicant Management System',
        journeyUrl: 'http://10.84.153.247:5173',
    },
    common: {
        actions: {
            add: 'Add',
            cancel: 'Cancel',
            confirm: 'Confirm',
            delete: 'Delete',
            edit: 'Edit',
            view: 'View',
            save: 'Save',
            discard: 'Discard',
            update: 'Update'
        },
        states: {
            loading: 'Loading...',
            empty: 'No data found',
            success: 'Success',
            error: 'Error'
        },
        validation: {
            required: 'This field is required'
        }
    },
    auth: {
        login: {
            title: 'Sign in',
            bannerImage: loginBanner,
            bannerAlt: 'Collateral AR',
            emailLabel: 'Email ID',
            emailPlaceholder: 'john@example.com',
            passwordLabel: 'Password',
            passwordPlaceholder: '**********',
            forgotPasswordLink: 'Forgot password ?',
            submitButton: 'Login',
            terms: {
                preText: 'I agree to the',
                termsText: 'Terms of service',
                andText: 'and',
                privacyText: 'Privacy policy'
            }
        },
        forgotPassword: {
            title: 'Forgot Password',
            description: 'Please enter the email ID associated with your account to get your password reset instructions',
            emailLabel: 'Email Id',
            emailPlaceholder: 'administrator@perfios.com',
            submitButton: 'Send Reset Instructions',
            backToLogin: 'Back to Login',
            success: {
                title: 'Password reset link sent',
                description: 'Please check your inbox for further instructions'
            }
        }
    },
    layout: {
        sidebar: {
            mainMenuLabel: 'Main Menu',
            navUser: {
                allApps: 'All Applications',
                manageUsers: 'Manage Users',
                settings: 'Settings'
            },
            collapseLabel: 'Collapse',
            profile: {
                viewProfile: 'View Profile',
                logout: 'Logout'
            }
        },
        footer: {
            copyright: '© 2026 Perfios Software Solutions Private Limited'
        }
    },
    pages: {
        applications: {
            title: 'Applications',
            addButton: 'Add Applicants',
            searchPlaceholder: 'Search by ID or Name...',
            stats: {
                successful: 'Completed',
                pending: 'Pending',
                failed: 'Failed'
            },
            table: {
                headers: {
                    name: 'Applicant Name',
                    id: 'Applicant ID',
                    perfiosId: 'Perfios ID',
                    email: 'Email',
                    contact: 'Phone Number',
                    status: 'Status',
                    actions: 'Actions'
                },
                empty: 'No applicants found',
                actions: {
                    viewTooltip: 'View Application',
                    urlLink: 'url'
                }
            },
            dialogs: {
                add: {
                    title: 'Add New Applicant',
                    nameLabel: 'Applicant Name',
                    namePlaceholder: 'Enter applicant name',
                    emailLabel: 'Email',
                    emailPlaceholder: 'Enter email',
                    contactLabel: 'Phone Number',
                    contactPlaceholder: 'Enter phone number',
                    submitButton: 'Add Applicant'
                }
            }
        },
        manageUsers: {
            title: 'Manage Users',
            addButton: 'Add New User',
            searchPlaceholder: 'Search users by name or email',
            table: {
                headers: {
                    name: 'Name',
                    email: 'Email',
                    organization: 'Organization',
                    customer: 'Customer',
                    role: 'Role',
                    created: 'Created',
                    status: 'Status'
                },
                empty: 'No users found',
                emptySubtext: 'Click "Add New User" to create one',
                itemsShowing: 'items'
            },
            dialogs: {
                add: {
                    title: 'Add New User',
                    nameLabel: 'Full Name',
                    namePlaceholder: 'Enter full name',
                    emailLabel: 'Email Address',
                    emailPlaceholder: 'Enter email address',
                    orgLabel: 'Organization',
                    orgPlaceholder: 'Enter organization name',
                    customerLabel: 'Customer',
                    customerPlaceholder: 'Enter customer name',
                    roleLabel: 'Role',
                    submitButton: 'Add User'
                },
                deactivate: {
                    title: 'Disable User',
                    message: 'Are you sure to disable the user?',
                    subMessage: 'You can re-enable the user later, if you wish.',
                    confirmButton: 'Confirm'
                },
                delete: {
                    title: 'Delete User',
                    message: 'Are you sure to delete the user?',
                    subMessage: 'This will delete all the organizations, roles and permissions associated with the user',
                    confirmButton: 'Confirm'
                }
            }
        },
        profile: {
            title: 'View Profile',
            user: {
                name: 'Administrator',
                email: 'administrator@perfios.com'
            },
            sections: {
                password: {
                    title: 'Password',
                    description: 'Strong password helps you prevent unauthorized access. You can modify your password anytime.',
                    changeButton: 'Change Password',
                    dialog: {
                        title: 'Change Password',
                        currentLabel: 'Current Password *',
                        currentPlaceholder: 'Enter current password',
                        newLabel: 'New Password *',
                        newPlaceholder: 'Enter new password',
                        confirmLabel: 'Confirm New Password *',
                        confirmPlaceholder: 'Confirm new password',
                        submitButton: 'Update Password',
                        errors: {
                            currentRequired: 'Please enter your current password',
                            newRequired: 'Please enter a new password',
                            confirmRequired: 'Please confirm your new password',
                            mismatch: 'New passwords do not match'
                        },
                        successMessage: 'Password updated successfully!'
                    }
                },
                organisations: {
                    title: 'My Organisations',
                    table: {
                        headers: {
                            name: 'Organisation Name',
                            role: 'Role',
                            permission: 'Permission'
                        },
                        empty: 'No organisations found'
                    }
                }
            }
        }
    }
};

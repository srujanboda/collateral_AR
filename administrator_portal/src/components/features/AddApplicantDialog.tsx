import React, { useState, useEffect } from 'react';
import DialogBox from '../common/DialogBox';
import Input from '../common/Input';
import Button from '../common/Button';
import { theme } from '../../config/theme';
import { appConfig } from '../../config/appConfig';
import { applicationService } from '../../services/applicationService';

interface AddApplicantDialogProps {
    isOpen: boolean;
    onClose: () => void;
    onSuccess: () => void;
}

const AddApplicantDialog: React.FC<AddApplicantDialogProps> = ({
    isOpen,
    onClose,
    onSuccess
}) => {
    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState<string | null>(null);
    const [availableCities, setAvailableCities] = useState<string[]>([]);
    const [isFetchingLocation, setIsFetchingLocation] = useState(false);

    const [newApplicant, setNewApplicant] = useState({
        name: '',
        email: '',
        phone_number: '',
        pincode: '',
        address: '',
        city: '',
        state: '',
        district: '',
        country: 'IN' // Default to India
    });

    // 📍 Pincode Auto-Fetch Logic
    useEffect(() => {
        if (newApplicant.pincode.length >= 5) {
            fetchLocation(newApplicant.pincode);
        } else {
            setAvailableCities([]);
            setNewApplicant(prev => ({
                ...prev,
                city: '',
                state: '',
                district: ''
            }));
        }
    }, [newApplicant.pincode]);

    const fetchLocation = async (pincode: string) => {
        setIsFetchingLocation(true);
        setError(null);
        try {
            const response = await applicationService.lookupPincode(pincode, newApplicant.country);

            if (response.status === 'Success') {
                const { state, district, cities } = response.data;

                setAvailableCities(cities);
                setNewApplicant(prev => ({
                    ...prev,
                    state: state,
                    district: district,
                    city: cities.length === 1 ? cities[0] : ''
                }));
            }
        } catch (err: any) {
            console.error('Failed to fetch pincode details:', err);
            if (pincode.length >= 6) {
                setError(err.message || 'Invalid Zipcode');
            }
            setAvailableCities([]);
        } finally {
            setIsFetchingLocation(false);
        }
    };

    const handleAddApplicant = async () => {
        if (!newApplicant.name || !newApplicant.email || !newApplicant.phone_number || !newApplicant.pincode || !newApplicant.address || !newApplicant.city) {
            setError('Please fill all fields, including Location details');
            return;
        }

        setIsLoading(true);
        setError(null);
        try {
            await applicationService.create(newApplicant);
            // Reset form
            setNewApplicant({
                name: '', email: '', phone_number: '',
                pincode: '', address: '', city: '',
                state: '', district: '', country: 'IN'
            });
            onSuccess();
            onClose();
        } catch (err: any) {
            setError(err.message);
        } finally {
            setIsLoading(false);
        }
    };

    return (
        <DialogBox
            isOpen={isOpen}
            onClose={onClose}
            title={appConfig.pages.applications.dialogs.add.title}
        >
            <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem', maxHeight: '70vh', overflowY: 'auto', padding: '10px' }}>
                {error && (
                    <div style={{
                        color: theme.colors.danger,
                        padding: '0.5rem',
                        backgroundColor: '#fce8e6',
                        borderRadius: '4px',
                        fontSize: '0.9rem'
                    }}>
                        {error}
                    </div>
                )}

                {/* Basic Info */}
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem' }}>
                    <Input
                        label={appConfig.pages.applications.dialogs.add.nameLabel}
                        placeholder={appConfig.pages.applications.dialogs.add.namePlaceholder}
                        value={newApplicant.name}
                        onChange={(e) => setNewApplicant({ ...newApplicant, name: e.target.value })}
                        disabled={isLoading}
                    />
                    <Input
                        label={appConfig.pages.applications.dialogs.add.emailLabel}
                        placeholder={appConfig.pages.applications.dialogs.add.emailPlaceholder}
                        value={newApplicant.email}
                        onChange={(e) => setNewApplicant({ ...newApplicant, email: e.target.value })}
                        disabled={isLoading}
                    />
                </div>

                {/* Contact & Country */}
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem' }}>
                    <Input
                        label={appConfig.pages.applications.dialogs.add.contactLabel}
                        placeholder={appConfig.pages.applications.dialogs.add.contactPlaceholder}
                        value={newApplicant.phone_number}
                        onChange={(e) => setNewApplicant({ ...newApplicant, phone_number: e.target.value })}
                        disabled={isLoading}
                    />
                    <div style={{ display: 'flex', flexDirection: 'column', gap: '4px' }}>
                        <label style={{ fontSize: '0.875rem', fontWeight: '500', color: '#555' }}>Country</label>
                        <select
                            style={{
                                padding: '0.6rem',
                                border: '1px solid #ddd',
                                borderRadius: '8px',
                                backgroundColor: 'white',
                                fontSize: '0.9rem'
                            }}
                            value={newApplicant.country}
                            onChange={(e) => setNewApplicant({ ...newApplicant, country: e.target.value })}
                            disabled={isLoading}
                        >
                            <option value="IN">India (IN)</option>
                            <option value="US">USA (US)</option>
                            <option value="GB">UK (GB)</option>
                            <option value="CA">Canada (CA)</option>
                            <option value="AU">Australia (AU)</option>
                        </select>
                    </div>
                </div>

                {/* Address & Zipcode */}
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem' }}>
                    <Input
                        label="Zipcode / Pincode"
                        placeholder="Enter code"
                        value={newApplicant.pincode}
                        onChange={(e) => setNewApplicant({ ...newApplicant, pincode: e.target.value.toUpperCase().slice(0, 10) })}
                        disabled={isLoading}
                    />
                    <Input
                        label="Building / Street"
                        placeholder="e.g. #123, Main St"
                        value={newApplicant.address}
                        onChange={(e) => setNewApplicant({ ...newApplicant, address: e.target.value })}
                        disabled={isLoading}
                    />
                </div>

                {isFetchingLocation && <div style={{ fontSize: '0.8rem', color: theme.colors.primary.main }}>Fetching location details...</div>}

                {/* Auto-filled Location Data */}
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem' }}>
                    <div style={{ display: 'flex', flexDirection: 'column', gap: '4px' }}>
                        <label style={{ fontSize: '0.875rem', fontWeight: '500', color: '#555' }}>City / Area</label>
                        <select
                            style={{
                                padding: '0.6rem',
                                border: '1px solid #ddd',
                                borderRadius: '8px',
                                backgroundColor: 'white',
                                fontSize: '0.9rem'
                            }}
                            value={newApplicant.city}
                            onChange={(e) => setNewApplicant({ ...newApplicant, city: e.target.value })}
                            disabled={isLoading || availableCities.length === 0}
                        >
                            <option value="">Select City/Area</option>
                            {availableCities.map(city => (
                                <option key={city} value={city}>{city}</option>
                            ))}
                        </select>
                    </div>
                    <Input
                        label="State / Province"
                        value={newApplicant.state}
                        readOnly
                    />
                </div>

                <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '1rem', marginTop: '1rem' }}>
                    <Button
                        variant="secondary"
                        onClick={onClose}
                        disabled={isLoading}
                    >
                        {appConfig.common.actions.cancel}
                    </Button>
                    <Button onClick={handleAddApplicant} disabled={isLoading || isFetchingLocation}>
                        {isLoading ? 'Adding...' : appConfig.pages.applications.dialogs.add.submitButton}
                    </Button>
                </div>
            </div>
        </DialogBox>
    );
};

export default AddApplicantDialog;

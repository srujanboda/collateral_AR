import PerfiosLogo from '../assets/perfios-logo.png';
import AcmeLogo from '../assets/acme-logo.png';

export const appConfig = {
    landingPage: {
        header: {
            logoSrc: AcmeLogo,
            logoAlt: "Acme"
        },
        title: "Share Property Documents",
        description: "Before you proceed, be ready with all the property documents listed below",
        documents: [
            { id: 1, label: "Land Records" },
            { id: 2, label: "Ownership Document" },
            { id: 3, label: "Encumbrance Certificate" },
            { id: 4, label: "Building Plan" },
        ],
        securityBanner: {
            collapsedText: "Your data is safe.",
            expandedTitle: "Your data is safe and never stored",
            expandedDescription: "We never share or store your credentials.",
            expandedDetail: "We use them once to get your account details and give you the best possible solutions."
        },
        buttons: {
            startUpload: "Start Uploading Documents >"
        }
    },
    uploadPage: {
        steps: [
            { id: 1, label: "Land Records" },
            { id: 2, label: "Ownership Documents" },
            { id: 3, label: "Encumbrance Certificate" },
            { id: 4, label: "Building Plan" },
        ],
        titlePrefix: "Upload",
        subtitle: "You can upload multiple files or as a ZIP",
        infoBoxPrefix: "Upload all pages of your",
        dropzoneText: "Click to upload",
        buttons: {
            uploadMore: "+ Upload More Files",
            next: "Next",
            finish: "Finish"
        },
        errors: {
            sizeLimit: (limit: number) => `Some files exceed the ${limit}MB limit and were not added.`,
            allStepsRequired: "Please upload documents for all steps to proceed.",
        }
    },
    successPage: {
        title: "Application Submitted!",
        message: "Your documents have been securely uploaded.",
        applicationIdLabel: "Application ID:",
        summaryTitle: "Submission Summary",
        buttons: {
            home: "Back to Home"
        }
    },
    apiBaseUrl: import.meta.env.VITE_API_URL || 'https://collateral-ar.onrender.com',
    footer: {
        poweredByText: "Powered by",
        logoSrc: PerfiosLogo,
        logoAlt: "Perfios"
    }
};

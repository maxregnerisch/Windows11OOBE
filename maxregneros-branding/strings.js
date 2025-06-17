// MaxRegneRos Custom String Resources
// Replacing Microsoft/Windows branding with MaxRegneRos branding

const MaxRegneRosStrings = {
    // Welcome and Setup Messages
    welcomeTitle: "Welcome to MaxRegneRos",
    welcomeSubtitle: "Let's get your MaxRegneRos experience set up",
    setupTitle: "Setting up MaxRegneRos",
    setupSubtitle: "This will only take a few minutes",
    
    // Region and Language
    regionTitle: "Choose your region",
    regionSubtitle: "MaxRegneRos will use this to customize your experience",
    languageTitle: "Select your language",
    languageSubtitle: "MaxRegneRos supports multiple languages",
    
    // Network Setup
    networkTitle: "Connect to the internet",
    networkSubtitle: "MaxRegneRos works best when connected",
    networkSkip: "Skip for now",
    networkConnect: "Connect",
    
    // Account Setup
    accountTitle: "Create your MaxRegneRos account",
    accountSubtitle: "Your personal gateway to the MaxRegneRos ecosystem",
    accountUsername: "Choose your username",
    accountPassword: "Create a secure password",
    accountConfirm: "Confirm your password",
    
    // Privacy and Settings
    privacyTitle: "Your privacy matters",
    privacySubtitle: "MaxRegneRos puts you in control of your data",
    privacyCustomize: "Customize settings",
    privacyAccept: "Accept recommended settings",
    
    // Windows Hello / Biometrics
    helloTitle: "Secure your MaxRegneRos experience",
    helloSubtitle: "Set up biometric authentication for enhanced security",
    helloFace: "Set up face recognition",
    helloFingerprint: "Set up fingerprint",
    helloSkip: "Skip for now",
    
    // Apps and Features
    appsTitle: "MaxRegneRos Essential Apps",
    appsSubtitle: "Get started with these recommended applications",
    appsInstall: "Install selected apps",
    appsSkip: "Skip app installation",
    
    // Completion
    completeTitle: "Welcome to MaxRegneRos!",
    completeSubtitle: "Your system is ready to use",
    completeMessage: "Enjoy your personalized MaxRegneRos experience",
    
    // Buttons and Actions
    next: "Next",
    back: "Back",
    skip: "Skip",
    finish: "Finish",
    continue: "Continue",
    cancel: "Cancel",
    retry: "Try again",
    
    // Error Messages
    errorTitle: "Something went wrong",
    errorSubtitle: "MaxRegneRos encountered an issue during setup",
    errorRetry: "Let's try that again",
    errorSkip: "Skip this step",
    
    // Legal and Terms
    termsTitle: "MaxRegneRos Terms of Service",
    termsAccept: "I accept the terms and conditions",
    privacyPolicy: "Privacy Policy",
    termsOfService: "Terms of Service",
    
    // System Information
    systemInfo: "MaxRegneRos System Information",
    version: "MaxRegneRos Version",
    build: "Build",
    
    // Branding
    brandName: "MaxRegneRos",
    brandTagline: "Your Personalized Computing Experience",
    brandCopyright: "© 2024 MaxRegneRos. All rights reserved.",
    
    // Custom Apps (to be integrated)
    customApps: {
        maxregnerosHub: {
            name: "MaxRegneRos Hub",
            description: "Central hub for all MaxRegneRos services and features"
        },
        maxregnerosStore: {
            name: "MaxRegneRos Store",
            description: "Discover and install apps from the MaxRegneRos ecosystem"
        },
        maxregnerosCloud: {
            name: "MaxRegneRos Cloud",
            description: "Sync your files and settings across all your devices"
        },
        maxregnerosSecure: {
            name: "MaxRegneRos Secure",
            description: "Advanced security and privacy protection tools"
        }
    }
};

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = MaxRegneRosStrings;
}

// Global assignment for browser usage
if (typeof window !== 'undefined') {
    window.MaxRegneRosStrings = MaxRegneRosStrings;
}

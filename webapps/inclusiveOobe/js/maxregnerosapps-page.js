// MaxRegneRos Apps OOBE Page
define(['lib/knockout', 'legacy/bridge', 'legacy/events', 'legacy/core'], function (ko, bridge, constants, core) {
    class MaxRegneRosAppsViewModel {
        constructor(resourceStrings, targetPersonality, appResult, isInternetAvailable) {
            // Initialize observables
            this.resourceStrings = resourceStrings;
            this.targetPersonality = targetPersonality;
            this.appResult = appResult;
            this.isInternetAvailable = isInternetAvailable;

            // Page content
            this.title = ko.observable("MaxRegneRos Essential Apps");
            this.subtitle = ko.observable("Get started with these recommended applications");
            this.introText = ko.observable("Select the MaxRegneRos apps you'd like to install. These apps are designed to enhance your MaxRegneRos experience.");
            this.summaryText = ko.observable("Selected apps will be installed after setup completes. You can always install more apps later from the MaxRegneRos Store.");

            // Apps data
            this.apps = ko.observableArray([
                {
                    id: 'maxregneros-hub',
                    name: 'MaxRegneRos Hub',
                    description: 'Central hub for all MaxRegneRos services, settings, and features. Your command center for the MaxRegneRos ecosystem.',
                    iconClass: 'icon-windowsLogo',
                    selected: ko.observable(true), // Pre-selected as essential
                    essential: true
                },
                {
                    id: 'maxregneros-store',
                    name: 'MaxRegneRos Store',
                    description: 'Discover and install apps, themes, and extensions from the MaxRegneRos ecosystem.',
                    iconClass: 'icon-onedrive',
                    selected: ko.observable(true),
                    essential: false
                },
                {
                    id: 'maxregneros-cloud',
                    name: 'MaxRegneRos Cloud',
                    description: 'Sync your files, settings, and preferences across all your MaxRegneRos devices.',
                    iconClass: 'icon-shield',
                    selected: ko.observable(false),
                    essential: false
                },
                {
                    id: 'maxregneros-secure',
                    name: 'MaxRegneRos Secure',
                    description: 'Advanced security and privacy protection tools to keep your data safe.',
                    iconClass: 'icon-lock',
                    selected: ko.observable(false),
                    essential: false
                },
                {
                    id: 'maxregneros-media',
                    name: 'MaxRegneRos Media',
                    description: 'Enhanced media player with support for all popular formats and streaming services.',
                    iconClass: 'icon-checkmark',
                    selected: ko.observable(false),
                    essential: false
                },
                {
                    id: 'maxregneros-productivity',
                    name: 'MaxRegneRos Productivity Suite',
                    description: 'Complete office suite with document editing, spreadsheets, and presentation tools.',
                    iconClass: 'icon-keyboard',
                    selected: ko.observable(false),
                    essential: false
                }
            ]);

            // Navigation buttons
            this.flexEndButtons = [
                {
                    buttonText: "Install Selected Apps",
                    buttonType: "button",
                    isPrimaryButton: true,
                    autoFocus: false,
                    buttonClickHandler: () => {
                        this.onInstallApps();
                    }
                }
            ];

            this.flexStartHyperLinks = [
                {
                    hyperlinkText: "Skip app installation",
                    handler: () => {
                        this.onSkipApps();
                    }
                }
            ];

            // Page actions
            this.pageDefaultAction = () => {
                this.onInstallApps();
            };

            this.optinHotKey = () => {
                this.onInstallApps();
            };
        }

        toggleApp(app) {
            // Don't allow deselecting essential apps
            if (app.essential && app.selected()) {
                return;
            }
            app.selected(!app.selected());
        }

        onInstallApps() {
            try {
                // Get selected apps
                const selectedApps = this.apps().filter(app => app.selected()).map(app => ({
                    id: app.id,
                    name: app.name,
                    essential: app.essential
                }));

                // Store selected apps for installation
                CloudExperienceHost.Storage.SharableData.addValue("MaxRegneRosSelectedApps", JSON.stringify(selectedApps));

                // Log telemetry
                CloudExperienceHost.Telemetry.logEvent("MaxRegneRosAppsSelected", {
                    selectedCount: selectedApps.length,
                    selectedApps: selectedApps.map(app => app.id).join(',')
                });

                // Navigate to next page
                bridge.invoke("CloudExperienceHost.goNext");
            } catch (error) {
                console.error("Error installing MaxRegneRos apps:", error);
                // Continue anyway
                bridge.invoke("CloudExperienceHost.goNext");
            }
        }

        onSkipApps() {
            try {
                // Only install essential apps
                const essentialApps = this.apps().filter(app => app.essential).map(app => ({
                    id: app.id,
                    name: app.name,
                    essential: app.essential
                }));

                CloudExperienceHost.Storage.SharableData.addValue("MaxRegneRosSelectedApps", JSON.stringify(essentialApps));

                // Log telemetry
                CloudExperienceHost.Telemetry.logEvent("MaxRegneRosAppsSkipped", {
                    essentialCount: essentialApps.length
                });

                // Navigate to next page
                bridge.invoke("CloudExperienceHost.goNext");
            } catch (error) {
                console.error("Error skipping MaxRegneRos apps:", error);
                // Continue anyway
                bridge.invoke("CloudExperienceHost.goNext");
            }
        }
    }

    return MaxRegneRosAppsViewModel;
});

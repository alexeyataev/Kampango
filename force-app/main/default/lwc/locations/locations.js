import { LightningElement, api } from 'lwc';
import NCT_STYLES from '@salesforce/resourceUrl/NCT_Styles';
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { SESSION_DELIVERY_TYPE_PHYSICAL,
         SESSION_DELIVERY_TYPE_ONLINE,
         SESSION_STATUS_CONFIRMED } from 'c/globalConstansHelper';

export default class Locations extends LightningElement {

    @api isStatusConfirmed;
    @api venues;
    @api sessions;
    sessionsForDisplay;

    connectedCallback() {
        loadStyle(this, NCT_STYLES + '/coursedetail.css')
            .then(() => {
                this.stylesLoaded = true;
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading styles',
                        message: error.message,
                        variant: 'error',
                    }),
                );
            });

        this.sessionsForDisplay = this.removeSessionsNotForDisplay(this.sessions);
        this.venues = this.deduplicateVenues(this.getVenues(this.sessionsForDisplay));
        this.formatVenues();
    }

    formatVenues() {
        let venueIdSessionListMap = this.getVenueToSessionMap(this.sessionsForDisplay);
        let array = this.venues, finalArray = [];
        array.forEach(
            row => {
                if (venueIdSessionListMap.get(row.Id)) {
                    row = Object.assign({ sessions: venueIdSessionListMap.get(row.Id) }, row);
                    finalArray.push(row);
                }
            }
        );
        this.venues = finalArray;
    }

    getVenueToSessionMap(sessionList) {
        let venueIdSessionListMap = new Map();
        sessionList.forEach(
            (row, index) => {
                if (row.Delivery_Type__c === SESSION_DELIVERY_TYPE_PHYSICAL) {

                    if (venueIdSessionListMap.has(row.Location_Id__c)) {
                        let sessionNumbers = venueIdSessionListMap.get(row.Location_Id__c);

                        if (!sessionNumbers.includes('sessions')) {
                            sessionNumbers = sessionNumbers.replace('session', 'sessions');
                        }

                        sessionNumbers = sessionNumbers + ', ' + ++index;
                        venueIdSessionListMap.set(row.Location_Id__c, sessionNumbers);
                    } else {
                        venueIdSessionListMap.set(row.Location_Id__c, 'session ' + ++index);
                    }

                }
            }
        )

        return venueIdSessionListMap;
    }

    deduplicateVenues(venues) {
        let deduplcicatedVenues = new Map();
        venues.forEach(
            row => {
                if (row.Id && !deduplcicatedVenues.has(row.Id)) {
                    deduplcicatedVenues.set(row.Id, row);
                }
            }
        );

        return Array.from(deduplcicatedVenues.values());
    }

    getVenues(sessions) {
        var venueList = [];
        sessions.forEach( row => {
            if (row.Delivery_Type__c === SESSION_DELIVERY_TYPE_PHYSICAL) {
                venueList.push (
                    Object.assign (
                        { StreetAddress: !this.isStatusConfirmed && row.Location_Home_Information__c ? '' : row.Location_Street__c},
                        { Town: row.Location_Town__c },
                        { County: row.Location_County__c },
                        { Postcode: !this.isStatusConfirmed && row.Location_Home_Information__c ? row.Location_Postcode__c.split(' ')[0] : row.Location_Postcode__c },
                        { Id: row.Location_Id__c },
                        { Name: !this.isStatusConfirmed && row.Location_Home_Information__c ? row.Location_Home_Information__c : row. Location_Name__c},
                        { SessionRoomName: row.Session_Room_Name__c || ''}
                    )
                );
            }
        });

        return venueList;
    }

    removeSessionsNotForDisplay(sessionList) {
        let finalArray = [];
        sessionList.forEach(
            row => {

                let isSessionValid = row.Status__c === SESSION_STATUS_CONFIRMED &&
                    (
                        row.Delivery_Type__c === SESSION_DELIVERY_TYPE_PHYSICAL ||
                        row.Delivery_Type__c === SESSION_DELIVERY_TYPE_ONLINE
                    )

                if (isSessionValid) {
                    finalArray.push(row);
                }

            }
        );

        return finalArray;
    }
}
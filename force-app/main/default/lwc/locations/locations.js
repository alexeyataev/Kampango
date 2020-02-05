import { LightningElement, api } from 'lwc';
import NCT_STYLES from '@salesforce/resourceUrl/NCT_Styles';
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Locations extends LightningElement {

    @api locations;
    @api venues;
    @api sessions;
    @api locationHeader;

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

        this.sessions = this.excludeProvisionalSessions(this.sessions);
        this.venues = this.deduplicateVenues(this.venues);
        this.formatVenues();
    }

    formatVenues(){
        let venueIdSessionListMap = this.getVenueToSessionMap(this.sessions);
        let array = this.venues, finalArray = [];
        array.forEach(
            row => {
                if(venueIdSessionListMap.get(row.Id)){
                    row = Object.assign({sessions: venueIdSessionListMap.get(row.Id)}, row);
                    finalArray.push(row);
                }
            }
        );
        this.venues = finalArray;
    }

    getVenueToSessionMap(sessionList){
        let venueIdSessionListMap = new Map();
        sessionList.forEach(
            (row, index) => {
                if(venueIdSessionListMap.has(row.Location_Id__c)){
                    let sessionNumbers = venueIdSessionListMap.get(row.Location_Id__c);
                    if(!sessionNumbers.includes('sessions')){
                        sessionNumbers = sessionNumbers.replace('session', 'sessions');
                    }
                    sessionNumbers = sessionNumbers + ', ' + ++index;
                    venueIdSessionListMap.set(row.Location_Id__c, sessionNumbers);
                } else {
                    venueIdSessionListMap.set(row.Location_Id__c, 'session ' + ++index);
                    
                }
            }
        )
        return venueIdSessionListMap;
    }

    deduplicateVenues(venues){
        let deduplcicatedVenues = new Map();
        venues.forEach(
            row => {
                if(row.Id && !deduplcicatedVenues.has(row.Id)){
                    deduplcicatedVenues.set(row.Id, row);
                }
            }
        );
        return Array.from(deduplcicatedVenues.values());
    }

    excludeProvisionalSessions(sessionList){
        let finalArray = [];
        sessionList.forEach(
            row => {
                if(row.Status__c === 'Confirmed'){
                    finalArray.push(row);
                }
            }
        );
        return finalArray;
    }
}
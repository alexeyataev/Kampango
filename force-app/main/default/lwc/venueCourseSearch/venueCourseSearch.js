import { LightningElement, track, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { VENUE_NAME } from 'c/globalConstansHelper';

const VENUE_LATITUDE_FIELD = 'Venue__c.Location__Latitude__s';
const VENNUE_LONGITUDE_FIELD = 'Venue__c.Location__Longitude__s';

export default class VenueCourseSearch extends LightningElement {
    @api recordId;
    
    @track venueData;
    @track error;


    @wire(getRecord, { recordId: '$recordId', fields: [VENUE_LATITUDE_FIELD, VENNUE_LONGITUDE_FIELD]})
    retrieveVenueData({error, data}) {
        if (data) {
          this.venueData = {
              name: VENUE_NAME,
              value: {
                  latitude: getFieldValue(data, VENUE_LATITUDE_FIELD),
                  longitude: getFieldValue(data, VENNUE_LONGITUDE_FIELD)
              }
          };

        } else if (error) {
            this.errors = error;
        }
    }
}
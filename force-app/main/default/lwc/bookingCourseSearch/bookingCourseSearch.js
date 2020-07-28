import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import { BOOKING_NAME } from 'c/globalConstansHelper';

const BOOKING_BIRTH_DUE_DATE_FIELD = 'Booking__c.Birth_Due_Date__c';
const BOOKING_COURSE_MAIN_VENUE_LATITUDE_FIELD = 'Booking__c.Course__r.Main_Venue__r.Location__Latitude__s';
const BOOKING_COURSE_MAIN_VENUE_LONGITUDE_FIELD = 'Booking__c.Course__r.Main_Venue__r.Location__Longitude__s';

const BOOKING_FIELDS_LIST = [
    BOOKING_BIRTH_DUE_DATE_FIELD,
    BOOKING_COURSE_MAIN_VENUE_LATITUDE_FIELD,
    BOOKING_COURSE_MAIN_VENUE_LONGITUDE_FIELD
]

export default class BookingCourseSearch extends LightningElement {
    @api recordId;

    @track bookingData;
    @track errors;

    @wire(getRecord, { recordId: '$recordId', fields: BOOKING_FIELDS_LIST})
    retrieveRecord({error, data}) {
        if (data) {
          this.bookingData = {
              name: BOOKING_NAME,
              value: {
                  birthDueDate: getFieldValue(data, BOOKING_BIRTH_DUE_DATE_FIELD),
                  latitude: getFieldValue(data, BOOKING_COURSE_MAIN_VENUE_LATITUDE_FIELD),
                  longitude: getFieldValue(data, BOOKING_COURSE_MAIN_VENUE_LONGITUDE_FIELD)
              }
          };

        } else if (error) {
            this.errors = error;
        }
    }
}
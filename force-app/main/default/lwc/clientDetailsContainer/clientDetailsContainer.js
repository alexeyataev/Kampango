import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {CurrentPageReference} from 'lightning/navigation';

const BOOKING_FIELDS = [
    'Booking__c.Primary_Contact__c'
];
const BOOKING_OPTIONAL_FIELDS = [
    'Booking__c.Partner_Contact__c'
];

export default class ClientDetailsContainer extends LightningElement {
    
    @api bookingId;
    @api primaryContactId;
    @api partnerContactId;
    @api partnersAllowed;
    @api valuesLoaded = false;

    @wire (getRecord, {recordId: '$bookingId', fields: BOOKING_FIELDS, optionalFields: BOOKING_OPTIONAL_FIELDS})
    getBooking({error, data}){
        if(error){
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading booking',
                    message,
                    variant: 'error',
                }),
            );
        } else if (data){
            this.primaryContactId = data.fields.Primary_Contact__c.value;
            this.partnerContactId = data.fields.Partner_Contact__c.value;
            this.valuesLoaded = true;
        }
    }

    @wire(CurrentPageReference)
    currentPageReference;

    connectedCallback(){
        this.bookingId = this.currentPageReference.state.bookingId;
    }
}
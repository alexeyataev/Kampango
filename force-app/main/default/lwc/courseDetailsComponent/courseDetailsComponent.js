import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import retrieveRelatedSessions from '@salesforce/apex/CourseDetailController.retrieveRelatedSessions';
import NCT_STYLES from '@salesforce/resourceUrl/NCT_Styles';
import { loadStyle } from 'lightning/platformResourceLoader';

const BOOKING_FIELDS = [
        'Booking__c.Name',
        'Booking__c.Final_Fee__c',
        'Booking__c.First_Name__c',
        'Booking__c.Last_Name__c',
        'Booking__c.PSA_Office__c',
        'Booking__c.Reservation_Expiry_Date__c',
        'Booking__c.Course__c',
        'Booking__c.Course__r.Name',
        'Booking__c.Course__r.Additional_Offer_Information__c',
        'Booking__c.Course__r.Branch__r.Name',
        'Booking__c.Course__r.End_Date__c',
        'Booking__c.Course__r.Main_Venue__r.Name',
        'Booking__c.Course__r.PSA_Area__c',
        'Booking__c.Course__r.Start_Date__c',
        'Booking__c.Course__r.Title__c'
    ];

export default class CourseDetailsComponent extends LightningElement {
    @api additionalOfferInformation;
    @api bookingRecord;
    @api bookingId;
    @api bookingName;
    @api bookingPsaOffice;
    @api expirationDate;
    @api courseId;
    @api courseName;
    @api coursePsaArea;
    @api firstName;
    @api lastName;
    @api startDate;
    @api endDate;
    @api sessions;
    @api courseFee;
    @api mainTown;
    @api venues;
    @api mainVenueName;
    @api allVenues;
    @api stylesLoaded = false;
    @api title;
    @api get valuesLoaded(){return this.bookingId && this.courseId && this.stylesLoaded;}
    @api get venuesLoaded(){return this.sessions;}

    @wire (getRecord, {recordId: '$bookingId', fields: BOOKING_FIELDS})
    retrieveRecord({error, data}){
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
        } else if (data) {
            let date;
            this.bookingRecord = data;
            date = this.bookingRecord.fields.Reservation_Expiry_Date__c.value;
            date = new Date(date);
            this.expirationDate = this.formatDate(date) + ' ' + date.toLocaleString('default', { year: 'numeric' });
            this.bookingName = this.bookingRecord.fields.Name.value;
            this.firstName = this.bookingRecord.fields.First_Name__c.value;
            this.lastName = this.bookingRecord.fields.Last_Name__c.value;
            this.bookingPsaOffice = this.bookingRecord.fields.PSA_Office__c.value;
            this.courseId = this.bookingRecord.fields.Course__c.value;
            this.courseName = this.bookingRecord.fields.Course__r.value.fields.Name.value;
            this.coursePsaArea = this.bookingRecord.fields.Course__r.value.fields.PSA_Area__c.value;
            this.courseFee = this.bookingRecord.fields.Final_Fee__c.value;
            this.additionalOfferInformation = this.bookingRecord.fields.Course__r.value.fields.Additional_Offer_Information__c.value;
            this.mainTown = this.bookingRecord.fields.Course__r.value.fields.Branch__r.value.fields.Name.value;
            this.mainVenueName = this.bookingRecord.fields.Course__r.value.fields.Main_Venue__r.value.fields.Name.value;
            this.title = this.bookingRecord.fields.Course__r.value.fields.Title__c.value;
            date = this.bookingRecord.fields.Course__r.value.fields.Start_Date__c.value;
            date = new Date(date);
            this.startDate = this.formatDate(date);
            date = this.bookingRecord.fields.Course__r.value.fields.End_Date__c.value;
            date = new Date(date);
            this.endDate = this.formatDate(date);
            this.retrieveSessions(this.courseId);
        }
    }

    retrieveSessions(id){
        retrieveRelatedSessions({courseId: id})
        .then(data => {
            this.sessions = data;
        })
        .catch(error => {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading sessions',
                    message,
                    variant: 'error',
                }),
            )
        });
    }

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
    }

    addDateOrdinal(monthDay){
        switch(monthDay.substring(monthDay.length - 1, monthDay.length)){
            case '1':
                if(monthDay !== '11'){
                    monthDay += 'st';
                } else
                    monthDay += 'th';
                break;
            case '2':
                if(monthDay !== '12'){
                    monthDay += 'nd';
                } else
                    monthDay += 'th';
                break;
            case '3':
                if(monthDay !== '13'){
                    monthDay += 'rd';
                } else
                    monthDay += 'th';
                break;
            default:
                monthDay += 'th';
        }
        return monthDay;
    }

    formatDate(dateToBeFormatted){
        return this.addDateOrdinal(dateToBeFormatted.getDate().toString()) + ' ' + dateToBeFormatted.toLocaleString('default', { month: 'long' });
    }

}
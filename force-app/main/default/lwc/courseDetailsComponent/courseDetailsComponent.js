import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import retrieveRelatedSessions from '@salesforce/apex/CourseDetailController.retrieveRelatedSessions';
import NCT_STYLES from '@salesforce/resourceUrl/NCT_Styles';
import { loadStyle } from 'lightning/platformResourceLoader';
import {CurrentPageReference} from 'lightning/navigation';

const BOOKING_FIELDS = [
        'Booking__c.Reservation_Expiry_Date__c',
        'Booking__c.Course__c',
        'Booking__c.First_Name__c',
        'Booking__c.Last_Name__c',
        'Booking__c.Course__r.Start_Date__c',
        'Booking__c.Course__r.End_Date__c',
        'Booking__c.Fee_Override__c',
        'Booking__c.Course__r.Sub_Type__c',
        'Booking__c.Course__r.Main_Venue__r.Town__c'
    ];


export default class CourseDetailsComponent extends LightningElement {

    @api bookingId;
    @api expirationDate;
    @api courseId;
    @api bookingRecord;
    @api firstName;
    @api lastName;
    @api startDate;
    @api endDate;
    @api sessions;
    @api courseFee;
    @api coursetype;
    @api mainTown;
    @api venues;
    @api stylesLoaded = false;
    @api get valuesLoaded(){return this.bookingId && this.courseId && this.stylesLoaded;}
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
            this.bookingRecord = data;
            this.expirationDate = this.bookingRecord.fields.Reservation_Expiry_Date__c.value;
            this.firstName = this.bookingRecord.fields.First_Name__c.value;
            this.lastName = this.bookingRecord.fields.Last_Name__c.value;
            this.startDate = this.bookingRecord.fields.Course__r.value.fields.Start_Date__c.value;
            this.endDate = this.bookingRecord.fields.Course__r.value.fields.End_Date__c.value;
            this.courseId = this.bookingRecord.fields.Course__c.value;
            this.courseFee = this.bookingRecord.fields.Fee_Override__c.value;
            this.coursetype = this.bookingRecord.fields.Course__r.value.fields.Sub_Type__c.value;
            this.mainTown = this.bookingRecord.fields.Course__r.value.fields.Main_Venue__r.value.fields.Town__c.value;
            this.retrieveSessions(this.courseId);
        }
    } 
    sessionColumns = [
        {
            label: 'Day',
            fieldName: 'Date__c',
            type: 'date',
            typeAttributes:{
                weekday: 'short',
                timeZone: 'Europe/London'
            }
        },
        {
            label: 'Date',
            fieldName: 'Date__c',
            type: 'date',
            typeAttributes:{
                month: 'long',
                day: '2-digit',
                timeZone: 'Europe/London'
            }
        },
        {
            label: 'Starts',
            fieldName: 'Start__c',
            type: 'date',
            typeAttributes:{
                hour: '2-digit',
                minute: '2-digit',
                timeZone: 'Europe/London'
            }
        },
        {
            label: 'Ends',
            fieldName: 'End__c',
            type: 'date',
            typeAttributes:{
                hour: '2-digit',
                minute: '2-digit',
                timeZone: 'Europe/London'
            }
        }
    ];   

    retrieveSessions(id){
        retrieveRelatedSessions({courseId: id})
        .then(data => {
            this.sessions = data;
            this.getVenues(data);
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

    @wire(CurrentPageReference)
    currentPageReference;

    connectedCallback(){
        this.bookingId = this.currentPageReference.state.bookingId;
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

    getVenues(sessions){
        var array;
        var sessionMap = new Map();
        array = sessions.map (
            function(row, index){
                if(row.Venue__c){
                    return Object.assign(
                        {street: row.Venue__r.Street_Address__c},
                        {town: row.Venue__r.Town__c},
                        {county: row.Venue__r.County__c},
                        {postcode: row.Venue__r.Postcode__c},
                        {id: row.Venue__c},
                        {name: row.Venue__r.Name},
                        {sessions: index + 1}
                    );
                }
        });
        array = array.filter(
            function(row){
                return row != null;
            }
        );
        array.forEach(
            function (row){
                if(sessionMap.has(row.id)){
                    let record = sessionMap.get(row.id);
                    record.sessions = record.sessions.replace('session', 'sessions');
                    record.sessions = record.sessions + ', ' + row.sessions;
                    sessionMap.set(row.id, record);
                } else {
                    row.sessions = 'session ' + row.sessions;
                    sessionMap.set(row.id, row);
                }
            }
        );
        this.venues = sessionMap.values();
    }

}
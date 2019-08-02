import { LightningElement, api, wire } from 'lwc';
import {getFieldValue} from 'lightning/uiRecordApi';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import retrieveRelatedSessions from '@salesforce/apex/CourseDetailController.retrieveRelatedSessions';

const BOOKING_FIELDS = [
        'Booking__c.Reservation_Expiry_Date__c',
        'Booking__c.Course__c',
        'Booking__c.First_Name__c',
        'Booking__c.Last_Name__c',
        'Booking__c.Course__r.Course_Reference__c',
        'Booking__c.Course__r.Start_Date__c',
        'Booking__c.Course__r.End_Date__c',
        'Booking__c.Course__r.Course_Fee__c',
        'Booking__c.Course__r.Sub_Type__c'
    ];

export default class CourseDetailsComponent extends LightningElement {

    @api bookingId;
    @api expirationDate;
    @api courseId;
    @api bookingRecord;
    @api firstName;
    @api lastName;
    @api courseRef;
    @api startDate;
    @api endDate;
    @api sessions;
    @api courseFee;
    @api coursetype;
    @api get valuesLoaded(){return this.bookingId && this.courseId;}
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
            console.log(JSON.stringify(data));
            this.expirationDate = this.bookingRecord.fields.Reservation_Expiry_Date__c.value;
            this.firstName = this.bookingRecord.fields.First_Name__c.value;
            this.lastName = this.bookingRecord.fields.Last_Name__c.value;
            this.courseRef = this.bookingRecord.fields.Course__r.value.fields.Course_Reference__c.value;
            this.startDate = this.bookingRecord.fields.Course__r.value.fields.Start_Date__c.value;
            this.endDate = this.bookingRecord.fields.Course__r.value.fields.End_Date__c.value;
            this.courseId = this.bookingRecord.fields.Course__c.value;
            this.courseFee = this.bookingRecord.fields.Course__r.value.fields.Course_Fee__c.value;
            this.coursetype = this.bookingRecord.fields.Course__r.value.fields.Sub_Type__c.value;
            this.retrieveSessions(this.courseId);
        }
    } 
    sessionColumns = [
        {
            label: 'Day',
            fieldName: 'Date__c',
            type: 'date',
            typeAttributes:{
                weekday: "short"
            }
        },
        {
            label: 'Date',
            fieldName: 'Date__c',
            type: 'date',
            typeAttributes:{
                month: "long",
                day: "2-digit"
            }
        },
        {
            label: 'Starts',
            fieldName: 'Start__c',
            type: 'date',
            typeAttributes:{
                hour: "2-digit",
                minute: "2-digit"
            }
        },
        {
            label: 'Ends',
            fieldName: 'End__c',
            type: 'date',
            typeAttributes:{
                hour: "2-digit",
                minute: "2-digit"
            }
        }
        // },
        // {
        //     label: 'Notes',
        //     fieldName: 'Notes__c',
        //     type: 'Text'
        // }
    ];   

    retrieveSessions(id){
        retrieveRelatedSessions({courseId: id})
        .then(data => {
            this.sessions = data;
            console.log(JSON.stringify(data));
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

}
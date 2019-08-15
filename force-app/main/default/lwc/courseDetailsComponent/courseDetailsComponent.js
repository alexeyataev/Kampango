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
        'Booking__c.Final_Fee__c',
        'Booking__c.Course__r.Sub_Type__c',
        'Booking__c.Course__r.Main_Venue__r.Town__c',
        'Booking__c.Course__r.Main_Venue__r.Name'
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
    sessions;
    @api formattedSessions;
    @api courseFee;
    @api coursetype;
    @api mainTown;
    @api venues;
    @api mainVenueName;
    allVenues;
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
            this.courseId = this.bookingRecord.fields.Course__c.value;
            this.courseFee = this.bookingRecord.fields.Final_Fee__c.value;
            this.coursetype = this.bookingRecord.fields.Course__r.value.fields.Sub_Type__c.value;
            this.mainTown = this.bookingRecord.fields.Course__r.value.fields.Main_Venue__r.value.fields.Town__c.value;
            this.mainVenueName = this.bookingRecord.fields.Course__r.value.fields.Main_Venue__r.value.fields.Name.value;
            this.retrieveSessions(this.courseId);
        }
    } 
    sessionColumns = [
        {
            fieldName: 'row',
            type: 'number',
            cellAttributes: { alignment: 'center' }
        },
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
            fieldName: 'dateFormatted',
            type: 'string'
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
            this.sessions = data.map(
                function(row, index){
                    return Object.assign(
                        {Date__c: row.Date__c},
                        {dateFormatted: row.Date__c},
                        {Start__c: row.Start__c},
                        {End__c: row.End__c},
                        {row: index + 1},
                        {id: row.Id}
                    );
                }
            );
            this.formatSessions();
            this.getVenues(data);
            this.formatVenues();
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
        var array = sessions.map (
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
        this.allVenues = array;
    }

    formatSessions(){
        var array = this.sessions;
        var monthDay;
        let start, end;
        array.forEach(
            function(row, index){
                let date = new Date(row.dateFormatted);
                monthDay = date.getDate().toString();
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
                let dateStr = monthDay + ' ' + date.toLocaleString('default', { month: 'long' });
                row.dateFormatted = dateStr;
                if(index === 0){
                    start = dateStr;
                }
                if(index === (array.length - 1)){
                    end = dateStr;
                }
            }
        );
        this.startDate = start;
        this.endDate = end;
        this.formattedSessions = array;
    }

    formatVenues(array){
        var sessionMap = new Map();
        var array = this.allVenues;
        array = array.filter(
            function(row){
                return row != null;
            }
        );
        array.forEach(
            function (row){
                if(sessionMap.has(row.id)){
                    let record = sessionMap.get(row.id);
                    if(!record.sessions.includes('sessions')){
                        record.sessions = record.sessions.replace('session', 'sessions');
                    }
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
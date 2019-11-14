import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import retrieveRelatedSessions from '@salesforce/apex/CourseDetailController.retrieveRelatedSessions';
import NCT_STYLES from '@salesforce/resourceUrl/NCT_Styles';
import { loadStyle } from 'lightning/platformResourceLoader';

const BOOKING_FIELDS = [
        'Booking__c.Reservation_Expiry_Date__c',
        'Booking__c.Course__c',
        'Booking__c.First_Name__c',
        'Booking__c.Last_Name__c',
        'Booking__c.Final_Fee__c',
        'Booking__c.Course__r.Sub_Type__c',
        'Booking__c.Course__r.Branch__r.Name',
        'Booking__c.Course__r.Main_Venue__r.Name',
        'Booking__c.Course__r.Start_Date__c',
        'Booking__c.Course__r.End_Date__c',
        'Booking__c.Course__r.Course_Duration__c'
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
    @api courseDuration;
    @api get valuesLoaded(){return this.bookingId && this.courseId && this.stylesLoaded;}
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
                weekday: 'short'
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
            typeAttributes: {
                hour: '2-digit',
                minute: '2-digit',
                timeZone: 'GMT'
            }
        },
        {
            label: 'Ends',
            fieldName: 'End__c',
            type: 'date',
            typeAttributes: {
                hour: '2-digit',
                minute: '2-digit',
                timeZone: 'GMT'
            }
        }
    ];

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
            this.expirationDate = this.bookingRecord.fields.Reservation_Expiry_Date__c.value;
            this.firstName = this.bookingRecord.fields.First_Name__c.value;
            this.lastName = this.bookingRecord.fields.Last_Name__c.value;
            this.courseId = this.bookingRecord.fields.Course__c.value;
            this.courseFee = this.bookingRecord.fields.Final_Fee__c.value;
            this.coursetype = this.bookingRecord.fields.Course__r.value.fields.Sub_Type__c.value;
            this.mainTown = this.bookingRecord.fields.Course__r.value.fields.Branch__r.value.fields.Name.value;
            this.mainVenueName = this.bookingRecord.fields.Course__r.value.fields.Main_Venue__r.value.fields.Name.value;
            this.courseDuration = this.bookingRecord.fields.Course__r.value.fields.Course_Duration__c.value;
            date = this.bookingRecord.fields.Course__r.value.fields.Start_Date__c.value;
            date = new Date(date);
            this.startDate = this.addDateOrdinal(date.getDate().toString()) + ' ' + date.toLocaleString('default', { month: 'long' });
            date = this.bookingRecord.fields.Course__r.value.fields.End_Date__c.value;
            date = new Date(date);
            this.endDate = this.addDateOrdinal(date.getDate().toString()) + ' ' + date.toLocaleString('default', { month: 'long' });
            this.retrieveSessions(this.courseId);
        }
    }

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
                        {id: row.Id},
                        {additionalInfo: row.Additional_Information__c}
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

    connectedCallback(){
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
                    let county = '';
                    if(row.Venue__r.County__c){
                        county = row.Venue__r.County__c;
                    }
                    return Object.assign(
                        {street: row.Venue__r.Street_Address__c},
                        {town: row.Venue__r.Town__c},
                        {county: county},
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
        let array = this.sessions,
            weekdays = new Array('Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'),
            monthDay,
            weekday,
            month;
        array.forEach(
            (row) => {
                let date = new Date(row.dateFormatted);
                monthDay = date.toLocaleString('default', {day: '2-digit'});
                weekday = weekdays[date.getDay()];
                month = date.toLocaleString('default', {month: 'short'});
                let dateStr = weekday + ' ' + monthDay + ' ' + month;
                row.dateFormatted = dateStr;
                row.Start__c = Math.floor(row.Start__c / 3600000) + ':' + (row.Start__c % 3600000 / 60000).toString().padEnd(2, '0');
                row.End__c = Math.floor(row.End__c / 3600000) + ':' + (row.End__c % 3600000 / 60000).toString().padEnd(2, '0');
            }
        );
        this.formattedSessions = array;
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
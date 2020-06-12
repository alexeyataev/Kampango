import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import retrieveRelatedSessions from '@salesforce/apex/CourseDetailController.retrieveRelatedSessions';
import getCourseDetailsInformation from '@salesforce/apex/CourseDetailController.getCourseDetailsInformation';
import NCT_STYLES from '@salesforce/resourceUrl/NCT_Styles';
import { loadStyle } from 'lightning/platformResourceLoader';

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

    loadCourseDetailsInformationByBookingId(id) {
        getCourseDetailsInformation({bookingId: id})
            .then(result => {
                let data = result[0];
                let date;
                date = data.Reservation_Expiry_Date__c;
                date = new Date(date);
                this.expirationDate = this.formatDate(date) + ' ' + date.toLocaleString('default', { year: 'numeric' });
                this.bookingName = data.Name;
                this.firstName = data.First_Name__c;
                this.lastName = data.Last_Name__c;
                this.bookingPsaOffice = data.PSA_Office__c;
                this.courseFee = data.Final_Fee__c;
                this.courseId = data.Course__c;
                this.courseName = data.Course__r.Name || '';
                this.coursePsaArea = data.Course__r.PSA_Area__c || '';
                this.additionalOfferInformation = data.Course__r.Additional_Offer_Information__c || '';
                this.mainTown = data.Course__r.Branch__r.Name || '';
                this.mainVenueName = data.Course__r.Main_Venue_Name__c || '';
                this.title = data.Course__r.Title__c || '';
                date = data.Course__r.Start_Date__c || '';
                date = new Date(date);
                this.startDate = this.formatDate(date);
                date = data.Course__r.End_Date__c;
                date = new Date(date);
                this.endDate = this.formatDate(date);
                this.retrieveSessions(this.courseId);
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
                        title: 'Error loading booking',
                        message,
                        variant: 'error',
                    }),
                );
            });
    }

    retrieveSessions(id) {
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
        this.loadCourseDetailsInformationByBookingId(this.bookingId);

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
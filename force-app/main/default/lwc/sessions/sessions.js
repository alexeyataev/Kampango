import { LightningElement, api } from 'lwc';
import NCT_STYLES from '@salesforce/resourceUrl/NCT_Styles';
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import provisionCourseReunionTextLable from '@salesforce/label/c.Confirmation_Notification_Course_Reunion';

export default class Sessions extends LightningElement {
    provisionCourseReunionText = provisionCourseReunionTextLable;
    courseHasProvisionalReunion = false;
    @api sessions;
    @api sessionHeader;
    @api formattedSessions;

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
        this.formatSessions();
        
    }

    formatSessions(){
        let array = this.sessions,
            weekdays = new Array('Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'),
            monthDay,
            weekday,
            month,
            start,
            end,
            formattedArray = [];
        array.forEach(
            (row, index) => {
                let date = new Date(row.Date__c);
                monthDay = date.toLocaleString('default', {day: '2-digit'});
                weekday = weekdays[date.getDay()];
                month = date.toLocaleString('default', {month: 'short'});
                let dateStr = weekday + ' ' + monthDay + ' ' + month;
                start = Math.floor(row.Start__c / 3600000) + ':' + (row.Start__c % 3600000 / 60000).toString().padEnd(2, '0');
                end = Math.floor(row.End__c / 3600000) + ':' + (row.End__c % 3600000 / 60000).toString().padEnd(2, '0');
                row = Object.assign (
                    {
                        row: ++index,
                        dateFormatted: dateStr,
                        start: start,
                        end: end,
                        deliveryType: row.Delivery_Type__c,
                        additionInformation: row.Additional_Information__c
                    }
                );

                formattedArray.push(row);
            }
        );
        this.formattedSessions = formattedArray;
    }

    excludeProvisionalSessions(sessionList){
        let finalArray = [];
        sessionList.forEach(
            row => {
                if(row.Status__c === 'Confirmed') {
                    finalArray.push(row);
                } else if (row.Type__c === 'Reunion') {
                    this.courseHasProvisionalReunion = true;
                }
            }
        );

        return finalArray;
    }

}
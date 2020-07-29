import { LightningElement, api, track } from 'lwc';
import courseSearchInternalByBranch from '@salesforce/apex/CourseSearchUtility.courseSearchInternalByBranch';
import courseSearchInternalByDistance from '@salesforce/apex/CourseSearchUtility.courseSearchInternalByDistance';

import { ACCOUNT_BRANCH_NAME,
         BOOKING_NAME,
         VENUE_NAME,
         RADIUS_DEFAULT,
         COURSE_URL_FIELD } from 'c/globalConstansHelper';

const columns = [
    {   
        label: 'Name',
        fieldName: 'Id',
        hideDefaultActions:true,
        type:'courseNumberTmp',
        typeAttributes: {
            [ COURSE_URL_FIELD ] : { fieldName: COURSE_URL_FIELD }
        }
    },

    { label: 'Sub Type', fieldName: 'Type', type: 'text', wrapText:true, hideDefaultActions:false},
    { label: 'Delivery Type', fieldName: 'DeliveryMethod', type: 'text', hideDefaultActions:true},
    { label: 'Start Date', fieldName: 'StartDate', type: 'date', hideDefaultActions:true },
    { label: 'End Date ', fieldName: 'EndDate', type: 'date', sortable: true, hideDefaultActions:true},
    { label: 'PSA Area', fieldName: 'PsaArea', type: 'text' , hideDefaultActions:true},
    { label: 'Remaining Places', fieldName: 'RemainingPlaces', type: 'number', cellAttributes: { alignment: 'left' }, hideDefaultActions:true},
    { label: 'Confirmed Places', fieldName: 'ConfirmedPlaces', type: 'number', cellAttributes: { alignment: 'left' }, hideDefaultActions:true},
    { label: 'Status', fieldName: 'Status', type: 'text', hideDefaultActions:true },
    { label: 'Rank', fieldName: 'Rank', type: 'text', hideDefaultActions:true },
];

export default class CourseSearchComponent extends LightningElement {
    @api courseList;
    @api searchCourseParams;
    @api tableCourseData = [];

    @track error;
    @track sortBy;
    @track sortDirection;

    displayHeaderMenuSearchByDistance = false;
    displayHeaderMenuSearchByBranch = false;
    isLoading = false;
    rowOffset = 0;
    columns = columns;
    radius = RADIUS_DEFAULT;
    birthDueDateInputField;
    birthDueDateValue;
    branchNumber;
    isCoursesFound;
    paramsOfDistance;

    distanceRadiusHandleChange(event) {
        this.radius = event.detail.value;
    }

    connectedCallback() {
        switch(this.searchCourseParams.name) {

            case ACCOUNT_BRANCH_NAME : this.getCourseByBranch(this.searchCourseParams.value)
            break;

            case BOOKING_NAME : this.setBookingData(this.searchCourseParams);
            break;

            case VENUE_NAME : this.setVenueData(this.searchCourseParams);
            break;

        }
    }

    getCourseByBranch(branchNumber) {
        this.displayHeaderMenuSearchByBranch = true;
        this.isLoading = true;
        this.branchNumber = branchNumber;

        courseSearchInternalByBranch({ branchId: branchNumber })
        .then(data => {
            this.isLoading = false;
            this.tableCourseData = this.getDataWithCourseUrlField(data);
            this.error = undefined;
            this.isCoursesFound = true;

            if (!this.tableCourseData.length) {
                this.isCoursesFound = false;
            }

        })
        .catch(error => {
            this.tableCourseData = undefined;
            this.isCoursesFound = false;
            this.error = error;
            this.isLoading = false;
        })
    }

    getDataForSearchByDistanse () {
        return {
            latitude: this.paramsOfDistance.latitude || '',
            longitude: this.paramsOfDistance.longitude || '',
            birthDueDate: this.birthDueDateInputField ? this.birthDueDateInputField.value : this.paramsOfDistance.birthDueDate,
            radius: this.radius || RADIUS_DEFAULT
         } 
     }

     getCourseByDistanse(distanseData) {
        this.isLoading = true;

        courseSearchInternalByDistance(distanseData)
        .then(data => {
            this.isLoading = false;
            this.tableCourseData = this.getDataWithCourseUrlField(data);
            this.error = undefined;
            this.isCoursesFound = true;

            if (!this.tableCourseData.length) {
                this.isCoursesFound = false;
            }
        })
        .catch(error => {
            this.tableCourseData = undefined;
            this.isCoursesFound = false;
            this.error = error;
            this.isLoading = false;
        })
    }

    getDataWithCourseUrlField(data) {
        return data.map(index => Object.assign (
                {},
                { [ COURSE_URL_FIELD ]: '/lightning/r/Course/' + index.CourseId + '/view'} ,
                index
            )
        );
    }

    handlerByClickSearchByDate() {
        this.getCourseByDistanse(this.getDataForSearchByDistanse());
    }

    handlerByClickSearchByBranch() {
        this.getCourseByBranch(this.branchInputField.value);
    }

    renderedCallback() {
        this.birthDueDateInputField = this.template.querySelector('.birth_due_date_input_field');
        this.branchInputField = this.template.querySelector('.branch_input_field');
    }

    setVenueData(searchCourseParams) {
        this.displayHeaderMenuSearchByDistance = true;
        this.paramsOfDistance = searchCourseParams.value;
    }

    setBookingData(searchCourseParams) {
        this.birthDueDateValue = searchCourseParams.value.birthDueDate;
        this.displayHeaderMenuSearchByDistance = true;
        this.paramsOfDistance = searchCourseParams.value;
        this.getCourseByDistanse(this.getDataForSearchByDistanse());
    }

    handleSortdata(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(event.detail.fieldName, event.detail.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.tableCourseData));

        let keyValue = (a) => {
            return a[fieldname];
        };

        let isReverse = direction === 'asc' ? 1: -1;

        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';

            return isReverse * ((x > y) - (y > x));
        });

        this.tableCourseData = parseData;
    }
}
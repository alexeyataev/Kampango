import { LightningElement, api, wire, track } from 'lwc';
import courseNameLinkTemplate from './courseNameLinkTemplate.html';

import courseSearchiInternalByBranch from '@salesforce/apex/CourseSearchUtility.courseSearchiInternalByBranch';
import courseSearchInternalByDistance from '@salesforce/apex/CourseSearchUtility.courseSearchInternalByDistance';

import { ACCOUNT_BRANCH_NAME,
         BOOKING_NAME,
         VENUE_NAME,
         DISTANCE_OPTIONS,
         RADIUS_DEFAULT,
         HIDE_FROM_PUBLIC_ACCESS_TRUE} from 'c/globalConstansHelper';



const columns = [
    { label: 'Name', fieldName: 'name', hideDefaultActions:true},
    { label: 'Sub Type', fieldName: 'subType', type: 'text',wrapText: true, hideDefaultActions:true},
    { label: 'Start Date', fieldName: 'startDate', type: 'date',hideDefaultActions:true },
    { label: 'End Date ', fieldName: 'endDate', type: 'date', sortable: true, hideDefaultActions:true},
    { label: 'PSA Area', fieldName: 'psaArea', type: 'text' , hideDefaultActions:true},
    { label: 'Remaining Places', fieldName: 'remainingPlaces', type: 'number', cellAttributes: { alignment: 'left' }, hideDefaultActions:true},
    { label: 'Confirmed Places', fieldName: 'confirmedPlaces', type: 'number', cellAttributes: { alignment: 'left' }, hideDefaultActions:true},
    { label: 'Status', fieldName: 'status', type: 'text', hideDefaultActions:true },
];

export default class CourseSearchComponent extends LightningElement {
    @api courseList;
    @api searchCourseParams;
    @api tableCourseData;

    @track error;

    searchOnVenueObject = false;
    isLoading = false;
    rowOffset = 0;
    columns = columns;
    radius;
    birthDueDate;
    courseNotFound
    paramsOfDistance;

    get distanceOptions() {
        return DISTANCE_OPTIONS;
    }

    handleChange(event) {
        this.radius = event.detail.value;
    }

    connectedCallback() {
        switch(this.searchCourseParams.name) {

            case ACCOUNT_BRANCH_NAME : this.getCourseByBranch(this.searchCourseParams.value)
            break;

            case BOOKING_NAME : this.getCoursesByBookingData(this.searchCourseParams);
            break;

            case VENUE_NAME : this.setVenueData(this.searchCourseParams);
            break;
        }
    }

    getCourseByBranch(branchNumber) {
        this.isLoading = true;
        courseSearchiInternalByBranch({ branchId: branchNumber, hideFromPublicAccess: HIDE_FROM_PUBLIC_ACCESS_TRUE })
        .then(data => {
            this.isLoading = false;
            this.tableCourseData = data;
            this.error = undefined;
            this.courseNotFound = false;

            if (!this.tableCourseData.length) {
                this.courseNotFound = true;
            }

        })
        .catch(error => {
            this.tableCourseData = undefined;
            this.error = error;
            this.isLoading = false;
        })
    }


    getCoursesByBookingData(dataOfSearchByDistance) {
        
      let distanseData = {
          latitude: dataOfSearchByDistance.value.latitude || '',
          longitude: dataOfSearchByDistance.value.longitude,
          birthDueDate: dataOfSearchByDistance.value.birthDueDate || '',
          radius: +this.radius || RADIUS_DEFAULT,
          hideFromPublicAccess: HIDE_FROM_PUBLIC_ACCESS_TRUE
        }

        this.getCourseByDistanse(distanseData);
    }


    getDataForSearchCoursesByDistanseInVenueObject () {
        return {
             latitude: this.paramsOfDistance.latitude || '',
             longitude: this.paramsOfDistance.longitude,
             birthDueDate: this.birthDueDate.value || '',
             radius: +this.radius || RADIUS_DEFAULT,
             hideFromPublicAccess: HIDE_FROM_PUBLIC_ACCESS_TRUE
         } 
     }

     getCourseByDistanse(distanseData) {
        this.isLoading = true;

        courseSearchInternalByDistance(distanseData)
        .then(data => {
            this.isLoading = false;
            this.tableCourseData = data;
            this.error = undefined;
            this.courseNotFound = false;

            if (!this.tableCourseData.length) {
                this.courseNotFound = true;
            }
        })
        .catch(error => {
            this.tableCourseData = undefined;
            this.error = error;
            this.isLoading = false;
        })
    }

    searchHandlerClick() {
        this.getCourseByDistanse(this.getDataForSearchCoursesByDistanseInVenueObject());
    }

    renderedCallback() {
        this.birthDueDate = this.template.querySelector('.birth_due_date');
    }

    setVenueData(searchCourseParams) {
        this.paramsOfDistance = searchCourseParams.value;
        this.searchOnVenueObject = true;
    }

}
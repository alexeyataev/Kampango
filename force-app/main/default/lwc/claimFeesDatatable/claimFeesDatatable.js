import { LightningElement, api, track } from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';

const COLUMNS = [
    { label: 'Name', fieldName: 'Name'},
    { label: 'Course', fieldName: 'Course_Name__c'},
    { label: 'Date', fieldName: 'Date__c', type: 'date-local', typeAttributes: { year:"numeric", month:"numeric", day:"numeric"}},
    { label: 'Fee', fieldName: 'Practitioner_Fees__c', type: 'currency', cellAttributes: { alignment: 'left' }},
];

export default class ClaimFeesDatatable extends LightningElement {
    @api practitioner;
    @api sessions;
    @api registrationFeeRate;
    @api registrationFee;
    @api totalRegistrationFee;
    @api registrationCappedFees;

    @api totalFee;
    @api checkedRows;

    @track columns;

    @track isButtonDisabled = true;
    @track isSessionsPresented = false;
    
    connectedCallback() {
        this.columns = COLUMNS;
    }

    get isDataPresented() {
        return !!this.sessions && this.sessions.length !== 0;
    }

    handleGoNext() {
        this.dispatchEvent(new FlowNavigationNextEvent());
    }

    handleSelectRow(event) {
        this.checkedRows = event.target.getSelectedRows();
        this.isButtonDisabled = this.checkedRows.length === 0;
        this.calculateTotalFee();
    }

    calculateTotalFee() {
        let totalFee = 0;
        this.checkedRows.forEach(element => {
            totalFee += element.Practitioner_Fees__c;
        });
        this.totalFee = totalFee.toFixed(2);
        this.calculateRegistrationFee();
    }

    calculateRegistrationFee() {
        let currentRegistrationFee = 0;
        let totalRegistrationFee = 0;

        currentRegistrationFee = this.totalFee * this.registrationFeeRate;
        totalRegistrationFee =  +this.practitioner.Deducted_Practitioner_Fees__c + currentRegistrationFee;
   
        if(totalRegistrationFee <= this.registrationCappedFees) {
            this.registrationFee = currentRegistrationFee.toFixed(2);
        } else {
            let delta = totalRegistrationFee - this.registrationCappedFees;
            this.registrationFee = currentRegistrationFee - delta;
            this.registrationFee = this.registrationFee < 0 ? 0 : Math.abs(this.registrationFee.toFixed(2));
        }
        this.dispatchEventList();
    }
    dispatchEventList(){
        this.dispatchEvent(new FlowAttributeChangeEvent('totalFee', this.totalFee));
        this.dispatchEvent(new FlowAttributeChangeEvent('registrationFee', this.registrationFee));
        this.dispatchEvent(new FlowAttributeChangeEvent('checkedRows', this.checkedRows));
    }
}
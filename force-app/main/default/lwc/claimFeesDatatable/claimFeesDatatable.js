import { LightningElement, api, track } from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';

const COLUMNS = [
    { label: 'Name', fieldName: 'Name'},
    { label: 'Course', fieldName: 'Course_Name__c'},
    { label: 'Date', fieldName: 'Date__c', type: 'date-local', typeAttributes: { year:"numeric", month:"numeric", day:"numeric"}},
    { label: 'Fee', fieldName: 'Practitioner_Fees__c', type: 'currency', cellAttributes: { alignment: 'left' }},
];

export default class ClaimFeesDatatable extends LightningElement {
    @api sessions;
    @track columns;

    @track isButtonDisabled = true;
    @track isSessionsPresented = false;
    @api checkedRows;
    @api totalFee;

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
        let totalFee = 0;
        this.checkedRows = event.target.getSelectedRows();
        this.isButtonDisabled = this.checkedRows.length === 0;
        this.checkedRows.forEach(element => {
            totalFee += element.Practitioner_Fees__c;
        });
        this.totalFee = totalFee;
        this.dispatchEvent(
            new FlowAttributeChangeEvent('totalFee', this.totalFee)
        );
    }
}
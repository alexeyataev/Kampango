import { LightningElement, api, track } from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';

const columns = [
    { label: 'Name', fieldName: 'Name'},
    { label: 'Course', fieldName: 'Course_Name__c'},
    { label: 'Start', fieldName: 'Start__c', type: 'date', typeAttributes:{ hour: "2-digit", minute: "2-digit"} },
    { label: 'End', fieldName: 'End__c', type: 'date', typeAttributes:{ hour: "2-digit", minute: "2-digit"} },
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
        this.columns = columns;
    }

    get isDataPresented() {
        return !!this.sessions && this.sessions.length !== 0;
    }

    handleGoNext() {
        this.dispatchEvent(new FlowNavigationNextEvent());
    }

    handleSelectRow(event) {
        let _totalFee = 0;
        this.checkedRows = event.target.getSelectedRows();
        this.isButtonDisabled = this.checkedRows.length === 0;
        this.checkedRows.forEach(element => {
            _totalFee += element.Practitioner_Fees__c;
        });
        this.totalFee = _totalFee;
        this.dispatchEvent(
            new FlowAttributeChangeEvent('totalFee', this.totalFee)
        );
    }
}
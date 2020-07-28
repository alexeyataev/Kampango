import { LightningElement, api, wire, track} from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ACCOUNT_BRANCH_NAME } from 'c/globalConstansHelper';

const ACCOUNT_BRANCH_NUMBER_FIELD = 'Account.Branch_Number__c'

export default class BranchCourseSearch extends LightningElement {
    @api recordId;
    
    @track branchData;
    @track errors;

    @wire(getRecord, { recordId: '$recordId', fields: ACCOUNT_BRANCH_NUMBER_FIELD})
    retrieveRecord({error, data}) {
        if (data) {
          this.branchData = {
              name: ACCOUNT_BRANCH_NAME,
              value: getFieldValue(data, ACCOUNT_BRANCH_NUMBER_FIELD)
          };
        } else if (error) {
          this.errors = error;
        }
    }

}
import { LightningElement, api, wire, track} from 'lwc';
import getOptions from '@salesforce/apex/PaymentPlanOptionsController.getOptions';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';

export default class PaymentOptionsTest extends LightningElement {
    @api paymentPlanOptionSelected;
    @api courseFee;
    @api courseStartDate;
    @track isLabelVisible = 'label-hidden';
    @track value = '';
    @track options = [];
    @track dataLoaded = false;
    @track isPayByInstallmentsAvailable = true;

    nextCollectionDate;
    optionsDisplayList = [];
    optionsMap = new Map();

    @wire(getOptions, {
        courseFee: '$courseFee',
        courseStartDate: '$courseStartDate'
    }) wiredPaymentPlanOptions({ error, data }) {
        if (data) {
            data.forEach( element => {
                this.options.push ({ label:element.displayLabel, value: element.numberOfPayments });
                this.optionsMap.set(element.numberOfPayments, {
                    amountFirst:element.amountFirst,
                    amountRecurring:element.amountRecurring,
                    startDate:element.startDate,
                    endDate:element.endDate,
                    displayLabel:element.displayLabel,
                    nextCollectionDate:element.nextCollectionDate
                });
            });

            if (data.length === 0 || data === undefined) {
                this.isPayByInstallmentsAvailable = false;
                this.dataLoaded = true; 

            } else {
                this.isLabelVisible = '';
                this.dataLoaded = true;
                this.nextCollectionDate = new Date(data[0].nextCollectionDate).toLocaleString('default', {day:'numeric', month:'long', year:'numeric'});
            }
            
        } else if (error) {
            this.isPayByInstallmentsAvailable = false;
        }
    }

    chooseOption(e) {
        this.paymentPlanOptionSelected = this.optionsMap.get(e.target.value);
        this.dispatchEvent(new FlowAttributeChangeEvent('paymentPlanOptionSelected', this.paymentPlanOptionSelected));
    }

    @api validate() {
        if(this.paymentPlanOptionSelected === undefined) {
            return {
                isValid: false,
                errorMessage: 'Please select a choice'
            }
        } else {
            return {
                isValid: true
            }
        }
    }
}
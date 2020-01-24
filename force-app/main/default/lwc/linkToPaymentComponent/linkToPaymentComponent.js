import { LightningElement, api, track } from 'lwc';

export default class linkToPaymentComponent extends LightningElement {
    @api paymentLink;
    @track isRedirect = false;

    redirectHandler() {
        this.isRedirect = true;
    }
}
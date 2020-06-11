import { LightningElement, api, wire } from 'lwc';
import NCT_STYLES from '@salesforce/resourceUrl/NCT_Styles';
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import retrieveMarketingPreferences from '@salesforce/apex/BookingJourneyHelper.retrieveMarketingPreferences';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';

export default class MarketingPreferencesComponent extends LightningElement {

    @api individualId;
    @api individualRecord;
    @api email;
    @api sms;
    @api post;
    @api phone;
    @api marketingValues = new Array();
    @api optionsLoaded = false;
    MARKETING_OPTIONS = [
        {label: 'Email', value: 'email'},
        {label: 'Post', value: 'post'},
        {label: 'SMS text', value: 'sms'},
        {label: 'Telephone', value: 'phone'}
    ];

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
    }

    @wire (retrieveMarketingPreferences, {individualId: '$individualId'})
        getPreferences({error, data}) {
            if (data) {
                if (this.email === undefined && this.sms === undefined
                    && this.post === undefined && this.phone === undefined) {
                    this.email = data.Email__c;
                    this.sms = data.SMS__c;
                    this.post = data.Post__c;
                    this.phone = data.Telephone__c;
                }

                if (this.email) {
                    this.marketingValues.push('email');
                }

                if (this.sms) {
                    this.marketingValues.push('sms');
                }

                if (this.post) {
                    this.marketingValues.push('post')
                }

                if (this.phone) {
                    this.marketingValues.push('phone');
                }

                this.dispatchEventList();
                this.optionsLoaded = true;

            } else if (error) {
                let message = 'Unknown error';

                if (Array.isArray(error.body)) {
                    message = error.body.map(e => e.message).join(', ');

                } else if (typeof error.body.message === 'string'){
                    message = error.body.message;
                }

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error occured while loading marketing preferences',
                        message,
                        variant: 'error'
                    })
                );
                
            }
        }

        handleChange(event){
            this.email = false;
            this.post = false;
            this.sms = false;
            this.phone = false;
            this.marketingValues = event.detail.value;
            if (this.marketingValues.includes('email')) {
                this.email = true;
            }

            if (this.marketingValues.includes('post')) {
                this.post = true;
            }

            if (this.marketingValues.includes('sms')){
                this.sms = true;
            }

            if (this.marketingValues.includes('phone')) {
                this.phone = true;
            }

            this.dispatchEventList();
        }

        dispatchEventList() {
            this.dispatchEvent(new FlowAttributeChangeEvent('email', this.email));
            this.dispatchEvent(new FlowAttributeChangeEvent('sms', this.sms));
            this.dispatchEvent(new FlowAttributeChangeEvent('post', this.post));
            this.dispatchEvent(new FlowAttributeChangeEvent('phone', this.phone));
        }


}
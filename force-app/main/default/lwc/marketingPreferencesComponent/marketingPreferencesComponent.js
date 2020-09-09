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

        if (this.individualId) {
            this.getIndividualOptionById(this.individualId);

        } else {
            this.optionsLoaded = true;
        }
    }

    async getIndividualOptionById() {
        let data = await retrieveMarketingPreferences({
            individualId: this.individualId
        })

        if (data) {
            if (this.email === undefined && this.sms === undefined &&
                this.post === undefined && this.phone === undefined) {
                this.email = data.Has_Opted_In_Email__c;
                this.sms = data.Has_Opted_In_SMS__c;
                this.post = data.Has_Opted_In_Post__c;
                this.phone = data.Has_Opted_In_Telephone__c;
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

            this.optionsLoaded = true;
            this.dispatchEventList();
        } else {

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error occured while loading marketing preferences',
                    message: result,
                    variant: 'error'
                })
            );
        }

    }

    handleChange(event) {
        this.email = false;
        this.post = false;
        this.sms = false;
        this.phone = false;
        this.marketingValues = event.detail.value;
        console.log(event.detail.value);
        if (this.marketingValues.includes('email')) {
            this.email = true;
        }

        if (this.marketingValues.includes('post')) {
            this.post = true;
        }

        if (this.marketingValues.includes('sms')) {
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
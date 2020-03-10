import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import NCT_STYLES from '@salesforce/resourceUrl/NCT_Styles';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class MembershipDescription extends LightningElement {
    @api stylesLoaded = false;
    
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

}
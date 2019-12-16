import { LightningElement, track } from 'lwc';
import unsupportedBrowserMessage from '@salesforce/label/c.Unsupported_Browser_Error_Message';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';

export default class СheckBrowserCompatibility extends LightningElement {

    @track isIE = false;

    label = {
        unsupportedBrowserMessage,
    };

    connectedCallback() {
        this.checkForIE();
    }
    checkForIE() {
        const userAgent = navigator.userAgent;
        //IE 10 or older
        let msie = userAgent.indexOf('MSIE ');
        //IE 11
        let trident = userAgent.indexOf('Trident/');
        this.isIE = msie > 0 || trident > 0;

        if(!this.isIE) {
            this.redirectToNextScreen();
        }
    }

    redirectToNextScreen() {
        this.dispatchEvent(new FlowNavigationNextEvent());
    }
}
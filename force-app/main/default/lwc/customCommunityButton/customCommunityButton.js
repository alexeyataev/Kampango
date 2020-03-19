import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class customCommunityButton extends NavigationMixin(LightningElement) {
    @api align;
    @api url;
    @api label;
    @api variant;

    get buttonVariant() {
        return this.variant.toLowerCase();
    }

    get alignClass() {
        return this.align.toLowerCase() === 'left' ? 'left' : 'right';
    }

    navigate() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: this.url
            }
        },
        true // Replaces the current page in your browser history with the URL
      );
    }
}
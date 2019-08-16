import {LightningElement, track, api, wire} from 'lwc';
import NCT_LOGO from '@salesforce/resourceUrl/NCT_Styles';
import { ShowToastEvent} from 'lightning/platformShowToastEvent';
// import createGiftAidDeclaration from '@salesforce/apex/GiftAidDetailController.createGiftAidDeclaration'
import {CurrentPageReference} from 'lightning/navigation';

export default class GiftAidDetailsContainer extends LightningElement {

    // @api giftAidValue = "decline";
    // @track dataSent = false;

    logo = NCT_LOGO + '/nct-landscape-logo-green-grey.png';
    // giftAidLogo = NCT_LOGO + '/Gift-Aid-logo.jpg';
   
    // choseGiftAid(event) {
    //     this.giftAidValue = event.target.value;
    // }

    // createDeclaration() {
    //     if(this.giftAidValue !== 'decline') {
    //         this.dataSent = true;
    //         createGiftAidDeclaration({
    //             value: this.giftAidValue,
    //             bookingId : this.bookingId
    //         })
    //         .then(data => {
    //             this.dataSent = false;
    //                 this.dispatchEvent(
    //                     new ShowToastEvent({
    //                         title: 'Success',
    //                         message: "Gift Aid is created!",
    //                         variant: 'success',
    //                     }),
    //                 )     
    //         })
    //         .catch(error => {
    //             this.dataSent = false;
    //             let message = 'Unknown error';
    //             if (Array.isArray(error.body)) {
    //                 message = error.body.map(e => e.message).join(', ');
    //             } else if (typeof error.body.message === 'string') {
    //                 message = error.body.message;
    //             }
    //             this.dispatchEvent(
    //                 new ShowToastEvent({
    //                     title: 'Error creating Gift Aid',
    //                     message,
    //                     variant: 'error',
    //                 }),
    //             )
    //             this.giftAidValue = 'decline';
    //         });
    //     }
    // }

    // @wire(CurrentPageReference)
    // currentPageReference;

    // connectedCallback() {
    //     this.bookingId = this.currentPageReference.state.bookingId;
    // }

}
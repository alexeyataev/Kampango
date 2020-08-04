import { LightningElement, api } from 'lwc';

const columns = [
    { label: 'First Name', fieldName: 'FirstName', type: 'text', hideDefaultActions:true},
    { label: 'Last Name ', fieldName: 'LastName', type: 'text', hideDefaultActions:true},
    { label: 'Email', fieldName: 'Email', type: 'email', hideDefaultActions:true},
];

export default class CourseAttendeesTable extends LightningElement {
    @api contactList;
    columns = columns;
}
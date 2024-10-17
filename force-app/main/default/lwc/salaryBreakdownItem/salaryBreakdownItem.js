import { LightningElement, api } from 'lwc';

export default class SalaryBreakdownItem extends LightningElement {
    @api label;
    @api value;
}
import { LightningElement, track } from 'lwc';

export default class PaycheckCalculator extends LightningElement {

    annualSalary = 0;
    monthlyGrossSalary = 0;
    biWeeklyGrossSalary = 0;
    monthlyNetSalary = 0;
    biWeeklyNetSalary = 0;

    federalIncomeTax = 0;
    socialSecurityTax = 0;
    medicareWithholding = 0;
    takeHomePay = 0;

    federalTaxBrackets = [
        { limit: 11000, rate: 0.1 },
        { limit: 44725, rate: 0.12 },
        { limit: 95375, rate: 0.22 },
        { limit: 182100, rate: 0.24 },
        { limit: 231250, rate: 0.32 },
        { limit: 578125, rate: 0.35 },
        { limit: Infinity, rate: 0.37 }
    ];

    // Columns for Salary Breakdown
    salaryColumns = [
        { label: 'Salary Type', fieldName: 'label' },
        { label: 'Amount', fieldName: 'value', type: 'currency' }
    ];

    // Columns for Tax Information
    taxColumns = [
        { label: 'Taxes Taken Out', fieldName: 'label' },
        { label: 'Amount', fieldName: 'value', type: 'currency' },
        {
            label: 'Info',
            type: 'button-icon',
            fieldName: 'info',  // Info field to trigger the tooltip
            typeAttributes: {
                iconName: 'utility:info',
                alternativeText: { fieldName: 'alternativeText' }, // hover text
                variant: 'border-filled',
                size: 'xx-small',
                iconPosition: 'right'
            }
        }
    ];

    handleChange(event) {
        this.annualSalary = Number(event.target.value);
        this.calculateBreakdown();
    }

    // Calculate salary intervals and tax liabilities
    calculateBreakdown() {
        // Calculate gross salary before deductions
        this.monthlyGrossSalary = (this.annualSalary / 12).toFixed(2);  
        this.biWeeklyGrossSalary = (this.annualSalary / 26).toFixed(2); 

        // Calculate tax liabilities and net salary
        this.calculateTaxLiabilities();
    }

    // Calculate tax-related amounts and take-home pay
    calculateTaxLiabilities() {
        this.federalIncomeTax = this.calculateFederalIncomeTax(this.annualSalary).toFixed(2);
        this.socialSecurityTax = (this.annualSalary * 0.062).toFixed(2);
        this.medicareWithholding = (this.annualSalary * 0.0145).toFixed(2);
        
        // Calculate total deductions
        const totalDeductions = parseFloat(this.federalIncomeTax) + parseFloat(this.socialSecurityTax) + parseFloat(this.medicareWithholding);
        
        // Calculate take-home pay after deductions (net annual)
        this.takeHomePay = (this.annualSalary - totalDeductions).toFixed(2);

        // Calculate monthly and bi-weekly pay after deductions (net)
        this.monthlyNetSalary = (this.takeHomePay / 12).toFixed(2); // net monthly pay after deductions
        this.biWeeklyNetSalary = (this.takeHomePay / 26).toFixed(2); // net bi-weekly pay after deductions
    }

    // Calculate Federal Income Tax based on brackets
    calculateFederalIncomeTax(income) {
        let tax = 0;
        let remainingIncome = income;

        for (let bracket of this.federalTaxBrackets) {
            if (remainingIncome > bracket.limit) {
                tax += bracket.limit * bracket.rate;
                remainingIncome -= bracket.limit;
            } else {
                tax += remainingIncome * bracket.rate;
                break;
            }
        }

        return tax;
    }

    // List for salary breakdown (for first section)
    get salaryBreakdown() {
        return [
            { label: 'Gross Monthly Salary', value: this.monthlyGrossSalary },  
            { label: 'Net Monthly Salary (After Deductions)', value: this.monthlyNetSalary },  
            { label: 'Gross Bi-Weekly Salary', value: this.biWeeklyGrossSalary },  
            { label: 'Net Bi-Weekly Salary (After Deductions)', value: this.biWeeklyNetSalary },  
            { label: 'Estimated Take-Home Pay (Annual)', value: this.takeHomePay }  
        ];
    }

    // List for tax-related breakdown (for second section)
    get taxBreakdown() {
        return [
            { label: 'Federal Income Tax', value: this.federalIncomeTax, alternativeText: 'Federal income tax is calculated based on tax brackets.' },
            { label: 'Social Security Tax', value: this.socialSecurityTax, alternativeText: 'Social Security tax is 6.2% of your salary.' },
            { label: 'Medicare Withholding', value: this.medicareWithholding, alternativeText: 'Medicare tax is 1.45% of your salary.' }
        ];
    }
}
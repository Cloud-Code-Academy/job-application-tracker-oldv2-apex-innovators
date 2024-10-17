import { LightningElement, track } from 'lwc';

export default class JobList extends LightningElement {
    @track keywords = '';
    @track location = '';
    @track jobs = [];
    
    // columns for the table
    columns = [
        { label: 'Job Title', fieldName: 'title', sortable: true },
        { label: 'Company', fieldName: 'company', sortable: true },
        { label: 'Location', fieldName: 'location', sortable: true },
        { label: 'Salary', fieldName: 'salary', sortable: true },
        { label: 'Date Posted', fieldName: 'datePosted', sortable: true },
        { label: 'Action', fieldName: 'action', sortable: true ,
            type: 'button',
            typeAttributes: {
                label: 'Save',
                name: 'save',
                variant: 'neutral'
            }
        }
    ];

    //  check if there are any jobs
    get hasJobs() {
        return this.jobs.length > 0;
    }

    // Handle changes to the keyword input
    handleKeywordChange(event) {
        this.keywords = event.target.value;
    }

    // Handle changes to the location input
    handleLocationChange(event) {
        this.location = event.target.value;
    }

    // Handle the search button click
    handleSearch() {
        // Simulate job search results based on keywords (replace with actual API call later)
        if (this.keywords.toLowerCase().includes('salesforce')) {
            // Simulate matching jobs 
            this.jobs = [
                { id: 1, title: 'Salesforce Developer', company: 'Company A', location: 'New York', datePosted: '2024-10-01', salary: '$100,000' },
                { id: 2, title: 'Salesforce Admin', company: 'Company B', location: 'San Francisco', datePosted: '2024-09-20', salary: '$90,000' },
                { id: 3, title: 'Salesforce Architect', company: 'Company C', location: 'Austin', datePosted: '2024-08-15', salary: '$120,000' }
            ];
        } else {
            // No matching jobs for the provided keywords
            this.jobs = [];
        }
    }

    // Handle saving job application; will need to save to custom object Job_Application__c
    handleSave(event) {
        const jobId = event.detail.row.id; // Accessing the ID of the clicked job
        console.log(`Saving job with ID: ${jobId}`);
    }

    // Handle resetting the search form
    handleReset() {
        this.keywords = '';  // Clear the keyword input
        this.location = '';  // Clear the location input
        this.jobs = [];      // Clear the jobs array
    }
}

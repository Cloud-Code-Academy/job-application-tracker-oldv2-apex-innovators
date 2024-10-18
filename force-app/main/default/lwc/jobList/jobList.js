import { LightningElement, track } from 'lwc';

export default class JobList extends LightningElement {
    @track keywords = '';
    @track location = '';
    @track jobs = [];

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
            this.jobs = [
                { id: 1, title: 'Salesforce Developer', company: 'Company A', location: 'New York', datePosted: '2024-10-01', salary: '$100,000' },
                { id: 2, title: 'Salesforce Admin', company: 'Company B', location: 'San Francisco', datePosted: '2024-09-20', salary: '$90,000' },
                { id: 3, title: 'Salesforce Architect', company: 'Company C', location: 'Austin', datePosted: '2024-08-15', salary: '$120,000' },
                { id: 4, title: 'Salesforce Consultant', company: 'Company D', location: 'London', datePosted: '2024-07-10', salary: '85,000' },
                { id: 5, title: 'Salesforce Engineer', company: 'Company E', location: 'Paris', datePosted: '2024-06-01', salary: '' },
                { id: 6, title: 'Salesforce Consultant', company: 'Company F', location: 'San Francisco', datePosted:'2024-06-01'}
            ];
        } else {
            this.jobs = [];
        }
    }

    // Handle resetting the search form
    handleReset() {
        this.keywords = '';  
        this.location = '';  
        this.jobs = [];     
    }
}

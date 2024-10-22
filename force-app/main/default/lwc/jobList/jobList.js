import { LightningElement, track } from 'lwc';
import searchJobs from '@salesforce/apex/JoobleJobSearchController.searchJobs';

export default class JobList extends LightningElement {
    @track keywords = '';
    @track location = '';
    @track jobs = [];
    @track totalPages = 1; // Track total pages for pagination
    @track currentPage = 1; // Track current page
    @track pageSize = 5; // Number of jobs per page
    @track errorMessage = ''; // To hold error messages

    get hasJobs() {
        return this.jobs.length > 0;
    }

    // Handle changes to the keyword input
    handleKeywordChange(event) {
        this.keywords = event.target.value;
        console.log('Keyword changed:', this.keywords);
    }

    // Handle changes to the location input
    handleLocationChange(event) {
        this.location = event.target.value;
        console.log('Location changed:', this.location);
    }

    // Handle the search button click
    async handleSearch() {
        this.currentPage = 1; // Reset to the first page on new search
        console.log('Search initiated with keywords:', this.keywords, 'and location:', this.location);
        await this.fetchJobs(); // Fetch jobs with pagination
    }

    // Fetch jobs from the Apex controller
    async fetchJobs() {
        try {
            console.log('Fetching jobs with:', {
                keyword: this.keywords,
                location: this.location,
                pageNumber: this.currentPage,
                pageSize: this.pageSize
            });
            
            const results = await searchJobs({
                keyword: this.keywords,
                location: this.location,
                pageNumber: this.currentPage,
                pageSize: this.pageSize
            });
            
            console.log('Results from searchJobs:', results);
            
            // Ensure that results.jobs is defined
            this.jobs = results.jobs || []; // Jobs fetched for the current page
            this.totalPages = Math.ceil(results.totalCount / this.pageSize); // Calculate total pages
            console.log('Jobs fetched:', this.jobs);
            console.log('Total pages:', this.totalPages);
        } catch (error) {
            // Handle errors as you've done before
            console.error('Error fetching jobs:', error);
            this.jobs = [];
            this.errorMessage = 'Failed to fetch jobs. Please try again.';
        }
    }
    

    // Handle pagination (triggered by child component)
    handlePageChange(event) {
        this.currentPage = event.detail.pageNumber;
        console.log('Page changed to:', this.currentPage);
        this.fetchJobs(); // Fetch jobs for the updated page number
    }

    // Handle reset functionality
    handleReset() {
        this.keywords = '';
        this.location = '';
        this.jobs = [];
        this.currentPage = 1;
        this.totalPages = 1;
        console.log('Search criteria reset');
    }
}

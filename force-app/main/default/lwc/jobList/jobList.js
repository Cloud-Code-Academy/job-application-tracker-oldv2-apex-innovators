import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import searchJobs from '@salesforce/apex/JoobleJobSearchController.searchJobs';
import createJobApplication from '@salesforce/apex/JoobleJobSearchController.createJobApplication';


export default class JobList extends LightningElement {
    @track keywords = '';
    @track location = '';
    @track jobs = [];
    @track totalPages = 1;
    @track currentPage = 1;
    @track pageSize = 10;
    @track errorMessage = '';
    @track totalCount = 0;
    @track selectedJob; // Track the selected job

    get hasJobs() {
        return this.jobs.length > 0;
    }

    handleKeywordChange(event) {
        this.keywords = event.target.value;
    }

    handleLocationChange(event) {
        this.location = event.target.value;
    }

    async handleSearch() {
        this.currentPage = 1;
        await this.fetchJobs();
    }

    async fetchJobs() {
        try {
            const results = await searchJobs({
                keyword: this.keywords,
                location: this.location,
                pageNumber: this.currentPage,
                pageSize: this.pageSize
            });
            if (results) {
                this.jobs = results.jobs || [];
                this.totalCount = results.totalCount || 0;
                this.totalPages = Math.max(1, Math.ceil(this.totalCount / this.pageSize));
            }
        } catch (error) {
            console.error('Error fetching jobs:', error);
            this.errorMessage = 'Failed to fetch jobs. Please try again.';
            this.jobs = [];
            this.totalPages = 1;
            this.currentPage = 1;
        }
    }

    handlePageChange(event) {
        const newPage = parseInt(event.detail.pageNumber, 10);
        if (newPage >= 1 && newPage <= this.totalPages && newPage !== this.currentPage) {
            this.currentPage = newPage;
            this.fetchJobs();
        }
    }

    handleReset() {
        this.keywords = '';
        this.location = '';
        this.jobs = [];
        this.currentPage = 1;
        this.totalPages = 1;
        this.totalCount = 0;
    }

    // Capture the selected job from the child component
    handleJobSelected(event) {
        this.selectedJob = event.detail; // Capture the selected job
        console.log('Selected job:', this.selectedJob); // For debugging
    }

    // Call this method to save the selected job when required
    getRecordUrl(recordId) {
        return `/lightning/r/Job_Application__c/${recordId}/view`;
    }
    
    handleSaveJob(event) {
        const jobData = event.detail;
        console.log('Job data before save:', JSON.stringify(jobData, null, 2));
        
        createJobApplication({ jobApp: jobData })
            .then(recordId => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Job saved successfully: {0}',
                        messageData: [
                            {
                                url: this.getRecordUrl(recordId),
                                label: jobData.title
                            }
                        ],
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                const errorDetails = {
                    message: error?.body?.message || 'Unknown error',
                    type: error?.body?.exceptionType || 'No type available',
                    stack: error?.body?.stackTrace || 'No stack trace'
                };
                console.log('Error details:', errorDetails);
                
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: errorDetails.message,
                        variant: 'error'
                    })
                );
            });
    }
    
    getRecordUrl(recordId) {
        return `/lightning/r/Job_Application__c/${recordId}/view`;
    }   
}
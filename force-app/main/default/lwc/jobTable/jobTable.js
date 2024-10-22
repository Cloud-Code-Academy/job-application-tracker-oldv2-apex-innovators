import { LightningElement, api, track } from 'lwc';

export default class JobTable extends LightningElement {
    @api jobs = []; // Jobs passed from parent component
    @api currentPage = 1; // Current page number passed from parent
    @api totalPages = 1; // Total pages passed from parent

    columns = [
        { label: 'Job Title', fieldName: 'title', sortable: true },
        { label: 'Company', fieldName: 'company', sortable: true },
        { label: 'Location', fieldName: 'location', sortable: true },
        { label: 'Salary', fieldName: 'salary', sortable: true },
        { label: 'Date Posted', fieldName: 'datePosted', sortable: true },
        { label: 'Action', fieldName: 'action', type: 'button', typeAttributes: { label: 'Save', name: 'save', variant: 'neutral' } }
    ];

    // Getter for paginated jobs based on current page and page size
    get paginatedJobs() {
        const start = (this.currentPage - 1) * 5; // Assuming 5 jobs per page
        return this.jobs.slice(start, start + 5);
    }

    // Disable the "Previous" button if on the first page
    get isPreviousDisabled() {
        return this.currentPage === 1;
    }

    // Disable the "Next" button if on the last page
    get isNextDisabled() {
        return this.currentPage >= this.totalPages;
    }

    // Example of emitting page change in child component
handlePageChange(pageNumber) {
    const pageChangeEvent = new CustomEvent('pagechange', {
        detail: { pageNumber }
    });
    this.dispatchEvent(pageChangeEvent);
}

    // Navigate to the next page
    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage += 1;
            console.log('Navigating to next page:', this.currentPage);
            this.dispatchEvent(new CustomEvent('pagechange', { detail: { pageNumber: this.currentPage }}));
        }
    }

    // Navigate to the previous page
    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage -= 1;
            console.log('Navigating to previous page:', this.currentPage);
            this.dispatchEvent(new CustomEvent('pagechange', { detail: { pageNumber: this.currentPage }}));
        }
    }

    // Log the jobs passed from the parent component
    connectedCallback() {
        console.log('Jobs passed to JobTable:', this.jobs);
    }
}

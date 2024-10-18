import { LightningElement, api, track } from 'lwc';

export default class JobTable extends LightningElement {
    @api jobs = [];
    @track currentPage = 1;
    @track pageSize = 2;
    @track sortedBy = '';
    @track sortedDirection = 'asc';
    @track paginatedJobs = [];

    columns = [
        { label: 'Job Title', fieldName: 'title', sortable: true },
        { label: 'Company', fieldName: 'company', sortable: true },
        { label: 'Location', fieldName: 'location', sortable: true },
        { label: 'Salary', fieldName: 'salary', sortable: true },
        { label: 'Date Posted', fieldName: 'datePosted', sortable: true },
        { label: 'Action', fieldName: 'action', type: 'button', typeAttributes: { label: 'Save', name: 'save', variant: 'neutral' } }
    ];

    connectedCallback() {
        this.updatePaginatedJobs();
    }

   
    get jobs() {
        return this._jobs || [];
    }
    set jobs(value) {
        this._jobs = value;
        this.updatePaginatedJobs();
    }

    get totalPages() {
        return Math.ceil(this.jobs.length / this.pageSize);
    }

    get paginatedJobs() {
        const start = (this.currentPage - 1) * this.pageSize;
        const end = this.currentPage * this.pageSize;
        return this.jobs.slice(start, end);
    }

    updatePaginatedJobs() {
        const start = (this.currentPage - 1) * this.pageSize;
        const end = this.currentPage * this.pageSize;
        this.paginatedJobs = this.jobs.slice(start, end);
    }

    // Getters for disabling the pagination buttons
    get isPreviousDisabled() {
        return this.currentPage === 1;
    }

    get isNextDisabled() {
        return this.currentPage >= this.totalPages;
    }

    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage += 1;
            this.updatePaginatedJobs();
        }
    }

    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage -= 1;
            this.updatePaginatedJobs();
        }
    }

    handleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        this.sortedBy = sortedBy;
        this.sortedDirection = sortDirection;
        this.sortData(sortedBy, sortDirection);
    }

    sortData(field, direction) {
        const sortedJobs = [...this.jobs];
        sortedJobs.sort((a, b) => {
            let aValue = a[field];
            let bValue = b[field];
    
            if (field === 'salary') {
                aValue = parseFloat(aValue.replace(/[^0-9.-]+/g, ""));
                bValue = parseFloat(bValue.replace(/[^0-9.-]+/g, ""));
            }
    
            const reverse = direction === 'asc' ? 1 : -1;
            return aValue > bValue ? reverse : aValue < bValue ? -reverse : 0;
        });
    
        this._jobs = sortedJobs;
        this.updatePaginatedJobs();
    }
}

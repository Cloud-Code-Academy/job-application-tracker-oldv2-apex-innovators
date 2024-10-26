import { LightningElement, api, track } from 'lwc';

export default class JobTable extends LightningElement {
    @api jobs = [];
    @api totalPages = 1;
    _currentPage = 1;

    @api
    get currentPage() {
        return this._currentPage;
    }
    
    set currentPage(value) {
        this._currentPage = Number(value);
    }

    get isPreviousDisabled() {
        return this.currentPage === 1;
    }

    get isNextDisabled() {
        return this.currentPage === this.totalPages;
    }

    columns = [
        { label: 'Job Title', fieldName: 'title', sortable: true },
        { label: 'Company', fieldName: 'company', sortable: true },
        { label: 'Location', fieldName: 'location', sortable: true },
        { label: 'Salary', fieldName: 'salary', sortable: true },
        { label: 'Date Posted', fieldName: 'updated', sortable: true },
        { label: 'Action', type: 'button', typeAttributes: { 
            label: 'Save', 
            name: 'save', 
            variant: 'neutral' 
        }}
    ];

    /*handleRowAction(event) {
        const row = event.detail.row;
        const actionName = event.detail.action.name;
        
        if (actionName === 'save') {
            // Create a new object without the 'id' property
            const { id, ...jobToSave } = row;
            
            this.dispatchEvent(new CustomEvent('savejob', {
                detail: jobToSave
            }));
        }
    }*/
    
    handleRowAction(event) {
        const row = event.detail.row;
        const actionName = event.detail.action.name;
        
        if (actionName === 'save') {
            // Include the ID in the job data
            const jobToSave = {
                id: row.id,
                title: row.title,
                link: row.link,
                salary: row.salary,
                snippet: row.snippet,
                company: row.company,
                type: row.type,
                location: row.location
            };
            
            this.dispatchEvent(new CustomEvent('savejob', {
                detail: jobToSave
            }));
        }
    }
    
    handleSave(event) {
    const jobId = event.detail.row.id; // Get the job ID from the row
    const selectedJob = this.jobs.find(job => job.id === jobId); // Find the selected job

    console.log('Selected job:', selectedJob); // Log the selected job

    // Dispatch event to save the job
    this.dispatchEvent(new CustomEvent('savejob', { detail: selectedJob }));
}

    get paginatedJobs() {
        return this.jobs; // Use the full jobs array for the current page
    }

    handlePageChange(pageNumber) {
        if (pageNumber >= 1 && pageNumber <= this.totalPages) {
            this.dispatchEvent(new CustomEvent('pagechange', {
                detail: { pageNumber }
            }));
        }
    }

    handleNextPage() {
        if (this._currentPage < this.totalPages) {
            this.handlePageChange(this._currentPage + 1);
        }
    }

    handlePreviousPage() {
        if (this._currentPage > 1) {
            this.handlePageChange(this._currentPage - 1);
        }
    }
}

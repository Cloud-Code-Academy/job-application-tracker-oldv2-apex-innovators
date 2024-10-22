String keyword = 'Salesforce Developer';
String location = 'San Francisco';

// Call the searchJobs method
List<JoobleJobSearchController.JobBoardResult> jobResults = JoobleJobSearchController.searchJobs(keyword, location);

// Output results in debug logs
for (JoobleJobSearchController.JobBoardResult jobResult : jobResults) {
    System.debug('Job Title: ' + jobResult.title);
    System.debug('Company: ' + jobResult.company);
    System.debug('Location: ' + jobResult.location);
    System.debug('Snippet: ' + jobResult.snippet);
    System.debug('Salary: ' + jobResult.salary);
    System.debug('Link: ' + jobResult.link);
    System.debug('Date Created: ' + jobResult.datecreatedfrom);
}

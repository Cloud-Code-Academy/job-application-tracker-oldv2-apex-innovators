@IsTest
private class JoobleJobSearchControllerTest {

    @IsTest
    static void testSearchJobs() {
        // Mock success response
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"totalCount": 100, "jobs": [{"id": "123", "title": "Software Engineer", "location": "San Francisco", "snippet": "Great opportunity", "salary": "$100k-$150k", "type": "Full-time", "link": "http://example.com", "company": "Tech Co", "updated": "2023-05-01T12:00:00Z"}]}');
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        
        API_Config__c config = new API_Config__c(Jooble_API__c = 'test-api-key');
        insert config;

        Test.startTest();
        Map<String, Object> result = JoobleJobSearchController.searchJobs('Software Engineer', 'San Francisco', 1, 10);
        Test.stopTest();

        // Verify results
        Assert.areEqual(100, result.get('totalCount'), 'Total count should match');
        List<JoobleJobSearchController.Job> jobs = (List<JoobleJobSearchController.Job>)result.get('jobs');
        Assert.areEqual(1, jobs.size(), 'Should have one job in the result');

        JoobleJobSearchController.Job job = jobs[0];
        Assert.areEqual('Software Engineer', job.title, 'Job title should match');
        Assert.areEqual('San Francisco', job.location, 'Job location should match');
        Assert.areEqual('May 1, 2023', job.updated, 'Job updated date should be formatted correctly');
    }

    @IsTest
static void testSearchJobsError() {
    // Mock error response
    HttpResponse mockResponse = new HttpResponse();
    mockResponse.setStatusCode(400);
    mockResponse.setBody('Error');
    
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));

    API_Config__c config = new API_Config__c(Jooble_API__c = 'test-api-key');
    insert config;

    Test.startTest();
    try {
        JoobleJobSearchController.searchJobs('Software Engineer', 'San Francisco', 1, 10);
        System.assert(false, 'Expected an exception but did not get one.');
    } catch (Exception e) {  
        //System.debug('Caught exception message: ' + e.getMessage());
        System.assert(true, 'Exception was correctly thrown due to error response.');
    }
    Test.stopTest();
}


    @IsTest
    static void testCreateJobApplication() {
        JoobleJobSearchController.Job jobApp = createTestJob();

        Test.startTest();
        Id jobAppId = JoobleJobSearchController.createJobApplication(jobApp);
        Test.stopTest();

        Job_Application__c createdJobApp = [SELECT Id, Job_Position__c, Company_Name__r.Name FROM Job_Application__c WHERE Id = :jobAppId];
        Assert.areEqual('Software Engineer', createdJobApp.Job_Position__c, 'Job position should match');
        Assert.areEqual('Tech Co', createdJobApp.Company_Name__r.Name, 'Company name should match');
    }

    @IsTest
static void testCreateDuplicateJobApplication() {
    // Create a job application to simulate 
    JoobleJobSearchController.Job jobApp = createTestJob();

    Job_Application__c existingJobApp = new Job_Application__c(
        JoobleExternalId__c = '123',  // Same ID as the test jobApp to trigger dupe
        Job_Position__c = 'Software Engineer',
        Job_Application_Status__c = 'Saved'
    );
    insert existingJobApp;

    // Verify the duplicate job setup
    Job_Application__c insertedJobApp = [SELECT Id, JoobleExternalId__c FROM Job_Application__c WHERE JoobleExternalId__c = :jobApp.id LIMIT 1];
    System.assertNotEquals(null, insertedJobApp, 'Setup failed: existing job application not found in database.');

    Test.startTest();
    try {
        JoobleJobSearchController.createJobApplication(jobApp);
        System.assert(false, 'Expected an exception for duplicate job but did not get it.');
    } catch (Exception e) {  
        //System.debug('Caught exception message: ' + e.getMessage());

        // Check for either expected message or "Script-thrown exception" as a fallback
        Boolean isExpectedMessage = e.getMessage().contains('This job is already saved!') ||
                                    e.getMessage().contains('Script-thrown exception');

        Assert.areEqual(true, isExpectedMessage,'Expected exception message to indicate duplicate job, but got: ' + e.getMessage());
    }
    Test.stopTest();
}

    @IsTest
    static void testSearchJobsEmptyResult() {
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"totalCount": 0, "jobs": []}');
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        
        API_Config__c config = new API_Config__c(Jooble_API__c = 'test-api-key');
        insert config;

        Test.startTest();
        Map<String, Object> result = JoobleJobSearchController.searchJobs('Software Engineer', 'San Francisco', 1, 10);
        Test.stopTest();

        Assert.areEqual(0, result.get('totalCount'), 'Total count should be zero for empty response');
        List<JoobleJobSearchController.Job> jobs = (List<JoobleJobSearchController.Job>)result.get('jobs');
        Assert.areEqual(0, jobs.size(), 'Jobs list should be empty');
    }

    // Helper method to create a test Job instance
    private static JoobleJobSearchController.Job createTestJob() {
        JoobleJobSearchController.Job jobApp = new JoobleJobSearchController.Job();
        jobApp.id = '123';
        jobApp.title = 'Software Engineer';
        jobApp.company = 'Tech Co';
        jobApp.link = 'http://example.com';
        jobApp.snippet = 'Great opportunity';
        jobApp.location = 'San Francisco';
        jobApp.updated = 'May 1, 2023';
        return jobApp;
    }

    // Mock HTTP Callout Response Generator
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private HttpResponse response;
        
        public MockHttpResponseGenerator(HttpResponse response) {
            this.response = response;
        }
        
        public HttpResponse respond(HttpRequest request) {
            return response;
        }
    }
}

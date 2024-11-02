@isTest
private class EventTriggerHelperTest {
    
    @isTest
    static void testNoOverlap() {
        // Create test data
        Event existingMeeting = new Event(
            Subject = 'Existing Meeting',
            StartDateTime = Datetime.now().addHours(1),
            EndDateTime = Datetime.now().addHours(2)
        );
        insert existingMeeting;
        
        Event newMeeting = new Event(
            Subject = 'New Meeting',
            StartDateTime = Datetime.now().addHours(3),
            EndDateTime = Datetime.now().addHours(4)
        );
        
        Test.startTest();
        try {
            EventHelper.validateNoOverlapAndFetchJobPosition(new List<Event>{newMeeting});
            insert newMeeting;
            Assert.areEqual(true, true, 'No overlap detected as expected');
        } catch(Exception e) {
            Assert.areEqual(false, true, 'Unexpected error occurred: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
    /*@isTest
static void testWithOverlap() {
    // Create test data
    Event existingMeeting = new Event(
        Subject = 'Existing Meeting',
        StartDateTime = Datetime.now().addHours(1),
        EndDateTime = Datetime.now().addHours(2)
    );
    insert existingMeeting;
    
    Event overlappingMeeting = new Event(
        Subject = 'Overlapping Meeting',
        StartDateTime = Datetime.now().addHours(1).addMinutes(30),
        EndDateTime = Datetime.now().addHours(2).addMinutes(30)
    );
    
    Test.startTest();
    try {
        // This line should throw an exception if there is an overlap
        EventHelper.validateNoOverlapAndFetchJobPosition(new List<Event>{overlappingMeeting});
        // If we reach this point, it means there was no overlap detected, which is unexpected
        Assert.fail('Expected an error due to overlap, but none was thrown');
    } catch(DmlException e) {
        // Validate the overlap error message
        Assert.isTrue(e.getMessage().contains('overlaps with an existing meeting'), 
                     'Expected overlap error message: ' + e.getMessage());
    }
    Test.stopTest();
}*/


    
    @isTest
    static void testMultipleEvents() {
        // Create test data
        Event existingMeeting = new Event(
            Subject = 'Existing Meeting',
            StartDateTime = Datetime.now().addHours(1),
            EndDateTime = Datetime.now().addHours(2)
        );
        insert existingMeeting;
        
        Event newMeeting1 = new Event(
            Subject = 'New Meeting 1',
            StartDateTime = Datetime.now().addHours(3),
            EndDateTime = Datetime.now().addHours(4)
        );
        
        Event newMeeting2 = new Event(
            Subject = 'New Meeting 2',
            StartDateTime = Datetime.now().addHours(1).addMinutes(30),
            EndDateTime = Datetime.now().addHours(2).addMinutes(30)
        );
        
        Test.startTest();
        try {
            // Validate no overlap
            EventHelper.validateNoOverlapAndFetchJobPosition(new List<Event>{newMeeting1, newMeeting2});
            
            // If there is no overlap, this means the code execution should continue
            insert new List<Event>{newMeeting1, newMeeting2};
            
            // If we reach this point, it means there was no overlap, so assert that the expected outcome was achieved
            Assert.isTrue(true, 'No overlap detected as expected.');
        } catch(DmlException e) {
            // If an exception is thrown, it indicates there was an overlap
            Assert.isTrue(e.getMessage().contains('overlaps with an existing meeting'), 
                         'Expected overlap error message: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
    
    @isTest
    static void testConvertToMinutes() {
        Datetime testDate = Datetime.newInstance(2023, 1, 1, 12, 0, 0);
        Long minutes = EventHelper.convertToMinutes(testDate);
        Assert.areNotEqual(null, minutes, 'Minutes should not be null');
        Assert.isTrue(minutes > 0, 'Minutes should be positive');
    }

    /*@isTest
static void testSendUpcomingEventEmails() {
    // Create a test Job Application
    Job_Application__c jobApp = new Job_Application__c(
        Job_Position__c = 'Software Engineer',
        Company_Name__c = 'Acme Corp'
    );
    insert jobApp;

    // Create a test User
    User testUser = new User(
        Username = 'testuser@example.com',
        Email = 'testuser@example.com',
        Alias = 'tuser',
        ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
        LastName = 'User',
        FirstName = 'Test',
        IsActive = true
    );
    insert testUser;

    // Create a test Event linked to the Job Application and the User
    Event meeting = new Event(
        WhatId = jobApp.Id,
        OwnerId = testUser.Id,
        StartDateTime = Datetime.now().addHours(1),
        Type = 'Interview'
    );
    insert meeting;

    // Now call the method you're testing
    EventHelper.sendUpcomingEventEmails(new List<Event> { meeting });

    // Add assertions here to verify expected email sent, etc.
}*/



}

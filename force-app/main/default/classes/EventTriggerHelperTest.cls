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
            EventHelper.validateNoOverlap(new List<Event>{newMeeting});
            insert newMeeting;
            Assert.areEqual(true, true, 'No overlap detected as expected');
        } catch(Exception e) {
            Assert.areEqual(false, true, 'Unexpected error occurred: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
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
            EventHelper.validateNoOverlap(new List<Event>{overlappingMeeting});
            insert overlappingMeeting;
            Assert.areEqual(false, true, 'Expected an error due to overlap');
        } catch(DmlException e) {
            Assert.isTrue(e.getMessage().contains('overlaps with an existing meeting'), 
                         'Expected overlap error message: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
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
            EventHelper.validateNoOverlap(new List<Event>{newMeeting1, newMeeting2});
            insert new List<Event>{newMeeting1, newMeeting2};
            Assert.areEqual(false, true, 'Expected an error due to overlap');
        } catch(DmlException e) {
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

    @isTest
    static void testSendUpcomingEventEmails() {
        // Setup test data
        Event meeting = new Event(
            Subject = 'Test Meeting',
            StartDateTime = Datetime.now().addHours(1),
            EndDateTime = Datetime.now().addHours(2),
            WhatId = [SELECT Id FROM Job_Application__c LIMIT 1].Id // Assuming there is at least one Job Application
        );
        insert meeting;

        Test.startTest();
        // Call the method to send emails
        EventHelper.sendUpcomingEventEmails(new List<Event>{meeting});
        Test.stopTest();

        // Verify that emails were sent
        List<Messaging.SingleEmailMessage> sentEmails = [SELECT Id FROM EmailMessage WHERE Subject = 'Upcoming Interview Reminder'];
        Assert.isTrue(!sentEmails.isEmpty(), 'Expected emails to be sent');
        
        // Check if the expected email fields are set correctly (additional assertions)
        for (Messaging.SingleEmailMessage email : sentEmails) {
            Assert.areEqual('Upcoming Interview Reminder', email.Subject, 'Email subject does not match');
            // Add more assertions as necessary to validate the content of the email
        }
    }
}

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
            System.assert(true, 'No overlap detected as expected');
        } catch(Exception e) {
            System.assert(false, 'Unexpected error occurred');
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
            System.assert(false, 'Expected an error due to overlap');
        } catch(DmlException e) {
            System.assert(e.getMessage().contains('overlaps with an existing meeting'), 
                         'Expected overlap error message');
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
            System.assert(false, 'Expected an error due to overlap');
        } catch(DmlException e) {
            System.assert(e.getMessage().contains('overlaps with an existing meeting'), 
                         'Expected overlap error message');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testConvertToMinutes() {
        Datetime testDate = Datetime.newInstance(2023, 1, 1, 12, 0, 0);
        Long minutes = EventHelper.convertToMinutes(testDate);
        Assert.areNotEqual(null, minutes, 'Minutes should not be null');
        System.assert(minutes > 0, 'Minutes should be positive');
    }
}

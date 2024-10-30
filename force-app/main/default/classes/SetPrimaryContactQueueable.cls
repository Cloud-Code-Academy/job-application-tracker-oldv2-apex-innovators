public with sharing class SetPrimaryContactQueueable implements Queueable {
    private List<Id> jobAppIds;
    
    public SetPrimaryContactQueueable(List<Id> jobAppIds) {
        this.jobAppIds = jobAppIds;
    }

    public void execute(QueueableContext context) {
        List<Job_Application__c> jobAppList = [
            SELECT Id, Primary_Contact__c, Company_Name__c
            FROM Job_Application__c
            WHERE Id IN :jobAppIds
        ];

        JobApplicationHelper.setPrimaryContact(jobAppList);

        update jobAppList;
    }
}
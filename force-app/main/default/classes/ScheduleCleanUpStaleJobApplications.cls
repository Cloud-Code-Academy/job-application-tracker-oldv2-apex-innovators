global class ScheduleCleanUpStaleJobApplications implements Schedulable {
    global void execute(SchedulableContext SC) {
        CleanUpStaleJobApplications batchJob = new CleanUpStaleJobApplications();
        Database.executeBatch(batchJob, 200);  // Adjust batch size if necessary
    }
}

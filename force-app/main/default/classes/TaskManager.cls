public with sharing class TaskManager {
    public static void createTasksForApplication (List<Task> tasks) {
        if (!tasks.isEmpty()) {
            if (Schema.SObjectType.Task.isCreateable()) {
                insert tasks;
            } else {
                System.debug('User does not have permission to create Task records.');
            }   
        }         
    }

    public static Task prepareTask(Job_Application__c app, String type, String priority, String subject) {
        Task newTask = new Task(
            Subject = subject,
            ActivityDate = Date.today().addDays(7),
            Priority = priority,
            OwnerId = app.OwnerId,
            WhatId = app.Id,
            Application_Status_Snapshot__c = app.Job_Application_Status__c,
            Type = type
        );
        
        return newTask;
    }
}
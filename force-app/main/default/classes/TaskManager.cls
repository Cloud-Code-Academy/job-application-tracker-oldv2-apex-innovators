public with sharing class TaskManager {
    public static void createTasksForApplication (List<Task> tasks) {
        try {
            if (!tasks.isEmpty()) {
                if (Schema.SObjectType.Task.isCreateable()) {
                    insert tasks;
                } else {
                    System.debug('User does not have permission to create Task records.');
                }   
            }         
        } catch (DmlException e) {
            System.debug('Error creating tasks: ' + e.getMessage() + ' | Tasks: ' + tasks);
        }
    }

    public static Task prepareTask(Job_Application__c app, String subject, String priority, String description) {
        Task newTask = new Task(
            Subject = subject,
            ActivityDate = Date.today().addDays(7),
            Priority = priority,
            OwnerId = app.OwnerId,
            WhatId = app.Id,
            Status = 'Not Started',
            Description = description
        );
        
        return newTask;
    }
}
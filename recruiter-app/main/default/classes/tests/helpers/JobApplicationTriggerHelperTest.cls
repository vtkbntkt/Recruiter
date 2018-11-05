@isTest
private class JobApplicationTriggerHelperTest {
    
    @isTest static void test_processTaskAdding_insertsRejectedTaskCorrectly(){
        // Given
        addUser();
        Map<Id, Job_Application__c> oldMap =  getJobAppMap('New');
        Map<Id, Job_Application__c> newMap =  getNewJobAppMap(oldMap,'Closed - Rejected');        
        
        // When
        Test.startTest();
        
        JobApplicationTriggerHelper.processTaskAdding(oldMap,newMap);
        Test.stopTest();
        
        // Then
        List<Task> tasks = [SELECT Id, Subject FROM Task];
        System.assertEquals(1, tasks.size());
        System.assertEquals('Send Rejection Letter',tasks[0].Subject);
    }
    
    // нет изменения статуса
    
    @isTest static void test_processTaskAdding_insertsAcceptedTaskCorrectly(){
        // Given
        addUser();
        Map<Id, Job_Application__c> oldMap =  getJobAppMap('New');
        Map<Id, Job_Application__c> newMap =  getNewJobAppMap(oldMap,'Offer Extended');
        
        //When   
        Test.startTest();                     
        JobApplicationTriggerHelper.processTaskAdding(oldMap,newMap);
        Test.stopTest();
        
        //Then
        List<Task> tasks = [SELECT Id, Subject FROM Task];
        System.assertEquals(1, tasks.size());
        System.assertEquals('Extend an Offer',tasks[0].Subject);
    }
    
    @isTest static void test_processTaskAdding_StatusIsNotChanged(){
        // Given
        addUser();
        Map<Id, Job_Application__c> oldMap =  getJobAppMap('Offer Extended');
        Map<Id, Job_Application__c> newMap =  getNewJobAppMap(oldMap,'Offer Extended');
        
        //When   
        Test.startTest();                     
        JobApplicationTriggerHelper.processTaskAdding(oldMap,newMap);
        Test.stopTest();
        
        //Then
        List<Task> tasks = [SELECT Id, Subject FROM Task];
        System.assertEquals(0, tasks.size());
    }
    
    @isTest static void test_processTaskAdding_Exception_invalid_OwnerId(){
        // Given
        addUser();
        Map<Id, Job_Application__c> oldMap =  getJobAppMap('New');
        Map<Id, Job_Application__c> newMap =  getNewJobAppMap(oldMap,'Offer Extended');
        newMap.get(new List<Id>(newMap.keySet()).get(0)).OwnerId = null;
        
        Test.startTest();
        try{
            // When
            JobApplicationTriggerHelper.processTaskAdding(oldMap,newMap);
            System.assert(false, 'Expected exception');
        }
        catch(Exception exc){
            //Exc - inner class
            // Then
            System.assert(exc instanceOf JobApplicationTriggerHelper.TaskByJobAppStatusException);           
        }
        Test.stopTest();
    }
    
    @isTest static void test_processTaskAdding_BulkInsertCorrectly(){
        //Given
        addUser();
        Integer rejectedNum = 100;
        Integer acceptedNum = 100;
        List<Job_Application__c> rejectedJobApps = TestDataFactory.getJobApps(rejectedNum,0);
        List<Job_Application__c> acceptedJobApps = TestDataFactory.getJobApps(0,acceptedNum);
        
        //Given
        insert rejectedJobApps;
        insert acceptedJobApps;
        
        //Given
        System.assertEquals(rejectedNum,[SELECT COUNT()FROM Job_Application__c WHERE Stage__c='Closed - Rejected']);
        System.assertEquals(acceptedNum,[SELECT COUNT()FROM Job_Application__c WHERE Stage__c='Offer Extended']);
        
        //Given
        Map<Id, Job_Application__c> rejectedOldMap = new Map<Id,Job_Application__c>(rejectedJobApps);
        Map<Id, Job_Application__c> acceptedOldMap = new Map<Id,Job_Application__c>(acceptedJobApps);            
        Map<Id, Job_Application__c> rejectedNewMap = getNewJobAppMap(acceptedOldMap, 'Closed - Rejected');
        Map<Id, Job_Application__c> acceptedNewMap = getNewJobAppMap(rejectedOldMap, 'Offer Extended');
        rejectedNewMap.putAll(acceptedNewMap);
        rejectedOldMap.putAll(acceptedOldMap);
        
        //When
        Test.startTest();
        JobApplicationTriggerHelper.processTaskAdding(rejectedOldMap, rejectedNewMap);
        Test.stopTest();
        
        //Then
        System.assertEquals(acceptedNum,[SELECT COUNT()FROM Task WHERE Subject='Extend an Offer']);
        System.assertEquals(rejectedNum,[SELECT COUNT()FROM Task WHERE Subject='Send Rejection Letter']);        
    }
    
    
    private static Map<Id, Job_Application__c> getJobAppMap(String status){
        Map<Id, Job_Application__c> jobAppMap = new Map<Id, Job_Application__c>();  
        Job_Application__c jobApp = TestDataFactory.getRandomJobApp(status,true);
        jobAppMap.put(jobApp.id, jobApp);
        return jobAppMap;
    }
    
    private static Map<Id, Job_Application__c> getNewJobAppMap(Map<Id, Job_Application__c> oldJobAppMap, String status){
        Map<Id, Job_Application__c> jobAppMap = new Map<Id, Job_Application__c>();
        for(Id jobAppId:oldJobAppMap.keySet()){
            Job_Application__c newJobApp = oldJobAppMap.get(jobAppId).clone(true);
            newJobApp.Stage__c=status;
            jobAppMap.put(newJobApp.id, newJobApp);
        }      
        return jobAppMap;
    }
    private static void addUser(){
         System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()].get(0)){
            TestDataFactory.getRandomUser('Recruiter','System Administrator', 'Anton', 'Bezuh', true);
        }
    }
}
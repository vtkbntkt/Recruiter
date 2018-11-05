@isTest
private class JobApplicationTest {
    
    @isTest static void test_jobApplicationTrigger(){      
        //Given
        addUser();
        Integer rejectedNum = 99;
        Integer acceptedNum = 101;
        List<Job_Application__c> jobApps = TestDataFactory.getJobApps(rejectedNum,acceptedNum);
        insert jobApps;
        System.assertEquals(rejectedNum,[SELECT COUNT()FROM Job_Application__c WHERE Stage__c='Closed - Rejected']);
        System.assertEquals(acceptedNum,[SELECT COUNT()FROM Job_Application__c WHERE Stage__c='Offer Extended']);
        
        //Given
        for(Job_Application__c jobApp:jobApps){
            if(jobApp.Stage__c=='Closed - Rejected'){
               jobApp.Stage__c='Offer Extended';
            }
            else if(jobApp.Stage__c=='Offer Extended'){
                jobApp.Stage__c='Closed - Rejected';
            }
        }
        Integer rejectedNumNew = acceptedNum;
        Integer acceptedNumNew = rejectedNum;
        
        //When
        Test.startTest();
        update jobApps;
        Test.stopTest();
        
        //Then
        System.assertEquals(rejectedNumNew,[SELECT COUNT()FROM Job_Application__c WHERE Stage__c='Closed - Rejected']);
        System.assertEquals(acceptedNumNew,[SELECT COUNT()FROM Job_Application__c WHERE Stage__c='Offer Extended']);
        
        System.assertEquals(acceptedNumNew,[SELECT COUNT()FROM Task WHERE Subject='Extend an Offer']);
        System.assertEquals(rejectedNumNew,[SELECT COUNT()FROM Task WHERE Subject='Send Rejection Letter']);
    }
    
    private static void addUser(){
         System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()].get(0)){
            TestDataFactory.getRandomUser('Recruiter','System Administrator', 'Anton', 'Bezuh', true);
        }
    }
    
    // 2 статуса и балк 200
    
    
    
}
@isTest
private class UploadCandidatePhotoControllerTest {
    
    @isTest static void test_uploadPhotoCorrectly(){
        //Given
        Candidate__c candidate = TestDataFactory.getRandomCandidate(true);
        UploadCandidatePhotoController controller = getController(candidate);
        initControllerFields(controller);
        
        //When
        Test.startTest();
        controller.uploadPhoto();
        Test.stopTest();
        
        //Then
        List<ContentVersion> contentVersions = [SELECT ContentDocumentId, Title FROM ContentVersion WHERE Title=:controller.photoName];      
        System.assertEquals(1, contentVersions.size());
        System.assertEquals(controller.photoName, contentVersions.get(0).title);
        
        List<ContentDocument> contentDocs = 
            [SELECT id, Title FROM ContentDocument WHERE id=:contentVersions.get(0).ContentDocumentId];       
        System.assertEquals(1, contentDocs.size());
        System.assertEquals(controller.photoName, contentDocs.get(0).title);
        
        List<ContentDocumentLink> contentDocLinks = 
            [SELECT id FROM ContentDocumentLink WHERE ContentDocumentId=:contentDocs.get(0).id AND LinkedEntityId = :candidate.id];
        System.assertEquals(1, contentDocLinks.size());
        
        System.assertEquals(contentVersions.get(0).id, controller.photoFileId);               
    }
    
    @isTest static void test_replacePhotoCorrectly(){
        //Given
        Candidate__c candidate = TestDataFactory.getRandomCandidate(true);
        UploadCandidatePhotoController controller = getController(candidate);
        initControllerFields(controller);
        
        //When
        Test.startTest();
        controller.uploadPhoto();
        
        //Given
        controller.photoName = 'testPhotoNew.jpeg';
        controller.uploadPhoto();
        Test.stopTest();
        
        //Then
        List<ContentVersion> contentVersions = [SELECT ContentDocumentId, Title FROM ContentVersion WHERE Title=:controller.photoName];      
        System.assertEquals(1, contentVersions.size());
        System.assertEquals(controller.photoName, contentVersions.get(0).title);
        
        List<ContentDocument> contentDocs = 
            [SELECT id, Title FROM ContentDocument WHERE id=:contentVersions.get(0).ContentDocumentId];       
        System.assertEquals(1, contentDocs.size());
        System.assertEquals(controller.photoName, contentDocs.get(0).title);
        
        List<ContentDocumentLink> contentDocLinks = 
            [SELECT id FROM ContentDocumentLink WHERE ContentDocumentId=:contentDocs.get(0).id AND LinkedEntityId = :candidate.id];
        System.assertEquals(1, contentDocLinks.size());
        
        System.assertEquals(contentVersions.get(0).id, controller.photoFileId);       
    }
    
    @isTest static void test_uploadPhotoFileIsNull(){
        Candidate__c candidate = TestDataFactory.getRandomCandidate(true);
        UploadCandidatePhotoController controller = getController(candidate);
        initControllerFields(controller);
        controller.photo = null;
        
        //When
        Test.startTest();
        controller.uploadPhoto();
        Test.stopTest();
        
        //Then
        List<ContentDocument> contentDocs = [SELECT id, Title FROM ContentDocument];       
        System.assert(contentDocs.isEmpty());
        System.assertEquals(null, controller.photoFileId);
        
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        System.assert(msgs.get(0).getDetail().contains(System.Label.ImageNull));      
    }
    
    @isTest static void test_uploadPhotoFileOverSizeLimit(){
        Candidate__c candidate = TestDataFactory.getRandomCandidate(true);
        UploadCandidatePhotoController controller = getController(candidate); 
        initControllerFields(controller);
        controller.photoSize ='1048577';
        
        //When
        Test.startTest();
        controller.uploadPhoto();
        Test.stopTest();
        
        //Then
        List<ContentDocument> contentDocs = [SELECT id, Title FROM ContentDocument];       
        System.assert(contentDocs.isEmpty());
        System.assertEquals(null, controller.photoFileId);
        
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        System.assert(msgs.get(0).getDetail().contains(System.Label.ImageBig));       
    }
    
    @isTest static void test_uploadPhotoInvalidFileType(){
        Candidate__c candidate = TestDataFactory.getRandomCandidate(true);
        UploadCandidatePhotoController controller = getController(candidate);
        initControllerFields(controller);
        controller.photoContentType = 'image/jpeg7'; 
        
        //When
        Test.startTest();
        controller.uploadPhoto();
        Test.stopTest();
        
        //Then
        List<ContentDocument> contentDocs = [SELECT id, Title FROM ContentDocument];       
        System.assert(contentDocs.isEmpty());
        System.assertEquals(null, controller.photoFileId);
        
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        System.assert(msgs.get(0).getDetail().contains(System.Label.ImageInvalid));       
    }
    
    @isTest static void test_SavePhotoToFileExceptionWithRollback(){
        //Given
        Candidate__c candidate = TestDataFactory.getRandomCandidate(true);
        UploadCandidatePhotoController controller = getController(candidate);
        initControllerFields(controller);
        delete candidate;
        
        //When
        Test.startTest();    
        controller.uploadPhoto();         
        Test.stopTest();
        
        //Then
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        Boolean isFound = false;
        for(Apexpages.Message msg:msgs){
            if(msg.getDetail().contains(System.Label.Exc_SavePhoto)){
                isFound = true;}}
        System.assert(isFound);
        
        //ContentDocument record should be lolledback
        List<ContentDocument> contentDocs = [SELECT id, Title FROM ContentDocument];       
        System.assert(contentDocs.isEmpty());
        System.assertEquals(null, controller.photoFileId);       
    }
    
    @isTest static void test_ClearPhotoException(){
        //Given
        Candidate__c candidate = TestDataFactory.getRandomCandidate(true);
        UploadCandidatePhotoController controller = getController(candidate);
        initControllerFields(controller);
              
        //When
        Test.startTest();    
        controller.uploadPhoto(); 

        //Given   
        controller.photoFileId = controller.photoFileId+'test';
        controller.uploadPhoto();     
        Test.stopTest();
        
        //Then
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        Boolean isFound = false;
        for(Apexpages.Message msg:msgs){
            if(msg.getDetail().contains(System.Label.Exc_ReplacePhoto)){
                isFound = true;}}
        System.assert(isFound);              
    }
    
    @isTest static void test_RollbackIfNewPhotoIsInvalidUnderReplacing(){     
         //Given
        Candidate__c candidate = TestDataFactory.getRandomCandidate(true);
        UploadCandidatePhotoController controller = getController(candidate);
        initControllerFields(controller);
        Id candidateIdReserved = controller.candidate.id;
              
        //When
        Test.startTest();    
        controller.uploadPhoto(); 

        //Given  
        delete candidate; 
        controller.uploadPhoto();     
        Test.stopTest();
        
        //Then
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        Boolean isFound = false;
        for(Apexpages.Message msg:msgs){
            if(msg.getDetail().contains(System.Label.Exc_SavePhoto)){
                isFound = true;}}
        System.assert(isFound);
        
         //All previous data (created before adding of new photo) should exist
        List<ContentVersion> contentVersions = [SELECT ContentDocumentId, Title FROM ContentVersion WHERE Title=:controller.photoName];      
        System.assertEquals(1, contentVersions.size());
        System.assertEquals(controller.photoName, contentVersions.get(0).title);
        System.debug('Here1');
        List<ContentDocument> contentDocs = 
            [SELECT id, Title FROM ContentDocument WHERE id=:contentVersions.get(0).ContentDocumentId];       
        System.assertEquals(1, contentDocs.size());
        System.assertEquals(controller.photoName, contentDocs.get(0).title);
        List<ContentDocumentLink> contentDocLinks = 
            [SELECT id FROM ContentDocumentLink WHERE ContentDocumentId=:contentDocs.get(0).id];
        System.assertEquals(1, contentDocLinks.size());
        System.assertEquals(contentVersions.get(0).id, controller.photoFileId);       
    }
       
    private static UploadCandidatePhotoController getController(Candidate__c candidate){
        ApexPages.StandardController standardController = new ApexPages.StandardController(candidate);       
        return new UploadCandidatePhotoController(standardController);
    }
    
    private static void initControllerFields(UploadCandidatePhotoController controller){
        Blob photo = Blob.valueOf('photo');
        controller.photo = photo;
        controller.photoSize ='1048576'; 
        controller.photoName = 'testPhoto.jpeg';
        controller.photoContentType = 'image/jpeg';
    }
    
}
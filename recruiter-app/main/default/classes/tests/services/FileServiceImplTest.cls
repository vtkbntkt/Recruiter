@isTest
private class FileServiceImplTest {
    
    
     @IsTest static void test_saveFilesCorrectly(){
        //Given
        Candidate__c candidate = TestDataFactory.getRandomCandidate(true);
        FileDetails fileDetails = new FileDetails('test.gif',Blob.valueOf('test.txt'),'I','AllUsers', candidate.id);
        List<FileDetails> fdList = new List<FileDetails>{fileDetails};
        FileServiceImpl service = new FileServiceImpl();
        
        
        //When
        Test.startTest();
        service.saveFiles(fdList);
        Test.stopTest();
        
        //Then
        List<ContentVersion> contentVersions = [SELECT ContentDocumentId, Title FROM ContentVersion];      
        System.assertEquals(1, contentVersions.size());
        System.assertEquals(fdList.get(0).fileName, contentVersions.get(0).title);
        
        List<ContentDocument> contentDocs = 
            [SELECT id, Title FROM ContentDocument WHERE id=:contentVersions.get(0).ContentDocumentId];       
        System.assertEquals(1, contentDocs.size());
        System.assertEquals(fdList.get(0).fileName, contentDocs.get(0).title);
        
        List<ContentDocumentLink> contentDocLinks = 
            [SELECT id FROM ContentDocumentLink WHERE ContentDocumentId=:contentDocs.get(0).id AND LinkedEntityId = :candidate.id];
        System.assertEquals(1, contentDocLinks.size());

        System.assertEquals(contentVersions.get(0).id, fdList.get(0).contentVersionId);       
    }

     @IsTest static void test_saveFilesExc(){
        //Given
        Candidate__c candidate = TestDataFactory.getRandomCandidate(true);
        FileDetails fileDetails = new FileDetails('test.gif',Blob.valueOf('test.txt'),'I','AllUsers', candidate.id);
        List<FileDetails> fdList = new List<FileDetails>{fileDetails};
        FileServiceImpl service = new FileServiceImpl();
        delete candidate;
        
        //When
        Test.startTest();
        try{
            service.saveFiles(fdList);
            System.assert(false,'expected exception');
        }
        catch(Exception exc){
            //Then
            System.assert(exc instanceOf SaveFileException);
        }
        Test.stopTest();     
    }

    @IsTest static void test_saveFilesCorrectlyBulk(){
        //Given
        Integer recordNum = 3;
        List<Candidate__c> candidates = TestDataFactory.getRandomCandidates(recordNum,true);
        List<FileDetails> fileDetailsList = TestDataFactory.getFileDetailsList(candidates);
        FileServiceImpl service = new FileServiceImpl();
        
        //When
        Test.startTest();
        service.saveFiles(fileDetailsList);
        Test.stopTest();
        
        //Then
        Map<Id, Candidate__c> candidateMap = new Map<Id, Candidate__c>(candidates);
        List<Id> candidateIds = new List<ID>(candidateMap.keySet());
        List<ContentDocumentLink> links = 
        [SELECT LinkedEntityId, ContentDocument.title FROM ContentDocumentLink WHERE LinkedEntityId IN :candidateIds];
        System.assertEquals(recordNum,links.size());
        Boolean result = true;
        for(ContentDocumentLink item:links){
            Candidate__c currentCandidate = candidateMap.get(item.LinkedEntityId);
            if(currentCandidate.First_Name__c!=item.ContentDocument.title){
                result = false;
            }
        }
        System.assert(result);
    }


     @IsTest static void test_removeFilesBulk(){
        Integer recordNum = 3;
        List<Candidate__c> candidates = TestDataFactory.getRandomCandidates(recordNum,true);
        List<FileDetails> fileDetailsList = TestDataFactory.getFileDetailsList(candidates);
        FileServiceImpl service = new FileServiceImpl();
        
        //When
        Test.startTest();
        service.saveFiles(fileDetailsList);
        
        
        //Then
        Map<Id, Candidate__c> candidateMap = new Map<Id, Candidate__c>(candidates);
        List<Id> candidateIds = new List<ID>(candidateMap.keySet());
        List<ContentDocumentLink> links = 
        [SELECT LinkedEntityId, ContentDocument.title FROM ContentDocumentLink WHERE LinkedEntityId IN :candidateIds];
        System.assertEquals(recordNum,links.size());

        List<Id> contentVersionIds = new List<Id>();
        for(FileDetails item:fileDetailsList){
            contentVersionIds.add(item.contentVersionId);

        }
        service.removeFilesByContentVersionIds(contentVersionIds);

        links = [SELECT LinkedEntityId, ContentDocument.title FROM ContentDocumentLink WHERE LinkedEntityId IN :candidateIds];
        System.assert(links.isEmpty());
        Test.stopTest();    
    }
    
}

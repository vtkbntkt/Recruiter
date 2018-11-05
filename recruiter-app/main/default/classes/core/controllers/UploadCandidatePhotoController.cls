public class UploadCandidatePhotoController {
    public Candidate__c candidate;
    public static final Integer FILE_SIZE_LIMIT = 1048576;
    public static final Set<String> FILE_EXTENSIONS_ALLOWED = new Set<String>{'image/jpeg','image/gif','image/pjpeg','image/png'};
        public transient Blob photo{get; set;}
    public String photoName{get; set;}
    public String photoSize{get; set;}
    public String photoContentType{get; set;}
    public String photoFileId{get; set;}
    
    public UploadCandidatePhotoController(ApexPages.StandardController stdController) {
        this.candidate = (Candidate__c)stdController.getRecord();
        photoFileId = [SELECT PhotoFileId__c FROM Candidate__c WHERE id=:candidate.id].get(0).PhotoFileId__c;       
    }
    
    private void clearPhoto(){
        try{
        ContentDocument contentDoc = 
            [SELECT id FROM ContentDocument WHERE id IN (SELECT ContentDocumentId FROM ContentVersion WHERE id=:photoFileId)];        
            delete contentDoc;
        }
         catch(DmlException dmlExc){
            throw new ClearPhotoException(dmlExc.getMessage());
        }
        catch(QueryException queryExc){
            throw new ClearPhotoException(queryExc.getMessage());
        }
    }
    
    public void uploadPhoto(){        
        List<String> errors = getErrors();
        if(errors.isEmpty()){ 
            Savepoint savePoint = Database.setSavepoint();
            try{
                if (photoFileId!=null){            
                    clearPhoto();         
                }
                addPhotoToFiles();                
            }
            catch(ClearPhotoException exc){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Exc_ReplacePhoto));
            }
            catch(SavePhotoToFileException exc){
                Database.rollback(savePoint);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Exc_SavePhoto));
            }           
        }
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, String.join(errors,'\r\n')));   //' \r\n'       
        }
        
    }
    
    private void addPhotoToFiles(){
        try{          
            ContentVersion contentVersion = getContentVersion();
            insert contentVersion;
            Id contentDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersion.Id].ContentDocumentId;
            ContentDocumentLink contentDocLink = getContentDocLink(contentDocId);
            insert contentDocLink;
            photoFileId = contentVersion.id;
            candidate.PhotoFileId__c = contentVersion.id;
            update candidate;
        }
        catch(DmlException dmlExc){
            throw new SavePhotoToFileException(dmlExc.getMessage());
        }
        catch(QueryException queryExc){
            throw new SavePhotoToFileException(queryExc.getMessage());
        }
    }
    
    
    private ContentVersion getContentVersion(){
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.versionData = photo;
        contentVersion.title = photoName;
        contentVersion.pathOnClient =photoName;
        return contentVersion;       
    }
    
    private ContentDocumentLink getContentDocLink(Id contentDocId){
        ContentDocumentLink contentDocLink = new ContentDocumentLink();
        contentDocLink.ContentDocumentId = contentDocId;
        contentDocLink.LinkedEntityId = candidate.Id;
        contentDocLink.ShareType = 'I'; 
        contentDocLink.Visibility = 'AllUsers';
        return contentDocLink;
    }
       
    private List<String> getErrors(){
        List<String> errors = new List<String>(); 
        if(photo==null){
            errors.add(System.Label.ImageNull);
            return errors;
        }
        if(Integer.valueOf(photoSize)>FILE_SIZE_LIMIT){
            errors.add(System.Label.ImageBig);
            
        }
        if (!FILE_EXTENSIONS_ALLOWED.contains(photoContentType)){
            errors.add(System.Label.ImageInvalid);
        }       
        return errors;        
    }
    
    public class SavePhotoToFileException extends Exception{}
    public class ClearPhotoException extends Exception{}
    
}
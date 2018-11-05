public class FileServiceImpl implements IfileService {
    private List<WrappedFileDetails> wrappedFileDetails;
    
    public FileServiceImpl() {
        wrappedFileDetails = new List<WrappedFileDetails>();
    }


    public void saveFiles(List<FileDetails> fileDetails){
        try{
            initWrappedFileDetails(fileDetails);
            List<ContentVersion> contentVersions = prepareContentVersions();
            insert contentVersions;
            Map<Id,ContentVersion> contentVersionMap = new Map<Id,ContentVersion>(contentVersions);
            List<ContentVersion> retrievedContentVersions = [SELECT ContentDocumentId FROM ContentVersion WHERE id IN:contentVersionMap.keySet()];
            fillContentDocIds(retrievedContentVersions);
            insert prepareContentDocLinks();
            updateFileDetails();
        }
        catch (DmlException exc){
             throw new SaveFileException(exc.getMessage(), exc);
        }
    }

    public void removeFilesByContentVersionIds(List <Id> contentVersionIds){
        try{
            List<ContentDocument> contentDocs = 
            [SELECT id FROM ContentDocument WHERE id IN (SELECT ContentDocumentId FROM ContentVersion WHERE id IN :contentVersionIds)];        
            delete contentDocs;
        }
        catch(DmlException exc){
            throw new ClearFileException(exc);
        }
    }

    private void initWrappedFileDetails(List<FileDetails> fileDetails){
        for(FileDetails fileDetailsItem:fileDetails){
            wrappedFileDetails.add(new WrappedFileDetails(fileDetailsItem));
        }
    }


    private List<ContentVersion> prepareContentVersions(){
     List<ContentVersion> contentVersions = new List<ContentVersion>();
     for(WrappedFileDetails item:wrappedFileDetails){
         contentVersions.add(item.contentVersion);
     }
     return contentVersions;

    }

    private void fillContentDocIds(List<ContentVersion> retrievedContentVersions){
        Map<Id, ContentVersion> retrievedContentVersionMap = new Map<Id, ContentVersion>(retrievedContentVersions);
        for(WrappedFileDetails item:wrappedFileDetails){
            item.contentDocumentId = retrievedContentVersionMap.get(item.contentVersion.id).ContentDocumentId;
        }
    }

    private List<ContentDocumentLink> prepareContentDocLinks(){
        List<ContentDocumentLink> contentDocLinks = new List<ContentDocumentLink>();
        for(WrappedFileDetails item:wrappedFileDetails ){
            contentDocLinks.add(
                new ContentDocumentLink(ContentDocumentId = item.contentDocumentId, 
                LinkedEntityId = item.fileDetails.relatedEntityId,
                ShareType = item.fileDetails.shareType,
                Visibility = item.fileDetails.visibility));
        }
        return contentDocLinks;
    } 

    private void updateFileDetails(){
        for(WrappedFileDetails item:wrappedFileDetails){
            item.updateContentVersionId();
        }
    }

    private class WrappedFileDetails{
        public FileDetails fileDetails{get;set;}
        public ContentVersion contentVersion{get;set;}
        public Id contentDocumentId{get;set;}

        public wrappedFileDetails(FileDetails fileDetails){
            this.fileDetails = fileDetails;
            contentVersion = new ContentVersion(
                versionData = fileDetails.fileContent,
                title = fileDetails.fileName,
                pathOnClient =fileDetails.fileName);
        }

        public void updateContentVersionId(){
            fileDetails.contentVersionId = contentVersion.id;
        }
        
    }
}

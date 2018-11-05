public  class FileDetails {
    public String fileName{get;set;}
    public Blob fileContent{get;set;}
    public String shareType{get;set;}
    public String visibility{get;set;}
    public id relatedEntityId{get;set;}
    public id contentVersionId{get;set;}
    
    public FileDetails(String fileName, Blob fileContent, String shareType, String visibility, id relatedEntityId) {
        this.fileName = fileName;
        this.fileContent = fileContent;
        this.shareType = shareType;
        this.visibility = visibility;
        this.relatedEntityId = relatedEntityId;

    }

    public FileDetails(String fileName, String fileContent, String shareType, String visibility, id relatedEntityId) {
        this(fileName, 
        //EncodingUtil.base64Decode(fileContent.substring(fileContent.indexOf(',') + 1, fileContent.length()-1)), 
        EncodingUtil.base64Decode(fileContent), 
        shareType, 
        visibility, 
        relatedEntityId);


    }
}

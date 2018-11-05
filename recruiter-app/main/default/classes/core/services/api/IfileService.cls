public interface IfileService {
    
    void saveFiles(List<FileDetails> fileDetails);
    void removeFilesByContentVersionIds(List <Id> contentVersionIds);
}

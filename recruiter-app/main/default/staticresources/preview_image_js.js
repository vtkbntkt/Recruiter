var uploadInput;
var currentImage;
var input;
var preview;



function initPreview(uploadId,imageId){
    uploadInput = document.getElementById(uploadId); 
    currentImage = document.getElementById(imageId);
    uploadInput.style.visibility = 'hidden';   
    input = uploadInput;
    preview = document.querySelector('.preview');
    input.addEventListener('change', updateImageDisplay);             
}

function updateImageDisplay(){       
    clearImgBlock();      
    var curFiles = input.files;
    if(curFiles.length === 0) {
        var para = document.createElement('p');
        para.textContent = 'No files selected';
        preview.appendChild(para);
    }
    else{          
        var para = document.createElement('p');           
        if(validFileType(curFiles[0])){
            para.textContent = 'File ' + curFiles[0].name + ', size ' + returnFileSize(curFiles[0].size) + '.';
            var image = document.createElement('img');
            image.src = window.URL.createObjectURL(curFiles[0]);
            preview.appendChild(image);
            currentImage.style.display = "none";
        }           
        else{
            para.textContent = 'File ' + curFiles[0].name + ': Invalid type';                
        }
        preview.appendChild(para);          
    }     
}

function clearImgBlock(){
    while(preview.firstChild) {
        preview.removeChild(preview.firstChild);
    }
    
}

var fileTypes = [
    'image/jpeg',
    'image/pjpeg',
    'image/png'
]
function validFileType(file) {
    for(var i = 0; i < fileTypes.length; i++) {
        if(file.type === fileTypes[i]) {
            return true;
        }
    }
    return false;
}

function returnFileSize(number) {
    if(number < 1024) {
        return number + 'bytes';
    } else if(number > 1024 && number < 1048576) {
        return (number/1024).toFixed(1) + 'KB';
    } else if(number > 1048576) {
        return (number/1048576).toFixed(1) + 'MB';
    }
}   
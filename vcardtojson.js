var vcard = require('vcard-json');
 
vcard.parseVcardFile('allPeople.vcf', function(err, data){
  if(err) console.log('oops:'+ err);
  else {
    console.log('should be good to go:\n'+ JSON.stringify(data));    
  }
});
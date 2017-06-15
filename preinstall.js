var os = require('os')
var fs = require('fs');
var dir = os.homedir()+"/.atom/snippets"

if (!fs.existsSync(dir)){
    fs.mkdirSync(dir);
}

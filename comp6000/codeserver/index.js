const express = require('express');
const bodyParser = require('body-parser');
const jsonParser = bodyParser.json();
const cors = require('cors');
const { NodeVM } = require('vm2');
const port = 3000;
const app = express();

app.use(cors());

app.post('/run', jsonParser, (req, res) => {
    console.log('------');
    console.log(req.body);

    const vm = new NodeVM({
        console: 'redirect',
    });

    let logs = [];

    vm.on('console.log', data => {
        console.log('vm log data: ', data);
        logs.push({
            type: 'log',
            data: data
        });
    });

    vm.on('console.warn', data => {
        console.log('vm warn data: ', data);
        logs.push({
            type: 'warn',
            data: data
        });
    });

    vm.on('console.error', data => {
        console.log('vm error data: ', data);
        logs.push({
            type: 'error',
            data: data
        });
    });

    let output;
    let error;
    try {
        let userCode = req.body.code;
        userCode += '\nmodule.exports = ' + req.body.run;
        let test = vm.run(userCode);
        output = test('5');
        console.log(output);
    } catch (e) {
        console.error(e.stack);
        error = e.message;
    }

    console.log('------');

    let result = {
        logs: logs,
        output: output
    };
    if (error) {
        result.error = error;
    }
    res.send(result);
});

app.listen(port, () => {
    console.log('Server is on');
});
const express = require('express');
const bodyParser = require('body-parser');
const jsonParser = bodyParser.json();
const cors = require('cors');
const { fork } = require('child_process');
const port = 3000;
const app = express();

const maxExecutionTime = 2000;

app.use(cors());

app.post('/run', jsonParser, (req, res) => {
    const vm = fork('container.js');

    const timer = setTimeout(() => {
        vm.kill();
        console.log("killed the vm");
        res.send({error: 'timeout'});
    }, maxExecutionTime);

    vm.on('message', msg => {
        clearTimeout(timer);
        console.log(msg);
        res.send(msg);
    });

    vm.send(req.body);
});

app.listen(port, () => {
    console.log('Server is on');
});
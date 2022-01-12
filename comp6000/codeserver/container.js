const { NodeVM } = require('vm2');

const vm = new NodeVM({
    console: 'redirect',
});

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

let logs = [];
let output;
let error;

process.on('message', msg => {
    try {
        userCode = msg.code + '\nmodule.exports = ' + msg.run;
        const container = vm.run(userCode);
        output = container(...msg.args);
    } catch (e) {
        console.error(e.stack);
        error = e.message;
    }

    let result = {
        logs: logs,
        output: output
    };
    if (error) {
        result.error = error;
    }
    process.send(result);
})


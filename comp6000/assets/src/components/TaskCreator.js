class TaskCreator extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            tasks: [
                {
                    detail: 'Example task...',
                    tests: [
                        {
                            run: '',
                            args: [],
                            output: {
                                type: 'string',
                                value: '',
                                isValid: true
                            }
                        }
                    ]
                }
            ]
        };

        this.onDetailChange = this.onDetailChange.bind(this);
        this.addTask = this.addTask.bind(this);
        this.removeTask = this.removeTask.bind(this);
        this.addTest = this.addTest.bind(this);
        this.removeTest = this.removeTest.bind(this);
        this.onTestRunUpdate = this.onTestRunUpdate.bind(this);
        this.addTestArgument = this.addTestArgument.bind(this);
        this.removeTestArgument = this.removeTestArgument.bind(this);
        this.onTestArgumentUpdate = this.onTestArgumentUpdate.bind(this);
        this.validateInput = this.validateInput.bind(this);
        this.onTestOutputUpdate = this.onTestOutputUpdate.bind(this);
    }

    onDetailChange(taskNum, event) {
        let updatedTasks = this.state.tasks;
        updatedTasks[taskNum].detail = event.target.value;
        this.setState({ tasks: updatedTasks });
    }

    addTask() {
        let updatedTasks = this.state.tasks;
        updatedTasks.push({
            detail: '',
            tests: [
                {
                    run: '',
                    args: [],
                    output: {
                        type: 'string',
                        value: '',
                        isValid: true
                    }
                }
            ]
        });
        this.setState({ tasks: updatedTasks });
    }

    removeTask(taskNum) {
        let updatedTasks = this.state.tasks;
        updatedTasks.splice(taskNum, 1);
        if (updatedTasks.length === 0) {
            updatedTasks = [
                {
                    detail: '',
                    tests: [
                        {
                            run: '',
                            args: [],
                            output: {
                                type: 'string',
                                value: '',
                                isValid: true
                            }
                        }
                    ]
                }
            ];
        }
        this.setState({ tasks: updatedTasks });
    }

    addTest(taskNum) {
        let updatedTasks = this.state.tasks;
        updatedTasks[taskNum].tests.push({
            run: '',
            args: [],
            output: {
                type: 'string',
                value: '',
                isValid: true
            }
        });
        this.setState({ tasks: updatedTasks });
    }

    removeTest(taskNum, testNum) {
        let updatedTasks = this.state.tasks;
        updatedTasks[taskNum].tests.splice(testNum, 1);
        if (updatedTasks[taskNum].tests.length === 0) {
            updatedTasks[taskNum].tests = [
                {
                    run: '',
                    args: [],
                    output: {
                        type: 'string',
                        value: '',
                        isValid: true
                    }
                }
            ]
        }
        this.setState({ tasks: updatedTasks });
    }

    onTestRunUpdate(taskNum, testNum, event) {
        let updatedTasks = this.state.tasks;
        updatedTasks[taskNum].tests[testNum].run = event.target.value
        this.setState({ tasks: updatedTasks });
    }

    addTestArgument(taskNum, testNum) {
        let updatedTasks = this.state.tasks;
        updatedTasks[taskNum].tests[testNum].args.push({
            type: 'string',
            value: '',
            isValid: true
        });
        console.log(updatedTasks);
        this.setState({ tasks: updatedTasks });
    }

    removeTestArgument(taskNum, testNum, argNum) {
        let updatedTasks = this.state.tasks;
        updatedTasks[taskNum].tests[testNum].args.splice(argNum, 1);
        this.setState({ tasks: updatedTasks });
    }

    onTestArgumentUpdate(taskNum, testNum, argNum, type, value) {
        let updatedTasks = this.state.tasks;
        updatedTasks[taskNum].tests[testNum].args[argNum] = {
            type: type,
            value: value,
            isValid: this.validateInput(type, value)
        }
        this.setState({ tasks: updatedTasks });
    }

    validateInput(type, value) {
        if (type == 'number' && (value === '' || isNaN(Number(value)))) {
            return false;
        } else if (type == 'object') {
            try {
                JSON.parse(value);
            } catch (e) {
                return false;
            }
        }
        return true;
    }

    onTestOutputUpdate(taskNum, testNum, type, value) {
        let updatedTasks = this.state.tasks;
        updatedTasks[taskNum].tests[testNum].output = {
            type: type,
            value: value,
            isValid: this.validateInput(type, value)
        }
        this.setState({ tasks: updatedTasks });
    }

    render() {
        return (
            <div>
                {
                    this.state.tasks.map((task, taskNum) => {
                        return (
                            <div key={taskNum}>
                                <h3>Task {taskNum + 1}</h3>
                                <input
                                    type="text"
                                    value={task.detail}
                                    onChange={(e) => { this.onDetailChange(taskNum, e); }}
                                />
                                <div>
                                    {
                                        task.tests.map((test, testNum) => {
                                            return (
                                                <div key={testNum}>
                                                    <label>
                                                        <p>The function to run</p>
                                                        <input
                                                            type="text"
                                                            value={test.run}
                                                            onChange={(e) => { this.onTestRunUpdate(taskNum, testNum, e); }}
                                                        />
                                                    </label>
                                                    <p>The arguments to provide</p>
                                                    <button
                                                        className="button secondary"
                                                        onClick={() => { this.addTestArgument(taskNum, testNum); }}>
                                                        Add Argument
                                                    </button>
                                                    {
                                                        test.args.map((arg, argNum) => {
                                                            return (
                                                                <div key={argNum}>
                                                                    <span className={"inline-block" + (arg.isValid ? "" : " invalid-input")}>
                                                                        <select
                                                                            value={arg.type}
                                                                            onChange={(e) => { this.onTestArgumentUpdate(taskNum, testNum, argNum, e.target.value, arg.value); }}>
                                                                            <option value="string">string</option>
                                                                            <option value="number">number</option>
                                                                            <option value="object">object/array</option>
                                                                        </select>
                                                                        <input
                                                                            type="text"
                                                                            value={arg.value}
                                                                            onChange={(e) => { this.onTestArgumentUpdate(taskNum, testNum, argNum, arg.type, e.target.value); }} />
                                                                    </span>
                                                                    <button
                                                                        className="button tertiary"
                                                                        onClick={() => { this.removeTestArgument(taskNum, testNum, argNum); }}>
                                                                        Remove Argument
                                                                    </button>
                                                                </div>
                                                            );
                                                        })
                                                    }
                                                    <p>Expected return value</p>
                                                    <span className={"inline-block" + (test.output.isValid ? "" : " invalid-input")}>
                                                        <select
                                                            value={test.output.type}
                                                            onChange={(e) => { this.onTestOutputUpdate(taskNum, testNum, e.target.value, test.output.value); }}>
                                                            <option value="string">string</option>
                                                            <option value="number">number</option>
                                                            <option value="object">object/array</option>
                                                        </select>
                                                        <input
                                                            type="text"
                                                            value={test.output.value}
                                                            onChange={(e) => { this.onTestOutputUpdate(taskNum, testNum, test.output.type, e.target.value); }} />
                                                    </span>
                                                </div>
                                            );
                                        })
                                    }
                                    <button className="button secondary" onClick={() => { this.addTest(taskNum) }}>Add Test</button>
                                </div>
                                <button className="button tertiary" onClick={() => { this.removeTask(taskNum) }}>Remove Task</button>
                            </div>
                        );
                    })
                }
                <button className="button secondary" onClick={this.addTask}>Add Task</button>
            </div>
        )
    }
}

export default TaskCreator;
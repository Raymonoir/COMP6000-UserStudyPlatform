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
        this.parseInput = this.parseInput.bind(this);
        this.onTestOutputUpdate = this.onTestOutputUpdate.bind(this);
        this.complete = this.complete.bind(this);
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

    parseInput(type, value) {
        if (type == 'number') {
            return Number(value);
        } else if (type == 'object') {
            return JSON.parse(value);
        } else {
            return value;
        }
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

    complete() {
        // No need to keep the annotated type for each argument or return value so convert them
        // to the type and discard that before the tasks get sent to the backend
        let hasInvalidInput = false;
        let updatedTasks = [];
        this.state.tasks.forEach((task, taskNum) => {
            let updatedTask = {
                detail: task.detail,
                tests: []
            };
            task.tests.forEach((test, testNum) => {
                if (!test.output.isValid) {
                    hasInvalidInput = true;
                    return;
                }
                updatedTask.tests[testNum] = {
                    run: test.run,
                    args: [],
                    output: this.parseInput(test.output.type, test.output.value)
                };
                test.args.forEach((arg, argNum) => {
                    if (!arg.isValid) {
                        hasInvalidInput = true;
                        return;
                    }
                    updatedTask.tests[testNum].args[argNum] = this.parseInput(arg.type, arg.value);
                })
            });
            updatedTasks[taskNum] = updatedTask;
        });

        if (!hasInvalidInput) {
            console.log('valid', updatedTasks);
            this.props.saveTasks(updatedTasks);
        }
    }

    render() {
        return (
            <div>
                {
                    this.state.tasks.map((task, taskNum) => {
                        return (
                            <div className="new-task" key={taskNum}>
                                <h3>Task {taskNum + 1}</h3>
                                <div className="new-task-detail">
                                    <input
                                        className="new-task-text"
                                        type="text"
                                        value={task.detail}
                                        onChange={(e) => { this.onDetailChange(taskNum, e); }}
                                    />
                                    <button className="button tertiary" onClick={() => { this.removeTask(taskNum) }}>Remove Task</button>
                                </div>
                                <div>
                                    {
                                        task.tests.map((test, testNum) => {
                                            return (
                                                <div className="new-task-test" key={testNum}>
                                                    <h3>Test {testNum + 1}</h3>
                                                    <label>
                                                        <h3>Function name</h3>
                                                        <input
                                                            type="text"
                                                            value={test.run}
                                                            onChange={(e) => { this.onTestRunUpdate(taskNum, testNum, e); }}
                                                        />
                                                    </label>
                                                    <h3>Arguments</h3>
                                                    {test.args.length === 0 &&
                                                        <p>No arguments</p>
                                                    }
                                                    {
                                                        test.args.map((arg, argNum) => {
                                                            return (
                                                                <div className="spaced-out-row" key={argNum}>
                                                                    <span className={"spaced-out-row" + (arg.isValid ? " valid-input" : " invalid-input")}>
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
                                                    <button
                                                        className="button secondary"
                                                        onClick={() => { this.addTestArgument(taskNum, testNum); }}>
                                                        Add Argument
                                                    </button>
                                                    <h3>Expected return value</h3>
                                                    <span className={"spaced-out-row" + (test.output.isValid ? " valid-input" : " invalid-input")}>
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
                                                    {task.tests.length > 1 && testNum != task.tests.length - 1 &&
                                                        <hr />
                                                    }
                                                </div>
                                            );
                                        })
                                    }
                                    <button className="button secondary" onClick={() => { this.addTest(taskNum) }}>Add Test</button>
                                </div>
                                {this.state.tasks.length > 1 && taskNum != this.state.tasks.length - 1 &&
                                    <hr />
                                }
                            </div>
                        );
                    })
                }
                <div className="bottom-buttons">
                    <button className="button secondary" onClick={this.addTask}>Add Task</button>
                    <button className="button primary" onClick={this.complete}>Complete</button>
                </div>
            </div>
        )
    }
}

export default TaskCreator;
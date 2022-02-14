import Questionnaire from './Questionnaire';
import AnswerSession from './AnswerSession';
import Editor from './Editor';
import CodeRunner from './CodeRunner';
import TaskList from './TaskList';
import Popup from './Popup';
import backend from '../helpers/backend';

class StudyManager extends React.Component {
    constructor(props) {
        super(props)
        this.state = {
            stage: 0,
            /* study: {
                "overview": "Welcome to our study about blah blah....",
                "backgroundQuestionnaire": [
                    {
                        "question": "TESTING Select something from this dropdown",
                        "type": "dropdown",
                        "options": [
                            "option A",
                            "option B"
                        ]
                    },
                    {
                        "question": "Type in some answer",
                        "type": "text"
                    },
                    {
                        "question": "Select any number of these checkboxes",
                        "type": "checkbox",
                        "options": [
                            "option A",
                            "option B"
                        ]
                    }
                ],
                "tasks": [
                    {
                        "description": "Write a function 'add' which takes two numbers and adds them together",
                        "function": "add",
                        "tests": [
                            {
                                "inputs": [1, 2],
                                "output": 3
                            },
                            {
                                "inputs": [5, 5],
                                "output": 10
                            }
                        ]
                    },
                    {
                        "description": "Write a function 'mul' which takes two numbers and multiplies them together",
                        "function": "mul",
                        "tests": [
                            {
                                "inputs": [2, 6],
                                "output": 12
                            },
                            {
                                "inputs": [10, 1],
                                "output": 10
                            }
                        ]
                    }
                ],
                "postStudyQuestionnaire": [
                    {
                        "question": "Select something from this dropdown",
                        "type": "dropdown",
                        "options": [
                            "option A",
                            "option B"
                        ]
                    },
                    {
                        "question": "How did it go??",
                        "type": "text"
                    },
                    {
                        "question": "Select any number of these checkboxes",
                        "type": "checkbox",
                        "options": [
                            "option A",
                            "option B"
                        ]
                    }
                ],
            }, */
            study: {
                overview: "",
                backgroundQuestionnaire: [],
                tasks: []
            },
            lastRanCode: {
                code: '',
                function: '',
                arguments: []
            },
            showConsole: false,
            loading: false
        };

        console.log(this.props.match.params.key);
        backend.get('/api/participant/get-uuid')
            .then(data => {
                this.state.userUUID = data.current_participant;
            });

        backend.get('/api/study/get-by/participant-code/' + this.props.match.params.key)
            .then(data => {
                console.log(data.study);
                let updatedStudy = this.state.study;
                updatedStudy.id = data.study.id;
                let programmingTasks = [];

                // Grab a background survey from the tasks if there is one
                data.study.tasks.forEach(t => {
                    if (t.optional_info == 'background') {
                        updatedStudy.backgroundQuestionnaire = JSON.parse(t.content).questions;
                    } else {
                        programmingTasks.push(t);
                    }
                })


                updatedStudy.tasks = programmingTasks;
                for (let i = 0; i < updatedStudy.tasks.length; i++) {
                    updatedStudy.tasks[i].answer.content = JSON.parse(updatedStudy.tasks[i].answer.content);
                }
                console.log(updatedStudy);
                this.setState({ study: updatedStudy });
                console.log(updatedStudy);
            })

        this.submitQuestionnaire = this.submitQuestionnaire.bind(this);
        this.onCodeChange = this.onCodeChange.bind(this);
        this.runTest = this.runTest.bind(this);
        this.completeCoding = this.completeCoding.bind(this);
        this.runAllTests = this.runAllTests.bind(this);
    }

    submitQuestionnaire(type, answers) {
        console.log(type, answers);
        backend.post('/api/study/' + this.state.study.id + '/background/' + this.state.userUUID + '/submit', {
            content: JSON.stringify(answers)
        });
        this.setState({ stage: this.state.stage + 1 });
    }

    onCodeChange(code) {
        this.setState({ code: code });
    }

    runTest(taskNum, showResult, allowRetest = false) {
        return new Promise((resolve, reject) => {
            let task = this.state.study.tasks[taskNum];
            if (!this.state.code) {
                resolve(task.complete);
            } else if ((this.state.code == this.state.lastRanCode.code) && (this.state.lastRanCode.function == task.function) && task.complete != undefined) {
                // We have already tested if you have passed this test and the code hasn't been changed since then.
                // No need to waste time running the test again
                resolve(task.complete);
            } else {
                this.setState({
                    loading: true,
                    lastRanCode: {
                        code: this.state.code,
                        function: task.answer.content.tests[0].function,
                        arguments: task.answer.content.tests[0].inputs
                    },
                    onExecutionComplete: (result) => {
                        console.log('callback', result);
                        if (result.output == task.answer.content.tests[0].output) {
                            task.complete = true;
                        } else {
                            task.complete = false;
                        }
                        let updatedStudy = this.state.study;
                        updatedStudy.tasks[taskNum] = task;
                        let stateUpdate = {
                            study: updatedStudy,
                            showConsole: showResult,
                            loading: false
                        }

                        // Don't keep the test we ran stored to allow retesting again
                        if (allowRetest) {
                            stateUpdate.lastRanCode = {
                                code: '',
                                function: '',
                                arguments: []
                            }
                        }

                        this.setState(stateUpdate);
                        resolve(task.complete);
                    }
                });
            }
        });
    }

    /* 
    * This seems to be kind of terrible but it does work.
    * To start running all tests you should not provide any parameters here,
    * the parameters are only for the function itself to use in the recursive calls.
    * We need to keep track of the original resolve method for the first promise that is 
    * actually returned so that we can resolve the promise actually returned to the caller.
    */
    runAllTests(test = 0, originalResolve) {
        return new Promise((resolve, reject) => {
            this.runTest(test, false)
                .then((passed) => {
                    if (!passed) {
                        this.setState({
                            lastRanCode: {
                                code: '',
                                function: '',
                                arguments: []
                            }
                        });
                        if (originalResolve) {
                            originalResolve(false);
                        } else {
                            resolve(false);
                        }
                        return;
                    }

                    if (test < this.state.study.tasks.length - 1) {
                        // If we already have a resolve function from an earlier promise then ignore the one
                        // made here as it isn't the one returned to the original caller
                        this.runAllTests(test + 1, originalResolve ? originalResolve : resolve);
                    } else {
                        this.setState({
                            lastRanCode: {
                                code: '',
                                function: '',
                                arguments: []
                            }
                        });
                        if (originalResolve) {
                            originalResolve(true);
                        } else {
                            resolve(true);
                        }
                    }
                });
        });
    }

    completeCoding(force) {
        if (!force) {
            this.runAllTests()
                .then((passed) => {
                    if (!passed) {
                        this.setState({ showWarning: true });
                    } else {
                        this.setState({ stage: this.state.stage + 1 });
                    }
                })
        } else {
            this.setState({ stage: this.state.stage + 1 });
        }
    }

    render() {
        const editorView = (
            <div>
                {this.state.showWarning &&
                    <Popup
                        text={(<span>You failed one or more of the tests.<br />Would you still like to continue?</span>)}
                        buttons={[
                            {
                                text: 'Return to Code',
                                style: 'tertiary',
                                action: () => { this.setState({ showWarning: false }); }
                            },
                            {
                                text: 'Continue Anyway',
                                style: 'primary',
                                action: () => { this.completeCoding(true); }
                            }
                        ]}
                    />
                }
                <TaskList
                    tasks={this.state.study.tasks}
                    runTest={this.runTest}
                    disableTesting={this.state.loading}
                />
                <Editor onCodeChange={this.onCodeChange} />
                <CodeRunner
                    className={this.state.showConsole ? "" : "hidden"}
                    code={this.state.lastRanCode.code}
                    run={this.state.lastRanCode.function}
                    args={this.state.lastRanCode.arguments}
                    onExecutionComplete={this.state.onExecutionComplete}
                />
                <button
                    className="button primary"
                    onClick={() => { this.completeCoding(); }}
                    disabled={this.state.loading}
                >
                    Complete
                </button>
            </div>
        );

        if (this.state.stage === 0) {
            if (this.state.study.backgroundQuestionnaire) {
                return (<Questionnaire
                    questions={this.state.study.backgroundQuestionnaire}
                    onSubmit={this.submitQuestionnaire}
                    type="background"
                />);
            } else {
                return editorView;
            }
        } else if (this.state.stage == 1) {
            if (this.state.study.backgroundQuestionnaire) {
                return editorView;
            }
        } else if (this.state.study.postStudyQuestionnaire && (this.state.stage == 2 || !this.state.study.backgroundQuestionnaire)) {
            return (<Questionnaire
                questions={this.state.study.postStudyQuestionnaire}
                onSubmit={this.submitQuestionnaire}
                type="post"
            />);
        } else {
            return (
                <div className="container primary centered">
                    <h1>Thank you for participating</h1>
                    <p>Everything is complete</p>
                    <a href="/app/">Homepage</a>
                </div>
            );
        }
    }
}

export default StudyManager;
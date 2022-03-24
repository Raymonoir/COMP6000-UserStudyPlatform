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
                this.setState({ userUUID: data.current_participant });
            });

        backend.post('/api/study/get', {
            participant_code: this.props.match.params.key
        })
            .then(sData => {
                console.log(sData);
                let updatedStudy = this.state.study;
                updatedStudy.id = sData.study.id;
                updatedStudy.tasks = sData.study.tasks.map(task => {
                    task.answer = JSON.parse(task.answer.content);
                    return task;
                });
                this.setState({ study: updatedStudy });
                console.log('got tasks', updatedStudy);

                backend.post('/api/survey/pre/get', {
                    study_id: sData.study.id
                })
                    .then(preQuestionnaire => {
                        let updatedStudy = this.state.study;
                        updatedStudy.backgroundQuestionnaire = preQuestionnaire.survey_question.questions.map(q => {
                            return JSON.parse(q);
                        });
                        this.setState({ study: updatedStudy });
                        console.log(updatedStudy);
                    });

                backend.post('/api/survey/post/get', {
                    study_id: sData.study.id
                })
                    .then(postQuestionnaire => {
                        let updatedStudy = this.state.study;
                        updatedStudy.postStudyQuestionnaire = postQuestionnaire.survey_question.questions.map(q => {
                            return JSON.parse(q);
                        });
                        this.setState({ study: updatedStudy });
                    });
            });

        this.submitQuestionnaire = this.submitQuestionnaire.bind(this);
        this.onCodeChange = this.onCodeChange.bind(this);
        this.runTest = this.runTest.bind(this);
        this.completeCoding = this.completeCoding.bind(this);
        this.runAllTests = this.runAllTests.bind(this);
        this.uploadReplayData = this.uploadReplayData.bind(this);
    }

    submitQuestionnaire(type, answers) {
        console.log(type, answers);
        backend.post('/api/survey/' + type + '/submit', {
            study_id: this.state.study.id,
            participant_uuid: this.state.userUUID,
            answers: answers.map(answer => {
                if (typeof answer == 'string') {
                    return answer;
                } else {
                    return JSON.stringify(answer);
                }
            })
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
                const lastRanCode = this.state.lastRanCode;
                if (lastRanCode.code == this.state.code && lastRanCode.function == task.answer.tests[0].run && lastRanCode.arguments == task.answer.tests[0].args) {
                    resolve(task.complete);
                } else {
                    this.setState({
                        loading: true,
                        lastRanCode: {
                            code: this.state.code,
                            function: task.answer.tests[0].run,
                            arguments: task.answer.tests[0].args
                        },
                        onExecutionComplete: (result) => {
                            console.log('callback', result);

                            result.timestamp = +new Date();
                            backend.post('/api/data/append', {
                                study_id: this.state.study.id,
                                participant_uuid: this.state.userUUID,
                                data_type: 'replay_data',
                                content: JSON.stringify(result)
                            });

                            if (result.output == task.answer.tests[0].output) {
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

    uploadReplayData(history) {
        console.log(history);
        if (history.events.length) {
            backend.post('/api/data/append', {
                study_id: this.state.study.id,
                participant_uuid: this.state.userUUID,
                data_type: "replay_data",
                content: JSON.stringify(history)
            });
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
                    className="study-task-list"
                    tasks={this.state.study.tasks}
                    runTest={this.runTest}
                    disableTesting={this.state.loading}
                />
                <div className="full-width editor-container">
                    <Editor
                        className="editor-on-page"
                        onCodeChange={this.onCodeChange}
                        uploadFrequency="10000"
                        uploadChunk={this.uploadReplayData}
                    />
                    <CodeRunner
                        className={(this.state.showConsole ? "" : "hidden ") + "editor-code-output"}
                        code={this.state.lastRanCode.code}
                        run={this.state.lastRanCode.function}
                        args={this.state.lastRanCode.arguments}
                        onExecutionComplete={this.state.onExecutionComplete}
                    />
                </div>
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
                    type="pre"
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
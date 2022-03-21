import QuestionnaireCreator from './QuestionnaireCreator';
import TaskCreator from './TaskCreator';

class StudyCreator extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            stage: 0,
            title: '',
            titleTooShort: false
        };

        this.nextStage = this.nextStage.bind(this);
        this.saveTitle = this.saveTitle.bind(this);
        this.onTitleChange = this.onTitleChange.bind(this);
        this.saveQuestions = this.saveQuestions.bind(this);
        this.saveTasks = this.saveTasks.bind(this);
        this.saveStudy = this.saveStudy.bind(this);
    }

    nextStage() {
        this.setState({ stage: this.state.stage + 1 });
        if (this.state.stage + 1 >= 4) {
            this.saveStudy();
        }
    }

    saveTitle() {
        if (this.state.title.length >= 4) {
            this.nextStage();
        } else {
            this.setState({ titleTooShort: true });
        }
    }

    onTitleChange(e) {
        this.setState({ title: e.target.value });
    }

    saveQuestions(questions, type) {
        if (type == 'background') {
            this.setState({
                backgroundQuestionnaire: questions,
            });
        } else {
            this.setState({
                postQuestionnaire: questions,
            });
        }
        this.nextStage();
        console.log(questions, type);
    }

    saveTasks(tasks) {
        console.log('got tasks', tasks);
        this.setState({
            tasks: tasks,
        });
        this.nextStage();
    }

    saveStudy() {
        console.log('saving study');
        backend.post('/api/study/create', {
            title: this.state.title,
            username: 'jacmol7'
        }).then(study => {
            console.log(study);
            backend.post('/api/survey/pre/create', {
                study_id: study.created_study,
                questions: this.state.backgroundQuestionnaire.map(q => { return JSON.stringify(q) })
            });
            backend.post('/api/survey/post/create', {
                study_id: study.created_study,
                questions: this.state.postQuestionnaire.map(q => { return JSON.stringify(q) })
            });

            backend.post('/api/task/create', {
                tasks: this.state.tasks.map(task => { return { study_id: study.created_study, content: task.detail } })
            }).then(createdTasks => {
                console.log(createdTasks);
                createdTasks.created_tasks.forEach((taskId, taskNum) => {
                    let taskToUpload = this.state.tasks[taskNum];
                    delete taskToUpload.detail;
                    backend.post('/api/answer/create', {
                        task_id: taskId,
                        content: JSON.stringify(taskToUpload)
                    })
                });
            })

            backend.post('/api/study/get', {
                study_id: study.created_study
            }).then(studyDetails => {
                console.log(studyDetails);
                this.setState({ completedDetails: studyDetails.study });
            })
        });
    }

    render() {
        const intro = (
            <div className="centered fit-content">
                <h1>Create a new study</h1>
                <p>A study is made up of three parts:</p>
                <div>
                    <h3>Background Questionnaire</h3>
                    <p>These questions will be the first thing shown to a participant when they start the study.</p>
                    <p>This is a good place to gather background information about a participant to help with analysing their answers later.</p>
                </div>
                <div>
                    <h3>Tasks</h3>
                    <p>These are the actual tasks a participant will be asked to complete.</p>
                    <p>Each task will have a short description and one or more tests to run against a participant's answers.</p>
                    <p>A test allows you to specify a function to run, the arguments to provide and the return value you expect.</p>
                </div>
                <div>
                    <h3>Post Questionnaire</h3>
                    <p>This questionnaire will be shown to the participant after they finish the study and submit their answers.</p>
                </div>
                <hr />
                <p>Enter a title for your study to get started:</p>
                {this.state.titleTooShort &&
                    <p>Title must be at least 4 characters</p>
                }
                <div className="spaced-out-row">
                    <span className={this.state.titleTooShort ? "invalid-input" : "valid-input"}>
                        <input type="text" onChange={this.onTitleChange} value={this.state.title} />
                    </span>
                    <button
                        className="button primary"
                        onClick={this.saveTitle}
                    >
                        Get Started
                    </button>
                </div>
            </div>
        );

        if (this.state.stage === 0) {
            return intro;
        } else if (this.state.stage == 1) {
            return <QuestionnaireCreator saveQuestions={this.saveQuestions} type="background" />
        } else if (this.state.stage == 2) {
            return <TaskCreator saveTasks={this.saveTasks} />
        } else if (this.state.stage == 3) {
            return <QuestionnaireCreator saveQuestions={this.saveQuestions} type="post" />
        } else {
            if (!this.state.completedDetails) {
                return (
                    <div>
                        Saving study...
                    </div>
                );
            } else {
                return (
                    <div>
                        <h2>Study: {this.state.completedDetails.title}</h2>
                        <h3>Join code: {this.state.completedDetails.participant_code}</h3>
                    </div>
                );
            }
        }
    }
}

export default StudyCreator;
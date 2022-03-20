import QuestionnaireCreator from './QuestionnaireCreator';
import TaskCreator from './TaskCreator';

class StudyCreator extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            stage: 0,
            title: ''
        };

        this.nextStage = this.nextStage.bind(this);
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
            <div>
                <h1>Create a new study</h1>
                <p>Explanation of how to create a study...</p>
                <input type="text" onChange={this.onTitleChange} value={this.state.title} />
                <button
                    className="button primary"
                    onClick={this.nextStage}
                >
                    Get Started
                </button>
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
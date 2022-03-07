import QuestionnaireCreator from './QuestionnaireCreator';
import TaskCreator from './TaskCreator';

class StudyCreator extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            stage: 0
        };

        this.nextStage = this.nextStage.bind(this);
        this.saveQuestions = this.saveQuestions.bind(this);
        this.saveTasks = this.saveTasks.bind(this);
    }

    nextStage() {
        this.setState({ stage: this.state.stage + 1 });
    }

    saveQuestions(questions, type) {
        if (type == 'background') {
            this.setState({
                backgroundQuestionnaire: questions,
                stage: this.state.stage + 1
            });
        } else {
            this.setState({
                postQuestionnaire: questions,
                stage: this.state.stage + 1
            });
        }
        console.log(questions, type);
    }

    saveTasks(tasks) {
        console.log('got tasks', tasks);
        this.setState({
            tasks: tasks,
            stage: this.state.stage + 1
        });
    }

    render() {
        const intro = (
            <div>
                <h1>Create a new study</h1>
                <p>Explanation of how to create a study...</p>
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
        } else {
            return <TaskCreator saveTasks={this.saveTasks} />
        }
    }
}

export default StudyCreator;
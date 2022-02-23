class QuestionnaireCreator extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            questions: []
        }

        this.addQuestion = this.addQuestion.bind(this);
        this.removeQuestion = this.removeQuestion.bind(this);
        this.onQuestionChange = this.onQuestionChange.bind(this);
        this.onQuestionTypeChange = this.onQuestionTypeChange.bind(this);
        this.addOption = this.addOption.bind(this);
        this.removeOption = this.removeOption.bind(this);
        this.onOptionChange = this.onOptionChange.bind(this);
        this.complete = this.complete.bind(this);
    }

    addQuestion() {
        let updatedQuestions = this.state.questions;
        this.state.questions.push({
            question: '',
            type: 'text',
            options: ['']
        })
        this.setState({ questions: updatedQuestions });
    }

    removeQuestion(i) {
        let updatedQuestions = this.state.questions;
        updatedQuestions.splice(i, 1);
        this.setState({ questions: updatedQuestions });
    }

    onQuestionChange(i, e) {
        let updatedQuestions = this.state.questions;
        updatedQuestions[i].question = e.target.value;
        this.setState({ questions: updatedQuestions });
    }

    onQuestionTypeChange(i, e) {
        let updatedQuestions = this.state.questions;
        updatedQuestions[i].type = e.target.value;
        this.setState({ questions: updatedQuestions });
    }

    addOption(i) {
        let updatedQuestions = this.state.questions;
        updatedQuestions[i].options.push('');
        this.setState({ questions: updatedQuestions });
    }

    removeOption(i, o) {
        let updatedQuestions = this.state.questions;
        updatedQuestions[i].options.splice(o, 1);
        if (updatedQuestions[i].options.length === 0) {
            updatedQuestions[i].options = [''];
        }
        this.setState({ questions: updatedQuestions });
    }

    onOptionChange(i, o, e) {
        let updatedQuestions = this.state.questions;
        updatedQuestions[i].options[o] = e.target.value;
        this.setState({ questions: updatedQuestions });
    }

    complete() {
        console.log(this.state.questions.map(q => {
            if (q.type == 'text') {
                delete q.options;
            }
            return q;
        }));
    }

    render() {
        return (
            <div>
                {
                    this.state.questions.map((q, i) => {
                        return (
                            <div key={i}>
                                <h3>Question {i + 1}</h3>
                                <input
                                    type="text"
                                    value={this.state.questions[i].question}
                                    onChange={(e) => { this.onQuestionChange(i, e); }}
                                />
                                <button
                                    className="button tertiary"
                                    onClick={() => { this.removeQuestion(i) }}>
                                    Remove
                                </button>
                                <select
                                    value={this.state.questions[i].type}
                                    onChange={(e) => { this.onQuestionTypeChange(i, e); }}
                                >
                                    <option value="text">text</option>
                                    <option value="dropdown">dropdown</option>
                                    <option value="checkbox">checkbox</option>
                                </select>
                                {this.state.questions[i].type != 'text' &&
                                    <button
                                        className="button primary"
                                        onClick={() => { this.addOption(i); }}>
                                        Add Option
                                    </button>
                                }
                                {this.state.questions[i].type != 'text' &&
                                    this.state.questions[i].options.map((o, oi) => {
                                        return (
                                            <div key={oi}>
                                                <input
                                                    type="text"
                                                    value={o}
                                                    onChange={(e) => { this.onOptionChange(i, oi, e) }} />
                                                <button
                                                    className="button tertiary"
                                                    onClick={() => { this.removeOption(i, oi); }}>
                                                    Remove Option
                                                </button>
                                            </div>
                                        );
                                    })
                                }
                            </div>
                        )
                    })
                }
                <button className="button secondary" onClick={this.addQuestion}>Add Question</button>
                <button className="button primary" onClick={this.complete}>Complete</button>
            </div>
        )
    }

}

export default QuestionnaireCreator;
import Question from './Question';

class Questionnaire extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            answers: []
        }

        this.onAnswerChange = this.onAnswerChange.bind(this);
        this.submit = this.submit.bind(this);
    }

    onAnswerChange(i, v) {
        let updatedAnswers = this.state.answers;
        updatedAnswers[i - 1] = v;
        this.setState({ answers: updatedAnswers });
    }

    submit() {
        this.props.onSubmit(this.props.type, this.state.answers);
    }

    render() {
        return (
            <div className="container primary centered">
                <h1 className="centered-text">Questionnaire</h1>
                {
                    this.props.questions.map((q, i) => {
                        return (
                            <Question
                                key={i}
                                question={q}
                                questionNum={i + 1}
                                onAnswerChange={this.onAnswerChange}
                            />
                        )
                    })
                }
                <button onClick={this.submit} className="button primary right" >Submit</button>
            </div>
        );
    }
}

export default Questionnaire;
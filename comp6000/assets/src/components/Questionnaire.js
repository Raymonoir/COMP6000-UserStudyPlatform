import Question from './Question';

class Questionnaire extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            answers: []
        }

        this.onAnswerChange = this.onAnswerChange.bind(this);
    }

    onAnswerChange(i, v) {
        let updatedAnswers = this.state.answers;
        updatedAnswers[i] = v;
        this.setState({ answers: updatedAnswers });
    }

    render() {
        return (
            <div>
                {
                    this.props.questions.map((q, i) => {
                        return (
                            <Question
                                key={i}
                                question={q}
                                questionNum={i}
                                onAnswerChange={this.onAnswerChange}
                            />
                        )
                    })
                }
            </div>
        );
    }
}

export default Questionnaire;
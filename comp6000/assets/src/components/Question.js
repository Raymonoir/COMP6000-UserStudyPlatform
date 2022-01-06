class Question extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            value: props.value ? props.value : props.question.type == 'checkbox' ? [] : ''
        }
        this.handleChange = this.handleChange.bind(this);
    }

    handleChange(e) {
        // Checkboxes are handled differently to deal with selecting multiple options
        if (this.props.question.type == 'checkbox') {
            let updatedValues = this.state.value;
            if (e.target.checked) {
                updatedValues.push(e.target.value);
            } else {
                updatedValues = updatedValues.filter(o => { return o != e.target.value; });
            }
            this.setState({ value: updatedValues });
            this.props.onAnswerChange(this.props.questionNum, updatedValues);
        } else {
            this.setState({ value: e.target.value });
            this.props.onAnswerChange(this.props.questionNum, e.target.value);
        }
    }

    render() {
        return (
            <div>
                <p>
                    <b>{this.props.questionNum}) </b>
                    {this.props.question.question}
                </p>

                {this.props.question.type == 'text' &&
                    <input type="text" value={this.state.value} onChange={this.handleChange}></input>}

                {this.props.question.type == 'dropdown' &&
                    <select onChange={this.handleChange}>
                        {this.props.question.options.map((o, i) => {
                            return <option key={i} value={o}>{o}</option>
                        })}
                    </select>}

                {this.props.question.type == 'checkbox' &&
                    <div>
                        {this.props.question.options.map((o, i) => {
                            return (
                                <label key={i}>
                                    {o}
                                    <input type="checkbox" value={o} onChange={this.handleChange} />
                                </label>
                            )
                        })}
                    </div>}
            </div>
        );
    }
}

export default Question;
class CodeRunner extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            loading: false
        }

        this.runCode = this.runCode.bind(this);
    }

    componentDidUpdate(prevProps) {
        if (this.props.code && this.props != prevProps) {
            this.runCode();
        }

    }

    componentDidMount() {
        if (this.props.code) {
            this.runCode();
        }
    }

    componentWillUnmount() {
        this.state.abortController.abort();
    }

    runCode() {
        const abort = new AbortController();

        const request = fetch('http://localhost:3000/run', {
            signal: abort.signal,
            method: 'POST',
            mode: 'cors',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ code: this.props.code, run: this.props.run, args: this.props.args })
        })
            .then(res => res.json())
            .then(data => {
                this.setState({
                    loading: false,
                    result: data
                });
            });

        this.setState({
            request: request,
            abortController: abort,
            loading: true
        });
    }

    render() {
        let result = <p data-cy="code-output">...</p>;
        if (this.state.result) {
            if (this.state.result.error) {
                if (this.state.result.error == 'timeout') {
                    result = <p className="code-output error" data-cy="code-output">Your code took too long to run</p>
                } else {
                    result = <p className="code-output error" data-cy="code-output">An error occured when attempting to run your code</p>
                }
            } else if (this.state.result.userCodeError) {
                result = <p className="code-output error" data-cy="code-output">error: {this.state.result.userCodeError}</p>
            } else {
                result = <p className="code-output" data-cy="code-output">output: {this.state.result.output}</p>
            }
        }

        return (
            <div className={"container primary " + this.props.className}>
                <div>
                    <h3>Console output</h3>
                    {this.state.result && this.state.result.logs &&
                        this.state.result.logs.map((line, i) => {
                            return (
                                <p key={i} className="console-line" data-cy="console-line">
                                    <span className={"console-line type " + line.type}>{line.type}: </span>
                                    {line.data.map((part, j) => {
                                        return <span key={j} className="console-line data">{part + " "}</span>
                                    })}
                                </p>
                            )
                        })
                    }
                    {!this.state.result &&
                        <p>...</p>}
                </div>
                <hr />
                <div>
                    <h3>Result</h3>
                    {result}
                </div>
            </div>
        );
    }
}

export default CodeRunner;
class CodeRunner extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            loading: false
        }

        this.runCode = this.runCode.bind(this);
    }

    componentDidUpdate(prevProps) {
        if (this.props.code && (this.props.code != prevProps.code || this.props.run != prevProps.run || this.props.args != prevProps.args)) {
            console.log('props updated');
            this.runCode();
        }

    }

    componentDidMount() {
        if (this.props.code) {
            this.runCode();
        }
    }

    componentWillUnmount() {
        if (this.state.abortController) {
            this.state.abortController.abort();
        }
    }

    runCode() {
        const abort = new AbortController();

        const request = fetch('http://' + window.location.hostname + ':3000/run', {
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

                // Send the result back to our parent.
                // This is used by StudyMananager to check if you have passed a task
                if (this.props.onExecutionComplete) {
                    this.props.onExecutionComplete(data);
                }
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

        let executedFunction;
        if (this.props.run) {
            executedFunction = (
                <div>
                    <h3>Ran</h3>
                    <p className="console-line">{this.props.run}(
                        {
                            this.props.args.map((arg, i) => {
                                return <span className="console-line" key={i}>{arg}{i < this.props.args.length - 1 ? ", " : ""}</span>
                            })
                        }
                        )
                    </p>
                </div>
            );
        }

        return (
            <div className={"container primary " + this.props.className}>
                <div>
                    {this.state.result && executedFunction}
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
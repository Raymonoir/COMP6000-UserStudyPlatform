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
        return (
            <div className={"container primary " + this.props.className}>
                <div>
                    <h3>Console output</h3>
                    {this.state.result &&
                        this.state.result.logs.map((line, i) => {
                            return (
                                <p key={i} className="console-line">
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
                    {this.state.result && !this.state.result.error &&
                        <p className="code-output">output: {this.state.result.output}</p>}

                    {this.state.result && this.state.result.error &&
                        <p className="code-output error">error: {this.state.result.error}</p>}

                    {!this.state.result &&
                        <p>...</p>}
                </div>
            </div>
        );
    }
}

export default CodeRunner;
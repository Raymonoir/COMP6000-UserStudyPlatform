class CodeRunner extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            ran: false
        }
    }

    componentDidMount() {
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
                console.log(data);
                this.setState({
                    ran: true,
                    result: data
                });
            });

        this.setState({
            request: request,
            abortController: abort
        });
    }

    componentWillUnmount() {
        this.state.abortController.abort();
    }

    render() {
        if (!this.state.ran) {
            return <div className="container primary">Loading...</div>
        }

        return (
            <div className="container primary">
                <div>
                    <h3>Console output</h3>
                    {
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
                </div>
                <hr />
                <div>
                    <h3>Result</h3>
                    {!this.state.result.error &&
                        <p className="code-output">output: {this.state.result.output}</p>}

                    {this.state.result.error &&
                        <p className="code-output error">error: {this.state.result.error}</p>}
                </div>
            </div>
        );
    }
}

export default CodeRunner;